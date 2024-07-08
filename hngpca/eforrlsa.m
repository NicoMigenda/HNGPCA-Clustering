function [units] = eforrlsa(units)
    % EFORRLSA (Moeller, 2002)
    % Interlocking of learning and orthonormalization in RRLSA
    V = units.weight;
    EFO_L2 = zeros(units.m,1);
    EFO_p = zeros(units.m,1);
    EFO_q = zeros(units.m,units.m);
    EFO_r = zeros(units.m,units.m);
    %Algorithm Equations 3-12
    for i = 1:units.m    
        % Helpervariables
        % (1-Learningrate) * Eigenvalue
        helperVariable1 = (1-units.learningRate)*units.eigenvalue(i);
        % Learningrate * Output
        helperVariable2 = units.learningRate * units.y(i);
        
        % Init and update of t and d based on Equation 5+6
        if i == 1
            EFO_t = 0;
            EFO_d = units.x_c'*units.x_c;
        else
            EFO_t = EFO_t + EFO_p(i-1)*EFO_p(i-1);
            EFO_d = EFO_d - units.y(i-1)*units.y(i-1);
            if EFO_d < eps
               EFO_d = eps; 
            end
        end
        %Equation 7
        EFO_s = (helperVariable1+units.learningRate*EFO_d)*units.y(i);
        %Equation 8
        EFO_L2(i) = helperVariable1*helperVariable1 ...
            + helperVariable2 * (helperVariable1*units.y(i) + EFO_s);
        %Equation 9
        EFO_n2 = EFO_L2(i) - EFO_s*EFO_s*EFO_t;
        % ensure that EFO_n2 > 0
        if( EFO_n2 < eps )
            EFO_n2 = eps;
        end
        EFO_n = sqrt( EFO_n2 );
        %Equation 12
        EFO_p(i) = (helperVariable2 - EFO_s*EFO_t) / EFO_n;
        % Calculate the two additive terms in Equation 4
        units.weight(:,i) = EFO_p(i) * units.x_c;
        for i2 = 1:i
            %Equation 10+11
            if i2 < i 
                EFO_r(i,i2) = EFO_r(i-1,i2) + EFO_p(i-1)*EFO_q(i-1,i2);
                EFO_q(i,i2) = -(helperVariable2*units.y(i2)+EFO_s*EFO_r(i,i2)) / EFO_n;
            elseif i2 == i
                EFO_r(i,i2) = 0;
                EFO_q(i,i2) = helperVariable1 / EFO_n;
            else
                EFO_r(i,i2) = 0;
                EFO_q(i,i2) = 0;
            end
            % Equation 4
            units.weight(:,i) = units.weight(:,i) + EFO_q(i,i2) * V(:,i2);
        end
    end
    units.eigenvalue = sqrt(EFO_L2);
end

