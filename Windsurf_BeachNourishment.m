%Windsurf_BeachNourishment
    %Code for modifying the beach profile based on volume (type 1), contour (type 2), or fixed time (type 3) changes at some
    %fixed time intervals based on specified user inputs
    %
    %Created By: N. Cohn, Oregon State University

if project.flag.nourishment ~= 0 && run_number > 1
    
    %type 1 = volume consideration
    if project.flag.nourishment == 1 %nourish based on a volume lost threshold [NOT YET TESTED]
        
        %find volume in between specified contours
        ivol = find(run.z>=nourishment.vol.cont1 & run.z<= nourishment.vol.cont2);
        
        zvol = run.z - nourishment.vol.cont1;
        diffX = diff(grids.XGrid);
        diffX = [diffX diffX(end)];
        zvol = zvol.*   diffX;
        zvol = sum(zvol(ivol));
        
        if run_number <= 2
            init_vol = zvol;
        end
        
        volchange = zvol-init_vol;
        
        if volchange< nourishment.vol.threshold
            %should track nourishment time schedule
            nourishment_time_series(run_number) = 1;
          
            %only nourish if beyond the time scale needed
            iuse = [run_number-nourishment.delay]:run_number;
            iuse = iuse(find(iuse>0));
            if nansum(nourishment_time_series(iuse)) > nourishment.delay
                nourishment_time_series(iuse) = NaN;
                run.z = nourish(run, grids, nourishment);  
            end
        end
        
        
    elseif project.flag.nourishment == 2 %nourish based on a contour retreat threshold [NOT YET TESTED]
        initialX = interp1(XZfinal(:,2), XZfinal(:,1), nourishment.cont.elev);
        currentX = interp1(run.z, XZfinal(:,1), nourishment.cont.elev);
        if [initialX-currentX]<-nourishment.cont.maxretreat
            %only nourish if beyond the time scale needed
            iuse = [run_number-nourishment.delay]:run_number;
            iuse = iuse(find(iuse>0));
            if nansum(nourishment_time_series(iuse)) > nourishment.delay
                nourishment_time_series(iuse) = NaN;
                run.z = nourish(run, grids, nourishment);  
            end   
        end
    elseif project.flag.nourishment == 3 %nourish at fixed times
            go_nourish = find(nourishment.times == run_number);
            if numel(go_nourish) == 1
                run.z = nourish(run, grids, nourishment);
            end
            clear go_nourish
    end
end

    
function z_out = nourish(run, grids, nourishment) %provide new morphologic profile based on nourishment guidelines  
    %define geometry
    x = grids.XGrid(:);
    z = run.z(:);
    iuse = find(z>nourishment.minZ & z<=nourishment.maxZ);
    dx = abs(diff(x));
    dx = [dx(1); dx(:)];
    dx = dx(:);
    addVol = nourishment.volume;

    %make all the elevations such that it is appeoximately a flat top
    addVals = (nourishment.maxZ - z(iuse)).*dx(iuse);

    %alternative approach for adding sine wave
    %addVals = sin(0:pi/(numel(iuse)-1):pi).dx(iuse)';

    %remove mass from seaward most cells so that is not beyond angle of repose
    modVals = ones(size(addVals));
    entries = round(numel(modVals)/3);
    if entries>3
       modVals(1:entries) = linspace(0,1,entries);
    end

    %fix so that the appropriate volume is added
    addVals = addVals.*modVals;
    addVals = ((addVals./dx(iuse))./nansum(addVals)).*addVol;

    %correct the z value
    z(iuse) = z(iuse)+addVals;

    %output values
    z_out = z; 
end
