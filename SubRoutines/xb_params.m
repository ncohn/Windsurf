%xb_params.m - This code ssets up XBeach params file for Windsurf
    %Created By: N. Cohn, Oregon State University

function xb_params(project, grid, waves, flow, tides, winds, sed, veg, run_number)

    %open filename
    fid = fopen(['params.txt'], 'w');
    fprintf(fid, '%s\n', 'left = 0');
    fprintf(fid, '%s\n', 'right = 0');
    
    %determine if 1D or 2D grid
    if  waves.XB.nonhydrostatic ~= 1
        fprintf(fid, '%s\n', 'back = abs_1d');   
        fprintf(fid, '%s\n', 'front = abs_1d');        
    end
    
    %NECESSARY VARIABLES
    %Model Setup
        fprintf(fid, '%s\n', 'depfile = z.dep');
        fprintf(fid, '%s\n', 'xfile = x.grd');
        fprintf(fid, '%s\n', 'yfile = y.grd');
        fprintf(fid, '%s\n', ['nx = ', num2str(grid.nx-1)]);
        fprintf(fid, '%s\n', ['ny = 0']);
        fprintf(fid, '%s\n', 'vardx = 1');
        fprintf(fid, '%s\n', 'posdwn = -1');

    %Waves/Flow
        fprintf(fid, '%s\n', 'lwave = 1');
        fprintf(fid, '%s\n', ['dtheta = ', num2str(waves.XB.dtheta)]);   
        fprintf(fid, '%s\n', ['thetamin = ', num2str(waves.XB.thetamin)]);
        fprintf(fid, '%s\n', ['thetamax = ', num2str(waves.XB.thetamax)]);
        fprintf(fid, '%s\n', ['random = ', num2str(waves.XB.random)]);      
        fprintf(fid, '%s\n', ['eps = ', num2str(waves.XB.eps)]); %threshold depth for drying and flooding        
        if waves.XB.dtheta < 359
            fprintf(fid, '%s\n', 'single_dir = 1'); %try new key name for single wave direction
        end
        fprintf(fid, '%s\n', ['fw = ',num2str(waves.XB.fw)]);
%        if regimes.wave_type(run_number) == 1 %instationary wave solver (jonswap)
            fprintf(fid, '%s\n', ['instat = 4']); 
            fprintf(fid, '%s\n', ['bcfile = specfilelist.txt']);
