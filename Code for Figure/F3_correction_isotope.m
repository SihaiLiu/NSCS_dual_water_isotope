%% Extract data
load('total_table.mat')


%% Plot first row - Water isotope anomaly detection and correction
load('correction_records.mat')

% Keep only four voyages and create a 3x4 plot layout


cfg = {'δD', 'δ18O', 'Depth', 'd_excess', 'S'};
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
            {{[0, 29]}, {[0, 850]}, {[0, 340]}, {[5, 50]}}}; % Depth ranges for selected stations
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
% Scatter parameters for WGCC
select_WGCC_flag = {[0,0,0], [0,0,0], [0,1,0], [0,1,0], [0,0,0], [0,0,0,0]}; % SBBG and QD use NBBG's WGCC end-member

voyage_unique = unique(total_data.Voyage);
anomaly_records = cell(length(voyage_unique),1);

f1 = figure('Position', [100 100 1600 1600], 'Units','pixels');
tlo = tiledlayout(3,4,'TileSpacing','tight','Padding','compact');
selected_voyage = [1, 3, 5, 6];
clear WGCC_dexcess WGCC_d18O

for voyage_i = 1:length(voyage_unique)
    voyage_item = voyage_unique{voyage_i};
    voyage_find = find(strcmp(total_data.Voyage, voyage_item));
    
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
        nexttile;
        hold on 
    end
    
    all_em_d18O = [];
    all_em_dexcess = [];
    other_find = true(size(Station));
    
    for source_idx = 1:length(selected_source_station{voyage_i})
        station_item = selected_source_station{voyage_i}{source_idx};
        depth_item = selected_source_depth{voyage_i}{source_idx};
        name_item = selected_source_name{voyage_i}{source_idx};
        color_item = source_color{source_idx};
        source_logical = false(size(Station));
        
        for source_station_idx = 1:length(station_item)
            source_logical = source_logical | (strcmp(Station, station_item{source_station_idx}) & ...
                Depth <= depth_item{source_station_idx}(2) & Depth >= depth_item{source_station_idx}(1));
        end
        
        if strcmp(voyage_item, 'NBBG') && strcmp(name_item, 'WGCC') 
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

        all_em_d18O = [all_em_d18O; current_em_d18O];
        all_em_dexcess = [all_em_dexcess; current_em_dexcess];
        
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
        
    h_back = scatter(d18O(other_find), dexcess(other_find), 50, [0.7 0.7 0.7], 'filled','HandleVisibility','off');
    uistack(h_back, 'bottom');
    
    lgd = legend('Location', 'southwest', 'FontWeight','bold', 'FontSize',10, 'Box','on', 'NumColumns',1);
    lgd.Title.String = voyage_item;
    set(gca, 'FontSize',12, 'TickDir','in', 'Box','on', 'LineWidth',1.2,'FontName','Arial')
    
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
    
    if ~isnan(max_d18O)
        plot([max_d18O, max_d18O], [min_dexcess, maxY], '--', 'Color', 'k', 'LineWidth', 1.5, 'HandleVisibility','off');
    end
    if ~isnan(min_dexcess)
        plot([minX, max_d18O], [min_dexcess, min_dexcess], '--', 'Color', 'k', 'LineWidth', 1.5, 'HandleVisibility','off');
    end
    
    if voyage_i == 1
        xlabel('δ¹⁸O', 'FontSize', 12, 'FontWeight','bold'); 
        ylabel('\itd\rm\bf-excess', 'FontSize', 12, 'FontWeight','bold');
    end
        
    if ~isnan(max_d18O) && ~isnan(min_dexcess)

        [~, selected_idx] = ismember(voyage_i, selected_voyage);
        text(0.02,0.98,[char('a'+selected_idx-1)],'Units','normalized',...
        'FontSize',16,'FontWeight','bold','Color','k','BackgroundColor','None',...
        'VerticalAlignment','top','HorizontalAlignment','left');

        non_em_Salt = Salt(other_find);
        non_em_d18O = d18O(other_find);
        non_em_dD = dD(other_find);
        non_em_dexcess = dexcess(other_find);
        non_em_Station = Station(other_find);
        non_em_Depth = Depth(other_find);
        
        anomaly_idx = (non_em_d18O > max_d18O) | (non_em_dexcess < min_dexcess);
        anomaly_d18O = non_em_d18O(anomaly_idx);
        anomaly_dD = non_em_dD(anomaly_idx);
        anomaly_Salt = non_em_Salt(anomaly_idx);
        anomaly_dexcess = non_em_dexcess(anomaly_idx);
        anomaly_Station = non_em_Station(anomaly_idx);
        anomaly_Depth = non_em_Depth(anomaly_idx);
        
        if ~isempty(anomaly_d18O)
            scatter(anomaly_d18O, anomaly_dexcess, 80, 'k', 'LineWidth',1.5,...
                'MarkerEdgeColor','k','MarkerFaceColor','none','HandleVisibility','off');
        end
        
        scatter(correction_records{voyage_i}.d18O, correction_records{voyage_i}.dD-8*correction_records{voyage_i}.d18O, 50, 'LineWidth',1.5,...
                'MarkerEdgeColor','k','MarkerFaceColor', [0.55 0.78 0.22],'HandleVisibility','off');    
                
        anomaly_records{voyage_i} = table(anomaly_Station, anomaly_Depth, anomaly_Salt, anomaly_d18O, anomaly_dD,...
            'VariableNames',{'Station','Depth', 'Salt', 'd18O','dD'});
    end    
