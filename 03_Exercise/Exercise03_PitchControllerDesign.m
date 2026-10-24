% -----------------------------
% Script: Designs pitch controller with closed-loop shaping.
% Exercise 03 of "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------
clearvars;close all;clc;
addpath(genpath('../Library/'))

%% Design
OPs         = [12 16 20 24];    % [m/s]
D_d         = 0.7;              % [-]
omega_d     = 0.5;              % [rad/s]

%% Default Parameter Turbine and Controller (only M_g_rated and Omega_g_rated needed for LinearizeSLOW1DOF_PC)
Parameter                       = NREL5MWDefaultParameter_SLOW1DOF;
Parameter                       = NREL5MWDefaultParameter_FBNREL_PitchController(Parameter);
SteadyStates                    = load('SteadyStatesNREL5MW_FBNREL_SLOW','v_0','Omega','theta');                       

%% loop over operation points
nOP     = length(OPs);
kp      = NaN(1,nOP);
Ti      = NaN(1,nOP);
theta   = NaN(1,nOP);

for iOP = 1:nOP  
    
    % Get operation point
    v_0_OP      = OPs(iOP);
    Omega_OP    = NaN; % please adjust
    theta_OP    = NaN; % please adjust

    % Linearize at each operation point
    [A,B,C,D]   = LinearizeSLOW1DOF_PC(theta_OP,Omega_OP,v_0_OP,Parameter); 
    
    % Determine theta, kp and Ti for each operation point
    kp(iOP)     = NaN; % please adjust
    Ti(iOP)     = NaN; % please adjust
    theta(iOP)  = NaN; % please adjust
end

fprintf('Parameter.CPC.GS.theta                  = [%s];\n',sprintf('%f ',theta));
fprintf('Parameter.CPC.GS.kp                     = [%s];\n',sprintf('%f ',kp));
fprintf('Parameter.CPC.GS.Ti                     = [%s];\n',sprintf('%f ',Ti));  
 
