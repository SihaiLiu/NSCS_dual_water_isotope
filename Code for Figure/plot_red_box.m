function plot_red_box(lat1, lat2, lon1, lon2)
    n = 200;  % Number of sampling points

    %===== 1) lat = lat1, lon from lon1 to lon2 =====
    lat = lat1 * ones(1,n);
    lon = linspace(lon1, lon2, n);
    [x, y, z] = sph2xyz(lat, lon);
    hold on; plot3(x, y, z, 'r', 'LineWidth', 2);

    %===== 2) lat = lat2, lon from lon1 to lon2 =====
    lat = lat2 * ones(1,n);
    lon = linspace(lon1, lon2, n);
    [x, y, z] = sph2xyz(lat, lon);
    plot3(x, y, z, 'r', 'LineWidth', 2);

    %===== 3) lon = lon1, lat from lat1 to lat2 =====
    lat = linspace(lat1, lat2, n);
    lon = lon1 * ones(1,n);
    [x, y, z] = sph2xyz(lat, lon);
    plot3(x, y, z, 'r', 'LineWidth', 2);

    %===== 4) lon = lon2, lat from lat1 to lat2 =====
    lat = linspace(lat1, lat2, n);
    lon = lon2 * ones(1,n);
    [x, y, z] = sph2xyz(lat, lon);
    plot3(x, y, z, 'r', 'LineWidth', 2);

    hold off;
end

%% Spherical coordinate conversion function
function [x, y, z] = sph2xyz(lat_deg, lon_deg)
    % Convert latitude/longitude (бу) to radians
    lat = deg2rad(lat_deg);
    lon = deg2rad(lon_deg);
    % Unit spherical coordinate system
    x = cos(lat).*cos(lon);
    y = cos(lat).*sin(lon);
    z = sin(lat);
end