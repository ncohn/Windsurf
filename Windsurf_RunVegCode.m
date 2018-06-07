%Windsurf_RunVegCode.m - Code to implement vegetation routine originally from CDM but from outside of the C++ model
    %THIS CODE IS STILL A WORK IN PROGRESS!
    %Written by N. Cohn

if project.flag.VegCode == 1
            
    %set up vegetation and calculate temporal vegetation growth
    if run_number == 1
            %set up model grids
            grids.CDM.CDM_YGrid = [0:grids.dx:grids.dx*3];
            grids.CDM.XD = repmat(grids.XGrid(:)', numel(grids.CDM.CDM_YGrid), 1);
            grids.CDM.YD = repmat(zeros(size(grids.XGrid(:)')), numel(grids.CDM.CDM_YGrid), 1); %this is all zeros, but is never used so shouldnt matter
            grids.CDM.ZD = repmat(grids.ZGrid(:)', numel(grids.CDM.CDM_YGrid), 1);    
            iuse = find(grids.CDM.ZD>=veg.CDM.elevMin & grids.CDM.ZD<=veg.CDM.elevMax);
            veg.CDM.vegmatrix = zeros(size(grids.CDM.ZD));
            veg.CDM.vegmatrix(iuse) = veg.CDM.startingDensity; %starting vegetation density - ultimately this probably shouldnt be hard coded 
            dlmwrite([project.Directory, filesep, 'cdm', filesep, 'init_vx.dat'], veg.CDM.vegmatrix', 'delimiter', ' ');   
            dlmwrite([project.Directory, filesep, 'cdm', filesep, 'init_vy.dat'], zeros(size(veg.CDM.vegmatrix')), 'delimiter', ' ');   
            run.veget = veg.CDM.vegmatrix(round(grids.ny/2), :);

    else %perform vegetation growth
        try
            dhdt = run.wind_dz(:)';
        catch err
            dhdt = zeros(size(run.z(:)'));
        end
        
            %re-calculate where vegetation is allowed to grow at each time step
            [~, iveg] = min(abs(run.z-veg.CDM.elevMin));
            xmin = iveg;
            
            %run 1d veg model
            run.veget = cdm_veg_routine_1d(project, veg, grids, run.veget, dhdt, xmin);
    end
    
    %eliminate vegetation if it was knocked out by waves & water levels
    if project.flag.XB == 1 && run_number>1 %need to update the vegetation grid if there was erosion from XBeach
         
        %assume erosion eliminates the vegetation and requires it to regrow
         ierode = find(run.wave_dz < veg.erosion_threshold & run.veget > 0);
         run.veget(ierode) = 0; %set vegetation back to zero density if vertical rates of erosion sufficient
         
         %assume that if too much accretion happens that the vegetation is
         %covered and also needs to start re-growing to induce wind+sed
         %transport
         iacc = find(run.wave_dz > veg.accretion_threshold & run.veget > 0);
         run.veget(iacc) = 0; %set vegetation back to zero density if vertical rates of erosion sufficient
         
         %if the water level has been above the vegetation for more than the threshold than assume it has died - this really eliminates the need for a Lveg condition
         iflood = find((run.z - project.twl(run_number)+veg.flood_threshold)<0);
         run.veget(iflood) = 0; %set vegetation back to zero density if vertical rates of erosion sufficient
    end  
    
    
    clear dhdt ierode iflood flood_threshold erosion_threshold iveg iuse iacc accretion_threshold
end