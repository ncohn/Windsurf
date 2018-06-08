%Windsurf_Initialize_Coupler.m - Code to initialize Windsurf coupler
    %Created By: N. Cohn, Oregon State University

%Initialize model tasks
if exist('startingSim') == 0
    startingSim = 1;
end

%Initiative NetCDF Output File and Relevant Inputs Only if not a HotStart
if startingSim == 1 %if code crashes part way through simulation this allows restarting not at beginning
    %delete any pre-existing output if restarting simulation  
    delete([project.Directory, filesep, 'windsurf.nc']); 
    
    %Create subfolders
    mkdir([project.Directory, filesep, 'xbeach'])
    mkdir([project.Directory, filesep, 'cdm'])
    mkdir([project.Directory, filesep, 'aeolis'])    
    mkdir([project.Directory, filesep, 'cdm', filesep, 'CDM_temp'])
    
   %Read Input Files to Determine Exact XY Variables (tho should be same as in "grids" variable)
   X = grids.XGrid(:);
   Y = zeros(size(X));
   Z = grids.ZGrid(:);
   run.z = Z(:);
   
   %Ensure grid dimensions are correct
   grids.nx = numel(grids.XGrid);
   grids.ny = 4; %hardcoded for now - relevant for CDM grid only
   grids.dx = abs(grids.XGrid(end)-grids.XGrid(end-1));
   
   %set up times
   project.numSims = numel(winds.windspeed);
   project.Times_days = 0:project.timeStep/(60*60*24):(project.numSims-1)*project.timeStep/(60*60*24);

   %Set Up Variables for output files
   nccreate([project.Directory, filesep, 'windsurf.nc'], 'zb', 'Dimensions', {'r' numel(project.Times_days)+1 'c' numel(X)});
   nccreate([project.Directory, filesep, 'windsurf.nc'], 'veget', 'Dimensions', {'r' numel(project.Times_days)+1 'c' numel(X)});
   nccreate([project.Directory, filesep, 'windsurf.nc'], 'x', 'Dimensions', {'c' numel(X)});
   nccreate([project.Directory, filesep, 'windsurf.nc'], 'y', 'Dimensions', {'c' numel(X)});
   nccreate([project.Directory, filesep, 'windsurf.nc'], 'times', 'Dimensions', {'r' numel(project.Times_days)+1});
   nccreate([project.Directory, filesep, 'windsurf.nc'], 'dz_wave', 'Dimensions', {'r' numel(project.Times_days)+1 'c' numel(X)});
   nccreate([project.Directory, filesep, 'windsurf.nc'], 'dz_wind', 'Dimensions', {'r' numel(project.Times_days)+1 'c' numel(X)});
   nccreate([project.Directory, filesep, 'windsurf.nc'], 'total_water_level', 'Dimensions', {'r' numel(project.Times_days)+1});
  
   %write out the pre-time step to the model - this is so that the initial Z value is appropriately recorded (e.g., not after 1 time step) 
   ncwrite([project.Directory, filesep, 'windsurf.nc'], 'zb', Z(:)', [1 1]);
   ncwrite([project.Directory, filesep, 'windsurf.nc'], 'dz_wind', zeros(size(Z')), [1 1]);
   ncwrite([project.Directory, filesep, 'windsurf.nc'], 'veget', zeros(size(Z')), [1 1]);
   ncwrite([project.Directory, filesep, 'windsurf.nc'], 'dz_wave', zeros(size(Z')), [1 1]);
    
   %Write Non-Changing Variables to NetCDF
   ncwrite([project.Directory, filesep, 'windsurf.nc'], 'x', X);
   ncwrite([project.Directory, filesep, 'windsurf.nc'], 'y', Y);
   ncwrite([project.Directory, filesep, 'windsurf.nc'], 'times', [project.Times_days project.Times_days(end)+(project.Times_days(2)-project.Times_days(1))]);

else
    
   display(['Starting at Simulation ', num2str(startingSim)]) 
   
end
    