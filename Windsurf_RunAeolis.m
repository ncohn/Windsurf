%Windsurf_RunAeolis.m - Code to run Aeolis within the Windsurf framework
    %Created By: N. Cohn, Oregon State University

%Windsurf_RunAeolis
if project.flag.Aeolis == 1 %only run if Aeolis is requested
    %move to right sub-model directory
    cd([project.Directory, filesep, 'aeolis']);
    
   %Input Parameter File
    if run_number == 1 || run_number == 2 %only need to do this if its the first simulation or second. second iteration adds the bed composition file
        aeolis_params
        dlmwrite('x_aeolis.txt', grids.XGrid-grids.XGrid(1), 'delimiter', ' '); %write aeolis x-grid
        dlmwrite('y_aeolis.txt', zeros(size(grids.XGrid)), 'delimiter', ' '); %write aeolis y-grid
    end
    
    if winds.windspeed(run_number) > winds.threshold  && abs(winds.winddir(run_number)) < 88%only run above wind threshold
        % Generate Environmental Parameters
        
        %until moisture and groundwater are implemented, assume that the
        %swash zone does not dry instantaneously, so give a 6 hour buffer
        %for drying
        iuse = [run_number-waves.Aeolis.swashDryTimeSteps]:run_number;
        iuse(iuse<1) = run_number;
        max_tide = nanmax(project.twl(iuse));
        
        fid = fopen('tide.txt', 'w');
        fprintf(fid, '%s\n', ['0 ', num2str(max_tide)]);
        fprintf(fid, '%s\n', [num2str(project.timeStep), ' ', num2str(max_tide)]);
        fclose(fid);
        clear iuse max_tide

        %Generate Morphology Input
         dlmwrite('z.txt', run.z(:), 'delimiter', ' ');   

        %Velocity and Shear Stress - store all outputs to standard netcdf file, assume shore normal winds if nan'd out
        wind_direction = winds.winddir(run_number);
        if isnan(wind_direction) == 1
            wind_direction = 0; 
        end

        if project.flag.CDM == 2 %flag says that CDM is run for wind model only and not morphology change
             shear = run.shear; %use the existing shear if already ran CDM
             maxshear = 5; %this is a high value to start, but should help model from blowing up
             shear(shear>maxshear) = maxshear; 
             shear(run.z < project.twl(run_number)) = 0;        
             shearx = shear.*cosd(wind_direction);
             sheary = shear.*sind(wind_direction);                
             run.shear = shear;
             run.shearx = shearx;
             run.sheary = sheary;
             dlmwrite('tau.hotstart', shear(1:end)', 'delimiter', ' ', 'precision', '%.6f');                
        else
            run.shear = zeros(size(run.z)); %else temporarily store as zeros, can add ability to output from Aeolis later
            run.shearx = zeros(size(run.z)); %else temporarily store as zeros, can add ability to output from Aeolis later
            run.sheary = zeros(size(run.z)); %else temporarily store as zeros, can add ability to output from Aeolis later
        end
           
        %set u to constant value for Aeolis simulations
        u = ones(size(run.z))*winds.windspeed(run_number);

        %set values that are zero slightly above zero
        smallval = 0.001;
        shear(shear == 0) = smallval;
        u(u == 0) = smallval;

        %eliminate any shear for water cells
        u(run.z < project.twl(run_number)) = smallval;

        %fix values for wind direction
        ux = u.*cosd(wind_direction);
        uy = u.*sind(wind_direction);

        %use hotstart files to initialize aeolis from CDM

        %for now just utilize the cross-shore component of wind to transport
        dlmwrite('uw.hotstart', ux(1:end)', 'delimiter', ' ', 'precision', '%.6f');
          
        %Clean up variables
        clear wind_direction u ux uy shear shearx sheary smallval maxshear

        %Run Model 
            if numel(project.Aeolis.AeolisExecutable) > 5 
                
                if isunix == 1
                    try %try up to 3 times because of bang-poll error on Centos7
                        system([project.Aeolis.AeolisExecutable, ' aeolis.txt > /dev/null']);
                    catch err
                        try 
                        pause(1);
                        system([project.Aeolis.AeolisExecutable, ' aeolis.txt > /dev/null']);                        
                        catch err
                         pause(1);
                         system([project.Aeolis.AeolisExecutable, ' aeolis.txt > /dev/null']);
                       end
                    end
                else %do a more standard command for non-unix systems which presumably dont see the bang-poll issue
                     system([project.Aeolis.AeolisExecutable, ' aeolis.txt']);                  
                end                   
            else %try the standard aeolis command if not model EXE declared
                system('aeolis aeolis.txt');
            end
            %pause(0.1)

        %Load/Save Outputs for Other Models        
        %store elevation and elevation changes
           try
            z = ncread('aeolis.nc', 'zb');
            if numel(z)>numel(grids.ZGrid)
                tempz = z(:, 1, end);
            else
                tempz = z;
            end
            run.wind_dz = tempz(:) - run.z(:);
            run.z = tempz;   
           catch err
               pause(3)
                       z = ncread('aeolis.nc', 'zb');
                    if numel(z)>numel(grids.ZGrid)
                        tempz = z(:, 1, end);
                    else
                        tempz = z(:);
                    end

                    size(tempz(:))
                    size(run.z(:))

                    run.wind_dz = tempz(:) - run.z(:);
                    run.z = tempz;         
           end

 
            %Delete output file in case of future model run crash
            delete('aeolis.nc');    
            
            %Clean up variables
            clear tempz z
    else
        run.wind_dz = zeros(size(run.z(:))); %this needs to be updated in the case that CDM is run to calculate aeolian transport      
    end   
end