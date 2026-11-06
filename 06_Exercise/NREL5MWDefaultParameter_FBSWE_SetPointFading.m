function [Parameter] = NREL5MWDefaultParameter_FBSWE_SetPointFading(Parameter)

%% FBSWE Pitch Controller
Parameter.CPC.GS.theta                  = [0.066817 0.210442 0.304976 0.389997 ];
Parameter.CPC.GS.kp                     = [0.021958 0.006669 0.003332 0.002561 ];
Parameter.CPC.GS.Ti                     = [2.897190 2.432029 1.808628 1.467248 ];

Omega_g_rated                           = rpm2radPs(12.1*97);               % [rad/s]
Parameter.CPC.Omega_g_rated             = Omega_g_rated;
Parameter.CPC.theta_max                 = deg2rad(90);                      % [rad]
Parameter.CPC.theta_min                 = deg2rad(0);                       % [rad]

%% FBSWE Torque Controller
eta_el                                  = 0.944;                            % [-]               Generator efficency
P_el_rated                              = 5e6;                              % [W]
Parameter.VSC.k                         = 2.3323;                           % [Nm/(rad/s)^2]    from [Jonkman2009a] 0.0255764*(60/(2*pi))^2
Parameter.VSC.Mode                      = 1;                                % 1: ISC, constant power in Region 3; 2: ISC, constant torque in Region 3 
Parameter.VSC.M_g_rated                 = P_el_rated/eta_el/Omega_g_rated;  % [Nm] 
Parameter.VSC.Omega_g_1d5               = rpm2radPs(8*97);                  % [rad/s];  
Parameter.VSC.M_g_max                   = Parameter.VSC.M_g_rated*1.1;      % [Nm] 

Parameter.VSC.kp                        = 2974.123913;                      % [Nm/(rad/s)]  
Parameter.VSC.Ti                        = 2.556479;                         % [s] 

%% Set-Point-Fading
Parameter.SPF.Delta_Omega_g             = 0;                                % [rad/s]   % over-/under-speed limit for setpoint-fading, first guess
Parameter.SPF.Delta_theta               = deg2rad(0);                       % [rad]     % change of pitch angle at which under-speed limit should be reached, brute-force-optimized
Parameter.SPF.Delta_P                   = 0;                          	    % [W]       % change of power at which over-speed limit should be reached, first guess
Parameter.Filter.LowPass2.f_cutoff     	= 0;                                % [Hz]      % cut-off-frequency for low pass filter for setpoint-fading, first guess

%% Filter Generator Speed
Parameter.Filter.LowPass.Enable         = 0;
Parameter.Filter.LowPass.f_cutoff       = 2;                                % [Hz]

r_GB                                                    = 97;               % [-]
Parameter.Filter.DynamicNotchFilter1.Enable             = 0;                % [-]
Parameter.Filter.DynamicNotchFilter1.Gain        	    = 3/r_GB;           % [-]
Parameter.Filter.DynamicNotchFilter1.RelativeBandwidth  = 0.3;              % [-]
Parameter.Filter.DynamicNotchFilter1.Depth              = 0.1;              % [-] 
Parameter.Filter.LowPassDynamicNotchFilter.f_cutoff     = 0.0279;           % [Hz] % 0.7/2/pi/4
   
end