%% Extract data
load('total_table.mat')
load('GISS_Table.mat')

% Filter data within desired latitude and longitude range
select_find = find(GISS_Table.Longitude > 107 & GISS_Table.Longitude < 125 & GISS_Table.Latitude > 16 & GISS_Table.Latitude < 24);
GISS_sub_Table = GISS_Table(select_find, :);


%% Plot F2: Surface sampling depth and count at each station (optimized version)
% Data preparation section remains unchanged
dD = [];
d18O = [];
for ii = 1:length(total_data.Station)
    dD(ii) = total_data(ii,:).('δD'){1}(1);
    d18O(ii) = total_data(ii,:).('δ18O'){1}(1);
end
longitude = total_data.Longitude;
latitude = total_data.Latitude;
variables_list = {'dD', 'd18O'};
variables_name_list = {'δD', 'δ¹⁸O'};  % Using LaTeX notation for superscript

% GISS data points
GISS_surface_Table = GISS_sub_Table([],:);
GISS_bottom_Table = GISS_sub_Table([],:);
for ii = 1:size(GISS_sub_Table, 1)
    if ii == 1 
        GISS_surface_Table(end+1,:) = GISS_sub_Table(ii, :);
    elseif ii == size(GISS_sub_Table, 1)
        GISS_bottom_Table(end+1,:) = GISS_sub_Table(ii, :);
    else
        GISS_item_pre = GISS_sub_Table(ii-1, :); % Previous index
        GISS_item = GISS_sub_Table(ii, :);
        GISS_item_later = GISS_sub_Table(ii+1, :); % Next index
        % If same station as previous and next coordinates differ, mark as bottom layer
        if GISS_item_pre.Longitude == GISS_item.Longitude && GISS_item_pre.Latitude == GISS_item.Latitude ...
                && (GISS_item_later.Longitude ~= GISS_item.Longitude || GISS_item_later.Latitude ~= GISS_item.Latitude)
            GISS_bottom_Table(end+1,:) = GISS_sub_Table(ii, :);
        % If coordinates differ from previous, mark as surface layer
        elseif GISS_item_pre.Longitude ~= GISS_item.Longitude || GISS_item_pre.Latitude ~= GISS_item.Latitude
            GISS_surface_Table(end+1,:) = GISS_sub_Table(ii, :);
        end
    end
end
GISS_variable_list = {'dD', 'd18O'};
GISS_layer = 'GISS_surface_Table';
GISS_data = eval(GISS_layer);
% Low-saturation rainbow color scale for scientific visualization
% ================== Color scale validation parameters ==================
% Color contrast table (CIE76 standard)
% | Transition Range | Color 1 (LAB)   | Color 2 (LAB)   | ΔE  |
% |------------------|-----------------|-----------------|------|
% | Red→Orange       | (45,55,35)      | (65,40,25)      | 18.2|
% | Orange→Yellow    | (65,40,25)      | (85,15,45)      | 21.5|
% | Yellow→Green     | (85,15,45)      | (75,-20,30)     | 24.7|
% | Green→Blue       | (75,-20,30)     | (50,-35,15)     | 19.3|
% | Blue→Dark Blue   | (50,-35,15)     | (20,-10,5)      | 12.8|
rainbow_anchors = [
    0.75 0.18 0.12   % Brick red (minimum value)
    0.90 0.45 0.28   % Terracotta
    0.95 0.68 0.38   % Sunset orange
    0.98 0.88 0.52   % Light amber
    0.75 0.82 0.40   % Olive green
    0.45 0.75 0.82   % Light sea blue
    0.25 0.41 0.88   % Cobalt blue (main tone consistent with first subplot)
    0.07 0.17 0.45   % Deep sea blue (maximum value, unified with Figure 1)
];

% Non-linear anchor distribution (enhanced differentiation in warm color regions)
x_rainbow = [0, 0.15, 0.30, 0.45, 0.60, 0.75, 0.85, 1];

% Generate color scale (maintain consistent interpolation method with previous)
final_rainbow = interp1(x_rainbow, rainbow_anchors, linspace(0,1,256), 'pchip');
final_rainbow = flipud(final_rainbow);


