%%
load('total_table.mat')

% ========= Data reading section remains unchanged =========
file = '.\etopo2.nc';
lon  = double(ncread(file,'lon'));
lat  = double(ncread(file,'lat'));
topo0 = double(ncread(file,'topo'));
lon_min = 105;
lon_max = 125;
lat_min = 15.5;
lat_max = 24.5;
mask = [lon_min , lon_max; lat_min,lat_max];
lon_mask = find(lon >= mask(1, 1) & lon <= mask(1, 2));
lat_mask = find(lat >= mask(2, 1) & lat <= mask(2, 2));
topo_lon = lon(lon_mask);
topo_lat = lat(lat_mask);
topo = topo0(lon_mask, lat_mask); 
topo(topo>=0) = NaN;
[LON, LAT] = meshgrid(topo_lon, topo_lat);


 %%        
% ========= Custom color scheme =========
% Create colormap with specified colors (low-saturation scientific style)
custom_colors = [...
    0.00 0.24 0.49; % Deep navy blue (depth region)
    0.20 0.56 0.79; % Cobalt blue
    0.47 0.77 0.82; % Light sea blue
    0.94 0.95 0.85]; % Light米色 (shelf area)
cmap = interp1(linspace(0,1,4), custom_colors, linspace(0,1,256));

% ========= Globe-specific colormap1 (dark) =========
% Graded color scale for clear land-sea boundary (abrupt color change at 0)
earth_colors = [...
    % Ocean part (darkened version of main map, -6000 to 0)
    0.00 0.18 0.38   % Deep sea blue (darker than main map)
    0.15 0.42 0.65   % Medium deep sea blue
    0.35 0.68 0.78   % Light sea blue
    0.85 0.92 0.95   % Nearshore light blue (close to 0)
    
    % Land part (low-saturation earth tones, 0 to 6000)
    0.92 0.86 0.76   % Coastal light米色 (contrast with ocean light blue)
    0.72 0.62 0.46   % Tan
    0.50 0.42 0.32   % Dark brown
    0.35 0.28 0.21]; % Mountain dark brown
% Create segmented colormap (natural break at 0)
N = 256;
sea_level = 0.5; % Control abrupt color change position at sea level (0.5 = middle)
cmap_sea = interp1(linspace(0,1,4), earth_colors(1:4,:), linspace(0,sea_level,round(N/2)));
cmap_land = interp1(linspace(0,1,4), earth_colors(5:8,:), linspace(0,1,round(N/2)));
earth_cmap = [cmap_sea; cmap_land];

% % ========= Create globe-specific colormap2 (light) =========
% % Ocean part (-6000 to 0): Dark blue to light sea blue
% ocean_colors = [0.00 0.24 0.49;    % Deep navy blue
%                 0.20 0.56 0.79;    % Cobalt blue
%                 0.47 0.77 0.82];   % Light sea blue (ocean side at 0m)
% ocean_cmap = interp1(linspace(0,1,3), ocean_colors, linspace(0,1,128));
% % Land part (0 to 6000): Light米色 to dark brown
% land_colors = [0.94 0.95 0.85;    % Light米色 (land side at 0m)
%                0.85 0.70 0.50;    % Light brown
%                0.65 0.50 0.35;    % Medium brown
%                0.45 0.35 0.25];   % Dark brown
% land_cmap = interp1(linspace(0,1,4), land_colors, linspace(0,1,128));
% % Merge colormap and set caxis range
% earth_cmap = [ocean_cmap; land_cmap];

% ========= Graph initialization =========
f1 = figure('Color','w','Position',[100 100 1600 800],'Renderer','painters');
ax_main = axes('FontName','Arial','FontSize',15,'FontWeight','bold');

