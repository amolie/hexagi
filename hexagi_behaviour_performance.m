function hexagi_behaviour_performance(Subjects,ProcPath,FigPath,StatsPath)
% Define and evaluate performance
% Mean distance error for all trials of equal object type/locations

% Exclude backward movements for the correlation with navigation strategy
        
if  nargin<1
    Subjects  = load('hexagi_subjects')';
    ProcPath  = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
    StatsPath = 'C:\MasterThesis\Data\Hexagi\Behaviour\Stats';
    FigPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Figures';
end

nSubs         = length(Subjects);
YoungIdx      = Subjects <200;
OldIdx        = Subjects >= 200;


%% PERFORMANCE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Performance = [];
for iSub    = 1:nSubs 
    SubID   = Subjects(iSub);
    
    PerformanceSub = [];
    for iRun  = 1:2
                
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Test', sprintf('Test%d.mat', iRun)));
        Test = sortrows(Test,'Object');
        
        % Performance
        PerformanceRun  = [mean(Test.DropError(1:6)) mean(Test.DropError(7:12)) mean(Test.DropError(13:18)) ... 
                          mean(Test.DropError(19:24)) mean(Test.DropError(25:30))]';  
        
        % Performance both runs
        PerformanceSub  = [PerformanceSub ; PerformanceRun];
    end
    
    % All subs
    Performance         = [Performance ; mean(PerformanceSub)];
end

if ~exist(fullfile(StatsPath,'Test\Performance'),'dir') 
    mkdir(fullfile(StatsPath,'Test\Performance')); end
save(fullfile(StatsPath,'\Test\Performance\Performance'),'Performance')


%% Check differences in Performance for the groups
[p,stats]       = vartestn([Performance(YoungIdx),[Performance(OldIdx);nan(4,1)]],'TestType','LeveneQuadratic');
[h,p,ci,stats]  = ttest2(Performance(OldIdx),Performance(YoungIdx)); 

SEMYoung        = std(Performance(YoungIdx)) / sqrt(length(Performance(YoungIdx)));
SEMOld          = std(Performance(OldIdx)) / sqrt(length(Performance(OldIdx)));

CohensD         = abs(mean(Performance(YoungIdx)) - mean(Performance(OldIdx))) / std(Performance(OldIdx));


%% Barplot of Performance

data = [ Performance(YoungIdx) [Performance(OldIdx);nan(4,1)] ];

plotoptions                     = [];
%plotoptions.title               = sprintf('');
plotoptions.fontSize            = 20;
plotoptions.fontName            = 'Gill Sans MT';
plotoptions.indMeas             = 'dots';               % leave as dots if you have uneven number of datapoints per condition
plotoptions.ylabel              = 'Performance';
%plotoptions.xlabel              = '';
plotoptions.xticklabel          = {'Young' 'Old'};
plotoptions.barcolor            =  [[0.0,0.5,0.5];[0 0.5 0.3]];

fHandle = hexagi_barplotscript(data, plotoptions);

% Save the figure
if ~exist(fullfile(FigPath,'Performance'),'dir') 
    mkdir(fullfile(FigPath,'Performance')); 
end
box off
fileName = fullfile(FigPath,'\Performance\Performance');
saveas(fHandle, fileName,'epsc')


end
