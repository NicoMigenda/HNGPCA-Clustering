function unit = unit_learningrate(unit, mu)
  % Update the unit specific learning rate according to equation 2. We
  % refer to https://doi.org/10.1016/j.patcog.2023.110030 for details
  unit.gamma_bar = unit.gamma_bar*(1-mu) + mu * (unit.y.^2 - unit.eigenvalue);
  unit.eta_bar = unit.eta_bar*(1-mu) + mu * unit.y.^2;
  unit.l_bar = unit.l_bar*(1-mu) + mu * unit.eigenvalue;
  unit.learningRate = sum(abs(unit.gamma_bar ./ (unit.eta_bar + unit.l_bar))) / unit.m;
end