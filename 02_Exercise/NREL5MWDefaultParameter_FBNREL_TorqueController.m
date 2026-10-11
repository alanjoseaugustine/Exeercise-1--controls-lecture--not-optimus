% -----------------------------
% Function: Adds parameters for NREL5MW Baseline Torque Controller.
% Exercise 02 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ------------
% Input:
% - Parameter   struct of Parameters
% ------------
% Output:
% - Parameter   struct of Parameters
% ----------------------------------
function Parameter = NREL5MWDefaultParameter_FBNREL_TorqueController(Parameter)

%% FBNREL Pitch Controller
Parameter.CPC.Omega_g_rated             = rpm2radPs(12.1*97);               % [rad/s]

%% FBNREL Torque Controller

% region limits & region parameters based on Jonkman 2009
Parameter.VSC.Omega_g_1To1_5            = rpm2radPs(670);                   % [rad/s]
Parameter.VSC.Omega_g_1_5To2            = rpm2radPs(871);                   % [rad/s]
Parameter.VSC.Omega_g_2To2_5            = rpm2radPs(1150.9);              	% [rad/s]
Parameter.VSC.Omega_g_2_5To3            = Parameter.CPC.Omega_g_rated;      % [rad/s]

% region parameters
Parameter.VSC.k                         = NaN;                              % [Nm/(rad/s)^2]    
Parameter.VSC.M_g_rated                 = NaN;                              % [Nm] 
Parameter.VSC.a_1_5                     = NaN;                              % [Nm/(rad/s)]
Parameter.VSC.b_1_5                     = NaN;                              % [Nm]
Parameter.VSC.a_2_5                     = NaN;                              % [Nm/(rad/s)]
Parameter.VSC.b_2_5                     = NaN;                              % [Nm]
Parameter.VSC.theta_fine                = deg2rad(1);                       % [rad]      
Parameter.VSC.Mode                      = 1;                                % [1/2]             1: ISC, constant power in Region 3; 2: ISC, constant torque in Region 3 

end