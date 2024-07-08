function unit = unit_learningrate(unit, mu)
  % Update the unit specific learning rate according to equation 2. We
  % refer to https://doi.org/10.1016/j.patcog.2023.110030
  unit.mt = unit.mt*(1-mu) + mu * (unit.y.^2 - unit.eigenvalue);
  unit.y_bar = unit.y_bar*(1-mu) + mu * unit.y.^2;
  unit.l_bar = unit.l_bar*(1-mu) + mu * unit.eigenvalue;
  unit.learningRate = sum(abs(unit.mt ./ (unit.y_bar + unit.l_bar))) / unit.m;
end