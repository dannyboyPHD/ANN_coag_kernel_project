function [mfp,mu] = ideal_gas_constraints(T)
kb = 1.380649*10^-23; % J/K
m_air = 28.96*10^3/(6*10^23); %g/mol
d = 4*10^-10; %m
p= 1.013*10^5; %Pa atm assume incompressible flow, althouh can be varying density


mfp(:) = kb*T(:)/(2^0.5*p*pi*d^2);
mu = ((4*kb*m_air*T(:))./(9*pi^3*d^4)).^0.5;

end

