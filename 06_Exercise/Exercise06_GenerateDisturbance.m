% -----------------------------
% Script: Generates a set of time series for rotor-effective wind speed.
% Exercise 06 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ----------------------------------
clearvars;close all;clc;
addpath(genpath('..\Library\'))

%% Configuration

% Parameter 
Parameter.Turbine.R                     = 63;       % [m] rotor radius
Parameter.Time.dt                       = 0.1;      % [s] simulation time step            
Parameter.Time.TMax                     = 3600;     % [s] simulation lenght
Parameter.TurbSim.IRef                  = 0.16;     % [-] ClassA

% windfield
[windfield.grid.Y,windfield.grid.Z]     = meshgrid(-64:8:64);

%% Generate Disturbances
figure
hold on;box on
xlabel('t [s]')
ylabel('v_0 [m/s]')

% Mean wind speeds for DLC 1.2
URef_v      = [4:2:24];
nURef       = length(URef_v);

% loop over wind speeds
for iURef = 1:nURef
    
    % Generate Rotor-Effective Wind Speed
    URef                        = URef_v(iURef);
    Parameter.TurbSim.URef      = URef;
    Parameter.TurbSim.RandSeed 	= URef; % to be different for every URef
    fprintf('Generating %d m/s!\n',URef)
    Disturbance                 = GenerateRotorEffectiveWindSpeed(windfield,Parameter);
    
    % plot and save
    plot(Disturbance.v_0.time,Disturbance.v_0.signals.values);
    drawnow
    save(['wind\URef_',num2str(URef,'%02d'),'_Disturbance'],'Disturbance','windfield','Parameter')    
    
end