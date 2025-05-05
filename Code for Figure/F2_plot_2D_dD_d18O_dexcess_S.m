%% Extract data
load('total_table.mat')
load('GISS_Table.mat')


%% Plot 2D graph
f1 = figure('Position', [100 100 1600 500], 'Units','pixels');
tlo = tiledlayout(1,2,'TileSpacing','tight','Padding','compact');

% Define subplot configuration parameters
subplot_config = {
    {'S', 'δ18O', 'Salinity', 'δ¹⁸O (‰)', '(d) δ¹⁸O vs Salinity', [28, 36], [-2 1], [28:36], [-2:1:1]},...
    {'δ18O', 'd_excess', 'δ¹⁸O (‰)', 'd-excess (‰)', '(c) d-excess vs δ¹⁸O', [-2 1], [-15 25], [-2:1:2], [-15:5:25]}...
};

% Style parameters
color_list = {[31, 119, 180]/255, [255, 127, 14]/255, [44, 160, 44]/255,...
             [214, 39, 40]/255, [148, 103, 189]/255, [140, 86, 75]/255};
style_list = {'o', 's', '^', 'd', 'p', 'h'};
marker_size = 8;
line_width = 2;
clear d18O_S_linear_param
clear dexcess_d18O_linear_param

% Main loop to generate subplots
for sub_idx = 1:2
    nexttile;
    cfg = subplot_config{sub_idx};
    
    % Initialize axes
    ax = gca;
    set(ax,'LineWidth',0.5,'TickLength',[0.005 0.005],...
          'XMinorTick','off','YMinorTick','off','Layer','top',...
          'XColor',[0.2 0.2 0.2],'YColor',[0.2 0.2 0.2]);
    hold on;
    
    % Data preparation and plotting
    voyage_unique = unique(total_data.Voyage);
    text_handle = gobjects(length(voyage_unique),1); % Preallocate graphics objects
    
    for voyage_i = 1:length(voyage_unique)
        voyage_item = voyage_unique{voyage_i};
        voyage_find = find(strcmp(total_data.Voyage, voyage_item));
        
        % Dynamically extract data
        [station_x, station_y] = deal([]);
        for ii = 1:length(voyage_find)
            station_find = voyage_find(ii);
            valid_idx = ~isnan(total_data(station_find,:).(cfg{1}){1}) & ...
                       ~isnan(total_data(station_find,:).(cfg{2}){1});
            
            station_x = [station_x; total_data(station_find,:).(cfg{1}){1}(valid_idx)];
            station_y = [station_y; total_data(station_find,:).(cfg{2}){1}(valid_idx)];
        end
        
        % Data cleaning
        valid_idx = ~isnan(station_x) & ~isnan(station_y);
        x_data = station_x(valid_idx);
        y_data = station_y(valid_idx);
        
        % Plot scatter points
        scatter(x_data, y_data, marker_size^2-30,...
               'Marker', style_list{voyage_i},...
               'MarkerEdgeColor', color_list{voyage_i},...
               'MarkerFaceColor', color_list{voyage_i},...
               'MarkerFaceAlpha',0.5, 'LineWidth',line_width*0.8, 'HandleVisibility','off');
        
        
        % Regression analysis
        if length(x_data) > 1
            mdl = fitlm(x_data, y_data);
            x_fit = linspace(min(x_data), max(x_data), 100);
            [y_fit, yci] = predict(mdl, x_fit', 'Alpha',0.05);
            
            % Confidence interval
            fill([x_fit, fliplr(x_fit)], [yci(:,1)', fliplr(yci(:,2)')],...
                color_list{voyage_i}, 'FaceAlpha',0.2, 'EdgeColor','none', 'HandleVisibility','off');
            
            % Regression line
            plot(x_fit, y_fit, 'Color', color_list{voyage_i},...
                'LineWidth',line_width*1.5, 'DisplayName',voyage_item);
            
            % Dynamic annotation
            [text_x, text_y] = dynamic_text_position(x_data, y_data, voyage_i);
            if mdl.Coefficients.pValue(2) < 0.001
                text_str = sprintf('y = %.2fx%+.2f, \\itN\\rm\\bf = %d\n\\itR\\rm\\bf^2 = %.2f, \\itp\\rm\\bf < 0.001',...
                  mdl.Coefficients.Estimate(2),...
                  mdl.Coefficients.Estimate(1),...
                  length(x_data),...
                  mdl.Rsquared.Ordinary);
            else
                text_str = sprintf('y = %.2fx%+.2f, \\itN\\rm\\bf = %d\n\\itR\\rm\\bf^2 = %.2f, \\itp\\rm\\bf = %.3f',...
                  mdl.Coefficients.Estimate(2),...
                  mdl.Coefficients.Estimate(1),...
                  length(x_data),...
                  mdl.Rsquared.Ordinary,...
                  mdl.Coefficients.pValue(2));
            end
            text_handle(voyage_i) = text(text_x, text_y, text_str,...
                'Color', color_list{voyage_i}, 'FontSize',12,'FontWeight','bold',...
                'BackgroundColor',[1 1 1 0.7], 'EdgeColor','none');
            
            % Store regression parameters
            if strcmp(cfg{1}, 'S') && strcmp(cfg{2}, 'δ18O')
                d18O_S_linear_param{voyage_i} = table([mdl.Coefficients.Estimate(2), mdl.Coefficients.Estimate(1)],...
                    x_fit, y_fit',...
                    'VariableNames',{'coef','x_fit', 'y_fit'});
            elseif strcmp(cfg{1}, 'δ18O') && strcmp(cfg{2}, 'd_excess')
                dexcess_d18O_linear_param{voyage_i} = table([mdl.Coefficients.Estimate(2), mdl.Coefficients.Estimate(1)],...
                    x_fit, y_fit',...
                    'VariableNames',{'coef','x_fit', 'y_fit'});
            end
        end
    end
    
    
    % Graph beautification
    uistack(text_handle, 'top');
    % X-axis label control
    if sub_idx < 0%3
        set(ax,'XTickLabel',[]);
    else
        xlabel(cfg{3}, 'FontSize',15, 'FontWeight','bold');
    end
    % Axis settings
    if ~isempty(cfg{6})
        xticks(cfg{8}); yticks(cfg{9});
        xlim(cfg{6}); ylim(cfg{7});
    end
    ylabel(cfg{4}, 'FontSize',15, 'FontWeight','bold');
    % Subplot label
    text(0.015,0.97,[char('e'+sub_idx-1)],'Units','normalized',...
    'FontSize',15,'FontWeight','bold','Color','k','BackgroundColor','None',...
    'VerticalAlignment','top','HorizontalAlignment','left');
    
    % Legend setup
    if sub_idx == 1%4
        lgd = legend(voyage_unique, 'Orientation','vertical',...
            'Location','southeast', 'FontSize',12);
        lgd.Title.String = 'Voyage';
    end
    set(gca, 'FontSize',15, 'TickDir','out', 'Box','on', 'LineWidth',1.2,'FontName','Arial')
end

% Save image
output_filepath = '.\figure\';
exportgraphics(gcf,[output_filepath, '2D_dD_d18O_dexcess_S.jpg'],'Resolution',600);

% Helper function: Dynamic text positioning
function [x_pos, y_pos] = dynamic_text_position(x_data, y_data, group_id)
    x_range = range(x_data);
    y_range = range(y_data);
    
    % Generate different positioning strategies based on group ID
    switch mod(group_id,4)
        case 0
            x_pos = prctile(x_data,75);
            y_pos = prctile(y_data,25);
        case 1
            x_pos = prctile(x_data,25);
            y_pos = prctile(y_data,75);
        case 2
            x_pos = median(x_data);
            y_pos = max(y_data) - 0.2*y_range;
        otherwise
            x_pos = min(x_data) + 0.1*x_range;
            y_pos = min(y_data) + 0.9*y_range;
    end
end