%% Extract data
load('total_table.mat')

%% T-S diagram by voyage
cfg = {'T', 'S', 'Depth'};
selected_source_station = {{{'C36'},{'C05'},{'C34'}},...
             {{'A1','A3','B1','B3','C1', 'C3', 'D1'},{'E1','E2','E3'},{'E21','E23','E24'}},...
             {{'38'},{'E1','E2','E3'},{'47', '49'}},...
             {{'BBW21'},{'E1','E2','E3'},{'BBW06','BBW07','BBW015','BBW13'}},...
             {{'L1','Z1','JZ2','JW2'},{'M13','M17'},{'JZ22','Z22'}},...
             {{'20'},{'11'},{'9'},{'27'}}}; % Selected stations

selected_source_depth = {{{[5, 1486]}, {[5, 2773]}, {[5, 3000]}},...
            {{[0, 9], [0, 10], [0, 9], [0, 10], [0, 5], [0, 10], [0, 10]}, {[0, 45], [0, 34], [0, 30]}, {[0, 50], [0, 50], [0, 50]}},...
            {{[0,25]},{[0, 45], [0, 34], [0, 30]}, {[0, 1604], [0, 990]}},...
            {{[0, 104]}, {[0, 45], [0, 34], [0, 30]}, {[0, 128], [0, 150], [0, 100], [0, 80]}},...
            {{[0, 6], [0, 24], [0, 8], [5, 10]}, {[0,45], [0, 36]}, {[0, 50], [0, 50]}},...
            {{[0, 29]}, {[0, 850]}, {[0, 340]}, {[5, 50]}}}; % Depth ranges corresponding to selected stations

selected_source_name = {{{'CC'},{'KW'},{'SCSW'}},...
             {{'DW'},{'WGCC'},{'SCSW'}},...
            {{'DW'},{'WGCC'},{'SCSW'}},...
            {{'DW'},{'WGCC'},{'SCSW'}},...
            {{'DW'},{'WGCC'},{'SCSW'}},...
            {{'DW'},{'SCSW'},{'KW'},{'CC'}}};

source_color = {[0.75 0.18 0.12],...   % Brick red
                [0.95 0.68 0.38],...   % Sunset orange
                [0.25 0.41 0.88],...  % Cobalt blue
                [0.00 0.24 0.49]};    % Deep navy blue

% Additional scatter parameters for WGCC
select_WGCC_flag = {[0,0,0], [0,0,0], [0,1,0], [0,1,0], [0,0,0], [0,0,0,0]}; % SBBG and QD use WGCC end-member from NBBG

% Plot selected grouped points in uniform colors, remaining points in black
voyage_unique = unique(total_data.Voyage);
f1 = figure('Position', [100 100 1600 800], 'Units','pixels');
tlo = tiledlayout(2,3,'TileSpacing','tight','Padding','compact');
clear WGCC_salt WGCC_temp

