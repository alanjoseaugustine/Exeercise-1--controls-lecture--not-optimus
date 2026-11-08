% -----------------------------
% Function: Provides parameter for NREL5MW SLOW wind turbine model with 3
% degrees of freedom (rotor motion, tower motion, pitch actuator).
% ------------
% Input:
% none
% ------------
% Output:
% - Parameter   struct of Parameters
% ----------------------------------
function [Parameter] = NREL5MWDefaultParameter_SLOW3DOF

%% General          
Parameter.General.rho               = 1.225;         	% [kg/m^3]  air density

%% Turbine
Parameter.Turbine.r_GB             	= 97;               % [-]       gearbox ratio
Parameter.Turbine.R              	= 126/2;            % [m]       Rotor radius
Parameter.Turbine.SS             	= load('PowerAndThrustCoefficientsNREL5MW','c_P','c_T','theta','lambda');

% drive-train dynamics
J_G                               	= 534.116;          % [kgm^2]	generator inertia about high-speed shaft
J_R                                	= 3.8759e+007;      % [kgm^2]	rotor inertia about low-speed shaft
Parameter.Turbine.J                	= J_R+J_G*Parameter.Turbine.r_GB^2; % [kgm^2] sum of moments of inertia about low-speed shaft

% fore-aft tower dynamics  
d_s                                 = 0.01;             % [-]       Structural Damping ratio from NRELOffshrBsline5MW_Tower_Onshore.dat
f_0TwFADOF1                         = 0.324;            % [Hz]      first tower fore-aft eigenfrequency
Parameter.Turbine.x_T0           	= -0.0656145;       % [m]       tower top deflection without wind
Parameter.Turbine.k_Te            	= 1.80987e+06;      % [kg/s^2]  tower equivalent bending stiffness 
Parameter.Turbine.m_Te          	= Parameter.Turbine.k_Te/(f_0TwFADOF1*2*pi)^2;  	% [kg]      tower equivalent modal mass
Parameter.Turbine.c_Te            	= 2*Parameter.Turbine.m_Te*d_s*f_0TwFADOF1*2*pi;    % [kg/s]	tower equivalent structual damping
Parameter.Turbine.HubHeight       	= 90;               % [m]       hub height

%% Generator
Parameter.Generator.eta_el      	= 0.944;            % [-]       Generator efficency

%% PitchActuator            
Parameter.PitchActuator.omega           = 2*pi*1;           % [rad/s]
Parameter.PitchActuator.xi              = 0.7;              % [-]
Parameter.PitchActuator.theta_dot_max 	= deg2rad(8);       % [rad/s]

end