function hexagi_behaviour_chance(Subjects,ProcPath,StatsPath,FigPath)

% From Bellmund et al., Deforming the metric of cognitive maps distorts memory

% Larger values indicate better performance
% Chance = 0.5
% Memory score = the proportion of random locations further away from the
% correct position than the observed response position

if  nargin<1
    Subjects  = load('hexagi_subjects')';
    ProcPath  = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
    StatsPath = 'C:\MasterThesis\Data\Hexagi\Behaviour\Stats';
    FigPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Figures';    
end

nSubs         = length(Subjects);
YoungIdx      = Subjects < 200;
OldIdx        = Subjects >= 200;


%% Calculate memory scores %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up parameters
arenaRadius = 5175;
arenaCentre = [-175 -175];
nRanPos = 10000;

% Generate random circular coordinates
randRadii = randi([0 arenaRadius],[nRanPos,1]);    %radians
randAng   = deg2rad(randi([1 360],[nRanPos,1]));

% Convert to cartesian coordinates
[ranPos(:,1), ranPos(:,2)] = pol2cart(randAng, randRadii);

% Shift to account for arena shift origin       
% Accounts for the centre not being 0
ranPos(:,1) = ranPos(:,1)+arenaCentre(1);
ranPos(:,2) = ranPos(:,2)+arenaCentre(2);

% Load the correct object locations
for iSub    = 1:nSubs 
    SubID   = Subjects(iSub);
    a = [];
    if  ~exist(fullfile(FigPath,'\Subjects\',sprintf('Sub%d',SubID),'MemoryScore.png'))
        a = figure('Visible','on');
    end
    
    memScoreSub = [];
    for iRun  = 1:2
        SubID = Subjects(iSub);
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Test', sprintf('Test%d.mat', iRun)));
        
        for iTrial = 1:length(Test.TrialStart)
            
            % Correct coordinate
            corrLoc = [Test.CorrectLocX(iTrial) Test.CorrectLocY(iTrial)];
        
            % Response location coordinate
            respLoc = [Test.DropLocX(iTrial) Test.DropLocY(iTrial)];
        
            % Distance from the correct location to all random locations
            ranDists = pdist2(ranPos(:,:),corrLoc,'Euclidean');

            % Get distance error of current trial 
            %errDist = pdist2(respLoc,corrLoc,'Euclidean');
            errDist = Test.DropError(iTrial);
        
            % Memory score = proportion of smaller distances from the random distribution
            memScoreRun(iTrial,:) = sum(errDist < ranDists)/nRanPos;
            
            % Diagnostics plot 1
            if ~isempty(a)
                hold on
                scatter(ranPos(:,1), ranPos(:,2),2,'black','filled')
                viscircles(arenaCentre, arenaRadius,'color',[0.4,0.4,0.4],'LineWidth',0.3)
                scatter(corrLoc(:,1), corrLoc(:,2), 100, [0.4 0.2 0.2],'filled')
                scatter(respLoc(:,1), respLoc(:,2), 50, [0.0 0.6 0.5],'filled')
                axis square
                axis off      
            end
        end
        
        % Mean of both runs
        memScoreSub = [memScoreSub ; memScoreRun];
    
    end
    
    % All subs
    MemScore(iSub,:) = mean(memScoreSub);
        
    % Save the figure for each sub
    if ~exist(fullfile(FigPath,'\Subjects',sprintf('Sub%d',SubID)),'dir')
        mkdir(fullfile(FigPath,'\Subjects',sprintf('Sub%d',SubID)));
    end
    FigName = fullfile(FigPath,'\Subjects\',sprintf('Sub%d',SubID),'MemoryScore');        
    Fig = gcf;
    saveas(gcf,FigName ,'png')
    close all
    
end

% Save the memory scores
if ~exist(fullfile(StatsPath,'\Test\MemoryScore'),'dir')
    mkdir(fullfile(StatsPath,'\Test\MemoryScore'));
end
save(fullfile(StatsPath,'\Test\MemoryScore\MemScore'),'MemScore')


% Diagnostic plot 2

b = figure; hold on
histogram(ranDists, 50,'DisplayStyle', 'stairs');
%line([errDist errDist], [0 max(ylim)])                 


%% Compare the groups and to chance 
[hGroups,pGroups,ciGroups,statsGroups] = ttest2(MemScore(YoungIdx),MemScore(OldIdx));

[hYoung,pYoung,ciYoung,statsYoung] = ttest(MemScore(YoungIdx),0.5);
[hOld,pOld,ciOld,statsOld] = ttest(MemScore(OldIdx),0.5);


%% Bar plot of memory scores

data = [ MemScore(YoungIdx) [MemScore(OldIdx);nan(4,1)] ];

plotoptions                     = [];
%plotoptions.title               = sprintf('');
plotoptions.fontSize            = 20;
plotoptions.fontName            = 'Gill Sans MT';
plotoptions.indMeas             = 'dots';               % leave as dots if you have uneven number of datapoints per condition
plotoptions.ylabel              = 'Memory score';
% plotoptions.yticks              = (0:0.5:1);
% plotoptions.yticklabels         =  {'0' '0.5' '1'};
plotoptions.xticklabel          = {'Young' 'Old'};
plotoptions.barcolor            =  [[0.0,0.5,0.5];[0 0.5 0.3]];

fHandle = hexagi_barplotscript(data, plotoptions);

% Save the figure
if ~exist(fullfile(FigPath,'MemScore'),'dir') 
    mkdir(fullfile(FigPath,'MemScore')); 
end

fileName = fullfile(FigPath,'\MemScore\MemScore');
saveas(fHandle, fileName,'png')


end