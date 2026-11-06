% -----------------------------
% Script: Tests low pass.
% Exercise 04 of "Controller Design for Wind Turbines and Wind Farms"
% ----------------------------------
clearvars;close all;clc;
addpath(genpath('..\Library\'))

%% PreProcessing SLOW

% Default Parameter Turbine and Controller
Parameter                       = NREL5MWDefaultParameter_SLOW2DOF;
Parameter                       = NREL5MWDefaultParameter_FBNREL_LowPass(Parameter);

% Time
Parameter.Time.dt               = 0.001;            % [s] simulation time step            
Parameter.Time.TMax             = 0.1;              % [s] simulation length

% wind
OP = 12;                            
Disturbance.v_0.time            = [0; 60];          % [s]      time points to change wind speed
Disturbance.v_0.signals.values  = [OP;OP];          % [m/s]    wind speeds

% Noise
f   = 50;
a   = rpm2radPs(10);
Disturbance.noise.time                	= [0:Parameter.Time.dt:Parameter.Time.TMax]';                
Disturbance.noise.signals.values     	= a*sin(2*pi*f*Disturbance.noise.time);               

% Initial Conditions from SteadyStates
SteadyStates = load('SteadyStatesNREL5MW_FBNREL_SLOW','v_0','Omega','theta','x_T');                       
Parameter.IC.Omega          	= interp1(SteadyStates.v_0,SteadyStates.Omega   ,OP,'linear','extrap');
Parameter.IC.theta          	= interp1(SteadyStates.v_0,SteadyStates.theta   ,OP,'linear','extrap');
Parameter.IC.x_T                = interp1(SteadyStates.v_0,SteadyStates.x_T     ,OP,'linear','extrap');

%% Processing SLOW
sim('NREL5MW_FBNREL_SLOW2DOF_LowPass')

%% PostProcessing SLOW
figure

% plot pitch
subplot(311)
hold on;box on;grid on;
plot(tout,logsout.get('u').Values.theta_c.Data*360/2/pi)
ylabel('\theta [deg]')

% plot pitch
subplot(312)
hold on;box on;grid on;
plot(tout,logsout.get('u').Values.M_g_c.Data/1e3)
ylabel('M_G [kNm]')

% plot generator speed
subplot(313)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.Omega_g.Data*60/2/pi)
plot(tout,logsout.get('logFB').Values.Omega_g_f.Data*60/2/pi)
ylabel('\Omega_G [rpm]')
xlabel('time [s]')
legend('unfiltered','filtered')