%% Extract data
load('total_table.mat')

%% Plot the first row - Finding and correcting water isotope anomalies
load('correction_records.mat')
load('WGCC_source.mat')
% Keep only four regions and arrange in a 3x4 grid plot.

cfg = {'δD', 'δ18O', 'Depth', 'd_excess', 'S'};

% Order: EH LZ NBBG PRE SBBG WG
selected_source_station = {
     {{'38'},{'E1','E2','E3'},{'47', '49'}},...
     {{'C36'},{'C05'},{'C34'}},...
     {{'A1','A3','B1','B3','C1', 'C3', 'D1'},{'E1','E2','E3'},{'E21','E23','E24'}},...
     {{'20'},{'11'},{'9'},{'27'}},...
     {{'BBW21'},{'E1','E2','E3'},{'BBW06','BBW07','BBW015','BBW13'}},...
     {{'L1','Z1','JZ2','JW2'},{'M13','M17'},{'JZ22','Z22'}}}; % Selected stations
selected_source_depth = {
    {{[0,25]},{[0, 45], [0, 34], [0, 30]}, {[0, 1604], [0, 990]}},...
    {{[5, 1486]}, {[5, 2773]}, {[5, 3000]}},...
    {{[0, 9], [0, 10], [0, 9], [0, 10], [0, 5], [0, 10], [0, 10]}, {[0, 45], [0, 34], [0, 30]}, {[0, 50], [0, 50], [0, 50]}},...
    {{[0, 29]}, {[0, 850]}, {[0, 340]}, {[5, 50]}},...
    {{[0, 104]}, {[0, 45], [0, 34], [0, 30]}, {[0, 128], [0, 150], [0, 100], [0, 80]}},...
    {{[0, 6], [0, 24], [0, 8], [5, 10]}, {[0,45], [0, 36]}, {[0, 50], [0, 50]}}}; % Depth ranges for selected stations
selected_source_name = {
    {{'DW'},{'WGCC'},{'SCSW'}},...
    {{'CC'},{'KW'},{'SCSW'}},...
    {{'DW'},{'WGCC'},{'SCSW'}},...
    {{'DW'},{'SCSW'},{'KW'},{'CC'}},...
    {{'DW'},{'WGCC'},{'SCSW'}},...
    {{'DW'},{'WGCC'},{'SCSW'}}};
% Additional scatter parameters for WGCC
select_WGCC_flag = {[0,1,0], [0,0,0], [0,0,0], [0,0,0,0], [0,1,0], [0,0,0]}; % SBBG and QD use WGCC end-member from NBBG      
source_color = {[0.75 0.18 0.12],...   % Brick red
                [0.95 0.68 0.38],...   % Sunset orange
                [0.25 0.41 0.88],...  % Cobalt blue
                [0.00 0.24 0.49]};    % Navy blue

voyage_unique = unique(total_data.Voyage);
% Initialize anomaly record structure
anomaly_records = cell(length(voyage_unique),1);

% Plot grouped points with unified colors, remaining points in black
f1 = figure('Position', [100 100 1600 1600], 'Units','pixels');
tlo = tiledlayout(3,4,'TileSpacing','tight','Padding','compact');

