%cdm_params.m - Code to run Coastal Dune Model (CDM) parameter file for Windsurf coupler
    %Created By: N. Cohn, Oregon State University

function output = cdm_run(project, idx)

    %Run the simulation
    if numel(project.CDM.CDMExecutable)>3
        
        if isunix == 1
            try %try up to 3 times because of bang-poll error on Centos7
                system([project.CDM.CDMExecutable ' cdm.par > /dev/null']);
            catch err
                try
                 pause(1);
                 system([project.CDM.CDMExecutable ' cdm.par > /dev/null']);               
                catch err
                pause(1);
                system([project.CDM.CDMExecutable ' cdm.par > /dev/null']);
                end
            end
        else
            system([project.CDM.CDMExecutable, ' cdm.par > command_line_cdm.txt']);        
        end
    else %if no value given for where the CDM EXE is assume its in the path
        system('Dune cdm.par > command_line_cdm.txt');
    end

    %Load and store the output
    try
        output = load_cdm(project);
    catch err
        try
         pause(2) %need to add in a short pause between runs b/c model needs time to write out, 1 s seems to be plenty  
          output = load_cdm(project);
        catch err
            try
                pause(5)
                output = load_cdm(project);
            catch err
                pause(60)
                output = load_cdm(project);            
        end
        
    end

    end
end

    function output = load_cdm(project)
    
        %pick the last output file
        if project.flag.CDM ~=2
           output_num = project.timeStep/project.CDM.timestep;
        else
           output_num = 1; %only run for 1 time step if only pulling out wind
        end
    
         output.h = load([project.Directory, filesep, 'cdm', filesep, 'CDM_temp', filesep, 'h.', sprintf('%05d',output_num),'.dat']);
         output.veget_x = load([project.Directory, filesep,'cdm', filesep,'CDM_temp', filesep, 'veget_x.', sprintf('%05d',output_num),'.dat']);
         output.shear_x = load([project.Directory, filesep,'cdm', filesep,'CDM_temp', filesep, 'shear_x.', sprintf('%05d',output_num),'.dat']);
         output.u_x = load([project.Directory, filesep,'cdm', filesep,'CDM_temp', filesep, 'u_x.', sprintf('%05d',output_num),'.dat']);
        % output.flux_x = load([project.Directory, filesep, 'cdm', filesep,'CDM_temp', filesep, 'flux_x.', sprintf('%05d',output_num),'.dat']);
         output.stall = load([project.Directory, filesep, 'cdm', filesep,'CDM_temp', filesep, 'stall.', sprintf('%05d',output_num),'.dat']);
         output.shear_pert_x = load([project.Directory, filesep, 'cdm', filesep,'CDM_temp', filesep, 'shear_pert_x.', sprintf('%05d',output_num),'.dat']);
         output.h_sep = load([project.Directory, filesep, 'cdm', filesep,'CDM_temp', filesep, 'h_sep.', sprintf('%05d',output_num),'.dat']);
         %output.u_y = load([project.Directory, filesep,'cdm', filesep,'CDM_temp', filesep, 'u_y.', sprintf('%05d',output_num),'.dat']);
         %output.shear_y = load([project.Directory, filesep,'cdm', filesep,'CDM_temp', filesep, 'shear_y.', sprintf('%05d',output_num),'.dat']);
         %output.shear_pert_y = load([project.Directory, filesep,'cdm', filesep,'CDM_temp', filesep, 'shear_pert_y.', sprintf('%05d',output_num),'.dat']);
    end