function obj = drawupdate(obj)
%-------------------------------------------------------------------------%
% DRAWING FUNCTION                                                        %
%-------------------------------------------------------------------------%

units_to_plot = [];
% Loop through the tree and find the lowest level of fully developed units
% in each branch, which are then used to plot.
for k = 1 : obj.numberUnits
    if obj.units{k}.image_handle ~= 0
        delete(obj.units{k}.image_handle);
        delete(obj.units{k}.dim_handle);
    end
    if obj.units{k}.child_idx == 0
        units_to_plot(length(units_to_plot)+1) = obj.units{k}.parent_idx;
    end
end
units_to_plot = unique(units_to_plot);

for k = units_to_plot
    % Form the upper left 2x2 submatrix of the covariance matrix from the eigenvalues and eigenvectors
    sub_matrix = obj.units{k}.weight(1:2,:) * (obj.units{k}.eigenvalue .* obj.units{k}.weight(1:2,:)');
    if obj.dataDimensionality ~= 2
         sub_matrix = sub_matrix + ...
            obj.units{k}.sigma/(obj.dataDimensionality - obj.units{k}.m) * ( eye(2) - obj.units{k}.weight(1:2,:) * obj.units{k}.weight(1:2,:)' );
    end
    % determine the eigenvectors and eigenvalues of this submatrix (dimension 2), 
    % use these to draw the projected ellipse (without drawing them as axes)
    [eigenvectors_new,eigenvalues_new] = eig(sub_matrix); 
    % Get diag elements
    eigenvalues_new = diag(eigenvalues_new);
    % Get the 2 largest eigenvalues
    [~, idx] = maxk(obj.units{k}.eigenvalue, 2);
    % Get the corresponding eigenvectors
    w = obj.units{k}.weight(1:2,idx);
    scale = sqrt(obj.units{k}.eigenvalue(idx));
    % Plot the unit
    obj.units{k}.image_handle = plot_ellipse(eigenvectors_new, sqrt(eigenvalues_new(1:2)), obj.units{k}.center(1:2), w, scale);
    % Plot the Unit index and dimensionality next to center
    obj.units{k}.dim_handle = text(obj.units{k}.center(1),obj.units{k}.center(2), sprintf('%u(%u)', k,obj.units{k}.m), 'Color', 'r','FontSize',14);
end

pause(0.001)