selected_voyage = [1, 2, 4, 6]; % 1:6
% clear WGCC_dexcess WGCC_d18O
for voyage_i = 1:length(voyage_unique) % voyage_i = 3 used to calculate WGCC_source
    voyage_item = voyage_unique{voyage_i};
    voyage_find = find(strcmp(total_data.Voyage, voyage_item));
    % Dynamically extract data
    [dD, d18O, dexcess, Depth, Station, Salt] = deal([]);
    for ii = 1:length(voyage_find)
        station_find = voyage_find(ii);
        valid_idx = ~isnan(total_data(station_find,:).(cfg{1}){1}) & ...
                   ~isnan(total_data(station_find,:).(cfg{2}){1});
        
        dD = [dD; total_data(station_find,:).(cfg{1}){1}(valid_idx)];
        d18O = [d18O; total_data(station_find,:).(cfg{2}){1}(valid_idx)];
        Depth = [Depth; total_data(station_find,:).(cfg{3}){1}(valid_idx)];
        dexcess = [dexcess; total_data(station_find,:).(cfg{4}){1}(valid_idx)];
        Salt = [Salt; total_data(station_find,:).(cfg{5}){1}(valid_idx)];
        Station = [Station; repmat(total_data(station_find,:).('Station'), [sum(valid_idx), 1])];
    end
    
    if ismember(voyage_i, selected_voyage)
        % Plot
        nexttile;
        hold on 
    end
    
    % Initialize end-member data container
    all_em_d18O = [];
    all_em_dexcess = [];
    other_find = true(size(Station));
    
    % Loop to plot end-member points and collect data
    for source_idx = 1:length(selected_source_station{voyage_i})
        station_item = selected_source_station{voyage_i}{source_idx};
        depth_item = selected_source_depth{voyage_i}{source_idx};
        name_item = selected_source_name{voyage_i}{source_idx};
        color_item = source_color{source_idx};
        source_logical = false(size(Station));
        
        % Build logical index
        for source_station_idx = 1:length(station_item)
            source_logical = source_logical | (strcmp(Station, station_item{source_station_idx}) & ...
                Depth <= depth_item{source_station_idx}(2) & Depth >= depth_item{source_station_idx}(1));
        end
        
        % Get current end-member data
        if strcmp(voyage_item, 'NBBG') && strcmp(name_item, 'WGCC') % Save if NBBG WGCC
            WGCC_d18O = d18O(source_logical);
            WGCC_dexcess = dexcess(source_logical);
            current_em_d18O = WGCC_d18O;
            current_em_dexcess = WGCC_dexcess;
        elseif select_WGCC_flag{voyage_i}(source_idx) == 1 
            current_em_d18O = WGCC_d18O;
            current_em_dexcess = WGCC_dexcess;
        else
            current_em_d18O = d18O(source_logical);
            current_em_dexcess = dexcess(source_logical);
        end

        % Collect end-member data
        all_em_d18O = [all_em_d18O; current_em_d18O];
        all_em_dexcess = [all_em_dexcess; current_em_dexcess];
        
        % Plot end-member points
        if ~isempty(current_em_d18O) && ismember(voyage_i, selected_voyage)
            if select_WGCC_flag{voyage_i}(source_idx) == 1
                scatter(current_em_d18O, current_em_dexcess, 80, color_item, 'filled','DisplayName',name_item{:});
            else
                scatter(d18O(source_logical), dexcess(source_logical), 80, color_item, 'filled','DisplayName',name_item{:});
            end
        end
        other_find = other_find & ~source_logical;
    end
    
    if ~ismember(voyage_i, selected_voyage)
        continue
    end
        
    % Plot background points
    h_back = scatter(d18O(other_find), dexcess(other_find), 50, [0.7 0.7 0.7], 'filled','HandleVisibility','off');
    uistack(h_back, 'bottom');
    
    % Legend and style settings
    lgd = legend('Location', 'southwest', 'FontWeight','bold', 'FontSize',10, 'Box','on', 'NumColumns',1);
    lgd.Title.String = voyage_item;
    set(gca, 'FontSize',12, 'TickDir','in', 'Box','on', 'LineWidth',1.2,'FontName','Arial')
    
    % Calculate max δ18O and min d-excess
    if ~isempty(all_em_d18O)
        max_d18O = max(all_em_d18O);
        min_dexcess = min(all_em_dexcess);
    else
        max_d18O = NaN;
        min_dexcess = NaN;
    end
    xLimits = xlim; 
    yLimits = ylim; 
    maxY = yLimits(2);
    minX = xLimits(1);
    % Plot dashed lines
    if ~isnan(max_d18O)
        plot([max_d18O, max_d18O], [min_dexcess, maxY], '--', 'Color', 'k', 'LineWidth', 1.5, 'HandleVisibility','off');
    end
    if ~isnan(min_dexcess)
        plot([minX, max_d18O], [min_dexcess, min_dexcess], '--', 'Color', 'k', 'LineWidth', 1.5, 'HandleVisibility','off');
    end
    
    if voyage_i == 1
        xlabel('δ^1^8O', 'FontSize', 12, 'FontWeight','bold'); 
        ylabel('\itd\rm\bf-excess', 'FontSize', 12, 'FontWeight','bold');
    end
        
    % Detect and mark anomalies
    if ~isnan(max_d18O) && ~isnan(min_dexcess)

        [~, selected_idx] = ismember(voyage_i, selected_voyage);
        text(0.02,0.98,[char('a'+selected_idx-1)],'Units','normalized',...
        'FontSize',16,'FontWeight','bold','Color','k','BackgroundColor','None',...
        'VerticalAlignment','top','HorizontalAlignment','left');

        % Get non-end-member data
        non_em_Salt = Salt(other_find);
        non_em_d18O = d18O(other_find);
        non_em_dD = dD(other_find);
        non_em_dexcess = dexcess(other_find);
        non_em_Station = Station(other_find);
        non_em_Depth = Depth(other_find);
        
        % Find anomalies
        anomaly_idx = (non_em_d18O > max_d18O) | (non_em_dexcess < min_dexcess);
        anomaly_d18O = non_em_d18O(anomaly_idx);
        anomaly_dD = non_em_dD(anomaly_idx);
        anomaly_Salt = non_em_Salt(anomaly_idx);
        anomaly_dexcess = non_em_dexcess(anomaly_idx);
        anomaly_Station = non_em_Station(anomaly_idx);
        anomaly_Depth = non_em_Depth(anomaly_idx);
        
        % Plot black borders
        if ~isempty(anomaly_d18O)
            scatter(anomaly_d18O, anomaly_dexcess, 80, 'k', 'LineWidth',1.5,...
                'MarkerEdgeColor','k','MarkerFaceColor','none','HandleVisibility','off');
        end
        
        % Plot corrected points
        scatter(correction_records{voyage_i}.d18O, correction_records{voyage_i}.dD-8*correction_records{voyage_i}.d18O, 50, 'LineWidth',1.5,...
                'MarkerEdgeColor','k','MarkerFaceColor', [0.55 0.78 0.22],'HandleVisibility','off');    
                
        % Record anomaly information
        anomaly_records{voyage_i} = table(anomaly_Station, anomaly_Depth, anomaly_Salt, anomaly_d18O, anomaly_dD,...
            'VariableNames',{'Station','Depth', 'Salt', 'd18O','dD'});
    end    

