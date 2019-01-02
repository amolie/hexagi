function hexagi_behaviour_LMShift_MemoryBias(Subjects,StatsPath,FigPath)

% Correlate LM Shift (angular difference of the vectors drop locations to
% the true location, and the vector of the true location to the landmark)
% from the test phase with memory bias (doeller 2008) from the transfer
% phase. 


if  nargin <1
    Subjects  = load('hexagi_subjects');
    StatsPath = 'C:\MasterThesis\Data\Hexagi\Behaviour\Stats';
    FigPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Figures';
end


YoungIdx = Subjects < 200;
OldIdx   = Subjects >= 200;   

% Get LM Shift from the test phase
% Ang diff in abs!!
load (fullfile(StatsPath,'\Test\LMShift\AngDiff'),'AngDiff');

% Get memory bias from the transfer phase
load(fullfile(StatsPath,'\Transfer\MemoryBias_Doeller2008\MemoryBias'));


%% Robust correlation for young
X = AngDiff(YoungIdx);
Y = MemoryBias(YoungIdx);

corr_normplot(X,Y); % scatter plot and histograms
density = joint_density(X,Y); % joint density

%Assumption checking
HZmvntest([X,Y]); % test normality 

[h,CI] = variance_homogeneity(X,Y); % test homoscedasticity
outliers = detect_outliers(X,Y); % returns univariate and bivariate outliers
 
%Correlations
[r,t,p,hboot,CI] = Pearson(X,Y) % Pearson


%% Make the plot pretty and including a confidence interval
Young_color = [178 128 114]/255;
Line_color = [89 91 86]/255;
Edge_color = [141 85 74]/255;

% Copy the relevant subpanel to new figure
orgFig  = gcf;
hAx     = findobj(orgFig,'type', 'axes');
fNew    = figure;
hNew    = copyobj(hAx(2), fNew); close(orgFig);

set(hNew, 'pos', [0.23162 0.2233 0.72058 0.63107], 'FontName', 'Arial', 'FontSize', 16);
cH=hNew.Children;
set(cH(5),'MarkerFaceColor',Young_color)
set(cH(5),'MarkerEdgeColor',Edge_color)
set(cH(4), 'Linewidth', 3, 'Color', Line_color) % scatter plot
set(cH(2:3), 'Linewidth', 2, 'Color', Line_color, 'LineStyle', '--') % CI lines
set(cH(1), 'LineStyle', 'none', 'FaceColor', Young_color) % background patch color
xlabel('Landmark shift'); ylabel('Memory bias');
axis square; grid off; box off;

%xlim([0.4 0.8])
ylim([0.3 1.1]);
yticks([0.4 0.6 0.8 1])

saveas(fNew, fullfile(FigPath,'\LMShift','Corr_LMShift_MemBias1_Young'),'pdf');

%% Robust correlation for old
%Data visualization
X = [AngDiff(OldIdx)];
Y = MemoryBias(OldIdx);

corr_normplot(X,Y); % scatter plot and histograms
density = joint_density(X,Y); % joint density

%Assumption checking
HZmvntest([X,Y]); % test normality 

[h,CI] = variance_homogeneity(X,Y); 
outliers = detect_outliers(X,Y); % returns univariate and bivariate outliers

[r,t,p,hboot,CI] = Pearson(X,Y); 


%% Make the plot pretty and including a confidence interval
Old_color = [120 158 158]/255;
Line_color = [89 91 86]/255;
Edge_color = [82 124 123]/255;
% Copy the relevant subpanel to new figure
orgFig  = gcf;
hAx     = findobj(orgFig,'type', 'axes');
fNew    = figure;
hNew    = copyobj(hAx(2), fNew); close(orgFig);

set(hNew, 'pos', [0.23162 0.2233 0.72058 0.63107], 'FontName', 'Arial', 'FontSize', 16);
cH=hNew.Children;
set(cH(5),'MarkerFaceColor',Old_color)
set(cH(5),'MarkerEdgeColor',Edge_color)
set(cH(4),'Linewidth', 3, 'Color', Line_color) % scatter plot
set(cH(2:3), 'Linewidth', 2, 'Color', Line_color, 'LineStyle', '--') % CI lines
set(cH(1), 'LineStyle', 'none', 'FaceColor', Old_color) % background patch color
xlabel('Landmark shift'); ylabel('Memory bias');
axis square; grid off; box off;

% xlim([0.5 1]);
% ylim([0.3 1.1]);
% yticks([0.4 0.6 0.8 1])

saveas(fNew, fullfile(FigPath,'\LMShift','Corr_LMShift_MemBias1_Old'),'pdf');

end