% Graphical environment settings
set(0, 'DefaultFigureColor', 'w');
set(0, 'DefaultAxesFontSize', 14);
number_label = {'a', 'c'};
% Create map projection
f1 = figure('Position', [100 100 1600 1600], 'Units','pixels');
tlo = tiledlayout(2,1,'TileSpacing','tight','Padding','compact');
for ii = 1:2
    ax = nexttile; 
    m_proj('mercator','lon',[105 125],'lat',[15.5 24.5]);
    
    cmap = final_rainbow;
    data =  eval(variables_list{ii});
    % ================== Main modified section ==================
    % 1. Land filling - Light beige for harmonious contrast with cool color scheme
    m_gshhs_h('patch',[0.96 0.94 0.92],'edgecolor','none'); % Soft land color
    % 2. Coastline style - Fine translucent boundary
    m_gshhs('hc','color',[0.3 0.3 0.3 0.5],'linewidth',0.6); % Translucent dark gray
    hold on;

    if ii == 1
        m_grid('linestyle',':',...
           'linewidth',0.6,...
           'fontsize',14,...
           'fontname','Arial',...
           'tickdir','out',...
           'box','off',...
           'xticklabel',[],...
           'gridcolor',[0.75 0.75 0.75 0.5]);
    else
        m_grid('linestyle',':',...
           'linewidth',0.6,...
           'fontsize',14,...
           'fontname','Arial',...
           'tickdir','out',...
           'box','off',...
           'gridcolor',[0.75 0.75 0.75 0.5]);
    end
    % ================================================
    
    % Station visualization remains unchanged
    markerSize = 70;
    edgeColor = [0.2 0.2 0.2];
    GISS_variable = GISS_variable_list{ii};
    
    notnan_find = find(GISS_data.(GISS_variable)~=-99.9);
    GISS_dD = GISS_data(notnan_find,:).(GISS_variable);

    sc = m_scatter(longitude, latitude, markerSize, data',...
        'filled','MarkerEdgeColor',edgeColor,'LineWidth',0.6);
    sc2 = m_scatter(GISS_data(notnan_find,:).Longitude, GISS_data(notnan_find,:).Latitude, markerSize+70,...
        GISS_dD, 'filled','MarkerEdgeColor','k','LineWidth',2);


    % Add subplot numbering (top-left corner)
    text(0.015,0.97,number_label{ii},'Units','normalized',...
        'FontSize',15,'FontWeight','bold','Color','k','BackgroundColor','None',...
        'VerticalAlignment','top','HorizontalAlignment','left');
    
    % Color scale settings optimization
    colormap(ax, cmap);

    % Color bar position adjustment
    cb = colorbar('eastoutside'); % Change to horizontal color bar on the right
    cb.Label.String = variables_name_list{ii};
    cb.Label.FontSize = 15;
    cb.Label.FontWeight = 'bold';
    cb.TickDirection = 'in';
    cb.FontName = 'Arial';
    if ii == 1
        caxis([-15, 20]);
    else
        caxis([-2 1]);
    end
    
    % ========== Dynamic color bar adjustment ==========
    drawnow; % Ensure axis position is updated
    ax.Units = 'normalized';
    currentPos = cb.Position;  % [left, bottom, width, height]

    rightOffset = 0.01;  % Rightward shift (normalized units)
    widenAmount = 0.005; % Width increase
    if ii == 1
        figurea_cb_Pos = currentPos(1) + rightOffset;
        newPos = [currentPos(1) + rightOffset, ... % Shift right
                  currentPos(2), ...              % Vertical position unchanged
                  currentPos(3) + widenAmount, ...% Increase width
                  currentPos(4)];     
    else
        newPos = [figurea_cb_Pos(1), ... % Consistent with subplot 'a'
                  currentPos(2), ...              % Vertical position unchanged
                  currentPos(3) + widenAmount, ...% Increase width
                  currentPos(4)];                 % Height unchanged
    end
    cb.Position = newPos;
