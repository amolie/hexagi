function hexagi_behaviour_reg_learning(Subjects,StatsPath,FigPath)
% Regress backward movement, navigational preference and wall bumping on learning. 

if  nargin<1
    Subjects  = load('hexagi_subjects')';
    StatsPath = 'C:\MasterThesis\Data\Hexagi\Behaviour\Stats';
    FigPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Figures';
end

nSubs         = length(Subjects);
YoungIdx      = Subjects <200;
OldIdx        = Subjects >= 200;


%% REGRESSION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Dependent variable: learning
% Independent variables: backward movements, navigational preference and wall bumping
% grey  = navi preference = x1
% green = backward = x2
% blue  = bumping = x3


%% Load regressors and learning
load(fullfile(StatsPath,'\Test\Navi_strategy\NaviStrategy')); % = PCentral - PSurround

load(fullfile(StatsPath,'\Test\Backward\PBackwardYoung_Move'),'PBackwardYoung','nBackwardSubs');
load(fullfile(StatsPath,'\Test\Backward\PBackwardOld_Move'),'PBackwardOld','nBackwardSubs');
PBackward = [PBackwardYoung ; PBackwardOld];

load(fullfile(StatsPath,'Test\Wall_bumping\nBump'));

load(fullfile(StatsPath,'\Test\Learning\Learning'),'Learning')


%% Young
X = [zscore(NaviStrategy(YoungIdx)) zscore(nBackwardSubs(YoungIdx)) zscore(nBump(YoungIdx)) ]; % Add thigmotaxis 
Y = zscore(Learning(YoungIdx));

[Youngb,~,~] = glmfit(X,Y,'normal');
Young       = fitlm(X,Y)               %uses ordinary least squares.
CIbYoung    = coefCI(Young)

% Partial regression plots
InModel     = Young.VariableInfo.InModel(1:3)';

figure; 
addedvarplot(X,Y,1,InModel) % Holding the other variables constant!
xlabel('Preference | Backward & Wall bumping')
FigName = fullfile(FigPath,'\Learning','Partial_Regression_Preference_Young');
fig = gcf;
saveas(gcf,FigName,'png')

figure; addedvarplot(X,Y,2,InModel)
xlabel('Backward | Preference & Wall bumping')
FigName = fullfile(FigPath,'\Learning','Partial_Regression_Backward_Young');
fig = gcf;
saveas(gcf,FigName,'png')

figure; addedvarplot(X,Y,3,InModel) 
xlabel('Wall bumping | Backward & Wall bumping')
FigName = fullfile(FigPath,'\Learning','Partial_Regression_WallBumping_Young');
fig = gcf;
saveas(gcf,FigName,'png')

% Plot young
figure;  
a = plot(Youngb(2),1,'o','MarkerFaceColor',[0.4,0.4,0.4],'MarkerEdgeColor',[0.4,0.4,0.4]);
hold on; 
b = plot(Youngb(3),2,'o','MarkerFaceColor',[0.0 0.5 0.3],'MarkerEdgeColor',[0.0 0.5 0.3]);
c = plot(Youngb(4),3,'o','MarkerFaceColor',[0.3,0.8,0.8],'MarkerEdgeColor',[0.3,0.8,0.8]);

yticks(1:3);
yticklabels({'Preference', 'Backward', 'Wall bumping'});
xlabel('Learning');
set(gca,'fontSize',20)
ylim([0 3.5]);
xlim([-1.5 1.5]);

plot([CIbYoung(2,1), CIbYoung(2,2)],[1,1],'-','LineWidth',2,'color',[0.4,0.4,0.4]); %grey = navi preference = x1
plot([CIbYoung(3,1), CIbYoung(3,2)],[2,2],'-','LineWidth',2,'color',[0.0 0.5 0.3]); %green = backward = x2
plot([CIbYoung(4,1), CIbYoung(4,2)],[3,3],'-','LineWidth',2,'color',[0.3,0.8,0.8]); %blue = bumping = x3


%% Old
X = [zscore(NaviStrategy(OldIdx)) zscore(nBackwardSubs(OldIdx)) zscore(nBump(OldIdx)) ]; % Add thigmotaxis 
Y = zscore(Learning(OldIdx));

[Oldb,~,~]  = glmfit(X,Y,'normal');
Old         = fitlm(X,Y)
CIbOld      = coefCI(Old)

% Plot old
d = plot(Oldb(2),0.8,'o','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',[0.4,0.4,0.4]);
e = plot(Oldb(3),1.8,'o','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',[0.0 0.5 0.3]);
f = plot(Oldb(4),2.8,'o','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',[0.3,0.8,0.8]);

plot([CIbOld(2,1), CIbOld(2,2)],[0.8,0.8],'-','LineWidth',2,'color',[0.4,0.4,0.4]);
plot([CIbOld(3,1), CIbOld(3,2)],[1.8,1.8],'-','LineWidth',2,'color',[0.0 0.5 0.3]);
plot([CIbOld(4,1), CIbOld(4,2)],[2.8,2.8],'-','LineWidth',2,'color',[0.3,0.8,0.8]);

%legend([a,b,c,d,e,f],'Navigational preference (young)','Backward movements (young)','Wall bumping (young)','Navigational preference (old)', ... 
%                      'Backward movements (old)','Wall bumping (old)','Location','SouthWestOutside')

% Create the line at 0
y           = linspace(0.5,3.8,10);
x           = repmat(0,10); 
Line        = plot(x,y,'lineWidth',2,'color',[0.8,0.8,0.8],'LineStyle','--');

box off
FigName = fullfile(FigPath,'\Learning','Regression_Learning');
fig = gcf;
saveas(gcf,FigName,'epsc')


% Partial regression plots
InModel     = Old.VariableInfo.InModel(1:3)';

figure;
addedvarplot(X,Y,1,InModel) % Holding the other variables constant!
xlabel('Preference | Backward & Wall bumping')
FigName = fullfile(FigPath,'\Learning','Partial_Regression_Preference_Old');
fig = gcf;
saveas(gcf,FigName,'png')

figure;
addedvarplot(X,Y,2,InModel)
xlabel('Backward | Preference & Wall bumping')
FigName = fullfile(FigPath,'\Learning','Partial_Regression_Backward_Old');
fig = gcf;
saveas(gcf,FigName,'png')

figure;
addedvarplot(X,Y,3,InModel) 
xlabel('Wall bumping | Backward & Wall bumping')
FigName = fullfile(FigPath,'\Learning','Partial_Regression_WallBumping_Old');
fig = gcf;
saveas(gcf,FigName,'png')

end