end

% Add global axis labels
% xlabel(tlo, 'δ^1^8O', 'FontSize', 12, 'FontWeight','bold');
% ylabel(tlo, '\itd\rm\bf-excess', 'FontSize', 12, 'FontWeight','bold');
set(gca, 'FontSize',12, 'TickDir','in', 'Box','on', 'LineWidth',1.2,'FontName','Arial')

% Save figure
output_filepath = 'D:\BaiduNetdiskWorkspace\文章\海洋生物地球化学过程与其他\区域\南海北部氢氧同位素\figure\Initial\';
% exportgraphics(gcf,[output_filepath, 'F4_correction_isotope_3_dexcess_δ18O.jpg'],'Resolution',600);

% Display anomaly records (example)
for voyage_i = 1:length(anomaly_records)
    if ~isempty(anomaly_records{voyage_i})
        fprintf('Voyage: %s\n', voyage_unique{voyage_i});
        disp(anomaly_records{voyage_i});
    end
end


%% Plot the second row - δ18O-S to check if all anomalies are above the fitted line
load('anomaly_records.mat')
load('d18O_S_linear_param.mat')
load('dexcess_d18O_linear_param.mat')
cfg = {'δD', 'δ18O', 'Depth', 'd_excess', 'S'};
source_color = {[0.75 0.18 0.12],...   % Brick red
                [0.95 0.68 0.38],...   % Sunset orange
                [0.25 0.41 0.88],...  % Cobalt blue
                [0.00 0.24 0.49]};    % Navy blue

voyage_unique = unique(total_data.Voyage);
selected_voyage = [1, 2, 4, 6];
correction_records = anomaly_records; % Store corrected dD and d18O values