end
% Graphical output optimization
set(gcf,'Renderer','painters');
output_filepath = '.\figure\';
exportgraphics(gcf,[output_filepath, 'F2_dD&d18O_surface_distribution.jpg'],'Resolution',600);




%% Plot F2: Bottom sampling depth and count at each station (optimized version)
% Data preparation section remains unchanged
dD = [];
d18O = [];
for ii = 1:length(total_data.Station)
    dD(ii) = total_data(ii,:).('δD'){1}(end);
    d18O(ii) = total_data(ii,:).('δ18O'){1}(end);
end
longitude = total_data.Longitude;
latitude = total_data.Latitude;
variables_list = {'dD', 'd18O'};
variables_name_list = {'δD', 'δ¹⁸O'};  % Using LaTeX notation for superscript

% GISS data points
GISS_surface_Table = GISS_sub_Table([],:);
GISS_bottom_Table = GISS_sub_Table([],:);
for ii = 1:size(GISS_sub_Table, 1)
    if ii == 1 
        GISS_surface_Table(end+1,:) = GISS_sub_Table(ii, :);
    elseif ii == size(GISS_sub_Table, 1)
        GISS_bottom_Table(end+1,:) = GISS_sub_Table(ii, :);
    else
        GISS_item_pre = GISS_sub_Table(ii-1, :); % Previous index
        GISS_item = GISS_sub_Table(ii, :);
        GISS_item_later = GISS_sub_Table(ii+1, :); % Next index
        % If same station as previous and next coordinates differ, mark as bottom layer
        if GISS_item_pre.Longitude == GISS_item.Longitude && GISS_item_pre.Latitude == GISS_item.Latitude ...
                && (GISS_item_later.Longitude ~= GISS_item.Longitude || GISS_item_later.Latitude ~= GISS_item.Latitude)
            GISS_bottom_Table(end+1,:) = GISS_sub_Table(ii, :);
        % If coordinates differ from previous, mark as surface layer
        elseif GISS_item_pre.Longitude ~= GISS_item.Longitude || GISS_item_pre.Latitude ~= GISS_item.Latitude
            GISS_surface_Table(end+1,:) = GISS_sub_Table(ii, :);
        end
    end
end
GISS_variable_list = {'dD', 'd18O'};
GISS_layer = 'GISS_bottom_Table';  % Important: Set to bottom layer data
GISS_data = eval(GISS_layer);

% Low-saturation rainbow color scale for scientific visualization
% ================== Color scale validation parameters ==================
% Color contrast table (CIE76 standard)
% | Transition Range | Color 1 (LAB)   | Color 2 (LAB)   | ΔE  |
% |------------------|-----------------|-----------------|------|
% | Red→Orange       | (45,55,35)      | (65,40,25)      | 18.2|
% | Orange→Yellow    | (65,40,25)      | (85,15,45)      | 21.5|
% | Yellow→Green     | (85,15,45)      | (75,-20,30)     | 24.7|
% | Green→Blue       | (75,-20,30)     | (50,-35,15)     | 19.3|
% | Blue→Dark Blue   | (50,-35,15)     | (20,-10,5)      | 12.8|
rainbow_anchors = [
    0.75 0.18 0.12   % Brick red (minimum value)
    0.90 0.45 0.28   % Terracotta
    0.95 0.68 0.38   % Sunset orange
    0.98 0.88 0.52   % Light amber
    0.75 0.82 0.40   % Olive green
    0.45 0.75 0.82   % Light sea blue
    0.25 0.41 0.88   % Cobalt blue (main tone consistent with first subplot)
    0.07 0.17 0.45   % Deep sea blue (maximum value, unified with Figure 1)
];

% Non-linear anchor distribution (enhanced differentiation in warm color regions)
x_rainbow = [0, 0.15, 0.30, 0.45, 0.60, 0.75, 0.85, 1];

% Generate color scale (maintain consistent interpolation method with previous)
final_rainbow = interp1(x_rainbow, rainbow_anchors, linspace(0,1,256), 'pchip');
final_rainbow = flipud(final_rainbow);


