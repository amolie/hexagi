
function fh = hexagi_barplotscript(data, options)
% function to create barplots including error bars and optional lines for
% individual measurements
% calculates mean and SEM (using nanmean and nanstd) across columns of input array data
% inputs:
%     data = m x n array of obervations (e.g. rows = subjects, cols = runs)
%     options: structure to specify details of appearance in fields
%         possible options to set in fields:
%         barcolor, individmeascolor, errorbarcolor
%         xtick, xticklabel, xlabel,
%         ytick, yticklabel, ylabel,
%         title, fontSize, fontName
% for the colors of bars and individual measurements either specify one
% general color or one color for each bar/measurement


%% FOR DEBUGGING
if nargin == 0   
    data = rand(24,6);
    options.title = 'random data';  
end


%% SOME DEFAULTS
if nargin < 2
    
    % colors
    options.barcolor            = [157, 157, 156]/255;  % $lab gray
    options.individmeascolor    = [0 0 0]/255;          % black
    options.errorcolor          = [0 0 0]/255;          % black
    
    % default = individual measurements as dots
    options.indMeas = 'dots';
end

%default colors
if ~isfield(options, 'barcolor')
    options.barcolor = [157, 157, 156]/255;  % $lab gray   
end

if ~isfield(options, 'individmeascolor')
    options.individmeascolor = [0 0 0]/255;  % black 
end

if ~isfield(options, 'errorcolor')
    options.errorcolor = [0 0 0]/255;        % black 
end

%% CALCULATE MEAN AND SEM OF DATA
datMean = nanmean(data);
sem     = nanstd(data)/sqrt(size(data,1));


%% CREATE THE BARPLOT
fh = figure;
hold on;

% plot bars 
if size(options.barcolor,1) == 1 % all in the same color
    
    h = bar(1:size(datMean,2), datMean);
    set(h, 'FaceColor', options.barcolor);
    
elseif size(options.barcolor,1) == size(datMean,2) % different color for each bar
    
    for iBar = 1:size(data,2)
        h = bar(iBar,datMean(iBar));
        set(h, 'FaceColor', options.barcolor(iBar,:), 'EdgeColor','none')
    end
else
    error('Error!\nTrying to plot %d bars, but specified %d colors.\nSpecify one color only or as many colors as you want bars', size(datMean,2), size(optionsbarcolor,1))
end

% x limit for one bar needs adjusting to look good
if size(datMean,2)==1
    xlim([0.5 1.5]);
end


%% ADD INDIVIDUAL DATA POINTS
switch options.indMeas
    
    % lines connecting individual data points
    case 'lines'
    
        for iRow = 1:size(data,1)

            % handle colors of lines for individual measurements
            if size(options.individmeascolor,1) == size(data,1)
                currColor = options.individmeascolor(iRow,:);

            elseif size(options.individmeascolor,1) == 1
                currColor = options.individmeascolor;
            else
                error('Error!\nTrying to plot %d individual measurements, but specified %d colors.\nSpecify one color only or as many colors as you have measurements', size(data,1), size(options.individmeascolor,1))
            end

            % in case of two bars avoid overlapping of individual
            % datapoints with error bars by moving line end points
            if size(data,2) == 2
                lineXlocs = [1.2 1.8];
            else
                lineXlocs = 1:size(data,2);
            end
            
            % plot individual measurements
            indMeasHandle = plot(lineXlocs, data(iRow,:),...
                '-o',...
                'Color', currColor,...
                'MarkerEdgeColor',currColor,...
                'MarkerFaceColor',currColor,...
                'MarkerSize',5);
        end
        
    % jittered dots for individual data points
    case 'dots'
        
        jitter = (randi([8 12],size(data(:,1)))-10)/10;
                
        % handle colors of lines for individual measurements
        if size(options.individmeascolor,1) == 1
            currColor = options.individmeascolor;
            
        elseif size(options.individmeascolor,1) >= size(data,2)
            currColor = options.individmeascolor(iBar,:);

        else
            error('Error!\nTrying to plot %d individual measurements, but specified %d colors.\nSpecify one color only or as many colors as you have bars', size(data,2), size(options.individmeascolor,1))
        end
        
        for iBar = 1:size(data,2)
            
            indMeasHandle(iBar) = scatter(ones(size(data(:,iBar),1),1)*iBar,data(:,iBar),...
                 10, currColor, 'MarkerFaceColor', currColor, 'jitter','on', 'jitterAmount',0.2);
             
%             plot(iBar+jitter, data(:,iBar),...
%                 'o',...
%                 'Color', currColor,...
%                 'MarkerEdgeColor',currColor,...
%                 'MarkerFaceColor',currColor,...
%                 'MarkerSize',7)
        end

    % don't do this! #barbarplots!
    case 'none'
end

%% ADD ERRORBARS FOR SEM
errBarHandle = plot([1:size(data,2); 1:size(data,2)], [datMean-sem; datMean+sem],...
    '-', 'Color', options.errorcolor, 'LineWidth',3);
% errorbar(datMean, sem, 'LineStyle','none','Color',[0 0 0], 'LineWidth',3);


%% HANDLE APPEARANCE

%defaults
if ~isfield(options, 'fontSize')
    options.fontSize = 14;     
end

if ~isfield(options, 'xlim')
    options.xlim = xlim;
end

if ~isfield(options, 'ylim')
    options.ylim = ylim;
end

if ~isfield(options, 'xtick')
    options.xtick = 1:size(data,2);     
end

if ~isfield(options, 'xticklabel')
    options.xticklabel = 1:size(data,2);
end

if ~isfield(options, 'XTickLabelRotation')
    options.XTickLabelRotation = 0;
end

if ~isfield(options, 'xlabel')
    options.xlabel = '';
end

if ~isfield(options, 'yticklabel')
    options.yticklabel = get(gca, 'Yticklabels');
end

if ~isfield(options, 'ytick')
    options.ytick = get(gca, 'Ytick');
end

if ~isfield(options, 'ylabel')
    options.ylabel = '';    
end

if ~isfield(options, 'title')
    options.title = '';
end

% finishing touches
xlim(options.xlim);
ylim(options.ylim);
set(gca, 'XTick',  options.xtick, 'XTickLabel', options.xticklabel, 'XTickLabelRotation', options.XTickLabelRotation, 'FontSize', options.fontSize);
set(gca, 'YTick', options.ytick, 'YTickLabel',options.yticklabel , 'FontSize', options.fontSize)
set(gca,'linewidth',3)
xlabel(options.xlabel, 'Fontsize', options.fontSize)
ylabel(options.ylabel, 'Fontsize', options.fontSize)
title(options.title, 'FontSize', options.fontSize)

ax1 = gca;
ax1.YBaseline.LineWidth = 1.5;
ax1.YBaseline.Color = [0.8 0.8 0.8];
ax1.XRuler.Axle.Visible = 'off';

if isfield(options, 'fontName')
    set(gca,'FontName', options.fontName)
end