for voyage_i = 1:length(voyage_unique)
    voyage_item = voyage_unique{voyage_i};
    voyage_find = find(strcmp(total_data.Voyage, voyage_item));
    
    % Dynamically extract data
    [dD, d18O, dexcess, Depth, Station, Salt] = deal([]);
    for ii = 1:length(voyage_find)
        station_find = voyage_find(ii);
        valid_idx = ~isnan(total_data(station_find,:).(cfg{1}){1}) & ...
                   ~isnan(total_data(station_find,:).(cfg{2}){1});
        
        dD = [dD; total_data(station_find,:).(cfg{1}){1}(valid_idx)];
        d18O = [d18O; total_data(station_find,:).(cfg{2}){1}(valid_idx)];
        Depth = [Depth; total_data(station_find,:).(cfg{3}){1}(valid_idx)];
        dexcess = [dexcess; total_data(station_find,:).(cfg{4}){1}(valid_idx)];
        Salt = [Salt; total_data(station_find,:).(cfg{5}){1}(valid_idx)];
        Station = [Station; repmat(total_data(station_find,:).('Station'), [sum(valid_idx), 1])];
    end
    
    if ismember(voyage_i, selected_voyage)
        % Plot
        nexttile;
    end

    % Plot three end-member data (colored points) and other data (gray points)
    hold on 
    other_find = true(size(Station)); % Create all-true array
    for source_idx = 1:length(selected_source_station{voyage_i})
        station_item = selected_source_station{voyage_i}{source_idx};
        depth_item = selected_source_depth{voyage_i}{source_idx};
        name_item = selected_source_name{voyage_i}{source_idx};
        color_item = source_color{source_idx};
        source_logical = false(size(Station)); % Create all-false array
        for source_station_idx = 1:length(station_item)
            source_logical = source_logical | (strcmp(Station, station_item(source_station_idx)) &...
                        Depth<=depth_item{source_station_idx}(2) & Depth>=depth_item{source_station_idx}(1));
        end
        source_find = find(source_logical);
        if strcmp(voyage_item, 'NBBG') && strcmp(name_item, 'WGCC') % Save if NBBG WGCC
            WGCC_Salt = Salt(source_find);
            WGCC_d18O = d18O(source_find);
        elseif select_WGCC_flag{voyage_i}(source_idx) == 1 && ismember(voyage_i, selected_voyage) % Plot saved WGCC for SBBG and QD
            scatter(WGCC_Salt, WGCC_d18O, 80, color_item, 'filled','display', name_item{:});
        elseif ismember(voyage_i, selected_voyage)
            scatter(Salt(source_find), d18O(source_find), 80, color_item, 'filled','display', name_item{:});
        end
        other_find = other_find & ~source_logical;
    end
    
    % Determine if points need correction (delta δ18O>0), calculate dexcess (dD) correction value
    slope_OS = d18O_S_linear_param{voyage_i}.coef(1);
    intercept_OS = d18O_S_linear_param{voyage_i}.coef(2);
    slope_eO = dexcess_d18O_linear_param{voyage_i}.coef(1); 
    intercept_eO = dexcess_d18O_linear_param{voyage_i}.coef(2); 
    delta_d18O = anomaly_records{voyage_i}.d18O - (anomaly_records{voyage_i}.Salt .* slope_OS + intercept_OS);
    correction_find = find(delta_d18O>0); % Select points above the δ18O-S line
    new_d18O = correction_records{voyage_i}.d18O(correction_find) - delta_d18O(correction_find);
    delta_excess =  delta_d18O(correction_find) * slope_eO;   
    delta_dD = delta_excess + 8 * delta_d18O(correction_find);
    new_dD = anomaly_records{voyage_i}.dD(correction_find) - delta_dD; % Corrected dD  
    correction_records{voyage_i} = correction_records{voyage_i}(correction_find, :);
    correction_records{voyage_i}.d18O = new_d18O;
    correction_records{voyage_i}.dD = new_dD;
    
    if voyage_i == 1
        xlabel('Salinity', 'FontSize', 12, 'FontWeight','bold');
        ylabel('δ^1^8O', 'FontSize', 12, 'FontWeight','bold');
    end

    if ismember(voyage_i, selected_voyage)
        
        [~, selected_idx] = ismember(voyage_i, selected_voyage);
        text(0.02,0.98,[char('e'+selected_idx-1)],'Units','normalized',...
        'FontSize',16,'FontWeight','bold','Color','k','BackgroundColor','None',...
        'VerticalAlignment','top','HorizontalAlignment','left');

        h_back = scatter(Salt(other_find), d18O(other_find), 50, [0.7 0.7 0.7], 'filled','HandleVisibility','off');
        % Move second scatter to bottom layer
        uistack(h_back, 'bottom');
        lgd = legend( 'Location', 'southwest', 'FontWeight','bold', 'FontSize',10, 'Box','on', 'NumColumns',1);
        lgd.Title.String = voyage_item;

        % Plot black borders
        if ~isempty(anomaly_records{voyage_i}.d18O)
            scatter(anomaly_records{voyage_i}.Salt, anomaly_records{voyage_i}.d18O, 80, 'k', 'LineWidth',1.5,...
                'MarkerEdgeColor','k','MarkerFaceColor','none','HandleVisibility','off');
        end

        % Regression line
        plot(d18O_S_linear_param{voyage_i}.x_fit, d18O_S_linear_param{voyage_i}.y_fit,...
            'color', 'k', 'LineWidth',1.5,'HandleVisibility','off');

        set(gca, 'FontSize',12, 'TickDir','in', 'Box','on', 'LineWidth',1.2,'FontName','Arial')
    end
