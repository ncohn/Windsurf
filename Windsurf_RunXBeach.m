%Windsurf_RunXBeach.m - This code serves to run individual simulations of the XBeach to be used with the Windsurf set of codes for coupled model simulations
    %Created By: N. Cohn, Oregon State University

if project.flag.XB == 1 %only run XBeach if need to
        
        %Enter appropriate model directory
        cd([project.Directory, filesep, 'xbeach'])
        
        %Setup relevant input files and grids
        setup_xbeach_grids(project, waves, grids, run, run_number)         

        if abs(270-waves.D(run_number)) < 45 && waves.Hs(run_number) > 0.1 %dont run morph model if waves are too oblique or too small
            
            %Set up waves files
                setup_xbeach_hydro(run_number, waves, tides, winds, project, grids);

            %Note super efficient re-writing this file each iteration, but need to do in case morfac or stationary/instationary changes
                xb_params(project, grids, waves, flow, tides, winds, sed,  veg,  run_number);

            %Run XBeach
                if numel(project.XB.XBExecutable)>3 % this ensures that the variable is not empty
                    if isunix == 1
                        try %try the exe up to 3 times - there are issues on CENTOS7 that leads to a bang-poll error if EXE is run at the same time
                              system([project.XB.XBExecutable, ' > /dev/null']); 
                        catch err
                            try
                              pause(1);
                              system([project.XB.XBExecutable, ' > /dev/null']);                           
                            catch err
                              pause(1);
                              system([project.XB.XBExecutable, ' > /dev/null']);                            
                            end
                        end
                    else %hopefully dont have same bang-poll issues on other operating systems, will write out more data to screen without /dev/null command
                          system([project.XB.XBExecutable, ' > NUL 2>&1']);   
                    end
                else %if variable is empty then just try calling the system command, will throw an error if no xbeach executable in path otherwise
                    system('xbeach  > command_line_xbeach.txt');
                end
               % pause(0.1); %wait for system to catch up with writing files

            %Load Outputs
            [project, run] = load_xbeach_output(project, run, waves, grids, run_number);   
            
            %If there is an error in the output then re-run xbeach - happens sometimes on Centos7 (not sure why....)
            if numel(project.twl) < run_number 
                %first just try-reloading output, could be a time waiting issue
                 pause(1); %wait for system to catch up with writing files
                 [project, run] = load_xbeach_output(project, run, waves, grids, run_number);   
                  if numel(project.twl) < run_number %if its still an issue...
                          system([project.XB.XBExecutable, ' > command_line_xbeach.txt']); 
                          pause(10); %wait for system to catch up with writing files
                          [project, run] = load_xbeach_output(project, run, waves, grids, run_number);   
                  end
            end
            
            run.startz = dlmread('z.dep'); %probably orig z is loaded in somewhere in history, so this is a bit I/O intensive. But should be limited for 1D sims
            %run.init_z = grids.XZfinal(:,2); %probably orig z is loaded in somewhere in history, so this is a bit I/O intensive. But should be limited for 1D sims
            run.z(1:10) = run.startz(1:10);  %Correct offshore since there can be sediment accumulation at offshore extent of the model grid which can mess up long term simulations (though this does pose some mass balance issues...

            %Total Water Level Calc
            if waves.XB.useStockdon == 1 || isnan(project.twl(run_number)) == 1
                project.twl(run_number) = StockdonTWL(run_number, tides, waves, run, grids);
            end

            %Flag to say that clear xbeach was actually run - useful for debugging
            run.xbuse = 1; 
            
            %elevation change over simulation
            run.wave_dz = run.z(:)-run.startz(:);     

       else %if waves are too oblique, then dont run xbeach and just pass on relevant into to coupler
            project.twl(run_number) = tides.waterlevel(run_number); %here just assume the TWL is just the tides, since unclear what runup is under very steep angle waves - Stockdon likely not appropriate
            run.xbuse = 0; %flag to say xbeach was not run
            run.wave_dz = zeros(size(run.z(:)));
            run.Hmean = zeros(size(run.z(:)));            
        end
        
else %if the run_type is set to not run XBeach, then just pass on z info and TWL             
        project.twl(run_number) = StockdonTWL(run_number, tides, waves, run, grids);
        run.xbuse = 0;
        run.wave_dz = zeros(size(run.z(:)));
        run.Hmean = zeros(size(run.z(:)));
end
 
%want to make sure that this output is not re-used if simulation crashes
if project.XB.NetCDF == 0 && project.flag.XB == 1
    delete('zb.dat');
end

%clear all un-needed variables
clear iuse Z_OUT xbuse fid zs zs2 new_wave_angle new_wind_angle zb zb2 Hmean2 zsmax2


%SUB-FUNCTIONS
function setup_xbeach_hydro(run_number, waves, tides, winds, project, grids)

    %convention for the wave angles up to this point should have been that 0 is shore normal but for xbeach convention is that 270 is directed onshore
        wave_angle =  wrapTo360(waves.D(run_number));

   %This is the main code which sets up relevant input files at each time for xbeach and runs the simulations
    if wave_angle>(270-45) && wave_angle<(270+45) || run_number == 1 %only run simulation if waves are not super oblique
         %  if regimes.wave_type(run_number) == 1 %use instationary solver
                %set up JONSWAP wave file for XBeach
                outputSpectraFileName = ['spectra.spec'];
                fid = fopen(outputSpectraFileName, 'w');
                fprintf(fid,'%s\n',['Hm0= ', num2str(waves.Hs(run_number))]);
                if waves.Tp(run_number)>0 %need to check to make sure dont have infinite frequency
                    fprintf(fid,'%s\n',['fp= ', num2str(1/waves.Tp(run_number))]);
                else
                    fprintf(fid,'%s\n',['fp= 0']);                
                end
                fprintf(fid,'%s\n',['mainang= ', num2str(wave_angle)]);
                fclose(fid);
%            else  %set up stationary wave file for XBeach
%                 outputSpectraFileName = ['spectra.spec'];
%                 fid = fopen(outputSpectraFileName, 'w');
%                 fprintf(fid,'%s\n',['Hrms= ', num2str(waves.WaveRuns(run_number,5))]);
%                 fprintf(fid,'%s\n',['Trep= ', num2str(waves.WaveRuns(run_number,2))]);
%                 fprintf(fid,'%s\n',['dir0= ', num2str(wave_angle)]);
%                 fclose(fid);            
%            end

            %export new water level file for XBeach
                fid = fopen('waterlevel.inp', 'w');
                fprintf(fid, '%s\n', ['0 ', num2str(tides.waterlevel(run_number))]);
                fprintf(fid, '%s\n', [num2str(project.timeStep+project.XB.hydro_spinup), ' ', num2str(tides.waterlevel(run_number))]);
                fclose(fid);

            %export new wind file for XBeach - currently does this whether or not wind is actually used in XB
                new_wind_angle = wrapTo360(winds.winddir(run_number)+270);
                fid = fopen('winds.inp', 'w');
                fprintf(fid, '%s\n', ['0 ', num2str(winds.windspeed(run_number)), ' ', num2str(new_wind_angle)]);
                fprintf(fid, '%s\n', [num2str(project.timeStep+project.XB.hydro_spinup), ' ', num2str(winds.windspeed(run_number)), ' ', num2str(new_wind_angle)]);
                fclose(fid);
       end
   
end

function TWL = StockdonTWL(run_number, tides, waves, run, grids)
      
    %Geometry of high and low tide
        low_tide = prctile(tides.waterlevel, 10);  %first approximation at high/low tide
        high_tide = prctile(tides.waterlevel, 90);
        xlow = linterp(run.z(:), grids.XGrid(:), low_tide);
        xhigh = linterp(run.z(:), grids.XGrid(:), high_tide);
        Bf = abs(high_tide-low_tide)/abs(xhigh-xlow);

    %Calculate wave parameters and runup
        Lo = 9.81*waves.Tp(run_number)*waves.Tp(run_number)/(2*pi);
        Ho = waves.Hs(run_number);
        R2 = 1.1*(0.35*Bf*sqrt(Ho*Lo)+sqrt(Ho*Lo*(0.563*Bf*Bf+0.004))/2);
        TWL = tides.waterlevel(run_number)+R2;

end

function [project, run] = load_xbeach_output(project, run, waves, grids,run_number)
    %Setup variables
    loop = 1;
    count = 0;

    %Loop through repeatedly in case output does not load on first try, can be
    %due to slow writing of data from XB
    while loop == 1
        try
            %Load in morphology    
                if project.XB.NetCDF ==1
                     zb = ncread('xboutput.nc', 'zb');
                     zb = zb(:); %convert to column vector            
                     if numel(zb)> grids.nx
                        zb = zb(end-grids.nx+1:end);
                     end
                else %if its a fortran file - dont know why but sometimes there are issues with fortran versions...
                    clear zb2
                    xbdata = xb_read_dat('zb.dat');
                    zb2(:,:) = xbdata.data(2).value(:,1,:);
                    zb = zb2'; %for some reason size conventions for fortran and netcdf are opposite?
                    zb = zb(end-grids.nx+1:end);
                end
                run.z = zb(:); 

            %Load in waves
                if project.XB.NetCDF ==1
                    Hmean = ncread('xboutput.nc', 'H_mean');                    
                    Hmean = Hmean(:); %convert to column vector
                    if numel(Hmean)> grids.nx
                        Hmean = Hmean(end-grids.nx+1:end);
                     end
                else
                    try
                        clear Hmean2
                        xbdata = xb_read_dat('H_mean.dat');
                        Hmean(:,:) = xbdata.data(2).value(:,1,:);
                        Hmean = Hmean';
                    catch err
                       Hmean = zeros(size(zb2));
                    end
                end
                run.Hmean = Hmean(:);

            %Load in water level
                if project.XB.NetCDF ==1
                    zsmax = ncread('xboutput.nc', 'zs_max');                  
                    zsmax = zsmax(:); %convert to column vector
                     if numel(zsmax)> grids.nx
                         zsmax2 = zsmax(end-grids.nx+1:end);
                     else
                         zsmax2 = zsmax;
                     end
                else
                    xbdata = xb_read_dat('zs_max.dat');
                    try
                        zsmax(:,:) = xbdata.data(2).value(:,1,:);
                        zsmax2 = zsmax';
                        zsmax2 = zsmax2(end-grids.nx+1:end);
                    catch err
                        clear zsmax2
                        zsmax2 = ones(size(zb2)).*tides.waterlevel(run_number);
                    end
                end
                
               % size(zsmax2)
                zsmax2(zsmax2>999) = NaN; %sometimes has high output for last time step, so get rid of that
                ibad = find([zsmax2(:)-run.z(:)]< waves.XB.eps);
                zsmax2(ibad) = NaN;
                project.twl(run_number) = nanmax(zsmax2);
                if isnan(project.twl(run_number)) == 1
                   project.twl(run_number) = tides.waterlevel(run_number);
                end
                run.zsmax = zsmax2(:);
                
                
          %Use Runup Gauge Instead
          if project.XB.NetCDF ==1
                    zstemp = ncread('xboutput.nc', 'point_zs');                  
                    zstemp(zstemp>999) = NaN;
                    project.twl(run_number) = nanmax(zstemp);
                    
                    if project.twl(run_number) == max(run.z) %dont use if matches dune crest elevation exactly for some reason, sometimes there are output issues
                        project.twl(run_number) = tides.waterlevel(run_number);
                    end
          end
            
        %keyname to end the while loop            
        loop = 0; 
        catch err
            count = count+1;
            pause(0.5);
            if count > 10
                loop = 0; %get out of the loop if have tried too many times
            end
        end
    end
              
end

function setup_xbeach_grids(project, waves, grids, run, run_number)

        if run_number == 1
          %write out files
          dlmwrite('x.grd', grids.XGrid(:), 'delimiter', ' ', 'precision', '%10.4f');    
          dlmwrite('y.grd', zeros(size(grids.XGrid(:))), 'delimiter', ' ', 'precision', '%10.4f');           
        end
        
        dlmwrite('z.dep', run.z(:), 'delimiter', ' ', 'precision', '%6.20f');    
   
        if run_number == 1 %not really a grid, but this needs to be written on first XBeach run, so better here than in the setup_hydro in case first run has too steep of a wave angle
           %set up a wave spectrum file. this never needs to get replaced but the spectra.spec file is changes each time
           fid = fopen([project.Directory, filesep, 'xbeach', filesep, 'specfilelist.txt'], 'w');
           fprintf(fid, '%s\n', ['FILELIST']);
           fprintf(fid, '%s\n', [num2str(project.timeStep+project.XB.hydro_spinup),' ', num2str(waves.XB.dtbc),' spectra.spec']);
           fprintf(fid, '%s\n', [num2str(project.timeStep+project.XB.hydro_spinup),' ', num2str(waves.XB.dtbc),' spectra.spec']);
           fclose(fid);   
        end     
end