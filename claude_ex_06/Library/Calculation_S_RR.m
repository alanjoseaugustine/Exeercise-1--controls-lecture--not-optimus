% -----------------------------
% Function: calculates the rotor effective wind speed spectrum for given 
% Kaimal wind field and turbine
% Based on 
% D. Schlipf, Lidar-Assisted Control Concepts for Wind Turbines, DOI: 10.18419/opus-8796.
% ------------
% Usage:
% [S_RR] = Calculation_S_RR(f,windfield,Parameter)
% ------------ 
% Input:
% * f                 - frequency vector [Hz]
% * windfield         - struct
%   .grid.Y         - y-Grid of the wind field [m]
%   .grid.Z         - z-Grid of the wind field [m]
% * Parameter         - struct
%   .TurbSim.URef   - mean (total) wind speed at the reference height [m/s]
%   .TurbSim.IRef   - reference turbulence intensity (e.g. 0.16 for Class A) [-]
% 	.Turbine.R      - Rotor radius of the turbine [m]
% ------------
% Output: 
% S_RR              - vector of the rotor effective wind speed spectrum
% ------------
% History:
% v01:	David Schlipf on 18-Nov-2019
% ----------------------------------

%% Code:
function [S_RR] = Calculation_S_RR(f,windfield,Parameter)

%% Internal variables 
URef                = Parameter.TurbSim.URef;
IRef                = Parameter.TurbSim.IRef;
R                   = Parameter.Turbine.R;
Y                   = windfield.grid.Y;
Z                   = windfield.grid.Z;

%% Kaimal spectrum
% from [IEC 61400-1 third edition 2005-08 Wind turbines - Part 1: Design requirements 2005]
Lambda_1            = 42;
L_1                 = 8.1   *Lambda_1;
b                   = 5.6;
sigma_1             = IRef*(0.75*URef+b);

L_c                 = L_1;
a                   = 12;
kappa               = a*((f/URef).^2+(0.12/L_c).^2).^0.5;
S_uu                = 4*L_1/URef./((1+6*f*L_1/URef).^(5/3))*sigma_1^2;

%% Points in rotor disc
DistanceFromHub     = (Z(:).^2+Y(:).^2).^0.5;
PointsInRotorDisc   = DistanceFromHub<=R;
nPoints             = length(DistanceFromHub);
nPointsInRotorDisc  = sum(PointsInRotorDisc);

%% Loop over all points
% initialization
SumGamma            = zeros(size(f));

% loop over ...
for iPoint=1:1:nPoints;                     % ... all iPoints
    if PointsInRotorDisc(iPoint)
        for jPoint=1:1:nPoints;             % ... all jPoints
            if PointsInRotorDisc(jPoint)
                Distance   	= ((Y(jPoint)-Y(iPoint))^2+(Z(jPoint)-Z(iPoint))^2)^0.5;
                SumGamma  	= SumGamma + exp(-kappa.*Distance);
            end
        end
     end
end

% sum over loop
S_RR = SumGamma.*S_uu/nPointsInRotorDisc^2;

end
