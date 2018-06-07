%Windsurf_RunCDM.m - This code serves to run individual simulations of the Coastal Dune Model for Windsurf
    %Created By: N. Cohn, Oregon State University
        
if [run_number == 1 && project.flag.CDM > 0] || [run_number == startingSim && project.flag.CDM > 0]
        cd([project.Directory, filesep, 'cdm'])
        
        %set up model grids
        grids.CDM.CDM_YGrid = [0:grids.dx:grids.dx*3];
        grids.CDM.XD = repmat(grids.XGrid(:)', numel(grids.CDM.CDM_YGrid), 1);
        grids.CDM.YD = repmat(zeros(size(grids.XGrid(:)')), numel(grids.CDM.CDM_YGrid), 1); %this is all zeros, but is never used so shouldnt matter
        grids.CDM.ZD = repmat(grids.ZGrid(:)', numel(grids.CDM.CDM_YGrid), 1);    
         
        %set up the vegetation grid
        [~, i_zmin] = min(abs(run.z-veg.CDM.elevMin)); %find location corresponding to veg.zmin
        veg.CDM.xmin = i_zmin * grids.dx; %this should be valid as long as size of grid is contant (e.g., dont update grid size based on TWL condition)
        if project.flag.VegCode == 0
                iuse = find(grids.CDM.ZD>=veg.CDM.elevMin & grids.CDM.ZD<=veg.CDM.elevMax);
                veg.CDM.vegmatrix = zeros(size(grids.CDM.ZD));
                veg.CDM.vegmatrix(iuse) = veg.CDM.startingDensity; %starting vegetation density - ultimately this probably shouldnt be hard coded 
                dlmwrite('init_vx.dat', veg.CDM.vegmatrix', 'delimiter', ' ');   
                dlmwrite('init_vy.dat', zeros(size(veg.CDM.vegmatrix')), 'delimiter', ' ');   
                run.veget = veg.CDM.vegmatrix(round(grids.ny/2), :);
        end
        
        %set up the shear velocity
        winds.windshear = (winds.CDM.vonKarman/log(winds.CDM.z/winds.CDM.z0))*winds.windspeed(:);
        winds.windshear(find(isnan(winds.windshear) == 1)) = 0;

        %eliminate very oblique winds
        winds.windfrac = ones(size(winds.winddir));
        ibad = find(winds.winddir<-88 | winds.winddir>88);%find things that have some x-shore component
        winds.windfrac(ibad) = 0;
        winds.winddir(ibad) = 0;
        winds.windshear = winds.windshear(:).*winds.windfrac(:); %turn windshear to zero when has no x-shore component
        
        %clean up variables
        clear ibad iuse i_zmin     
end

if project.flag.CDM > 0 && winds.windspeed(run_number) > winds.threshold && abs(winds.winddir(run_number)) < 88 %dont need to do anything if this is an XBeach only simulation
     %move to right sub-model directory   
     cd([project.Directory, filesep, 'cdm'])

    %If for some reason get NaN for TWL then make it zero (need to assume that 0 is MSL for that to be reasonable water level on average)
     if isnan(project.twl(run_number)) == 1
         project.twl(run_number) = 0;
     end
     
    %Run model for above water areas only
    run.iuse = find(X == min(grids.XGrid)); %this is not typically used in current Windsurf implemenetation, but can be applicable if CDM grid is not identical to XB grid

    %Set up CDM morphology - only initialize morphology for zones that are above water
    itemp = find(run.z<= project.twl(run_number)); %find areas below TWL
    itemp = 1:max(itemp);
    tempz = run.z;
    tempz(1:max(itemp)) = project.twl(run_number); %make elevations below TWL, the TWL elevation for influencing the wind field
    ZNEW= tempz-project.twl(run_number); %make all elevations relative to the TWL elevation temporarily
    ZNEW = ZNEW(:)'; %make sure row vector
    ZDNEW = repmat(ZNEW, numel(grids.CDM.CDM_YGrid), 1); %make right dimension     
    dlmwrite('init_h.dat', ZDNEW', ' ');
   
    %Save data temporarily back to main set of files
    run.z_cdm = ZDNEW'; %load input morphology file
 
    %Make a Non-Erodible Surface that corresponds to anything below water since CDM is an aeolian model
    nonerode = ZDNEW;
    for ii = 1:grids.ny
        nonerode((max(itemp)+1):(end-grids.CDM.fixboundary_numcells), ii) = 0; %this makes the beach up to ten grid points before the end erodible, everything else is non-erodible
    end
    
    %Save out non-erodible surface file
    if project.flag.Aeolis ~=1 
        dlmwrite([project.Directory, filesep, 'cdm', filesep, 'init_h_nonerod.dat'], nonerode', 'delimiter', ' ');
    else %if running an aeolis simulation then just run winds, dont have morphological evolution by turning all bed to non-erodible surface
        dlmwrite([project.Directory, filesep, 'cdm', filesep, 'init_h_nonerod.dat'], ZDNEW', 'delimiter', ' ');
    end
    clear nonerode ii   
    delete([project.Directory, filesep, 'cdm', filesep, 'CDM_temp', filesep, '*.dat']) %delete all old output files    
    
    %Setup parameter file
    cdm_params(project, grids, veg, sed, run_number, winds); %set up parameter file for model
        
    %Run simulation and load outputs
    output = cdm_run(project, run_number); %run model through matlab and temporarily store output
      
    %save/exchange relevant info - dependent on run type
      if project.flag.Aeolis ~= 1          
          tempz = mean(output.h(:, 2:3), 2); %set to mean of middle grid cells, assumes that this is a 4 cell CDM implementation. Need to change for 2D cases
          iuse = [max(itemp)+1]:[numel(run.z)-grids.CDM.fixboundary_numcells];
          run.wind_dz = zeros(size(run.z));
          run.z = run.z(:);
          tempz = tempz(:);
          
          %correct back to right reference frame
          tempz = tempz+project.twl(run_number);
          tempz(1:max(itemp)) = run.z(1:max(itemp));
          
          run.wind_dz(iuse) = tempz(iuse) - run.z(iuse);
          run.z(iuse) = tempz(iuse);
      end
          
    %save CDM values for NetCDF file - Note that fill in zeros for where CDM grid was not run (e.g., seaward of water line)
    ycells2use = 2:3; %assumed ny = 4 for this which could change into the future for fully 2D simulations
    if project.flag.VegCode ~= 1 %only update vegetation if calculated internally within CDM
        run.veget = zeros(size(grids.XGrid)); %dont use CDM output for now
        run.veget((run.iuse+(max(itemp))):end) = mean(output.veget_x((max(itemp)+1):end, ycells2use), 2);
    end
    run.u = zeros(size(grids.XGrid));
    run.u((run.iuse+(max(itemp))):end) = mean(output.u_x((max(itemp)+1):end, ycells2use), 2);        
    run.shear = zeros(size(grids.XGrid));
    run.shear((run.iuse+(max(itemp))):end) = mean(output.shear_x((max(itemp)+1):end, ycells2use), 2);   
    run.shear_pertx = zeros(size(grids.XGrid));
    run.shear_pertx((run.iuse+(max(itemp))):end) = mean(output.shear_pert_x((max(itemp)+1):end, ycells2use), 2);  
    run.h_sep = zeros(size(grids.XGrid));
    run.h_sep((run.iuse+(max(itemp))):end) = mean(output.h_sep((max(itemp)+1):end, ycells2use), 2);  
    run.stall = zeros(size(grids.XGrid));
    run.stall((run.iuse+(max(itemp))):end) = mean(output.stall((max(itemp)+1):end, ycells2use), 2);          
    run.startvalue = run.iuse+(max(itemp));
    run.itemp = itemp;
    run.output = output;
    
    %Correct for the fact that CDM output does not represent the "final" shear velocity  
    run.shear = winds.windshear(run_number); %start with the input shear velocity
    total_tau = run.shear(:)+abs(run.shear(:)).*run.shear_pertx(:);
    
    %The variable that relates to seperation bubble seems to be "stall"
    %(h_sep) usually just equals h - DOES NOT SEEM TO FULLY WORK, COMMENTED OUT FOR NOW
    total_tau(run.stall<0) = 0; %set shear to zero where there is stall
      
    %Correct shear for vegetation
    if veg.CDM.shearType == 1 %this is the standard routine
        vegetgamma = veg.CDM.m*veg.CDM.beta/veg.CDM.sigma;
        total_tau = total_tau(:)./(1+vegetgamma.*run.veget(:));
    else % can add in the Okin model or others if want
        total_tau = total_tau(:).*(1-run.veget(:)); %linear reduction that will get rid of shear where there is 100% veg cover
    end
        
    %Fix issues near edge of grid
    total_tau(end-grids.CDM.fixboundary_numcells:end) = 0; 
    
    %Now pass the total shear
    run.shear = total_tau;
    
    clear ZDNEW tempz znew itemp total_tau vegetgamma tempz i_zmin ycells2use ZNEW itemp output
else %still need to create wind output if CDM was not run   
    run.shear = ones(size(run.z)).*winds.windshear(run_number);   
end