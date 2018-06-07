%aeolis_params.m - Code to set up Aeolis parameter file for Windsurf coupler
    %Created By: N. Cohn, Oregon State University

%create filename
fid = fopen([project.Directory, filesep, 'aeolis', filesep, 'aeolis.txt'], 'w');

%implement grain size distribution from d10,d50,d90
%assume the following distribution to start - NEED TO UPDATE THIS IN
%FUTURE TO TRACK CHANGES IN GRAIN SIZE WITH TIME
sed_dist = [0.3 0.4 0.3];

%write variables to file
fprintf(fid, '%s\n', ['bed_file = z.txt']);
%fprintf(fid, '%s\n', ['bi = 0.050000']);
fprintf(fid, '%s\n', ['bi = 1']);
fprintf(fid, '%s\n', ['dt = ', num2str(project.Aeolis.timestep)]);
fprintf(fid, '%s\n', ['dx = ', num2str(grids.dx)]);
fprintf(fid, '%s\n', ['dy = 1.000000']);
fprintf(fid, '%s\n', ['grain_dist = 0.3 0.4 0.3']);
fprintf(fid, '%s\n', ['grain_size = ', num2str(sed.XB.D10), ' ', num2str(sed.XB.D50), ' ', num2str(sed.XB.D90)]);
%    if run_number>1 %add in the bed composition file if it is not the first simulation
%       fprintf(fid, '%s\n', ['bedcomp_file = bedcomp.txt'])
%    end    
%fprintf(fid, '%s\n', ['layer_thickness = 0.01000']);
fprintf(fid, '%s\n', ['nfractions = 3']);
fprintf(fid, '%s\n', ['nlayers = 5']);
fprintf(fid, '%s\n', ['nx = ', num2str(grids.nx-1)]);
fprintf(fid, '%s\n', ['ny = 0']);
fprintf(fid, '%s\n', ['output_file = aeolis.nc']);
fprintf(fid, '%s\n', ['output_times = ', num2str(project.timeStep)]);
fprintf(fid, '%s\n', ['output_types = avg']);
%fprintf(fid, '%s\n', ['output_vars = zb zs Ct Cu uw udir uth mass pickup w']);
fprintf(fid, '%s\n', ['output_vars = zb']);
fprintf(fid, '%s\n', ['scheme = euler_backward']);
fprintf(fid, '%s\n', ['tide_file = tide.txt']);
fprintf(fid, '%s\n', ['tstart = 0']);
fprintf(fid, '%s\n', ['tstop = ', num2str(project.timeStep)]);
%fprintf(fid, '%s\n', ['wind_file = wind.txt'])
fprintf(fid, '%s\n', ['xgrid_file = x_aeolis.txt']);
fprintf(fid, '%s\n', ['ygrid_file = y_aeolis.txt']);
%fprintf(fid, '%s\n', ['meteo_file = meteo.txt']);
%fprintf(fid, '%s\n', ['process_meteo = T']);
fprintf(fid, '%s\n', ['Cb = ', num2str(sed.Aeolis.Cb)]);
fprintf(fid, '%s\n', ['m = ', num2str(sed.Aeolis.m)]);
fprintf(fid, '%s\n', ['A = ', num2str(sed.Aeolis.A)]);

%DONT NEED THE FOLLOWING BECAUSE OF HOTSTART FUNCTION
%fprintf(fid, '%s\n', ['u_type = 2']) %this is new variable to read external files
%fprintf(fid, '%s\n', ['u_file = cdm_u_file.txt'])
%fprintf(fid, '%s\n', ['ux_file = cdm_ux_file.txt'])
%fprintf(fid, '%s\n', ['uy_file = cdm_uy_file.txt'])
%fprintf(fid, '%s\n', ['tau_file = cdm_tau_file.txt'])
%fprintf(fid, '%s\n', ['taux_file = cdm_taux_file.txt'])
%fprintf(fid, '%s\n', ['tauy_file = cdm_tauy_file.txt'])

fclose(fid); 
clear sed_dist
    