function hexagi_behaviour_learning(Subjects,ProcPath,StatsPath,FigPath)
% Define and evaluate learning

% Learning = Change in drop error from over time 
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


%% LEARNING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Learning    = [];
for iSub    = 1:nSubs 
    SubID   = Subjects(iSub);
    
    LearningSub    = [];
    for iRun  = 1:2
        SubID = Subjects(iSub);
                
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Test', sprintf('Test%d.mat', iRun)));
        Test = sortrows(Test,'Object');
        
        % Get the drop error from the first and last time the object is tested
        Object1         = Test(1:6:end,:);
        Object6         = Test(6:6:end,:);
        
        % Calulate learning
        LearningRun     = Object1.DropError - Object6.DropError; 
         
        % Learning both runs
        LearningSub     = [LearningSub ; LearningRun];
    end
    
    % All subs
    Learning            = [Learning ; mean(LearningSub)]; 
end

if ~exist(fullfile(StatsPath,'Test\Learning'),'dir') 
    mkdir(fullfile(StatsPath,'Test\Learning')); 
end
save(fullfile(StatsPath,'\Test\Learning\Learning'),'Learning')


%% Check differences in learning for the groups - Schuck et al., 2015
[p,stats]       = vartestn([Learning(YoungIdx),[Learning(OldIdx);nan(4,1)]],'TestType','LeveneQuadratic'); 
[h,p,ci,stats]  = ttest2(Learning(OldIdx),Learning(YoungIdx));

SEMYoung        = std(Learning(YoungIdx)) / sqrt(length(Learning(YoungIdx)));
SEMOld          = std(Learning(OldIdx)) / sqrt(length(Learning(OldIdx)));
CohensD         = (mean(Learning(YoungIdx)) - mean(Learning(OldIdx))) / std(Learning(OldIdx)); %based on the largest std        


%% Barplot of learning

data = [ Learning(YoungIdx) [Learning(OldIdx);nan(4,1)] ];

plotoptions                     = [];
plotoptions.title               = sprintf('Learning');
plotoptions.fontSize            = 11;
plotoptions.fontName            = 'Gill Sans MT';
plotoptions.indMeas             = 'dots';               % leave as dots if you have uneven number of datapoints per condition
plotoptions.ylabel              = '';
%plotoptions.xlabel              = '';
plotoptions.xticklabel          = {'Young' 'Old'};
plotoptions.barcolor            =  [[0.0,0.5,0.5];[0 0.5 0.3]];

fHandle = hexagi_barplotscript(data, plotoptions);

% Save the figure
if ~exist(fullfile(FigPath,'Learning'),'dir') 
    mkdir(fullfile(FigPath,'Learning')); 
end
box off
fileName = fullfile(FigPath,'\Learning\Learning');
saveas(fHandle, fileName,'epsc')


end