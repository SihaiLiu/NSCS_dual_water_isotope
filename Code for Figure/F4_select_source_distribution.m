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

selected_source_station = {
     {{'38'},{'E1','E2','E3'},{'47', '49'}},...
     {{'C36'},{'C05'},{'C34'}},...
     {{'A1','A3','B1','B3','C1', 'C3', 'D1'},{'E1','E2','E3'},{'E21','E23','E24'}},...
     {{'20'},{'11'},{'9'},{'27'}},...
     {{'BBW21'},{'E1','E2','E3'},{'BBW06','BBW07','BBW015','BBW13'}},...
     {{'L1','Z1','JZ2','JW2'},{'M13','M17'},{'JZ22','Z22'}}}; % 选取的站点
selected_source_depth = {
    {{[0,25]},{[0, 45], [0, 34], [0, 30]}, {[0, 1604], [0, 990]}},...
    {{[5, 1486]}, {[5, 2773]}, {[5, 3000]}},...
    {{[0, 9], [0, 10], [0, 9], [0, 10], [0, 5], [0, 10], [0, 10]}, {[0, 45], [0, 34], [0, 30]}, {[0, 50], [0, 50], [0, 50]}},...
    {{[0, 29]}, {[0, 850]}, {[0, 340]}, {[5, 50]}},...
    {{[0, 104]}, {[0, 45], [0, 34], [0, 30]}, {[0, 128], [0, 150], [0, 100], [0, 80]}},...
    {{[0, 6], [0, 24], [0, 8], [5, 10]}, {[0,45], [0, 36]}, {[0, 50], [0, 50]}}}; % 选取的站点对应的深度范围
selected_source_name = {
    {{'DW'},{'WGCC'},{'SCSW'}},...
    {{'CC'},{'KW'},{'SCSW'}},...
    {{'DW'},{'WGCC'},{'SCSW'}},...
    {{'DW'},{'SCSW'},{'KW'},{'CC'}},...
    {{'DW'},{'WGCC'},{'SCSW'}},...
    {{'DW'},{'WGCC'},{'SCSW'}}}; 

% ========= Color allocation optimization =========
% Extract all unique source names and generate color mapping
all_names = cellfun(@(x) [x{:}], [selected_source_name{:}], 'UniformOutput', false);
[unique_names, ~, idx] = unique(all_names);
colors = lines(numel(unique_names)); % Generate unique colors using lines colormap
name_color_map = containers.Map(unique_names, num2cell(colors, 2)); 

% ========= Figure initialization =========
f1 = figure('Color','w','Position',[100 100 1600 800],'Renderer','painters');
ax_main = axes('FontName','Arial','FontSize',15,'FontWeight','bold');

% ========= Topography plotting optimization =========
m_proj('Mercator','lat',[lat_min lat_max],'lon',[lon_min lon_max]);
hold on 

% ========= Topographic contour plotting =========
levels = [-500, -100];
[C, h_contour] = m_contour(LON, LAT, topo', levels);
hText = clabel(C, h_contour, 'FontSize', 18,'color','k',...
    'BackgroundColor', 'none','LabelSpacing',700,...
    'Margin', 2, 'FontName', 'Arial','Fontweight', 'bold');
set(h_contour, 'LineColor', [0.4 0.4 0.4], 'LineWidth', 1.2)

% ========= Coastline style upgrade =========
m_gshhs_h('patch',[0.95 0.95 0.92],'EdgeColor','k','LineWidth',1.2);

% ========= Grid system optimization =========
m_grid('linestyle',':','linewidth',0.6,'fontsize',14,'fontname','Arial',...
       'tickdir','out','box','off','gridcolor',[0.75 0.75 0.75 0.5]);

% ========= Legend initialization =========
style_list = {'o', 's', '^', 'd', 'p', 'h'};
color_list = {[31, 119, 180]/255, [255, 127, 14]/255, [44, 160, 44]/255,...
             [214, 39, 40]/255, [148, 103, 189]/255, [140, 86, 75]/255};
legend_handles = [];
legend_names = {};

voyage_unique = unique(total_data.Voyage);
% ========= Plot sampling points =========
for voyage_i = 1:length(voyage_unique)         
    voyage_item = voyage_unique{voyage_i};
    voyage_find = find(strcmp(total_data.Voyage, voyage_item));
    
    % Extract current voyage station coordinates
    [station_x, station_y, Station] = deal([]);
    for ii = 1:length(voyage_find)
        station_find = voyage_find(ii);
        station_x = [station_x; total_data(station_find,:).Longitude];
        station_y = [station_y; total_data(station_find,:).Latitude];
        Station = [Station; total_data(station_find,:).Station];
    end
    
    % Plot basic sampling points (black border)
    for ns=1:length(station_x)
        m_plot(station_x(ns), station_y(ns),...
            'Marker',style_list{voyage_i},...
            'MarkerSize',8,...
            'MarkerFaceColor','k',...
            'MarkerEdgeColor','w',...
            'LineStyle','none',...
            'HandleVisibility','off');
    end
    
    % Plot special source points and manage legend
    for source_idx = 1:length(selected_source_station{voyage_i})
        % Get current source info
        station_item = selected_source_station{voyage_i}{source_idx};
        name_item = selected_source_name{voyage_i}{source_idx}{1};
        color_item = name_color_map(name_item);
        
        % Find matching stations
        source_find = find(ismember(Station, station_item));
        
        % Dynamically manage legend entries
        if ~ismember(name_item, legend_names)
            h = m_plot(station_x(source_find), station_y(source_find),...
                'o','MarkerSize',8,...
                'MarkerFaceColor',color_item,...
                'MarkerEdgeColor','none',...
                'LineStyle','none',...
                'DisplayName',name_item);
            legend_handles = [legend_handles; h];
            if ~isempty(h)
                legend_names = [legend_names; name_item];
            end
        else
            m_plot(station_x(source_find), station_y(source_find),...
                'o','MarkerSize',8,...
                'MarkerFaceColor',color_item,...
                'MarkerEdgeColor','none',...
                'LineStyle','none',...
                'HandleVisibility','off');
        end
    end
    
    % Plot voyage hull (maintain original logic)
    voyage_data = total_data(strcmp(total_data.Voyage, voyage_item),:);
    draw_voyage_hull(voyage_data, color_list{voyage_i}, voyage_item)
end

% ========= Optimize legend display =========
lgd = legend(legend_handles, 'Location', 'southeast',...
    'FontWeight','bold', 'FontSize',15, 'Box','on', 'NumColumns',1);
lgd.Title.String = 'End-member';
set(gca, 'fontsize', 10, 'FontName', 'Arial', 'FontWeight', 'bold');

% ========= Output settings =========
output_filepath = '.\figure\';
fileName = strcat(output_filepath, 'F4_select_source_distribution.jpg');
exportgraphics(f1, fileName, 'Resolution',600, 'BackgroundColor','white');