end

% Save figure
output_filepath = 'D:\BaiduNetdiskWorkspace\文章\海洋生物地球化学过程与其他\区域\南海北部氢氧同位素\figure\Initial\';
% exportgraphics(gcf,[output_filepath, 'F4_correction_isotope_3_δ18O_S.jpg'],'Resolution',600);

%% Plot row 3 - δD-S diagram. Correct δ18O based on 18O-S relationship, correct δD using d-excess-δ18O method, then save all corrected data to a table.
load('anomaly_records.mat')
load('d18O_S_linear_param.mat')
load('correction_records.mat')
cfg = {'δD', 'δ18O', 'Depth', 'd_excess', 'S'}; % Data field configuration

source_color = {[0.75 0.18 0.12],...   % Brick red
                [0.95 0.68 0.38],...   % Sunset orange
                [0.25 0.41 0.88],...   % Cobalt blue
                [0.00 0.24 0.49]};     % Navy blue
            
% Plot identified source groups in colors, other points in gray
voyage_unique = unique(total_data.Voyage);
selected_voyage = [1, 2, 4, 6];  % Voyages to display
clear WGCC_salt WGCC_d18O

for voyage_i = 1:length(voyage_unique)
    voyage_item = voyage_unique{voyage_i};
    voyage_find = find(strcmp(total_data.Voyage, voyage_item));
    
    % Dynamically extract data
    [dD, d18O, dexcess, Depth, Station, Salt] = deal([]);
    for ii = 1:length(voyage_find)
        station_find = voyage_find(ii);
        valid_idx = ~isnan(total_data(station_find,:).(cfg{1}){1}) & ...
                   ~isnan(total_data(station_find,:).(cfg{2}){1});
        
        dD = [dD; total_data(station_find,:).(cfg{1}){1}(valid_idx)];
        d18O = [d18O; total_data(station_find,:).(cfg{2}){1}(valid_idx)];
        Depth = [Depth; total_data(station_find,:).(cfg{3}){1}(valid_idx)];
        dexcess = [dexcess; total_data(station_find,:).(cfg{4}){1}(valid_idx)];
        Salt = [Salt; total_data(station_find,:).(cfg{5}){1}(valid_idx)];
        Station = [Station; repmat(total_data(station_find,:).('Station'), [sum(valid_idx), 1])];
    end
    
    if ismember(voyage_i, selected_voyage)
        nexttile; % Create subplot for selected voyages
    end

    % Plot identified sources (colored) vs other data (gray)
    hold on 
    other_find = true(size(Station)); 
    for source_idx = 1:length(selected_source_station{voyage_i})
        station_item = selected_source_station{voyage_i}{source_idx};
        depth_item = selected_source_depth{voyage_i}{source_idx};
        name_item = selected_source_name{voyage_i}{source_idx};
        color_item = source_color{source_idx};
        source_logical = false(size(Station));
        for source_station_idx = 1:length(station_item)
            source_logical = source_logical | (strcmp(Station, station_item(source_station_idx)) &...
                        Depth<=depth_item{source_station_idx}(2) & Depth>=depth_item{source_station_idx}(1));
        end
        source_find = find(source_logical);
        
        % Special handling for WGCC source in NBBG voyage
        if strcmp(voyage_item, 'NBBG') && strcmp(name_item, 'WGCC')
            WGCC_Salt = Salt(source_find);
            WGCC_dD = dD(source_find);
        elseif select_WGCC_flag{voyage_i}(source_idx) == 1 && ismember(voyage_i, selected_voyage)
            scatter(WGCC_Salt, WGCC_dD, 80, color_item, 'filled','DisplayName', name_item{:});
        elseif ismember(voyage_i, selected_voyage)
            scatter(Salt(source_find), dD(source_find), 80, color_item, 'filled','DisplayName', name_item{:});
        end
        other_find = other_find & ~source_logical;
    end
    
    % Set axes labels for first subplot
    if voyage_i == 1
        xlabel('Salinity', 'FontSize', 12, 'FontWeight','bold');
        ylabel( 'δD (‰)', 'FontSize', 12, 'FontWeight','bold');
    end
    
    % Plot corrected and raw data for selected voyages
    if ismember(voyage_i, selected_voyage)
        [~, selected_idx] = ismember(voyage_i, selected_voyage);
        text(0.02,0.98, char('i'+selected_idx-1), 'Units','normalized',...
            'FontSize',16,'FontWeight','bold','Color','k',...
            'VerticalAlignment','top','HorizontalAlignment','left');
        
        % Plot background points (gray)
        h_back = scatter(Salt(other_find), dD(other_find), 50, [0.7 0.7 0.7],...
                         'filled','HandleVisibility','off');
        uistack(h_back, 'bottom');  % Send to back
        
        % Configure legend
        lgd = legend('Location', 'southwest', 'FontWeight','bold',...
                    'FontSize',10, 'Box','on', 'NumColumns',1);
        lgd.Title.String = voyage_item;

        % Plot raw anomaly points
        scatter(anomaly_records{voyage_i}.Salt, anomaly_records{voyage_i}.dD, 50,...
                'LineWidth',1.5,'MarkerEdgeColor','k',...
                'MarkerFaceColor',[0.7 0.7 0.7],'HandleVisibility','off');

        % Plot corrected points
        scatter(correction_records{voyage_i}.Salt, correction_records{voyage_i}.dD, 50,...
                'LineWidth',1.5,'MarkerEdgeColor','k',...
                'MarkerFaceColor', [0.55 0.78 0.22],'HandleVisibility','off');
            
        % Format axes
        set(gca, 'FontSize',12, 'TickDir','in', 'Box','on',...
                'LineWidth',1.2,'FontName','Arial')
    end