% ========= Topography rendering optimization =========
m_proj('Mercator','lat',[lat_min lat_max],'lon',[lon_min lon_max]);
h = m_pcolor(LON, LAT, topo');
shading interp
hold on 
colormap(cmap)
caxis([-6000 0]);

% ========= Professional colorbar setup =========
hcolorbar = colorbar('eastoutside','FontWeight','bold','FontSize',14,'FontName','Arial');
hcolorbar.Label.String = 'Depth (m)';
hcolorbar.Ticks = -6000:1000:0;
hcolorbar.TickLabels = arrayfun(@(x)sprintf('%d',abs(x)),hcolorbar.Ticks,'UniformOutput',false);

% ========= Lock first colormap and colorbar to prevent changes when setting the second =========
freezeColors;freezeColors(hcolorbar); % Lock colormap

% ========= Coastline style upgrade =========
m_gshhs_h('patch',[0.95 0.95 0.92],... % Light米色 land
    'EdgeColor','k',... % Black boundary
    'LineWidth',1.2);

% ========= Grid system optimization =========
m_grid('linestyle',':',...             % Dashed grid
      'xtick',lon_min:2:lon_max,...
      'ytick',lat_min+0.5:2:lat_max+0.5,...
      'FontSize',14,...
      'LineWidth',0.8,...
      'box','fancy',...
      'tickdir','in','FontWeight','bold','FontName','Arial');      % Inward ticks

% ========= Uniform annotation style =========
annotation_style = {'FontSize',16,'FontWeight','bold','Color',[0.3 0.3 0.3]};
m_text(121.3, 17.1, ["Luzon","Island"],...
    'HorizontalAlignment','center', annotation_style{:});
m_text(113, 23.8, ["Mainland", "China"],... % Adjust position
    'HorizontalAlignment','center', annotation_style{:});
m_text(106, 16.5, 'Vietnam',... % New Vietnam annotation
    'HorizontalAlignment','center', annotation_style{:});
m_text(107, 19.8, ["Beibu", "Gulf"],... % New Beibu Gulf annotation
    'HorizontalAlignment','center', annotation_style{:});
m_text(123.5, 18.5, ["Western",  "Pacific"],... % Adjust position
    'HorizontalAlignment','center','VerticalAlignment','middle','Color','k','FontSize',22,'FontWeight','bold');
m_text(115.5, 18.5, 'South China Sea',... % Adjust position
    'HorizontalAlignment','center','VerticalAlignment','middle','Color','k','FontSize',22,'FontWeight','bold');
m_text(121.3, 20.2, 'Luzon Strait',...
    'HorizontalAlignment','center','VerticalAlignment','middle','Color',[0.3 0.3 0.3],'FontSize',16,'FontWeight','bold');
m_text(120.8, 23.4, ["Taiwan","Island"],...
    'HorizontalAlignment','center','VerticalAlignment','middle','Color',[0.3 0.3 0.3],'FontSize',16,'FontWeight','bold');
m_text(109.5, 19, ["Hainan","Island"],...
    'HorizontalAlignment','center','VerticalAlignment','middle','Color',[0.3 0.3 0.3],'FontSize',16,'FontWeight','bold');


% Add subplot number (top-left corner)
text(0.02,0.97,'a','Units','normalized',...
    'FontSize',15,'FontWeight','bold','Color','k','BackgroundColor','None',...
    'VerticalAlignment','top','HorizontalAlignment','left');

% ========= Plot sampling points =========
% Scatter styles for six voyages
style_list = {'o', 's', '^', 'd', 'p', 'h'};
color_list = {[31, 119, 180]/255, [255, 127, 14]/255, [44, 160, 44]/255,...
             [214, 39, 40]/255, [148, 103, 189]/255, [140, 86, 75]/255};
markerSize = 70;
voyage_unique = unique(total_data.Voyage);
clear station_x station_y
for voyage_i = 1:length(voyage_unique)         
    voyage_item = voyage_unique{voyage_i};
    voyage_find = find(strcmp(total_data.Voyage, voyage_item));
    
    % Dynamically extract data
%     [station_x, station_y] = deal([]);
    [station_x, station_y, Station] = deal([]);
    for ii = 1:length(voyage_find)
        station_find = voyage_find(ii);
        station_x = [station_x; total_data(station_find,:).Longitude];
        station_y = [station_y; total_data(station_find,:).Latitude];
        Station = [Station; total_data(station_find,:).Station];
    end
           
    % ========= Sampling point style upgrade =========
%     station_color = [0.86 0.16 0.16]; % High-contrast red
    for ns=1:length(station_x)
        m_plot(station_x(ns), station_y(ns),...
            'Marker',style_list{voyage_i},...
            'MarkerSize',8,...
            'MarkerFaceColor',color_list{voyage_i},...
            'MarkerEdgeColor','w',...  % Carbon black
            'LineWidth',0.6);
%         m_text(station_x(ns), station_y(ns), Station(ns));
    end
    
    % ========= Add enclosing polygon for each voyage =========
    voyage_data = total_data(strcmp(total_data.Voyage, voyage_item),:);
    draw_voyage_hull(voyage_data, color_list{voyage_i}, voyage_item)
end

set(gca, 'fontsize', 10, 'FontName', 'Arial', 'FontWeight', 'bold');

% ========= Add globe =========
bias = 180;
ax_earth = axes('position',[0.05 0.60 0.3 0.3]); % Add colormap cmap=load('MPL_terrain.txt');
set_caxis = [-6000 6000];
add_sphere1(earth_cmap, set_caxis) % Use new colormap
% Colorbar
plot_red_box(lat_min, lat_max, lon_min-bias, lon_max-bias);  % Example: Enclose lat=[10,20], lon=[100,120]
% plot_orange_box(lat_box(1), lat_box(2), lon_box(1)-bias, lon_box(2)-bias);  % Example: Enclose lat=[10,20], lon=[100,120]
view(30,25);% View angles% view(x,y);% x controls horizontal rotation, y controls vertical rotation.

set(gca, 'fontsize', 10, 'FontName', 'Arial', 'FontWeight', 'bold');

% % ========= Output settings =========
set(f1,'position',[100 100 1600 800]); % 100,100: Bottom-left coordinate of the figure, 1000,600: Figure size
output_filepath = '.\figure\';
fileName = strcat(output_filepath, 'F1_topo.jpg');
exportgraphics(f1, fileName, 'Resolution',600, 'BackgroundColor','white');