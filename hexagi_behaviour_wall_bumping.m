function hexagi_behaviour_wall_bumping(Subjects,ProcPath,StatsPath,FigPath)
% Finds wall bumping time points and evaluates differences in wall bumping for the groups


if  nargin<1
    Subjects  = load('hexagi_subjects'); 
    ProcPath  = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
    StatsPath = 'C:\MasterThesis\Data\Hexagi\Behaviour\Stats';
    FigPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Figures';
end

fprintf('Finding and evaluating wall bumping \n')

nSubs        = length(Subjects);
YoungIdx     = Subjects < 200;
OldIdx       = Subjects >= 200;


%% Define wall bumping -10% of the arena size close to the boundary 
Centers     = [-175 -175];
Radius      = 5175;
BumpCutOff  = 4657.5;  

nBump       = []; 
pBump       = [];
Diff        = [];
for iSub  = 1:nSubs
    SubID = Subjects(iSub);
    
    nBumpSub    = [];
    pBumpSub    = [];
    DiffSub     = [];
    nBumpRun    = [];
    pNonBumpRun = [];
    DiffRun     = [];    
    
    for iRun = 1:2
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Test', sprintf('Test%d.mat', iRun)));
        load(fullfile(ProcPath, sprintf('Sub%d', SubID),'Test\Player', sprintf('PlayerTest%d.mat', iRun)));    

        % Find bump time points for the phase
        X           = [PlayerTest.LocX PlayerTest.LocY];       
        BumpIdx     = pdist2(X,Centers) > BumpCutOff;
        Bump        = PlayerTest(BumpIdx,:);
                     
        % Find non bumping time points
        NonBump     = PlayerTest(~BumpIdx,:);
                
        % Number of wall bump time points for the entire phase for the sub, one run
        nBumpRun    = height(Bump);
        
        % Probabilities 
        pBumpRun    = height(Bump) / height(PlayerTest);
        pNonBumpRun = height(NonBump) / height(PlayerTest);
        
        DiffRun     = pBumpRun - pNonBumpRun;
        
        %  Both runs
        nBumpSub    = [nBumpSub ; nBumpRun];
        pBumpSub    = [pBumpSub ; pBumpRun];
        DiffSub     = [DiffSub ; DiffRun];
        
    end

    % Number of wall bump time points for all subs
    nBump = [nBump ; mean(nBumpSub)];

    % Mean probability of bumps for all sub both runs
    pBump = [pBump ; mean(pBumpSub)];
    
    Diff = [Diff ; mean(DiffSub)];
    
end

% Save to use for the performance script
if ~exist(fullfile(StatsPath,'Test\Wall_bumping\'),'dir')
    mkdir(fullfile(StatsPath,'Test\Wall_bumping\')); end

save(fullfile(StatsPath,'Test\Wall_bumping\pBump'),'pBump');
save(fullfile(StatsPath,'Test\Wall_bumping\nBump'),'nBump');


%% Compare the groups
% Compare probability of bumping
[p,stats]           = vartestn([pBump(YoungIdx) [pBump(OldIdx);nan(4,1)]],'TestType','LeveneQuadratic'); 
[h,p,ci,stats]      = ttest2(pBump(OldIdx), pBump(YoungIdx),'vartype','unequal'); 
cohensD             = (mean(pBump(OldIdx)) - mean(pBump(YoungIdx))) / std(pBump(OldIdx));

% Compare differences in bumping
[p,stats]           = vartestn([Diff(YoungIdx) [Diff(OldIdx);nan(4,1)]],'TestType','LeveneQuadratic');
[h,p,ci,stats]      = ttest2(Diff(YoungIdx), Diff(OldIdx),'vartype','unequal'); 


%% Barplots showing the difference in bumping and non bumping time points (normalised) for the groups

data  = [pBump(YoungIdx) [pBump(OldIdx);nan(4,1)] ]; 

plotoptions                     = [];
plotoptions.title               = sprintf('Wall bumping');
plotoptions.fontSize            = 20;
plotoptions.fontName            = 'Gill Sans MT';
plotoptions.indMeas             = 'dots';            
plotoptions.ylabel              = 'Probability of wall bumping';
plotoptions.xticklabel          = {'Young' 'Old',};
plotoptions.barcolor            = [[0.0,0.5,0.5];[0 0.5 0.3]];

fHandle = hexagi_barplotscript(data, plotoptions);

% Save the figure
if ~exist(fullfile(FigPath,'\Wall_bumping'),'dir')
    mkdir(fullfile(FigPath,'\Wall_bumping')); end

fileName = fullfile(FigPath,'\Wall_bumping','Wall_bumping');
saveas(fHandle, fileName,'epsc')
    

%% Plot all time points for all trials for both runs 

% YOUNG
fH = figure('visible', 'on');
axis off
%title('Young')
hold on
axis equal 
Centers    = [-175 -175];
BumpCutOff = 4657.5;
viscircles(Centers,Radius,'color',[89 91 86]/255,'LineWidth',1);
axis off
box off

for iSub = 1:nSubs
    SubID = Subjects(iSub);
    if SubID <= 200
        for iRun = 1:2
            load(fullfile(ProcPath, sprintf('Sub%d', SubID),'Test', 'Player', sprintf('PlayerTest%d.mat', iRun)));    
            X       = [PlayerTest.LocX PlayerTest.LocY];       
            BumpIdx = pdist2(X,Centers) > BumpCutOff;
            a       = scatter(PlayerTest.LocX(~BumpIdx), PlayerTest.LocY(~BumpIdx), 0.5, [0.7 0.7 0.7], 'MarkerFaceColor',[0.7 0.7 0.7],'Linewidth',0.3);
            b       = scatter(PlayerTest.LocX(BumpIdx), PlayerTest.LocY(BumpIdx), 0.5, [141 85 74]/255, 'MarkerFacecolor', [0.0 0.5 0.5],'Linewidth',0.3);
        end
    end
end

%legend([a,b],'Non wall bumping','Wall bumping','Location','SouthEastOutside')

% Save the figure
FigName = fullfile(FigPath,'\Wall_bumping\Young');        
Fig = gcf;
saveas(gcf,FigName ,'epsc')


% OLD
fH = figure('visible', 'on');
axis off
%title('Old')
hold on
axis equal 
Centers  = [-175 -175];
viscircles(Centers,Radius,'color',[0.4,0.4,0.4],'LineWidth',0.3);
axis off

for iSub = 1:nSubs
    SubID = Subjects(iSub);
    if SubID > 200
        for iRun = 1:2
            load(fullfile(ProcPath, sprintf('Sub%d', SubID),'Test', 'Player', sprintf('PlayerTest%d.mat', iRun)));    
            X       = [PlayerTest.LocX PlayerTest.LocY];       
            BumpIdx = pdist2(X,Centers) > BumpCutOff;
            a = scatter(PlayerTest.LocX(~BumpIdx), PlayerTest.LocY(~BumpIdx), 0.5, [0.7 0.7 0.7], 'MarkerFaceColor',[0.7 0.7 0.7],'Linewidth',0.3);
            b = scatter(PlayerTest.LocX(BumpIdx), PlayerTest.LocY(BumpIdx), 0.5, [82 124 123]/255, 'MarkerFacecolor', [0 0.5 0.3],'Linewidth',0.3); 
        end
    end
end

%legend([a,b],'Non wall bumping','Wall bumping','Location','SouthEastOutside')

% Save the figure
FigName = fullfile(FigPath,'\Wall_bumping\Old');        
Fig = gcf;
saveas(gcf,FigName ,'epsc')


end