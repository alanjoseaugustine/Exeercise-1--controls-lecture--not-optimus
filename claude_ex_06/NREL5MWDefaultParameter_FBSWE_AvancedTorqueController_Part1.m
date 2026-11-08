function [Parameter] = NREL5MWDefaultParameter_FBSWE_AvancedTorqueController_Part1(Parameter)

%% FBSWE Pitch Controller
Omega_g_rated                           = rpm2radPs(12.1*97);               % [rad/s]
Parameter.CPC.Omega_g_rated             = Omega_g_rated;

%% FBSWE Torque Controller
eta_el                                  = 0.944;                            % [-]               Generator efficency
P_el_rated                              = 5e6;                              % [W]
Parameter.VSC.k                         = 2.3323;                           % [Nm/(rad/s)^2]    from [Jonkman2009a] 0.0255764*(60/(2*pi))^2
Parameter.VSC.Mode                      = 1;                                % 1: ISC, constant power in Region 3; 2: ISC, constant torque in Region 3 
Parameter.VSC.M_g_rated                 = P_el_rated/eta_el/Omega_g_rated;  % [Nm] 
Parameter.VSC.Omega_g_1d5               = rpm2radPs(8*97);                  % [rad/s];  
Parameter.VSC.M_g_max                   = Parameter.VSC.M_g_rated*1.1;      % [Nm] 

Parameter.VSC.kp                        = 2972.8;                           % [Nm/(rad/s)]  torque PI proportional gain (Region 2.5 design, 11 m/s)
Parameter.VSC.Ti                        = 2.555;                            % [s]           torque PI integral time, K_I = kp/Ti = 1163 Nm/rad

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