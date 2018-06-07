function Windsurf_Run_Batch_Parfor(run_directory, num_runs, num_cores)

    p = parpool(num_cores);
    p.IdleTimeout = 120;
    
    parfor ii = 1:num_runs
        Directory = [run_directory, filesep, 'run', num2str(ii)]; 
        Windsurf_Run_Batch(Directory);
    end

    delete(gcp('nocreate'))
    
end