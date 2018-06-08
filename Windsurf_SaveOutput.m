%Windsurf_SaveOutput.m - Code to save output to netcdf file at end of a set of simulations
       %Created By: N. Cohn, Oregon State University

%Write to Master NetCDF
    ncwrite([project.Directory, filesep, 'windsurf.nc'], 'zb', run.z(:)', [run_number+1 1]);
    
    try %if its an xbeach only run then wont have this data    
        ncwrite([project.Directory, filesep, 'windsurf.nc'], 'dz_wind', run.wind_dz(:)', [run_number+1 1]);
        ncwrite([project.Directory, filesep, 'windsurf.nc'], 'veget', run.veget(:)', [run_number+1 1]);
    catch err
    end
    
    if project.flag.XB>0
        try %only xbeach simulations should have this        
            ncwrite([project.Directory, filesep, 'windsurf.nc'], 'dz_wave', run.wave_dz(:)', [run_number+1 1]);
        catch err
        end
    end
    
%For debugging temporarily store the run variable for can see what is happening    
    save([project.Directory, filesep, 'windsurf_running.mat'], 'run', 'project', 'run_number');
    
%clean up variables
    temprun.z = run.z; %only maintain the z and vegetation variables
    temprun.veget = run.veget;
    clearvars -global run %tried to eliminate global variables, so this may not do anything anymore
    run = temprun;
    clear temprun ans err fid
    
%Write to Command Line What Run is Done    
    display(['Finished Simulation ', num2str(run_number) ' of ', num2str(project.numSims)]);
    
%Allow matlab to catch up with writing files before moving to next model sims   
    pause(0.1)
    