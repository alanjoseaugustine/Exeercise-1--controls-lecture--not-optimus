% -----------------------------
% Function: Provides default parameters for feedback controller.
% Exercise 05 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ------------
% Input:
% - Parameter   struct of Parameters
% ------------
% Output:
% - Parameter   struct of Parameters
% ----------------------------------
function [Parameter] = NREL5MWDefaultParameter_FBNREL_TowerDamper(Parameter)

%% FBSWE Pitch Controller
Parameter.CPC.GS.theta                  = [0.066817 0.210442 0.304976 0.389997 ];
Parameter.CPC.GS.kp                     = [0.021958 0.006669 0.003332 0.002561 ];
Parameter.CPC.GS.Ti                     = [2.897190 2.432029 1.808628 1.467248 ];

Omega_g_rated                           = rpm2radPs(12.1*97);               % [rad/s]
Parameter.CPC.Omega_g_rated             = Omega_g_rated;
Parameter.CPC.theta_max                 = deg2rad(90);                      % [rad]
Parameter.CPC.theta_min                 = deg2rad(0);                       % [rad]

%% FBNREL Torque Controller
eta_el                                  = 0.944;                            % [-]               Generator efficency
P_el_rated                              = 5e6;                              % [W]
Parameter.VSC.k                         = 2.3323;                           % [Nm/(rad/s)^2]    from [Jonkman2009a] 0.0255764*(60/(2*pi))^2
Parameter.VSC.theta_fine                = deg2rad(1);                       % [rad]      
Parameter.VSC.Mode                      = 1;                                % 1: ISC, constant power in Region 3; 2: ISC, constant torque in Region 3 
Parameter.VSC.M_g_rated                 = P_el_rated/eta_el/Omega_g_rated;  % [Nm] 

% region limits & region parameters based on Jonkman 2009
Parameter.VSC.Omega_g_1To1_5            = rpm2radPs(670);                   % [rad/s]
Parameter.VSC.Omega_g_1_5To2            = rpm2radPs(871);                   % [rad/s]
Parameter.VSC.Omega_g_2To2_5            = rpm2radPs(1150.9);              	% [rad/s]
Parameter.VSC.Omega_g_2_5To3            = Parameter.CPC.Omega_g_rated;      % [rad/s]

% Region 1_5: M_g = a * Omega_g + b: 
% 1.Eq: 0                   = a * Omega_g_1To1_5 + b 
% 2.Eq: k*Omega_g_1_5To2^2  = a * Omega_g_1_5To2 + b
Parameter.VSC.a_1_5                     = Parameter.VSC.k*Parameter.VSC.Omega_g_1_5To2^2/(Parameter.VSC.Omega_g_1_5To2-Parameter.VSC.Omega_g_1To1_5);
Parameter.VSC.b_1_5                     = -Parameter.VSC.a_1_5*Parameter.VSC.Omega_g_1To1_5;

% Region 2_5: M_g = a * Omega_g + b: 
% 1.Eq: M_g_rated           = a * Omega_g_2_5To3   	+ b 
% 2.Eq: k*Omega_g_2To2_5^2  = a * Omega_g_2To2_5    + b
Parameter.VSC.a_2_5                     = (Parameter.VSC.M_g_rated-Parameter.VSC.k*Parameter.VSC.Omega_g_2To2_5^2)/(Parameter.VSC.Omega_g_2_5To3-Parameter.VSC.Omega_g_2To2_5);
Parameter.VSC.b_2_5                     = Parameter.VSC.M_g_rated-Parameter.VSC.a_2_5*Parameter.VSC.Omega_g_2_5To3;

%% Tower Damper
Parameter.TD.gain                       = 0.0;
Parameter.TD.Power                      = [0 1 2 3];    % [W]
Parameter.TD.Value                      = [0 0 0 0];

%% Filter Generator Speed
Parameter.Filter.LowPass.Enable         = 0;
Parameter.Filter.LowPass.f_cutoff       = 2;                                % [Hz]

r_GB                                                    = 97;               % [-]
Parameter.Filter.DynamicNotchFilter1.Enable             = 0;                % [-]
Parameter.Filter.DynamicNotchFilter1.Gain        	    = 3/r_GB;           % [-]
Parameter.Filter.DynamicNotchFilter1.RelativeBandwidth  = 0.3;              % [-]
Parameter.Filter.DynamicNotchFilter1.Depth              = 0.1;              % [-] 
Parameter.Filter.LowPassDynamicNotchFilter.f_cutoff     = 0.0279;           % [Hz] % 0.7/2/pi/4

%% Filter Tower Damper
Parameter.Filter.LowPassTowerDamper.Enable       	    = 0;
Parameter.Filter.LowPassTowerDamper.f_cutoff     	    = 1;                % [Hz]

end