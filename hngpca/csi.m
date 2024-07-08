function obj = csi(obj, eigenvalues, eigenvectors, gt)

%% CI_1
len = size(gt,1);
for z = 1:len
    % Sample center
    x = gt(z,:);
    % Reset ranking vector
    r = [0,0];
    % For each unborn child
    for i = obj.candidates
       % Get parent index, which is the lowest fully developed unit in a branch
       k = obj.units{i}.parent_idx;
       % Calculate potential function
       obj.units{k} = find_winner(x', obj.units{k}, "H", obj.dataDimensionality);
       r(k,:) = [k, obj.units{k}.distance];
    end
    r = sortrows(r, 2);
    winner(z) = r(1,1);
end
a = 1;
for i = obj.candidates
   k = obj.units{i}.parent_idx;
   parents(a) = k;
   a = a + 1;
   frequency(k) = sum(winner == k); % Assign the center to the winner unit
end
CI_1 = sum(frequency(parents) == 0); 

%% CI_2
winner = 0;
% Create a dummy unit that contains the properties of the given cluster, so
% that we can use the find_winner function for the ranking.
test_unit = struct;
for i = obj.candidates
    k = obj.units{i}.parent_idx;
    r = [0,0];
    for z = 1:len
        test_unit.center = gt(z,:)';
        test_unit.weight = eigenvectors{z};
        test_unit.eigenvalue = eigenvalues(z);
        test_unit.eigenvalue = diag(test_unit.eigenvalue{:});
        test_unit.m = size(gt,2);
        test_unit = find_winner(obj.units{k}.center, test_unit, "H", obj.units{k}.m);
        r(z,:) = [z, test_unit.distance];
    end
    r = sortrows(r, 2);
    winner(k) = r(1,1);
end

frequency = 0;
for i = 1 : len
   frequency(i) = sum(winner == i); 
end
CI_2 = sum(frequency == 0); 

obj.centroidIndex = max(CI_1, CI_2);