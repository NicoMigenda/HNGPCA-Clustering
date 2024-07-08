function y_pred = pred(obj, data)

% Find the closest unit to all data points. The resulting labels are used
% for both the NMI calculation and for the colored plots
len = size(data,1);
y_pred = zeros(len,1);
for z = 1:len
    x = data(z,:);
    r = [0,0];
    for i = obj.candidates
       k = obj.units{i}.parent_idx;
       obj.units{k} = find_winner(x', obj.units{k}, "N", obj.dataDimensionality);
       r(k,:) = [k, obj.units{k}.distance];
    end
    r = sortrows(r,2);
    y_pred(z) = r(1,1);
end