%         elseif regimes.wave_type(run_number) == 5 %external spectral input
%             fprintf(fid, '%s\n', ['instat = swan']);
%             xb_external_wave_spectrum(waves.XB.spectraFilename, project.startTime+project.Times_days(run_number))
%             fprintf(fid, '%s\n', ['dthetaS_XB = ', num2str(waves.XB.dthetaS_XB)]); %have to do this because SWAN was assumed cartesian and xbeach expects nautical convention, not sure this should always be zero - should recheck?
%             fprintf(fid, '%s\n', ['bcfile = specfilelist.txt']);
%         elseif waves.XB.nonhydrostatic ~= 1 %if stationary wave case
%            % fprintf(fid, '%WaveRs\n', ['wbctype = stat']);
%             fprintf(fid, '%s\n', ['instat = 0']);        
%             fprintf(fid, '%s\n', ['bcfile = specfilelist.txt']); 
%         end   
        if waves.XB.nonhydrostatic == 1 %add the non-hydrostatic correction if needed. should only not do if running stationary waves
           fprintf(fid, '%s\n', ['nonh = 1']);
        end
        if sed.XB.lws == 1 || waves.XB.nonhydrostatic == 1
            fprintf(fid, '%s\n', ['lws = 1']); 
        else
            fprintf(fid, '%s\n', 'lws =0');
        end   
        if sed.XB.lwt == 1 || waves.XB.nonhydrostatic == 1
            fprintf(fid, '%s\n', ['lwt = 1']); 
        else
            fprintf(fid, '%s\n', 'lwt =0');
        end    
    
    %Sediment and Morphology
        fprintf(fid, '%s\n', ['sedcal = ', num2str(sed.XB.sedcal)]);      
        fprintf(fid, '%s\n', ['morphology = ', num2str(sed.XB.morphology)]);
        if sed.XB.morphology == 1
            fprintf(fid, '%s\n', ['morstart = ', num2str(project.XB.hydro_spinup)]); 
            fprintf(fid, '%s\n', 'sedtrans = 1');
        else
            fprintf(fid, '%s\n', 'sedtrans = 0'); %dont bother with sed transport calcs if dont need them
        end
        fprintf(fid, '%s\n', ['morfac = ', num2str(sed.XB.morfac)]);
        %fprintf(fid, '%s\n', ['morfacopt = ' num2str(sed.XB.morfacopt)]);
        fprintf(fid, '%s\n', ['morfacopt = 1']);

        if waves.XB.nonhydrostatic == 1 %nonhydrostatic automatically accounts for assymmetry and skewness, so dont need to include variables
            %if running a version of xbeach that has nielsen-bagnold formula
            %included can run the following - only use if using the wave
            %resolving form of the model
            if sed.XB.form == 3 %add these additional values for now, other default values chosen by model are probably OK
                 fprintf(fid, '%s\n', ['form = nielsen_bagnold']); %this is a custom version of sed transport equations that is not in all versions of XBeach
                 fprintf(fid, '%s\n', ['fricAd = 1']); 
                 fprintf(fid, '%s\n', ['fric89 = 1']); 
                % fprintf(fid, '%s\n', ['turbadv = 1']); 
                 fprintf(fid, '%s\n', ['Tm0=', num2str(waves.Tp(run_number))]); 
            elseif sed.XB.form == 1
               fprintf(fid, '%s\n', ['form = soulsby_vanrijn']);
            else
               fprintf(fid, '%s\n', ['form = vanthiel_vanrijn']);     
            end

        else
            fprintf(fid, '%s\n', ['facAs = ', num2str(sed.XB.facAs)]); 
            fprintf(fid, '%s\n', ['facSk = ', num2str(sed.XB.facSk)]);  

            if sed.XB.form == 3 %shouldnt use nielsen bagnold if using hydrostatic model, so default to other formulation
                 fprintf(fid, '%s\n', ['form = soulsby_vanrijn']);
            elseif sed.XB.form == 1
               fprintf(fid, '%s\n', ['form = soulsby_vanrijn']);
            else
               fprintf(fid, '%s\n', ['form = vanthiel_vanrijn']);       
            end

        end

        if sed.XB.avalanche == 1
           fprintf(fid, '%s\n', ['avalanching = ', num2str(sed.XB.avalanche)]);
           fprintf(fid, '%s\n', ['wetslp = ', num2str(sed.XB.wetslope)]);
           fprintf(fid, '%s\n', ['dryslp = ', num2str(sed.XB.dryslope)]);
        else
          fprintf(fid, '%s\n', ['avalanching = 0']);
        end
     
    %Other Input types
        fprintf(fid, '%s\n', 'zs0file = waterlevel.inp');
        fprintf(fid, '%s\n', 'tideloc = 1');

    %Currently leave winds out of XBeach - not necessary for this application
        %fprintf(fid, '%s\n', 'windfile = winds.inp');        

    %Currently structures not yet implemented
        %if structures.struct == 1
        %  fprintf(fid, '%s\n', 'struct = 1');
        %  fprintf(fid, '%s\n', 'ne_layer = ne_layer.grd'); 
        %end

    %Output Requests
    
   % if sed.XB.morfacopt == 1 
        fprintf(fid, '%s\n', ['tstart = ', num2str(project.XB.hydro_spinup)]);
        fprintf(fid, '%s\n', ['tstop = ', num2str(project.timeStep+project.XB.hydro_spinup)]);
        fprintf(fid, '%s\n', ['tint = ', num2str(project.timeStep-1)]); %time step for output is calculated just as from tstart
        fprintf(fid, '%s\n', ['tintg = ', num2str(project.timeStep-1)]); %time step for output is calculated just as from tstart
        fprintf(fid, '%s\n', ['tintm = ', num2str(project.timeStep)]); %time step for output is calculated just as from tstart         
   % elseif sed.XB.morfacopt == 0 