end

% Save figure
output_filepath = 'D:\BaiduNetdiskWorkspace\Papers\Biogeochemistry\Regional\NSCS_isotope\figure\Initial\';
exportgraphics(gcf, [output_filepath, 'F4_correction_isotope.jpg'], 'Resolution', 600);

%% Export corrected data back to original table format
load('file_raw.mat')

cfg = {'δD', 'δ18O', 'Depth', 'd_excess', 'S'};
correction_data = total_data;  % Initialize corrected dataset
voyage_unique = unique(total_data.Voyage);
[correction_dD, correction_d18O] = deal([]); % Initialize storage

for voyage_i = 1:length(voyage_unique)
    voyage_item = voyage_unique{voyage_i};
    voyage_find = find(strcmp(total_data.Voyage, voyage_item));
    
    % Extract raw data
    [dD, d18O, ~, Depth, Station, ~] = deal([]);
    for ii = 1:length(voyage_find)
        station_find = voyage_find(ii);
        valid_idx = ~isnan(total_data(station_find,:).(cfg{1}){1}) & ...
                   ~isnan(total_data(station_find,:).(cfg{2}){1});

        dD = [dD; total_data(station_find,:).(cfg{1}){1}(valid_idx)];
        d18O = [d18O; total_data(station_find,:).(cfg{2}){1}(valid_idx)];
        Depth = [Depth; total_data(station_find,:).(cfg{3}){1}(valid_idx)];
        Station = [Station; repmat(total_data(station_find,:).('Station'), [sum(valid_idx), 1])];
    end   
    
    % Map corrections to original data structure
    origin_dD = file_raw(strcmp(voyage_item, file_raw(:, 12)), 7);
    origin_dD(strcmp(origin_dD, 'NA')) = {-999}; 
    origin_dD = cell2mat(origin_dD);
    
    origin_d18O = file_raw(strcmp(voyage_item, file_raw(:, 12)), 8);
    origin_d18O(strcmp(origin_d18O, 'NA')) = {-999};
    origin_d18O = cell2mat(origin_d18O);
    
    [~, station_idx] = ismember(dD, origin_dD);
    
    % Apply corrections
    correction_voyage = correction_records{voyage_i};
    dD_corrected = dD;  % Initialize with raw values
    d18O_corrected = d18O;
    
    for ii = 1:size(correction_voyage, 1)
        correction_item = correction_voyage(ii,:);
        idx = strcmp(correction_item.Station, Station) & ...
              (correction_item.Depth == Depth);
        dD_corrected(idx) = correction_item.dD;
        d18O_corrected(idx) = correction_item.d18O;
    end

    % Update original data arrays
    origin_dD(station_idx) = dD_corrected;
    origin_d18O(station_idx) = d18O_corrected;
    origin_dD(origin_dD == -999) = NaN;  % Restore NaNs
    origin_d18O(origin_d18O == -999) = NaN;
    
    % Store corrected values
    correction_dD{voyage_i} = origin_dD;
    correction_d18O{voyage_i} = origin_d18O;
end