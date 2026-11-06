% -----------------------------
% Script: Test Dynamic Notch Filter for 3P.
% Exercise 04 of "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------
clearvars;close all;clc;
addpath(genpath('..\Library\'))

%% PreProcessing SLOW

% Default Parameter Turbine and Controller
Parameter                       = NREL5MWDefaultParameter_SLOW2DOF;
Parameter                       = NREL5MWDefaultParameter_FBNREL_NotchFilter(Parameter);

% Time
Parameter.Time.dt               = 1/10;             % [s] simulation time step            
Parameter.Time.TMax             = 3600;             % [s] simulation length

% wind
OP = 20;                            
load(['wind/URef_',num2str(OP,'%02d'),'_Disturbance'],'Disturbance')              

% Initial Conditions from SteadyStates
SteadyStates = load('SteadyStatesNREL5MW_FBNREL_SLOW','v_0','Omega','theta','x_T');                       
Parameter.IC.Omega          	= interp1(SteadyStates.v_0,SteadyStates.Omega   ,OP,'linear','extrap');
Parameter.IC.theta          	= interp1(SteadyStates.v_0,SteadyStates.theta   ,OP,'linear','extrap');
Parameter.IC.x_T                = interp1(SteadyStates.v_0,SteadyStates.x_T     ,OP,'linear','extrap');

%% Processing SLOW
sim('NREL5MW_FBNREL_SLOW2DOF_NotchFilter')

%% PostProcessing SLOW

% estimate spectra
nBlocks                 = 6;
SamplingFrequency       = 1/Parameter.Time.dt;
nDataPerBlock           = round(length(tout)/nBlocks);
Omega_g_f               = logsout.get('logFB').Values.Omega_g_f.Data;
Omega_g                 = logsout.get('y').Values.Omega_g.Data;
theta_dot               = logsout.get('y').Values.theta_dot.Data;
[S_theta_dot,~]         = pwelch(detrend(theta_dot,'constant'),nDataPerBlock,[],[],SamplingFrequency);
[S_Omega_g_f,~]         = pwelch(detrend(Omega_g_f,'constant'),nDataPerBlock,[],[],SamplingFrequency);
[S_Omega_g,f_est]       = pwelch(detrend(Omega_g,  'constant'),nDataPerBlock,[],[],SamplingFrequency);


figure

% plot pitch
subplot(311)
hold on;box on;grid on;
plot(tout,logsout.get('u').Values.theta_c.Data*360/2/pi)
ylabel('\theta [deg]')

% plot generator torque
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
legend('unfiltered','filtered','Location','best')

figure
% plot rotor speed spectrum
subplot(211)
hold on;grid on;box on
title('rotor speed spectrum')
plot(f_est,S_Omega_g)
plot(f_est,S_Omega_g_f)
set(gca,'xScale','log')
set(gca,'yScale','log')
ylabel('[(rad/s)^2/Hz]')
legend('unfiltered','filtered','Location','best')

% plot pitch rate spectrum
subplot(212)
hold on;grid on;box on
title('pitch rate spectrum')
plot(f_est,S_theta_dot)
set(gca,'xScale','log')
set(gca,'yScale','log')
ylabel('[(rad/s)^2/Hz]')
xlabel('frequency [Hz]')

% display
fprintf('Standard devation of the generator speed %.4g rpm.\n',radPs2rpm(std(Omega_g)))
fprintf('Standard devation of the pitch rate %.4g deg/s.\n',rad2deg(std(theta_dot)))