%         timeStep = project.timeStep/regimes.morfac(run_number);
%         fprintf(fid, '%s\n', ['tstart = ', num2str(project.XB.hydro_spinup)]);
%         fprintf(fid, '%s\n', ['tstop = ', num2str(timeStep+project.XB.hydro_spinup)]);
%         fprintf(fid, '%s\n', ['tint = ', num2str(timeStep-1)]); %time step for output is calculated just as from tstart
%         fprintf(fid, '%s\n', ['tintg = ', num2str(timeStep-1)]); %time step for output is calculated just as from tstart
%         fprintf(fid, '%s\n', ['tintm = ', num2str(timeStep)]); %time step for output is calculated just as from tstart            
%    % end
        
        
        if project.XB.outputType == -1 
            fprintf(fid, '%s\n', 'nglobalvar = -1');
        elseif project.XB.outputType == 0
            fprintf(fid, '%s\n', 'nglobalvar = 1');
            %fprintf(fid, '%s\n', 'H');
            %fprintf(fid, '%s\n', 'zs');
            fprintf(fid, '%s\n', 'zb');  
            %fprintf(fid, '%s\n', 'cctot');  
             fprintf(fid, '%s\n', 'nmeanvar = 2');
             fprintf(fid, '%s\n', 'H');
             fprintf(fid, '%s\n', 'zs');
           % fprintf(fid, '%s\n', 'cctot');
            %fprintf(fid, '%s\n', 'ccg');
            fprintf(fid, '%s\n', 'nrugauge = 1');
            fprintf(fid, '%s\n', [num2str(nanmean(grid.XGrid)) , ' 0 runuptrans']);
            fprintf(fid, '%s\n', ['rugdepth = ', num2str(waves.XB.eps)]);
            fprintf(fid, '%s\n', 'tintp = 5'); %save runup output every 5 second (maybe too much for long sims?)
        elseif project.XB.outputType == 1
            fprintf(fid, '%s\n', 'nglobalvar = 4');
            fprintf(fid, '%s\n', 'H');
            fprintf(fid, '%s\n', 'zs');
            fprintf(fid, '%s\n', 'u');
            fprintf(fid, '%s\n', 'v');        
        elseif project.XB.outputType == 2
            fprintf(fid, '%s\n', 'nglobalvar = 5');
            fprintf(fid, '%s\n', 'H');
            fprintf(fid, '%s\n', 'zs');
            fprintf(fid, '%s\n', 'u');
            fprintf(fid, '%s\n', 'v');
            fprintf(fid, '%s\n', 'zb');
        elseif project.XB.outputType == 3
            fprintf(fid, '%s\n', 'nglobalvar = 10');
            fprintf(fid, '%s\n', 'H');
            fprintf(fid, '%s\n', 'zb');
            fprintf(fid, '%s\n', 'dxbdx');
            fprintf(fid, '%s\n', 'dzbdy');              
            fprintf(fid, '%s\n', 'dzbdt');
            fprintf(fid, '%s\n', 'sedero');
            fprintf(fid, '%s\n', 'ccg');
            fprintf(fid, '%s\n', 'ccbg');  
            fprintf(fid, '%s\n', 'Susg');
            fprintf(fid, '%s\n', 'Svsg');
         elseif project.XB.outputType == 4
            fprintf(fid, '%s\n', 'nglobalvar = 14');
            fprintf(fid, '%s\n', 'H');
            fprintf(fid, '%s\n', 'zs');
            fprintf(fid, '%s\n', 'u');
            fprintf(fid, '%s\n', 'v');
            fprintf(fid, '%s\n', 'zb');
            fprintf(fid, '%s\n', 'thetamean');
            fprintf(fid, '%s\n', 'E');
            fprintf(fid, '%s\n', 'D');
            fprintf(fid, '%s\n', 'Qb');
            fprintf(fid, '%s\n', 'Sk');
            fprintf(fid, '%s\n', 'As');
            fprintf(fid, '%s\n', 'Df');
            fprintf(fid, '%s\n', 'Dp');
            fprintf(fid, '%s\n', 'hh');
        elseif project.XB.outputType == 5
            fprintf(fid, '%s\n', 'nglobalvar = 4');
            fprintf(fid, '%s\n', 'H');
            fprintf(fid, '%s\n', 'zb');
            fprintf(fid, '%s\n', 'zs');
            fprintf(fid, '%s\n', 'gwlevel');    
        elseif project.XB.outputType == 6
            fprintf(fid, '%s\n', 'nglobalvar = 2');
            fprintf(fid, '%s\n', 'H');
            fprintf(fid, '%s\n', 'zs');
        end    
        if project.XB.NetCDF == 1
            fprintf(fid, '%s\n', 'outputformat = netcdf');
            fprintf(fid, '%s\n', 'tunits = seconds since 1970-01-01 +1');  
        else
             fprintf(fid, '%s\n', 'outputformat = fortran');
            fprintf(fid, '%s\n', 'tunits = seconds since 1970-01-01 +1');        
        end
    
    %Groundwater flow
        if sed.XB.gwflow == 1
          fprintf(fid, '%s\n', ['gwflow = ', num2str(sed.XB.gwflow)])   
          if sed.XB.gw0 == -99 && exist('tides.waterlevel') == 1
              if exist('tides.waterlevel')
              fprintf(fid, '%s\n', ['gw0 = ', num2str(nanmean(tides.waterlevel))]); 
             else
             fprintf(fid, '%s\n', ['gw0 = 0']);  
             end
          elseif sed.XB.gw0 == -88
             if exist('tides.waterlevel')
                [~, peakMag] = peakfinder(tides.waterlevel);    
                fprintf(fid, '%s\n', ['gw0 = ', num2str(nanmean(peakMag))]);   
             else
             fprintf(fid, '%s\n', ['gw0 = 0']);  
             end
          else
            fprintf(fid, '%s\n', ['gw0 = ', num2str(sed.XB.gw0)]);    
          end  
        end
     
    %Vegetation
    if veg.XB.vegUse == 1
         fprintf(fid, '%s\n', ['nveg = 1'])    
         fprintf(fid, '%s\n', ['veggiefile = veggiefile.txt'])    
         fprintf(fid, '%s\n', ['veggiemapfile = veggiemap.txt'])       
    end
    
    %Grain Size and Multiple Sediment Fractions
