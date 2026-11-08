% -----------------------------
% Script: Performs a fine tuning of the set-point-fading.
% Exercise 06 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ----------------------------------
clearvars;close all;clc;
addpath(genpath('..\Library\'))

%% PreProcessing SLOW

% Default Parameter Turbine and Controller
Parameter                       = NREL5MWDefaultParameter_SLOW2DOF;
Parameter                       = NREL5MWDefaultParameter_FBSWE_SetPointFading_Part2(Parameter);

% Time
Parameter.Time.dt             	= 0.1;         	% [s]   simulation time step            
Parameter.Time.TMax           	= 3600;        	% [s]   simulation length

% Postprocessing Parameter
C                               = 2/sqrt(pi)*10;% [m/s] TC I
k                               = 2;            % [-]
WoehlerExponent                 = 4;            % [-]   for steel
N_REF                           = 2e6/(20*8760);% [-]   fraction of 2e6 in 20 years for 1h

% SteadyStates
SteadyStates = load('SteadyStatesNREL5MW_FBSWE_SLOW','v_0','Omega','theta','x_T','M_g');

%% DLC 1.2
% Mean wind speeds for DLC 1.2
URef_v          = [4:2:24];
nURef           = length(URef_v);
Delta_P_v       = [3:1:7]*1e6;        % Values for Delta P to test
nDelta_P        = length(Delta_P_v);
Distribution    = k/C*(URef_v/C).^(k-1).*exp(-(URef_v/C).^k);
Weights         = Distribution/sum(Distribution); % relative frequency

for iDelta_P = 1:nDelta_P
    
    % Adjust Delta_P for this iDelta_P
    Parameter.SPF.Delta_P       = Delta_P_v(iDelta_P);
    
    for iURef = 1:nURef
        
        % Load wind speed
        URef                	= URef_v(iURef);
        load(['wind\URef_',num2str(URef,'%02d'),'_Disturbance'],'Disturbance')
        
        % Initial Conditions from SteadyStates
        Parameter.IC.Omega      = interp1(SteadyStates.v_0,SteadyStates.Omega   ,URef,'linear','extrap');
        Parameter.IC.theta   	= interp1(SteadyStates.v_0,SteadyStates.theta   ,URef,'linear','extrap');
        Parameter.IC.x_T    	= interp1(SteadyStates.v_0,SteadyStates.x_T     ,URef,'linear','extrap');
        Parameter.IC.M_g     	= interp1(SteadyStates.v_0,SteadyStates.M_g     ,URef,'linear','extrap');
        
        % Processing SLOW
        fprintf('Simulating %02d m/s for iDelta_P=%d!\n',URef,iDelta_P)
        sim('NREL5MW_FBSWE_SLOW2DOF_SetPointFading_Part2')
        
        % Collect statistics
        Omega_max(iURef)        = max(logsout.get('y').Values.Omega.Data);
        P_mean(iURef)           = mean(logsout.get('y').Values.P_el.Data);
        c                       = rainflow(logsout.get('y').Values.M_yT.Data);
        Count                   = c(:,1);
        Range                   = c(:,2);
        DEL_MyT(iURef)          = (sum(Range.^WoehlerExponent.*Count)/N_REF).^(1/WoehlerExponent);       
    end
    
    % Calculate Annual energy production and lifetime-weighted DEL
    % Annual energy production [Wh]: mean power of each wind speed x 8760 h x its probability of occurrence
    AEP(iDelta_P)  = 8760*sum(P_mean.*Weights);
    % Lifetime-weighted damage equivalent load [Nm]: Miner's sum over all wind speeds, weighted by Weights
    DEL(iDelta_P)  = (sum(DEL_MyT.^WoehlerExponent.*Weights)).^(1/WoehlerExponent);
    
end


%% Plot Brute Force Optimization Results
figure
subplot(211)
box on; hold on
plot(Delta_P_v/1e6,AEP/1e9,'.-','Markersize',20)
ylabel('AEP [GWh]')
xlabel('\Delta P [MW]')
subplot(212)
box on; hold on
plot(Delta_P_v/1e6,DEL/1e6,'.-','Markersize',20)
plot([min(Delta_P_v) max(Delta_P_v)]/1e6,[1 1]*42,'k')
ylabel('DEL(M_{yT}) [MNm]')
xlabel('\Delta P [MW]')

%% Select optimal Delta_P: highest AEP among all Delta_P with lifetime-weighted tower DEL below 42 MNm
feasible = find(DEL < 42e6);
if isempty(feasible)
    warning('No Delta_P keeps the tower DEL below 42 MNm. Extend Delta_P_v.')
else
    [AEP_best,j]    = max(AEP(feasible));
    Delta_P_best    = Delta_P_v(feasible(j));
    fprintf('Optimal Delta_P = %.1f MW: AEP = %.4f GWh, DEL = %.2f MNm\n', Delta_P_best/1e6, AEP_best/1e9, DEL(feasible(j))/1e6)
end
