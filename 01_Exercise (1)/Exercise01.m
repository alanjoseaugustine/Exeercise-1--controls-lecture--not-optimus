% -----------------------------
% Script: Constant wind simulation with manual control.  
% Exercise 01 of Course "Controller Design of Wind Turbines and Wind Farms"
% -----------------------------
clearvars;close all;clc;

%% Preprocessing SLOW
% Define parameter (turbine and controller)
Parameter                       = NREL5MWDefaultParameter_SLOW1DOF.m;  

% internal parameters to make code easier to read 
eta_el                          = Parameter.Generator.eta_el;
r_GB                            = Parameter.Turbine.r_GB;

% manual control
theta                           = 0;                    % constant pitch for 16 m/s TODO!!!
P_el_rated                      = 5e+006;
Omega_g_rated                   = 12.1*2*pi/60;            %rpm converted to rad/s
M_g                             = P_el_rated/(Omega_g_rated*r_GB*eta_el);                    % constant torque for 16 m/s TODO!!!

% Aerodynamics
Parameter.AD                    = load('PowerAndThrustCoefficientsNREL5MW','c_P','c_T','lambda','theta'); % Actuator Disc Parameter Region 2

% Define simulation details (same as FAST)
dt          = 0.0125;           % time step                 [s]
TMax        = 60;           	% maximum time              [s]
t           = 0:dt:TMax;        % time vector
n           = length(t);        % number of simulation steps

% Define disturbance (wind signal)
v_0         = interp1([0,60],[16 16],t);          % rotor effective wind speed at every simulation step

%% Processing SLOW
% initial values (from FAST simulation)
x           = NaN(n,1);         % allocation of state vector
x(1,1)      = 12.1/60*2*pi;     % rotor speed               [rad/s],, matlab evaluates from left and right so my expression is also correct for rotor speed conversion.

% simulation using Euler forward
tic
for k = 1:1:n-1
    x_dot_k = SLOW_OpenLoop(x(k,:),M_g,theta,v_0(k),Parameter);
    x(k+1,:)= x(k,:)+x_dot_k*dt;
end
TimeRatio   = TMax/toc;

%% PostProcessing SLOW
Omega       = x(:,1);                       % rotor speed is 1st state
P_el        = M_g*Omega_g_rated*r_GB*eta_el;                            % electrical power TODO!!! 

%% Compare Results
fprintf('Time Ratio SLOW (Sim/CPU): %f\n',TimeRatio)

figure

% plot wind
subplot(511)
hold on;box on;grid on;
plot(t,v_0)
ylabel('wind speed [m/s]')

% plot rotor speed
subplot(512)
hold on;box on;grid on;
plot(t,Omega/2/pi*60) % rad/s to rpm
ylabel('rotor speed [rpm]')

% plot pitch angle
subplot(513)
hold on;box on;grid on;
yline(rad2deg(theta),'b') 
ylabel('pitch [deg]')

% plot torque
subplot(514)
hold on;box on;grid on;
yline(M_g/1e3,'b')  
ylabel('torque [kNm]')

% plot power
subplot(515)
hold on;box on;grid on;
plot(t,P_el/1e6) 
ylabel('Power [MW]')
xlabel('time [s]')