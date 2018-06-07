%Windsurf_Run.m - Master loop to run Windsurf
    %Created By: N. Cohn, Oregon State University
 
cd(project.Directory)
       
Windsurf_Initialize_Coupler %Initialize all relevant variables for first simulation

progressbar %initialize progress bar for simulations

for run_number = startingSim:project.numSims %loop through all times/environmental conditions
         
    %Scenario Modifications
        Windsurf_BeachNourishment    
        Windsurf_Structures
        Windsurf_VegetationModification
      
    %Runs XBeach if appropriate for setup, if not running XB just spits out maximum runup for other codes
        Windsurf_RunXBeach;
    
    %Runs External (matlab-based) vegetation code instead of CDM if desired[Still Being Implemented]
        Windsurf_RunVegCode   
    
    %Runs CDM if appropriate, if Aeolis is also turned out just spits out shear and wind velocities and vegetation parameters
        Windsurf_RunCDM;
    
    %Runs Aeolis if turned on for sediment transport formulations and subaerial morphology change
        Windsurf_RunAeolis;   
        
    %Store Relevant Output
        Windsurf_SaveOutput
    
    %Update Progress
        progressbar(run_number/project.numSims)
    
end

Windsurf_Finalize %Finalize any remaining tasks before program terminates