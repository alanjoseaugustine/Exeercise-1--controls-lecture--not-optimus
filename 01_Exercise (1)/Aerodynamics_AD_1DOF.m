% -----------------------------
% Function: Calculates aerodynamic torque based on the "actuator
% disk" approach from [2].
% ------------
% Input:
% - x           vector of states 
% - v_0         scalar of rotor-effective wind speed
% - Parameter   struct of Parameters
% ------------
% Output:
% - M_a         scalar of aerodynamic torque
% ----------------------------------
function M_a = Aerodynamics_AD_1DOF(Omega,theta,v_0,Parameter)

% internal parameters to make code easier to read
R           = Parameter.Turbine.R;
rho         = Parameter.General.rho;

% Equation (3.10) in [2]
lambda      = (Omega*R)/v_0;

% power and thrust coefficient
c_P         = interp2(Parameter.AD.theta,Parameter.AD.lambda,Parameter.AD.c_P,theta,lambda);

% Equation (3.9) in [2]
M_a         = 1/2*rho*pi*R^2*(c_P/Omega)*v_0^3;

end