end

set(gca, 'FontSize',12, 'TickDir','in', 'Box','on', 'LineWidth',1.2,'FontName','Arial')


%% Plot second row - δ¹⁸O-S diagram - Check if all anomalies are above the fitted line
load('anomaly_records.mat')
load('d18O_S_linear_param.mat')
load('dexcess_d18O_linear_param.mat')
cfg = {'δD', 'δ18O', 'Depth', 'd_excess', 'S'};
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
            {{[0, 29]}, {[0, 850]}, {[0, 340]}, {[5, 50]}}}; % Depth ranges for selected stations
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
select_WGCC_flag = {[0,0,0], [0,0,0], [0,1,0], [0,1,0], [0,0,0], [0,0,0,0]}; % SBBG and QD use NBBG's WGCC end-member

voyage_unique = unique(total_data.Voyage);
selected_voyage = [1, 3, 5, 6];
correction_records = anomaly_records; 
clear WGCC_salt WGCC_d18O

for voyage_i = 1:length(voyage_unique)
        voyage_item = voyage_unique{voyage_i};
        voyage_find = find(strcmp(total_data.Voyage, voyage_item));
        
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
            nexttile;
        end

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
            if strcmp(voyage_item, 'NBBG') && strcmp(name_item, 'WGCC') 
                WGCC_Salt = Salt(source_find);
                WGCC_d18O = d18O(source_find);
            elseif select_WGCC_flag{voyage_i}(source_idx) == 1 && ismember(voyage_i, selected_voyage)
                scatter(WGCC_Salt, WGCC_d18O, 80, color_item, 'filled','DisplayName', name_item{:});
            elseif ismember(voyage_i, selected_voyage)
                scatter(Salt(source_find), d18O(source_find), 80, color_item, 'filled','DisplayName', name_item{:});
            end
            other_find = other_find & ~source_logical;
        end
        
        slope_OS = d18O_S_linear_param{voyage_i}.coef(1);
        intercept_OS = d18O_S_linear_param{voyage_i}.coef(2);
        slope_eO = dexcess_d18O_linear_param{voyage_i}.coef(1); 
        intercept_eO = dexcess_d18O_linear_param{voyage_i}.coef(2); 
        delta_d18O = anomaly_records{voyage_i}.d18O - (anomaly_records{voyage_i}.Salt .* slope_OS + intercept_OS);
        correction_find = find(delta_d18O>0); 
        new_d18O = correction_records{voyage_i}.d18O(correction_find) - delta_d18O(correction_find);
        delta_excess =  delta_d18O(correction_find) * slope_eO;   
        delta_dD = delta_excess + 8 * delta_d18O(correction_find);
        new_dD = anomaly_records{voyage_i}.dD(correction_find) - delta_dD; 
        correction_records{voyage_i} = correction_records{voyage_i}(correction_find, :);
        correction_records{voyage_i}.d18O = new_d18O;
        correction_records{voyage_i}.dD = new_dD;
        
        if voyage_i == 1
            xlabel('Salinity', 'FontSize', 12, 'FontWeight','bold');
            ylabel('δ¹⁸O', 'FontSize', 12, 'FontWeight','bold');
        end
    
        if ismember(voyage_i, selected_voyage)
            
            [~, selected_idx] = ismember(voyage_i, selected_voyage);
            text(0.02,0.98,[char('e'+selected_idx-1)],'Units','normalized',...
            'FontSize',16,'FontWeight','bold','Color','k','BackgroundColor','None',...
            'VerticalAlignment','top','HorizontalAlignment','left');
    
            h_back = scatter(Salt(other_find), d18O(other_find), 50, [0.7 0.7 0.7], 'filled','HandleVisibility','off');
            uistack(h_back, 'bottom');
            lgd = legend( 'Location', 'southwest', 'FontWeight','bold', 'FontSize',10, 'Box','on', 'NumColumns',1);
            lgd.Title.String = voyage_item;

            if ~isempty(anomaly_records{voyage_i}.d18O)
                scatter(anomaly_records{voyage_i}.Salt, anomaly_records{voyage_i}.d18O, 80, 'k', 'LineWidth',1.5,...
                    'MarkerEdgeColor','k','MarkerFaceColor','none','HandleVisibility','off');
            end

            plot(d18O_S_linear_param{voyage_i}.x_fit, d18O_S_linear_param{voyage_i}.y_fit,...
                'color', 'k', 'LineWidth',1.5,'HandleVisibility','off');

            set(gca, 'FontSize',12, 'TickDir','in', 'Box','on', 'LineWidth',1.2,'FontName','Arial')
        end
