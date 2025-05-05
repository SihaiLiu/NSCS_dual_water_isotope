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
% ========= Figure initialization =========
f1 = figure('Color','w','Position',[100 100 1600 800],'Renderer','painters');
ax_main = axes('FontName','Arial','FontSize',15,'FontWeight','bold');

% ========= Topography plotting optimization =========
m_proj('Mercator','lat',[lat_min lat_max],'lon',[lon_min lon_max]);
% h = m_pcolor(LON, LAT, topo');
% shading interp
hold on 
% colormap(cmap)
% caxis([-6000 0]);

% ========= Topographic contour lines plotting =========
levels = [-500, -500]; % Main contour lines + special topographic annotations
[C, h_contour] = m_contour(LON, LAT, topo', levels);
% hText = clabel(C, h_contour, 'FontSize', 14,'color','w',...
%     'BackgroundColor', 'none','LabelSpacing',1000,... % Translucent white background
%     'Margin', 2, 'FontName', 'Arial','Fontweight', 'bold');
set(h_contour, 'LineColor', 'w', 'LineWidth', 1.2)

% ========= Coastline style upgrade =========
m_gshhs_h('patch',[123, 154, 208]./256,... % Light beige land
    'EdgeColor','none',... % No color boundary
    'LineWidth',1.2);

% ========= Grid system optimization =========
m_grid('linestyle',':',...
           'linewidth',0.6,...
           'fontsize',14,...
           'fontname','Arial',...
           'tickdir','out',...
           'box','off',...
           'gridcolor','none','backcolor', [189, 207, 231]./256)


% % ========= Output settings =========
set(f1,'position',[100 100 1600 800]); % 100,100: Coordinates of bottom-left corner; 1000,600: Figure size
output_filepath = '.\figure\';
fileName = strcat(output_filepath, 'F5_map.jpg');
exportgraphics(f1, fileName, 'Resolution',600, 'BackgroundColor','white');