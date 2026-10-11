% -----------------------------
% Script: Tests Baseline Torque Controller.
% Exercise 02 of "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------
clearvars;close all;clc;
addpath(genpath('../Library/'))

%% PreProcessing SLOW

% default parameter turbine and controller
Parameter                       = NREL5MWDefaultParameter_SLOW1DOF;
Parameter                       = NREL5MWDefaultParameter_FBNREL_TorqueController(Parameter);

% time
dt                              = 1/80;
Parameter.Time.dt               = dt;   % [s] simulation time step              
Parameter.Time.TMax             = 60;   % [s] simulation length

% wind
Disturbance.v_0.time            = [0; 30; 30+dt; 60]; % [s]      time points to change wind speed
Disturbance.v_0.signals.values  = [8;  8;     9;  9]; % [m/s]    wind speeds

% initial conditions from SteadyStates
SteadyStates = load('SteadyStatesNREL5MW_FBNREL_SLOW','v_0','Omega','theta');                       
Parameter.IC.Omega          	= interp1(SteadyStates.v_0,SteadyStates.Omega   ,8,'linear','extrap');
Parameter.IC.theta          	= interp1(SteadyStates.v_0,SteadyStates.theta   ,8,'linear','extrap');

%% Processing SLOW
sim('NREL5MW_FBNREL_SLOW1DOF')

%% PostProcessing SLOW
figure

% plot wind
subplot(411)
hold on;box on;grid on;
plot(tout,logsout.get('d').Values.v_0.Data)
ylabel('v_0 [m/s]')

% plot generator torque
subplot(412)
hold on;box on;grid on;
plot(tout,logsout.get('u').Values.M_g_c.Data/1e3)
ylabel('M_G [kNm]')

% plot rotor speed
subplot(413)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.Omega.Data*60/2/pi)
ylabel('\Omega [rpm]')

% plot tip speed ratio
subplot(414)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.lambda.Data)
ylabel('\lambda [-]')
xlabel('time [s]')