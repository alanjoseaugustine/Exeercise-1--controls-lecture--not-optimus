% -----------------------------
% Script: Tests tower damper with wind step.
% Exercise 05 of Course "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------
clearvars;close all;clc;
addpath(genpath('..\Library\'))

%% PreProcessing SLOW

% Default Parameter Turbine and Controller
Parameter                           = NREL5MWDefaultParameter_SLOW2DOF;
Parameter                           = NREL5MWDefaultParameter_FBNREL_TowerDamper(Parameter);

% Time
Parameter.Time.dt                   = 0.01;            % [s] simulation time step            
Parameter.Time.TMax                 = 30;              % [s] simulation length

% Wind
DeltaU                              = 1;
URef                                = 20;                
Disturbance.v_0.time                = [0;     0.01;      	30];            % [s]      time points to change wind speed
Disturbance.v_0.signals.values      = [URef;  URef+DeltaU;  URef+DeltaU];   % [m/s]    wind speeds  

% Initial Conditions from SteadyStates
SteadyStates = load('SteadyStatesNREL5MW_FBNREL_SLOW','v_0','Omega','theta','x_T');                       
Parameter.IC.Omega          	    = interp1(SteadyStates.v_0,SteadyStates.Omega   ,URef,'linear','extrap');
Parameter.IC.theta          	    = interp1(SteadyStates.v_0,SteadyStates.theta   ,URef,'linear','extrap');
Parameter.IC.x_T                    = interp1(SteadyStates.v_0,SteadyStates.x_T     ,URef,'linear','extrap');

%% Processing SLOW
sim('NREL5MW_FBNREL_SLOW2DOF_TowerDamper')

%% PostProcessing SLOW
figure

% plot rotor speed
subplot(211)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.Omega.Data*60/2/pi)
ylabel('$\Omega$ [rpm]','Interpreter','latex')

% plot tower top velocity
subplot(212)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.x_T_dot.Data)
ylabel('$\dot x_T$ [m/s]','Interpreter','latex')
xlabel('time [s]')