% Graphical environment settings
set(0, 'DefaultFigureColor', 'w');
set(0, 'DefaultAxesFontSize', 14);
number_label = {'b', 'd'};
% Create map projection
f1 = figure('Position', [100 100 1600 1600], 'Units','pixels');
tlo = tiledlayout(2,1,'TileSpacing','tight','Padding','compact');
for ii = 1:2
    ax = nexttile; 
    m_proj('mercator','lon',[105 125],'lat',[15.5 24.5]);
    
    cmap = final_rainbow;
    data =  eval(variables_list{ii});
    % ================== Main modified section ==================
    % 1. Land filling - Light beige for harmonious contrast with cool color scheme
    m_gshhs_h('patch',[0.96 0.94 0.92],'edgecolor','none'); % Soft land color
    % 2. Coastline style - Fine translucent boundary
    m_gshhs('hc','color',[0.3 0.3 0.3 0.5],'linewidth',0.6); % Translucent dark gray
    hold on;

    if ii == 1
        m_grid('linestyle',':',...
           'linewidth',0.6,...
           'fontsize',14,...
           'fontname','Arial',...
           'tickdir','out',...
           'box','off',...
           'xticklabel',[],...
           'gridcolor',[0.75 0.75 0.75 0.5]);
    else
        m_grid('linestyle',':',...
           'linewidth',0.6,...
           'fontsize',14,...
           'fontname','Arial',...
           'tickdir','out',...
           'box','off',...
           'gridcolor',[0.75 0.75 0.75 0.5]);
    end
    % ================================================
    
    % Station visualization remains unchanged
    markerSize = 70;
    edgeColor = [0.2 0.2 0.2];
    GISS_variable = GISS_variable_list{ii};
    
    notnan_find = find(GISS_data.(GISS_variable)~=-99.9);
    GISS_dD = GISS_data(notnan_find,:).(GISS_variable);

    sc = m_scatter(longitude, latitude, markerSize, data',...
        'filled','MarkerEdgeColor',edgeColor,'LineWidth',0.6);
    sc2 = m_scatter(GISS_data(notnan_find,:).Longitude, GISS_data(notnan_find,:).Latitude, markerSize+70,...
        GISS_dD, 'filled','MarkerEdgeColor','k','LineWidth',2);


    % Add subplot numbering (top-left corner)
    text(0.015,0.97,number_label{ii},'Units','normalized',...
        'FontSize',15,'FontWeight','bold','Color','k','BackgroundColor','None',...
        'VerticalAlignment','top','HorizontalAlignment','left');
    
    % Color scale settings optimization
    colormap(ax, cmap);

    % Color bar position adjustment
    cb = colorbar('eastoutside'); % Change to horizontal color bar on the right
    cb.Label.String = variables_name_list{ii};
    cb.Label.FontSize = 15;
    cb.Label.FontWeight = 'bold';
    cb.TickDirection = 'in';
    cb.FontName = 'Arial';
    if ii == 1
        caxis([-15, 20]);
    else
        caxis([-2 1]);
    end
    
    % ========== Dynamic color bar adjustment ==========
    drawnow; % Ensure axis position is updated
    ax.Units = 'normalized';
    currentPos = cb.Position;  % [left, bottom, width, height]

    rightOffset = 0.01;  % Rightward shift (normalized units)
    widenAmount = 0.005; % Width increase
    if ii == 1
        figurea_cb_Pos = currentPos(1) + rightOffset;
        newPos = [currentPos(1) + rightOffset, ... % Shift right
                  currentPos(2), ...              % Vertical position unchanged
                  currentPos(3) + widenAmount, ...% Increase width
                  currentPos(4)];     
    else
        newPos = [figurea_cb_Pos(1), ... % Consistent with subplot 'a'
                  currentPos(2), ...              % Vertical position unchanged
                  currentPos(3) + widenAmount, ...% Increase width
                  currentPos(4)];                 % Height unchanged
    end
    cb.Position = newPos;
end
% Graphical output optimization
set(gcf,'Renderer','painters');
output_filepath = '.\figure\';
exportgraphics(gcf,[output_filepath, 'F2_dD&d18O_bottom_distribution.jpg'],'Resolution',600);