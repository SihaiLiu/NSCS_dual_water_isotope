% ========= Function to automatically generate enclosing polygon =========
function draw_voyage_hull(voyage_data, color, voyage_name)
    % Remove duplicate stations
    [unique_coords, ~] = unique([voyage_data.Longitude, voyage_data.Latitude], 'rows');
    if size(unique_coords,1) < 3
        return % Do not draw enclosing polygon if fewer than 3 points
    end
    
    % Calculate convex hull
    k = convhull(unique_coords(:,1), unique_coords(:,2));
    hull_lon = unique_coords(k,1);
    hull_lat = unique_coords(k,2);
    
    % Draw enclosing polygon
    m_plot(hull_lon, hull_lat, '--',...
        'Color', color,...
        'LineWidth', 1.5,...
        'MarkerSize', 10,'HandleVisibility','off');
    
    % Automatically determine label position (using the easternmost position)
    [max_lon, idx] = max(unique_coords(:,1));
    label_lon = max_lon + 0.2;
    label_lat = unique_coords(idx,2) + 0.1;
    
    % Add voyage label
    m_text(label_lon, label_lat, voyage_name,...
        'Color', color,...
        'FontSize', 12,...
        'FontWeight', 'bold',...
        'VerticalAlignment','middle',...
        'BackgroundColor',[1 1 1 0.7],'HandleVisibility','off');
end