%     if sed.ngd >1 %layers are not yet implemented in toolbox, so this is not super relevant
%           fprintf(fid, '%s\n', ['ngd = ', num2str(sed.ngd)]);
%           fprintf(fid, '%s\n', ['D90 = ', num2str(sed.D90)]);
%           fprintf(fid, '%s\n', ['D50 = ', num2str(sed.D50)]);
%             if exist('sed.D10') ==1
%              fprintf(fid, '%s\n', ['D10 = ', num2str(sed.D15)]);
%             end
%           fprintf(fid, '%s\n', ['nd = 3']);
%           fprintf(fid, '%s\n', ['dzg1 = ', num2str(sed.dzg1)]);
%           fprintf(fid, '%s\n', ['dzg2 = ', num2str(sed.dzg2)]);
%           fprintf(fid, '%s\n', ['dzg3 = ', num2str(sed.dzg3)]);
%           fprintf(fid, '%s\n', ['sedcal = ', num2str(sed.sedcal)]);  
%     else % put in grain size info into model
    fprintf(fid, '%s\n', ['D90 = ', num2str(sed.XB.D90(1))]);
    fprintf(fid, '%s\n', ['D50 = ', num2str(sed.XB.D50(1))]);
    if exist('sed.D10') == 1
     fprintf(fid, '%s\n', ['D15 = ', num2str(sed.XB.D10(1))]);
    end
%     end

%NON-DEFAULT VARIABLES
% if project.XB.default == 0
    %Wave params
