%% Extract data
load('total_table.mat')

%% Plot F2: Sampling depth and count at each station (optimized version)
% Data preparation section remains unchanged
Bot_depth = [];
Station_counter = [];
for ii = 1:length(total_data.Station)
    Bot_depth(ii) = total_data(ii,:).('Bot.'){1}(1);
    Station_counter(ii) = length(total_data(ii,:).('Bot.'){1});
end
longitude = total_data.Longitude;
latitude = total_data.Latitude;
variables_list = {'Station_counter', 'Bot_depth'};
variables_name_list = {'Sample layer count', 'Depth (m)'};
% Color scale for the first subplot (cool color scheme)
custom_map1 = [
    0.85 0.85 0.85  % Light gray
    0.62 0.71 0.84  % Sky blue
    0.25 0.41 0.88  % Cobalt blue
    0.07 0.17 0.45  % Deep sea blue
];

% ================== Improved second color scale ==================
% Segmented color scale design (four distinct transitions in the 0-500 range)
color_anchors = [
    0.98 0.96 0.92   % Very light off-white (0)
    0.95 0.85 0.70   % Light sand (100)
    0.90 0.70 0.50   % Terracotta orange (200)
    0.85 0.55 0.35   % Ochre orange (300)
    0.80 0.40 0.20   % Deep ochre (400)
    0.75 0.30 0.15   % Volcanic red (500)
    0.65 0.20 0.10   % Brownish red (1000)
    0.55 0.15 0.08   % Deep brownish red (5000)
];

% Non-linear anchor point distribution (enhanced density in low-value regions)
x_pos = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.7, 1]; % Corresponding to 0,100,200,300,400,500,1000,5000

% Use pchip interpolation to maintain sharp transitions
final_map2 = interp1(x_pos, color_anchors, linspace(0,1,256), 'pchip');

% Generate smooth color scale
final_map1 = interp1(linspace(0,1,size(custom_map1,1)), custom_map1, linspace(0,1,256));
% final_map2 = interp1(linspace(0,1,size(custom_map2,1)), custom_map2, linspace(0,1,256));


% Graphical environment settings
set(0, 'DefaultFigureColor', 'w');
set(0, 'DefaultAxesFontSize', 14);

% Create map projection
f1 = figure('Position', [100 100 1600 800], 'Units','pixels');
tlo = tiledlayout(1,2,'TileSpacing','tight','Padding','compact');
for ii = 1:2
    ax = nexttile; 
    m_proj('mercator','lon',[105 125],'lat',[15.5 24.5]);
    
    % Dynamic color scale setup
    if ii == 1
        cmap = final_map1;
%         markerColor = [0.25 0.41 0.88]; % Consistent with main color of color scale
    else
        cmap = final_map2;
%         markerColor = [0.82 0.40 0.12]; % Main color of warm color scheme
    end
    
    data =  eval(variables_list{ii});
    % ================== Main modified section ==================
    % 1. Land filling - Light beige for harmonious contrast with cool color scheme
    % m_coast('patch',[0.96 0.94 0.92],'edgecolor','none'); % Soft off-white fill
    m_gshhs_h('patch',[0.95 0.95 0.95],'EdgeColor',[0.6 0.6 0.6]); % Soft land color
%     % 2. Coastline style - Fine translucent boundary
%     m_gshhs('hc','color',[0.3 0.3 0.3 0.5],'linewidth',0.6); % Translucent dark gray
    hold on;

    if ii == 1
        m_grid('linestyle',':',...
           'linewidth',0.6,...
           'fontsize',14,...
           'fontname','Arial',...
           'tickdir','out',...
           'box','fancy',...
           'gridcolor',[0.75 0.75 0.75 0.5]);
    else
        m_grid('linestyle',':',...
           'linewidth',0.6,...
           'fontsize',14,...
           'fontname','Arial',...
           'tickdir','out',...
           'box','fancy',...
           'yticklabel',[],...
           'gridcolor',[0.75 0.75 0.75 0.5]);
    end
    % ================================================
    
    % Station visualization remains unchanged
    markerSize = 70;
    edgeColor = [0.2 0.2 0.2];
    if ii == 1
        sc = m_scatter(longitude, latitude, markerSize, data',...
            'filled','MarkerEdgeColor',edgeColor,'LineWidth',0.6);
    else
        sc = m_scatter(longitude, latitude, markerSize, log(data'),...
        'filled','MarkerEdgeColor',edgeColor,'LineWidth',0.6);
    end

    % Add subplot numbering (top-left corner)
    text(0.02,0.97,[char('b'+ii-1)],'Units','normalized',...
        'FontSize',15,'FontWeight','bold','Color','k','BackgroundColor','None',...
        'VerticalAlignment','top','HorizontalAlignment','left');
    
    % Color scale settings optimization
    colormap(ax, cmap);

    % Color bar position adjustment
    cb = colorbar('southoutside'); % Change to horizontal color bar at bottom
    % cb.Position = [0.25 0.08 0.5 0.02]; % Precise position control
    cb.Label.String = variables_name_list{ii};
    cb.Label.FontSize = 20;
    cb.Label.FontWeight = 'bold';
    cb.TickDirection = 'in';
    cb.FontName = 'Arial';
    if ii == 1
        caxis([floor(min(data)) ceil(max(data))]);
    else
%         caxis([0 6000])
        % Set non-linear color bar ticks
        cb_tick_list = [0 50 250 500 1000 2500 6000];
        cb.Ticks = log(cb_tick_list); 
        cb.TickLabels = arrayfun(@(x) sprintf('%.0f',x), cb_tick_list, 'uni',0);
    end
    
    % ========== Dynamic color bar adjustment ==========
    % Force layout calculation completion (cb position will change without refresh)
%     drawnow; % Ensure axis position is updated
    % Get current axis position (normalized units)
    ax.Units = 'normalized';

end
% cb.Ticks = linspace(caxis(1),caxis(2),5);
% m_ruler([0.05 0.2], 0.85, 'units', 'km'); % Scale bar
% Graphical output optimization
set(gcf,'Renderer','painters');
% exportgraphics(gcf,'Final_Map.png','Resolution',600);
% Save image
output_filepath = '.\figure\';
exportgraphics(gcf,[output_filepath, 'F2_count&depth.jpg'],'Resolution',600);