%cdm_veg_routine.m - Re-implementation of Coastal Dune Model (CDM) vegetation growth rate within Matlab
    %Created By: N. Cohn, Oregon State University and E. Goldstein, University of North Carolina Chapel Hill

function [veggie_matrix] = cdm_veg_routine_1d(project, veg, grids, veggie_matrix, dhdt, xmin)
    %INPUT ARGUMENTS
    %veggie_matrix = the percent cover of vegetation (i.e., previous timestep)
    %dhdt = the change in topography that occured in the current timestep

    %OUTPUT ARGUMENTS
    %veggie_matrix = the new percent cover of vegetation
    
    timefrac = 1; %set time frac as one here so that mimics real world time
    timeStep_days = project.timeStep/(24*60*60); %the Tveg is a growth rate in days, so time units need to be consistent within this routine

    %define the growrate
    V_gen = 1/veg.CDM.Tveg;
    shorefactor = ones(1, grids.nx);

    %growth from growth rate and deposition
    sensParam = 1; %sensitivity to burial parameter; hardcoded for now but should add as a user-defined parameter at some point
    dV = ((1 - veggie_matrix(:)) * V_gen .* shorefactor(:))- (abs(dhdt(:)) * sensParam);    
    
    %cover fraction evolves (timefrac is the rescaled wind time)
    veggie_matrix= veggie_matrix(:) + (timeStep_days(:) * dV(:) * timefrac(:));

    %limiting conditions
    %   can't have cover density greater than rhomax or less than 0))
    veggie_matrix(veggie_matrix > veg.CDM.maximumDensity) = veg.CDM.maximumDensity;
    veggie_matrix(veggie_matrix < 0) = 0;
    veggie_matrix(1:xmin) = 0;
end