%     if regimes.wave_type(run_number) == 2
%         fprintf(fid, '%s\n', ['break = 2']); %cant use all wave breaking formulas for stationary case        
%     else
        fprintf(fid, '%s\n', ['break = ', num2str(waves.XB.break)]);
 %   end
    fprintf(fid, '%s\n', ['gamma = ', num2str(waves.XB.gamma)]);
    fprintf(fid, '%s\n', ['gammax = ', num2str(waves.XB.gammax)]);
    fprintf(fid, '%s\n', ['alpha = ', num2str(waves.XB.alpha)]);
    fprintf(fid, '%s\n', ['breakerdelay = ', num2str(waves.XB.breakerdelay)]);
    fprintf(fid, '%s\n', ['roller = ', num2str(waves.XB.roller)]);
    fprintf(fid, '%s\n', ['beta = ', num2str(waves.XB.beta)]);
    fprintf(fid, '%s\n', ['rfb = ', num2str(waves.XB.rfb)]);
    fprintf(fid, '%s\n', ['shoaldelay = ', num2str(waves.XB.shoaldelay)]);
    fprintf(fid, '%s\n', ['n = ',num2str(waves.XB.n)]);
    fprintf(fid, '%s\n', ['wci = ',num2str(waves.XB.wci)]);
    fprintf(fid, '%s\n', ['hwci = ',num2str(waves.XB.hwci)]);
    fprintf(fid, '%s\n', ['cats = ',num2str(waves.XB.cats)]);
    fprintf(fid, '%s\n', ['taper = ',num2str(waves.XB.taper)]);

    %Wind
    fprintf(fid, '%s\n', ['wind = ',num2str(winds.XB.windUse)]);
    if winds.XB.windUse == 1
            fprintf(fid, '%s\n', ['windv = ',num2str(winds.windspeed(run_number))]);
                    %note that wind direction is nautical for xbeach, whereas 0 is convention for other models
                    tempwinddir = winds.winddir(run_number);
                    tempwinddir = wrapTo360(270-tempwinddir);
            fprintf(fid, '%s\n', ['windth = ',num2str(tempwinddir)]);
            fprintf(fid, '%s\n', ['rhoa = ',num2str(winds.XB.rhoa)]);
            fprintf(fid, '%s\n', ['Cd = ',num2str(winds.XB.Cd)]);
    end

    %Sed Params
     fprintf(fid, '%s\n', ['waveform = ', num2str(sed.XB.waveform)]); 
     %fprintf(fid, '%s\n', ['form = ', num2str(sed.XB.form)])  
     if sed.XB.hmin>0
     fprintf(fid, '%s\n', ['hmin = ', num2str(sed.XB.hmin)]);
     else
      fprintf(fid, '%s\n', ['hmin = ', num2str(waves.XB.eps)]);  
     end
     fprintf(fid, '%s\n', ['turb = ', num2str(sed.XB.turb)]);  
     fprintf(fid, '%s\n', ['rhos = ', num2str(sed.XB.rhos)]);  
     fprintf(fid, '%s\n', ['por = ', num2str(sed.XB.por)]);    
     fprintf(fid, '%s\n', ['sourcesink = ', num2str(sed.XB.sourcesink)]);    
     fprintf(fid, '%s\n', ['thetanum = ', num2str(sed.XB.thetanum)]);    
     fprintf(fid, '%s\n', ['cmax = ', num2str(sed.XB.cmax)]);    
     %fprintf(fid, '%s\n', ['lwt = ', num2str(sed.XB.lwt)])    
     fprintf(fid, '%s\n', ['betad = ', num2str(sed.XB.betad)]);    
     fprintf(fid, '%s\n', ['sus = ', num2str(sed.XB.sus)]);    
     fprintf(fid, '%s\n', ['bed = ', num2str(sed.XB.bed)]);    
     fprintf(fid, '%s\n', ['bulk = ', num2str(sed.XB.bulk)]);    
     %fprintf(fid, '%s\n', ['lws = ', num2str(sed.XB.lws)])    
     fprintf(fid, '%s\n', ['sws = ', num2str(sed.XB.sws)]);    
     fprintf(fid, '%s\n', ['BRfac = ', num2str(sed.XB.BRfac)]);    
     fprintf(fid, '%s\n', ['facsl = ', num2str(sed.XB.facsl)]); 
     fprintf(fid, '%s\n', ['bdslpeffmag = ', sed.XB.bdslpeffmag]); 
     fprintf(fid, '%s\n', ['bdslpeffdir = ', sed.XB.bdslpeffdir]); 
     fprintf(fid, '%s\n', ['bdslpeffini = ', sed.XB.bdslpeffini]); 
     fprintf(fid, '%s\n', ['bdslpeffdirfac = ', num2str(sed.XB.bdslpeffdirfac)]);        
     fprintf(fid, '%s\n', ['ucrcal = ', num2str(sed.XB.ucrcal)]);        
     fprintf(fid, '%s\n', ['fallvelred = ', num2str(sed.XB.fallvelred)]);        
     fprintf(fid, '%s\n', ['facDc = ', num2str(sed.XB.facDc)]);        
     fprintf(fid, '%s\n', ['turbadv = ', sed.XB.turbadv]); 
     fprintf(fid, '%s\n', ['z0 = ', num2str(sed.XB.z0)]);    
     fprintf(fid, '%s\n', ['smax = ', num2str(sed.XB.smax)]);    
     fprintf(fid, '%s\n', ['tsfac = ', num2str(sed.XB.tsfac)]);    
     fprintf(fid, '%s\n', ['Tbfac = ', num2str(sed.XB.Tbfac)]);    
     fprintf(fid, '%s\n', ['Tsmin = ', num2str(sed.XB.Tsmin)]);    

    if sed.XB.q3d == 1
         fprintf(fid, '%s\n', ['q3d = 1'])  
         fprintf(fid, '%s\n', ['vonkar = ', num2str(sed.XB.vonkar)]);  
         fprintf(fid, '%s\n', ['vicmol = ', num2str(sed.XB.vicmol)]);  
         fprintf(fid, '%s\n', ['kmax = ', num2str(sed.XB.kmax)]);  
         fprintf(fid, '%s\n', ['sigfac = ', num2str(sed.XB.sigfac)]);  
    end

    %Flow
    fprintf(fid, '%s\n', ['bedfriction = ', flow.XB.bedfriction]);  
    fprintf(fid, '%s\n', ['bedfriccoef = ', num2str(flow.XB.bedfriccoef)]);  
    fprintf(fid, '%s\n', ['nuh = ', num2str(flow.XB.nuh)]);  
    fprintf(fid, '%s\n', ['dilatancy = ', num2str(sed.XB.dilatancy)]);  

    %EXPERIMENTAL CODE
    fprintf(fid, '%s\n', ['lsgrad = ', num2str(sed.XB.lsgrad)]);  
    fclose(fid);       
end