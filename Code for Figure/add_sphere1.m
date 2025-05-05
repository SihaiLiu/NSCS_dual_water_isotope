function add_sphere1(cmap, set_caxis)
    load topo topo topomap1;  % Load data
    x = 0:359;                % Longitude
    y = -89:90;               % Latitude
    [X1, Y1] = meshgrid(x, y);
    x1 = 0:0.1:360;
    y1 = -89:0.1:90;
    [X, Y] = meshgrid(x1, y1);
    topo_new = griddata(X1, Y1, topo, X, Y);

    [x, y, z] = sphere(100);  % Create a sphere
    s = surface(x, y, z);     % Plot spherical surface
    s.FaceColor = 'texturemap'; % Use texture mapping
    s.CData = topo_new;        % Set color data to topographic data
    s.EdgeColor = 'none';      % Remove edges
    s.FaceLighting = 'gouraud'; % Preferred lighting for curved surfaces
    s.SpecularStrength = 0.4;  % Change the strength of reflected light

    if isempty(cmap)
        cmap = load('MPL_terrain.txt');
    else
        cmap = cmap;
    end

    caxis(set_caxis); % 设置完整的数值范围
    colormap(cmap);
    freezeColors;
    % light('Position', [1 0 1]);  % Add a light
    axis square off;               % Set axis to square and remove axis
    view([30, 10]);                % Set the viewing angle
end