end


%% Plot third row - δD-S diagram - Correct δD using δ¹⁸O-S and d-excess-δ¹⁸O corrections
load('anomaly_records.mat')
load('d18O_S_linear_param.mat')
load('correction_records.mat')
cfg = {'δD', 'δ18O', 'Depth', 'd_excess', 'S'};
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
            {{[0, 29]}, {[0, 850]}, {[0, 340]}, {[5, 50]}}}; % Depth ranges for selected stations
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
select_WGCC_flag = {[0,0,0], [0,0,0], [0,1,0], [0,1,0], [0,0,0], [0,0,0,0]}; % SBBG and QD use NBBG's WGCC end-member

voyage_unique = unique(total_data.Voyage);
selected_voyage = [1, 3, 5, 6];
clear WGCC_salt WGCC_d18O

for voyage_i = 1:length(voyage_unique)
        voyage_item = voyage_unique{voyage_i};
        voyage_find = find(strcmp(total_data.Voyage, voyage_item));
        
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
            nexttile;
        end

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
        
        if voyage_i == 1
            xlabel('Salinity', 'FontSize', 12, 'FontWeight','bold');
            ylabel('δD', 'FontSize', 12, 'FontWeight','bold');
        end
        
        if ismember(voyage_i, selected_voyage)
            
            [~, selected_idx] = ismember(voyage_i, selected_voyage);
            text(0.02,0.98,[char('i'+selected_idx-1)],'Units','normalized',...
            'FontSize',16,'FontWeight','bold','Color','k','BackgroundColor','None',...
            'VerticalAlignment','top','HorizontalAlignment','left');
        
            h_back = scatter(Salt(other_find), dD(other_find), 50, [0.7 0.7 0.7], 'filled','HandleVisibility','off');
            uistack(h_back, 'bottom');
            lgd = legend( 'Location', 'southwest', 'FontWeight','bold', 'FontSize',10, 'Box','on', 'NumColumns',1);
            lgd.Title.String = voyage_item;

            scatter(anomaly_records{voyage_i}.Salt, anomaly_records{voyage_i}.dD, 50, 'LineWidth',1.5,...
                    'MarkerEdgeColor','k','MarkerFaceColor',[0.7 0.7 0.7],'HandleVisibility','off');

            scatter(correction_records{voyage_i}.Salt, correction_records{voyage_i}.dD, 50, 'LineWidth',1.5,...
                    'MarkerEdgeColor','k','MarkerFaceColor', [0.55 0.78 0.22],'HandleVisibility','off');           

            set(gca, 'FontSize',12, 'TickDir','in', 'Box','on', 'LineWidth',1.2,'FontName','Arial')
        end
end

output_filepath = '.\figure\';
exportgraphics(gcf,[output_filepath, 'F3_correction_isotope.jpg'],'Resolution',600);


%% Output corrected data
load('file_raw.mat')

cfg = {'δD', 'δ18O', 'Depth', 'd_excess', 'S'};
correction_data = total_data;
voyage_unique = unique(total_data.Voyage);
[correction_dD, correction_d18O] = deal([]);

for voyage_i = 1:length(voyage_unique)
    voyage_item = voyage_unique{voyage_i};
    voyage_find = find(strcmp(total_data.Voyage, voyage_item));
    
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
    
    origin_dD = file_raw(strcmp(voyage_item, file_raw(:, 12)), 7);
    origin_dD(strcmp(origin_dD, 'NA')) = {-999}; 
    origin_dD = cell2mat(origin_dD); 
    origin_d18O = file_raw(strcmp(voyage_item, file_raw(:, 12)), 8);
    origin_d18O(strcmp(origin_d18O, 'NA')) = {-999}; 
    origin_d18O = cell2mat(origin_d18O); 
    [~, station_idx] = ismember(dD, origin_dD); 
    
    correction_voyage = correction_records{voyage_i};
    dD2 = dD;
    d18O2 = d18O;
    for ii = 1:size(correction_voyage, 1)
        correction_item = correction_voyage(ii,:);
        correction_find = find(strcmp(correction_item.Station, Station) & (correction_item.Depth == Depth));
        dD2(correction_find) = correction_item.dD;
        d18O2(correction_find) = correction_item.d18O;
    end

    origin_dD(station_idx) = dD2;
    origin_d18O(station_idx) = d18O2;
    origin_dD(origin_dD == -999) = NaN;
    origin_d18O(origin_d18O == -999) = NaN;
    
    correction_dD{voyage_i} = origin_dD;
    correction_d18O{voyage_i} = origin_d18O;
end