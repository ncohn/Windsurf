%Windsurf_Run_Batch.m - Code which allows to run multiple simulations at once via parfor loop
    %Created By: N. Cohn, Oregon State University
    
function XBCDM_Run_Batch(Directory)
    load([Directory, filesep, 'windsurf_setup.mat']);
    Windsurf_Run;
end
