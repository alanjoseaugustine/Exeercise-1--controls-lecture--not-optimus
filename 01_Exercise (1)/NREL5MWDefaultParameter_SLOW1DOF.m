% -----------------------------
% Function: Provides parameter for NREL5MW SLOW wind turbine model.
% ------------
% Input:
% none
% ------------
% Output:
% - Parameter   struct of Parameters
% ----------------------------------
function Parameter = NREL5MWDefaultParameter_SLOW1DOF

%% General          
Parameter.General.rho               = NaN;         	    % [kg/m^3]  air density

%% Turbine
Parameter.Turbine.r_GB            	= NaN;              % [-]       gearbox ratio
Parameter.Turbine.R              	= NaN;              % [m]       Rotor radius
Parameter.Turbine.SS             	= load('PowerAndThrustCoefficientsNREL5MW','c_P','theta','lambda'); % load Power coefficient look-up-table

% drive-train dynamics
J_G                               	= 534.116;          % [kgm^2]	generator inertia about high-speed shaft
J_R                                	= 3.8759e+007;      % [kgm^2]	rotor inertia about low-speed shaft
Parameter.Turbine.J                	= NaN;              % [kgm^2]   sum of moments of inertia about low-speed shaft

%% Generator
Parameter.Generator.eta_el      	= NaN;              % [-]       Generator efficency

end