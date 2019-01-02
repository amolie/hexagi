function hexagi_behaviour_test_centralVSsurround(Subjects,Bump,ProcPath,StatsPath,FigPath)
% Central vs. surround analysis, incl. barplot

% This function evaluates whether there is a difference in central vs. surround navigation strategy for old vs. young, both runs
% Gets info for surround vs. central for both runs and sub form the navi_strategy function
% Standardises the time spent in central vs. surround
% Finds mean central, surround and diff surround to central for each participants both runs
% Checks normal distributions
% Stats for both runs

% Barplots of C/S timepoints for the groups
% Barplots for the runs and groups separately - choose to plot number of time points or probabilities
% Controls for "anxiety" = temporal stability of navigation strategy
% Barplots of temporal stability

close all

if  nargin<1
    Subjects  = load('hexagi_subjects')';
    %Bump      = 0; %Include wall bumping time points
    %Bump      = 1; % Exclude wall bumping time points
    ProcPath  = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
    StatsPath = 'C:\MasterThesis\Data\Hexagi\Behaviour\Stats';
    FigPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Figures';
end

nSubs = length(Subjects);
fprintf('Evaluating surround vs. central navigation patterns for young vs. old \n')


%% Get info for surround vs. central for each run and sub, separate into young and old
Centers = [-175 -175];
BumpCutOff  = 4657.5;  

