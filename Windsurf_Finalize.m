%Windsurf_Finalize.m - Code to finalize  Windsurf coupler
    %Created By: N. Cohn, Oregon State University
    
%Finalize and lingering tasks not handled by other codes
cd(project.Directory);
ncwrite([project.Directory, filesep, 'windsurf.nc'], 'total_water_level', project.twl(1:project.numSims));
save windsurf_final.mat