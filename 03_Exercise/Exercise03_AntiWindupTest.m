% -----------------------------
% Script: Checks anti-windup of pitch controller.
% Exercise 03 of "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------
clearvars;close all;clc;
addpath(genpath('..\Library\'))

%% PreProcessing SLOW for all simulations

% Default Parameter Turbine and Controller
Parameter                       = NREL5MWDefaultParameter_SLOW1DOF;
Parameter                       = NREL5MWDefaultParameter_FBNREL_PitchController(Parameter);

% Time
dt                              = 1/80;
Parameter.Time.dt               = dt;   % [s] simulation time step              
Parameter.Time.TMax             = 60;   % [s] simulation length

% wind
Disturbance.v_0.time            = [ 0; 20; 20+dt; 40; 40+dt; 60];    % [s]      time points to change wind speed
Disturbance.v_0.signals.values  = [12; 12;    10; 10;    12; 12];    % [m/s]    wind speeds

% Initial Conditions from SteadyStates for this OP
SteadyStates = load('SteadyStatesNREL5MW_FBNREL_SLOW','v_0','Omega','theta');                       
Parameter.IC.Omega          	= interp1(SteadyStates.v_0,SteadyStates.Omega,12,'linear','extrap');
Parameter.IC.theta          	= interp1(SteadyStates.v_0,SteadyStates.theta,12,'linear','extrap');

%% Run Simulation Without and With AntiWindup

% Processing SLOW without AntiWindup
sim('NREL5MW_FBNREL_SLOW1DOF_PitchController')
    
% collect simulation Data
Omega(:,1) = logsout.get('y').Values.Omega.Data;
theta(:,1) = logsout.get('y').Values.theta.Data;

% Processing SLOW with AntiWindup
sim('NREL5MW_FBNREL_SLOW1DOF_PitchController')
    
% collect simulation Data
Omega(:,2) = logsout.get('y').Values.Omega.Data;
theta(:,2) = logsout.get('y').Values.theta.Data;


%% PostProcessing SLOW
figure
subplot(311)
hold on;box on;grid on;
plot(Disturbance.v_0.time,Disturbance.v_0.signals.values)
ylabel('v_0 [m/s]')
subplot(312)
hold on;box on;grid on;
plot(tout,theta*360/2/pi)
ylabel('\theta [deg]')
subplot(313)
hold on;box on;grid on;
plot(tout,Omega*60/2/pi)
ylabel('\Omega [rpm]')
xlabel('time [s]')
legend({'Without Anti-windup','With Anti-windup'},'location','best')