NaviStrategy = [];
for iRun = 1:2  
    
    for iSub  = 1:nSubs
        SubID = Subjects(iSub);
    
        load (fullfile(ProcPath, sprintf('sub%d',SubID),'\Test\Navi_strategy\',sprintf('SurroundRun%d',iRun)),'SurroundRun');
        load (fullfile(ProcPath, sprintf('sub%d',SubID),'\Test\Navi_strategy\',sprintf('CentralRun%d',iRun)),'CentralRun');
        
        if Bump == 1
            % Exclude wall bumps for the analysis
            X            = [SurroundRun.LocX SurroundRun.LocY];
            BumpIdx      = pdist2(X,Centers) > BumpCutOff;
            SurroundRun  = SurroundRun(~BumpIdx,:);

            X            = [CentralRun.LocX CentralRun.LocY];
            BumpIdx      = pdist2(X,Centers) > BumpCutOff;
            CentralRun   = CentralRun(~BumpIdx,:);
        end
        
        nCentral     = height(CentralRun);
        nSurround    = height(SurroundRun);
         
        % Normalise the data before concatenating runs and taking the means for each run
        % A control for differences in time spent navigating which might be different for the groups
        PC           = nCentral ./ (nCentral + nSurround);
        PS           = nSurround ./ (nCentral + nSurround);
        Diff_PC_PS   = PC - PS; 
        
        temp         = table(SubID,iRun,nCentral,PC,nSurround,PS,Diff_PC_PS,'VariableNames', ...
                       {'SubID','Run','nCentral','ProbCentral','nSurround','ProbSurround','Diff_ProbCentral_ProbSurround'});
        
        % Concatenate the info from the 2 runs for all subs
        NaviStrategy = [NaviStrategy ;temp]; 
    end
end


%% Find mean of normalised central and surround timepoints for both runs, and diff probability of central and probability surround

mCentral        = [];
mSurround       = [];
mDiff           = [];

for iSub        = 1:length(Subjects)
    SubID       = Subjects(iSub);
    SubIdx      = NaviStrategy.SubID == SubID;
   
    Central     = NaviStrategy.ProbCentral(SubIdx); 
    mCentral    = [mCentral ; mean(Central)];
    
    Surround    = NaviStrategy.ProbSurround(SubIdx);
    mSurround   = [mSurround ; mean(Surround)];
    
    Diff        = NaviStrategy.Diff_ProbCentral_ProbSurround(SubIdx);
    mDiff       = [mDiff ; mean(Diff)]; 
end

% Separate the groups
YoungIdx        = Subjects < 200;
mCentralYoung   = mCentral(YoungIdx);
mDiffYoung      = mDiff(YoungIdx);

OldIdx          = Subjects >=200;
mCentralOld     = mCentral(OldIdx);
mDiffOld        = mDiff(OldIdx);

% Save mDiff for the memory bias navigational strategy correlations
save(fullfile(StatsPath,'\Test\Navi_strategy\mDiff'));


%% Check normal distributions

% Q-Q plot, Kolmogorov-Smirnov, or Shapiro-Wilk (is the latter really that complicated in matlab)?
figure;
QQYoung         = qqplot(mDiffYoung);
figure;
QQOld           = qqplot(mDiffOld);

[h,p]           = kstest(mDiffYoung);
[h,p]           = kstest(mDiffOld);


%% Check difference in central to surround time points (normalised) for young and old

% Difference in prob. of central to surround for young vs. old
[p,stats]       = vartestn([mDiffYoung,[mDiffOld;nan(4,1)]],'TestType','LeveneQuadratic');
[h,p,ci,stats]  = ttest2(mDiffOld,mDiffYoung); %,'VarType','Unequal'); 

CohensD         = abs(mean(mDiffYoung) - mean(mDiffOld)) / std(mDiffOld); %based on the largest std

SEMYoung        = std(mDiffYoung) / sqrt(length(mDiffYoung));
SEMOld          = std(mDiffOld) / sqrt(length(mDiffOld));



%% Barplots showing the difference in central to surround time points (normalised) for the groups

data  = [mDiffYoung [mDiffOld;nan(4,1)] ]; 

plotoptions                     = [];
%plotoptions.title               = sprintf('Navigational strategy');
plotoptions.fontSize            = 20;
plotoptions.fontName            = 'Gill Sans MT';
plotoptions.indMeas             = 'dots';               % leave as dots if you have uneven number of datapoints per condition
plotoptions.ylabel              = 'Navigational preference';
plotoptions.ylim                = [-1 1];
plotoptions.ytick               = (-1:0.5:1);
plotoptions.yticklabel          = (-1:0.5:1);
plotoptions.xticklabel          = {'Young' 'Old'};
plotoptions.barcolor            = [[0.86 0.54 0.45] ; [0.61 0.73 0.73]];
fHandle = hexagi_barplotscript(data, plotoptions);
box('off')

% Save the figure
if ~exist(fullfile(FigPath,'\Navi_strategy'),'dir')
    mkdir(fullfile(FigPath,'\Navi_strategy')); end

FigName = fullfile(FigPath,'\Navi_strategy','NaviStrategy_backwardexcluded_wallbumpincluded');
saveas(fHandle, FigName,'epsc')
    
    
%% Barplots for the runs and groups separately

% Number of time points
%data = [ [NaviStrategy.nCentral(OldIdx);nan(4,1)] [NaviStrategy.nSurround(OldIdx);nan(4,1)] NaviStrategy.nCentral(YoungIdx) NaviStrategy.nSurround(YoungIdx) ]; 

% Normalised
data = [ NaviStrategy.ProbCentral(YoungIdx) NaviStrategy.ProbSurround(YoungIdx)... 
        [NaviStrategy.ProbCentral(OldIdx);nan(4,1)] [NaviStrategy.ProbSurround(OldIdx);nan(4,1)]...
       ]; 

plotoptions                     = [];
plotoptions.title               = sprintf('Navigational strategy separated in type and group');
plotoptions.fontSize            = 11;
plotoptions.fontName            = 'Gill Sans MT';
plotoptions.indMeas             = 'dots';               % leave as dots if you have uneven number of datapoints per condition
plotoptions.ylabel              = 'Mean number of central and surround time points ';
%plotoptions.xlabel              = '';
plotoptions.xticklabel          = {'Young central','Young surround','Old central','Old surround'};
plotoptions.barcolor            = [[0.0,0.5,0.5];[0.0,0.5,0.5];[0 0.5 0.3];[0 0.5 0.3]];

fHandle = hexagi_barplotscript(data, plotoptions);
xtickangle(45);

% Save the figure
FigName = fullfile(FigPath,'\Navi_strategy','NaviStrategy_groups');
saveas(fHandle, FigName,'png')


%% Find and compare mean distance to the centre for the groups %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DistCentre = [];
DistCentreRuns = [];

for iSub            = 1:nSubs
    SubID           = Subjects(iSub);
    DistCentreSub   = [];
    RunsSub         = [];
    
    for iRun = 1:2
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Test\Player', sprintf('PlayerTest%d.mat', iRun)),'PlayerTest')
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Test', sprintf('Test%d.mat', iRun)),'Test');
        
        X               = [PlayerTest.LocX PlayerTest.LocY];
        %Y              = [double(Test.LMLocX(1)) double(Test.LMLocY(1))];
        Y               = [-175 -175];
        DistCentreRun   = pdist2(X,Y); 
        
        % Mean distance to LM for both runs
        DistCentreSub   = [DistCentreSub ; DistCentreRun];
        RunsSub         = [RunsSub mean(DistCentreRun)];
    end 

    DistCentre          = [DistCentre ; mean(DistCentreSub)];
    DistCentreRuns      = [DistCentreRuns ; RunsSub];
end
save(fullfile(StatsPath,'\Test\Navi_strategy\DistCentre'),'DistCentre');


[p,stats]       = vartestn([DistCentre(YoungIdx),[DistCentre(OldIdx);nan(4,1)]],'testtype','LeveneQuadratic','display','on'); % sig
[h,p,ci,stats]  = ttest2(DistCentre(OldIdx),DistCentre(YoungIdx),'varType','unequal'); 
CohensD         = abs(mean(DistCentre(OldIdx)) - mean(DistCentre(YoungIdx))) / std(DistCentre(OldIdx)); %based on the largest std
SEMYoung        = std(DistCentre(YoungIdx)) / sqrt(length(DistCentre(YoungIdx)));
SEMOld          = std(DistCentre(OldIdx)) / sqrt(length(DistCentre(OldIdx)));


%% Barplots showing the difference mean distance to the centre for the groups

data  = [DistCentre(YoungIdx) [DistCentre(OldIdx);nan(4,1)] ]; 

plotoptions                     = [];
plotoptions.title               = sprintf('Navigational strategy');
plotoptions.fontSize            = 20;
plotoptions.fontName            = 'Gill Sans MT';
plotoptions.indMeas             = 'dots';               % leave as dots if you have uneven number of datapoints per condition
plotoptions.ylabel              = 'Distance to centre (vm)';
%plotoptions.ylim                = [-1 1];
%plotoptions.ytick               = (-1:0.2:1);
%plotoptions.yticklabel          = (-1:0.2:1);
plotoptions.xticklabel          = {'Young' 'Old'};
plotoptions.barcolor            = [[0.0,0.5,0.5];[0 0.5 0.3]];

fHandle = hexagi_barplotscript(data, plotoptions);

% Save the figure
if ~exist(fullfile(FigPath,'\Navi_strategy'),'dir')
    mkdir(fullfile(FigPath,'\Navi_strategy')); end

FigName = fullfile(FigPath,'\Navi_strategy','NaviStrategy_DistCentre');
saveas(fHandle, FigName,'epsc')


%% Compare over the runs
% Are many subs closer to the centre in the first run than the second?
Run1            = DistCentreRuns(:,1);
Run2            = DistCentreRuns(:,2);

% Young
[p,stats]       = vartestn([Run1(YoungIdx),Run2(YoungIdx)],'TestType','LeveneQuadratic','display','on'); 
[h,p,ci,stats]  = ttest(Run1(YoungIdx),Run2(YoungIdx)); %n.s
SEMYoungRun1    = std(Run1(YoungIdx)) /sqrt(length(Run1(YoungIdx)));
SEMYoungRun2    = std(Run2(YoungIdx)) /sqrt(length(Run2(YoungIdx)));

% Old
[p,stats]       = vartestn([Run1(OldIdx),Run2(OldIdx)],'TestType','LeveneQuadratic','display','on'); 
[h,p,ci,stats]  = ttest(Run1(OldIdx),Run2(OldIdx)); 
SEMOldRun1      = std(Run1(OldIdx)) /sqrt(length(Run1(OldIdx)));
SEMOldRun2      = std(Run2(OldIdx)) /sqrt(length(Run2(OldIdx)));


%% Control for "anxiety" = temporal stability of navigation strategy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Run1Idx         = NaviStrategy.Run == 1;
Run2Idx         = NaviStrategy.Run == 2; 

Young92Idx      = NaviStrategy.SubID < 200;
YoungRun1Idx    = Run1Idx & Young92Idx;
YoungRun2Idx    = Run2Idx & Young92Idx;

Old92Idx        = NaviStrategy.SubID >= 200;
OldRun1Idx      = Run1Idx & Old92Idx;
OldRun2Idx      = Run2Idx & Old92Idx;

% Young
[p,stats]       = vartestn([NaviStrategy.ProbCentral(YoungRun1Idx), ...
                  NaviStrategy.ProbCentral(YoungRun2Idx)],'TestType','LeveneQuadratic'); 
[h,p,ci,stats]  = ttest(NaviStrategy.ProbCentral(YoungRun1Idx),NaviStrategy.ProbCentral(YoungRun2Idx)); 
SEMYoungRun1    = std(NaviStrategy.ProbCentral(YoungRun1Idx))/sqrt(length((NaviStrategy.ProbCentral(YoungRun1Idx))));
SEMYoungRun2    = std(NaviStrategy.ProbCentral(YoungRun2Idx))/sqrt(length((NaviStrategy.ProbCentral(YoungRun2Idx))));

% Old
[p,stats]       = vartestn([NaviStrategy.ProbCentral(OldRun1Idx), ... 
                  NaviStrategy.ProbCentral(OldRun2Idx)],'TestType','LeveneQuadratic');
[h,p,ci,stats]  = ttest(NaviStrategy.ProbCentral(OldRun1Idx),NaviStrategy.ProbCentral(OldRun2Idx)); %n.s
SEMOldRun1      = std(NaviStrategy.ProbCentral(OldRun1Idx))/sqrt(length((NaviStrategy.ProbCentral(OldRun1Idx))));
SEMOldRun2      = std(NaviStrategy.ProbCentral(OldRun2Idx))/sqrt(length((NaviStrategy.ProbCentral(OldRun2Idx))));


%% Barplot showing the probability of central to surround run1 compared to run2 for young

data = [ NaviStrategy.ProbCentral(YoungRun1Idx) NaviStrategy.ProbCentral(YoungRun2Idx) ];

plotoptions                     = [];
%plotoptions.title               = sprintf('Temporal stability of navigational strategy for young');
plotoptions.fontSize            = 20;
plotoptions.fontName            = 'Gill Sans MT';
plotoptions.indMeas             = 'lines';               % leave as dots if you have uneven number of datapoints per condition
plotoptions.ylabel              = 'Proportions of central to surround';
plotoptions.xticklabel          = {'Run 1','Run 2'};
plotoptions.ylim                = [0 1];
plotoptions.ytick               = (0:0.5:1);
plotoptions.yticklabel          = (0:0.5:1);
plotoptions.barcolor            = [0.86 0.54 0.45];

fHandle = hexagi_barplotscript(data, plotoptions);
box('off')

% Save the figure 
FigName = fullfile(FigPath,'\Navi_strategy','NaviStability_Barplot_Young');
saveas(fHandle, FigName,'epsc')

    
%% Barplot showing the probability of central to surround run1 compared to run2 for old

data = [ NaviStrategy.ProbCentral(OldRun1Idx) NaviStrategy.ProbCentral(OldRun2Idx) ];

plotoptions                     = [];
%plotoptions.title               = sprintf('Temporal stability of navigational strategy for old');
plotoptions.fontSize            = 20;
plotoptions.fontName            = 'Gill Sans MT';
plotoptions.indMeas             = 'lines';               % leave as dots if you have uneven number of datapoints per condition
plotoptions.ylabel              = 'Central / Surround time points';
plotoptions.xticklabel          = {'Run 1','Run 2'};
plotoptions.ylim                = [0 1];
plotoptions.ytick               = (0:0.5:1);
plotoptions.yticklabel          = (0:0.5:1);
plotoptions.barcolor            = [0.61 0.73 0.73];

fHandle = hexagi_barplotscript(data, plotoptions);

% Save the figure 
FigName = fullfile(FigPath,'\Navi_strategy','NaviStability_Barplot_Old');
saveas(fHandle, FigName,'epsc')


%% Barplot showing the distance to the centre in run 1 compared to run2 for young

data = [ DistCentreRuns(YoungIdx,1) DistCentreRuns(YoungIdx,2) ];

plotoptions                     = [];
plotoptions.title               = sprintf('Temporal stability of navigational strategy for young');
plotoptions.fontSize            = 20;
plotoptions.fontName            = 'Gill Sans MT';
plotoptions.indMeas             = 'lines';               % leave as dots if you have uneven number of datapoints per condition
plotoptions.ylabel              = 'Distance to centre (vm)';
% plotoptions.ylim                = ([0 4500]);
% plotoptions.yticks              = ([0 2500 4500]);
% plotoptions.yticklabel          = ([0 2500 4500]);
plotoptions.xticklabel          = {'Run 1','Run 2'};
plotoptions.barcolor            = [0.0,0.5,0.5];

fHandle = hexagi_barplotscript(data, plotoptions);

% Save the figure 
FigName = fullfile(FigPath,'\Navi_strategy','NaviStability_Centre_Barplot_Young');
saveas(fHandle, FigName,'epsc')

    
%% Barplot showing the distance to the centre in run1 compared to run2 for old

data = [ DistCentreRuns(OldIdx,1) DistCentreRuns(OldIdx,2) ];

plotoptions                     = [];
%plotoptions.title               = sprintf('Temporal stability of navigational strategy for old');
plotoptions.fontSize            = 20;
plotoptions.fontName            = 'Gill Sans MT';
plotoptions.indMeas             = 'lines';               % leave as dots if you have uneven number of datapoints per condition
plotoptions.ylabel              = 'Distance to centre (vm)';
plotoptions.xticklabel          = {'Run 1','Run 2'};
plotoptions.barcolor            = [0 0.5 0.3];

fHandle = hexagi_barplotscript(data, plotoptions);

% Save the figure 
FigName = fullfile(FigPath,'\Navi_strategy','NaviStability_Centre_Barplot_Old');
saveas(fHandle, FigName,'epsc')


%% Correlate navigational strategy and backward movements

% Get probailities of backward movements
load(fullfile(StatsPath,'\Test\Backward\PBackwardYoung_Move'),'PBackwardYoung','nBackwardSubs');
load(fullfile(StatsPath,'\Test\Backward\PBackwardOld_Move'),'PBackwardOld')

PBackward_Move = [PBackwardYoung ; PBackwardOld];

[r,p] = corr(mDiff,PBackward_Move);
r2 = r^2;


%% Plot

figure;
a = scatter(mDiff,PBackward_Move,'MarkerEdgeColor',[0.4 0.8 0.6],'MarkerFaceColor',[0.4 0.8 0.6]);
lsline
%title(sprintf('Correlations, r = %.3f, r2 = %.3f, p = %.3f',r,r2,p));
xlabel('Navigational strategy','Fontsize',20); 
ylabel('Backward movements','Fontsize',20);

FigName = fullfile(FigPath,'\Navi_strategy','Correlation_NaviStrategy_Backward_WBIncluded');
fig = gcf;
saveas(gcf,FigName,'epsc')

end