for voyage_i = 1:length(voyage_unique)
    voyage_item = voyage_unique{voyage_i};
    voyage_find = find(strcmp(total_data.Voyage, voyage_item));
    
    % Dynamically extract data
    [Temp, Salt, Lon, Lat, Depth, Station] = deal([]);
    for ii = 1:length(voyage_find)
        station_find = voyage_find(ii);
        valid_idx = ~isnan(total_data(station_find,:).(cfg{1}){1}) & ...
                   ~isnan(total_data(station_find,:).(cfg{2}){1});
        
        Temp = [Temp; total_data(station_find,:).(cfg{1}){1}(valid_idx)];
        Salt = [Salt; total_data(station_find,:).(cfg{2}){1}(valid_idx)];
        Depth = [Depth; total_data(station_find,:).(cfg{3}){1}(valid_idx)];
        Lon = [Lon; repmat(total_data(station_find,:).('Longitude'), [length(valid_idx), 1])];
        Lat = [Lat; repmat(total_data(station_find,:).('Latitude'), [length(valid_idx), 1])];
        Station = [Station; repmat(total_data(station_find,:).('Station'), [sum(valid_idx), 1])];
    end
    
    % Data cleaning
    valid_idx = ~isnan(Temp) & ~isnan(Salt);
    x_data = Temp(valid_idx);
    y_data = Salt(valid_idx);
    group_names = unique(Station);
    clear layers
    for i = 1:length(Station)
        layers{i} = sprintf('%s-%dm', Station{i}, Depth(i));
    end
    
    % Generate density grid data
    if strcmp(voyage_item, 'SBBG') || strcmp(voyage_item, 'QD')  % Add WGCC for SBBG and QD
        t_range = linspace(min([Temp; WGCC_temp])-0.5, max([Temp; WGCC_temp])+0.5, 100);
        s_range = linspace(min([Salt; WGCC_salt])-0.1, max([Salt; WGCC_salt])+0.1, 100);
    else
        t_range = linspace(min(Temp)-0.5, max(Temp)+0.5, 100);
        s_range = linspace(min(Salt)-0.1, max(Salt)+0.1, 100);
    end
    [T_grid, S_grid] = meshgrid(t_range, s_range);
    
    % Calculate density
    p = gsw_p_from_z(0, mean(Lon)); 
    SA = gsw_SA_from_SP(S_grid, p, mean(Lon), mean(Lat));
    CT = gsw_CT_from_pt(SA, T_grid);
    dens_grid = gsw_sigma0(SA, CT);
    
    % Plotting
    nexttile;
    hold on 
    
    % Plot end-member data (colored) and remaining data (gray)
    other_find = true(size(Station)); % Initialize all-true array
    for source_idx = 1:length(selected_source_station{voyage_i})
        station_item = selected_source_station{voyage_i}{source_idx};
        depth_item = selected_source_depth{voyage_i}{source_idx};
        name_item = selected_source_name{voyage_i}{source_idx};
        color_item = source_color{source_idx};
        source_logical = false(size(Station)); % Initialize all-false array
        
        for source_station_idx = 1:length(station_item)
            source_logical = source_logical | (strcmp(Station, station_item(source_station_idx)) &...
                        Depth<=depth_item{source_station_idx}(2) & Depth>=depth_item{source_station_idx}(1));
        end
        source_find = find(source_logical);
        
        if strcmp(voyage_item, 'NBBG') && strcmp(name_item, 'WGCC') % Save WGCC data for NBBG
            WGCC_salt = Salt(source_find);
            WGCC_temp = Temp(source_find);
            scatter(Salt(source_find), Temp(source_find), 80, color_item, 'filled','DisplayName', name_item{:});
        elseif select_WGCC_flag{voyage_i}(source_idx) == 1 % Plot saved WGCC data for SBBG and QD
            scatter(WGCC_salt, WGCC_temp, 80, color_item, 'filled','DisplayName', name_item{:});
        else
            scatter(Salt(source_find), Temp(source_find), 80, color_item, 'filled','DisplayName', name_item{:});
        end
        other_find = other_find & ~source_logical;
    end
    
    h_back = scatter(Salt(other_find), Temp(other_find), 50, [0.7 0.7 0.7], 'filled','HandleVisibility','off');
    uistack(h_back, 'bottom'); % Move background points to bottom
    
    lgd = legend('Location', 'southwest', 'FontWeight','bold', 'FontSize',12, 'Box','on', 'NumColumns',1);
    lgd.Title.String = voyage_item;
    
    % Isopycnal lines and labels
    [C, h] = contour(S_grid, T_grid, dens_grid,...
        'LineColor', [0.5 0.5 0.5], 'ShowText', 'on','HandleVisibility','off');
    clabel(C, h, 'FontSize', 14, 'labelspacing', 400, 'FontName', 'Times New Roman');
    
    set(gca, 'FontSize',12, 'TickDir','in', 'Box','on', 'LineWidth',1.2,'FontName','Arial');
end

% Add global axis labels
xlabel(tlo, 'Salinity', 'FontSize', 15, 'FontWeight','bold');
ylabel(tlo, 'Temperature (°C)', 'FontSize', 15, 'FontWeight','bold');
set(gca, 'FontSize',12, 'TickDir','in', 'Box','on', 'LineWidth',1.2,'FontName','Arial');

% Save figure
output_filepath = '.\figure\';
exportgraphics(gcf,[output_filepath, 'F4_T_S.jpg'],'Resolution',600);