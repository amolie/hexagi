function hexagi_behaviour_navi_strategy(Input,Subjects,ProcPath,StatsPath,FigPath)
% This function looks at navigation strategy for the test phase 

% Choose input 1 to only evaluate forward entries (time points when the sub is standing still is excluded)
% Choose input 2 to also include backward entries (time points when the sub is standing still is excluded)

% Checks whether the distribution of correct object locations is equal in centre and surround for all subs
% Separates navigation into central and surround for both runs

% Plots all all trials for both runs for young and old

close all

%% List of subjects
if  nargin<1
    %Input     = 1; % Forward (not stand still)
    %Input     = 2; % AllMove  (not stand still)
    Subjects  = load('hexagi_subjects')';
    ProcPath  = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
    StatsPath = 'C:\MasterThesis\Data\Hexagi\Behaviour\Stats';
    FigPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Figures';
    
end

% Create output folders
if ~exist(fullfile(FigPath,'\Navi_strategy'),'dir')
    mkdir(fullfile(FigPath,'\Navi_strategy')); end

if ~exist(fullfile(StatsPath,'Test\Navi_strategy'),'dir')
    mkdir(fullfile(StatsPath,'Test\Navi_strategy')); end


nSubs         = length(Subjects);
YoungIdx      = Subjects <200;
OldIdx        = Subjects >= 200;


%% Specifics of the arena

% The whole arena
CenterX           = -175;                                                                      
CenterY           = -175;
Centers           = [CenterX CenterY];
Radius            = 5175;

% Navigation within here is central, the rest is surround (boundary based)
HalfRadius        = Radius/2;


%% Get the different (unique) correct object locations for each sub and run and check if the distance to the center varies between subjects. 
% For each participant there were 5 object locations for each run (5x2runs = 10 different object locations). 
% Each subset of object location was counterbalanced between participants.

corrLocs10        = [];
fprintf('Getting correct object locations from the test phase, both runs \n')

for iSub = 1:nSubs  
    for iRun = 1:2
        SubID = Subjects(iSub);
                
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Test', sprintf('Test%d.mat', iRun)));
        
        % Plot
         if  iRun == 1
            a = scatter(Test.CorrectLocX, Test.CorrectLocY, 'filled','MarkerFacecolor',[0.4 0.2 0.2]);
            hold on
            b = scatter(Test.LMLocX, Test.LMLocY,50,'MarkerFacecolor',[0.0 0.8 0.8],'MarkerEdgeColor',[0.0 0.5 0.5]); 
         else 
            figure; 
            c = scatter(Test.CorrectLocX, Test.CorrectLocY, 'filled','MarkerFacecolor',[0.4 0.2 0.2]);
            hold on
            d = scatter(Test.LMLocX, Test.LMLocY,50','MarkerFacecolor',[0.0 0.8 0.8],'MarkerEdgeColor',[0.0 0.5 0.5]);
         end
           
        % Arena circle and inner circle
        hold on
        axis equal 
        viscircles(Centers,Radius,'color',[0.4,0.4,0.4],'LineWidth',0.3);
        viscircles(Centers,HalfRadius,'color',[0.4,0.4,0.4],'LineWidth',0.3);
        axis off
              
        corrLocs(:,:, iRun, iSub) = unique([Test.CorrectLocX, Test.CorrectLocY], 'rows');
        hold on
        dist2center(:,iRun,iSub)  = pdist2(corrLocs(:,:, iRun, iSub), [-175 -175]);
    end
    tmpLocs     = [corrLocs(:,:,1,iSub); corrLocs(:,:,2,iSub)];
    corrLocs10  = [corrLocs10; tmpLocs];
    
    % The distance difference between objects in run 1 and run 2
    distDiff(:,iSub) = sort(dist2center(:,1,iSub))-sort(dist2center(:,2,iSub));
end

title('Correct object locations all subjects')
legend([a,b],'Object locations','Landmark','Location','SouthEastOutside')

% Save the figure
FigName = fullfile(FigPath,'\Navi_strategy\CorrectObjectLocations1_');        
Fig     = gcf;
saveas(gcf,FigName ,'png')
close all


%% Mean distances from center to all object correct object locations for each sub                
mObjDistAllSubs = [];

for iSub = 1:nSubs
    SubID = Subjects(iSub);
    
    ObjDistBothRuns = [];
    for iRun = 1:2
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Test', sprintf('Test%d.mat', iRun)),'Test');
        for iTrial                 = 1:length(Test.TrialStart)
            ObjLoc                 = [Test.CorrectLocX(iTrial) Test.CorrectLocY(iTrial)];
            Test.ObjDist(iTrial,1) = pdist2(Centers,ObjLoc); 
        end

        % Both runs
        ObjDistBothRuns = [ObjDistBothRuns ; Test.ObjDist];
    end
    
    % Mean for both runs
    mObjDist = mean(ObjDistBothRuns);
    
    % All subs
    mObjDistAllSubs = [mObjDistAllSubs ; mObjDist];

    save(fullfile(StatsPath,'\Test\Navi_strategy\mObjDistAllSubs'),'mObjDistAllSubs');
end


%% Check if there is a difference in number of object locations placed in center vs. surround for young vs. old
% Based on average distance from center to object

[p,stats]           = vartestn([mObjDistAllSubs(YoungIdx) [mObjDistAllSubs(OldIdx);nan(4,1)]],'TestType','LeveneQuadratic');
[h,p,ci,stats]      = ttest2(mObjDistAllSubs(YoungIdx), mObjDistAllSubs(OldIdx));

SEMYoung            = std(mObjDistAllSubs(YoungIdx))/sqrt(length(mObjDistAllSubs(YoungIdx)));
SEMOld              = std(mObjDistAllSubs(OldIdx))/sqrt(length(mObjDistAllSubs(OldIdx)));


%% Separate navigation into central and surround %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CentralAllSubsBR  = table;
SurroundAllSubsBR = table;
NaviStrategy      = [];

for iSub  =  1:nSubs 
    SubID = Subjects(iSub);
    
    fprintf('Getting central and surround time points for subject %d \n',SubID)
    
    % Create folder for each sub
    if ~exist(fullfile(ProcPath,sprintf('Sub%d',SubID),'Test\Navi_strategy\'),'dir') 
        mkdir(fullfile(ProcPath,sprintf('Sub%d',SubID),'Test\Navi_strategy\')); 
    end
    
    % Both runs
    CentralBR       = [];
    SurroundBR      = [];
    
    % Each run
    CentralRun      = [];
    SurroundRun     = [];
    
    for iRun = 1:2
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Test', sprintf('Test%d.mat', iRun)),'Test');
           
        % Run analysis on either only forward movements or all movements (including backwards)
        % Includes movement locations only, not stand still (taken out in the forward and backward trials that are loaded)           
        if  Input == 1                    
                % Forward 
                load(fullfile(ProcPath, sprintf('Sub%d',SubID),'\Test\Player\Backward\',sprintf('Forward_Move_Run%d',iRun)));
                Player  = Forward(:,{'LocTime' 'LocX' 'LocY'}) ;

        elseif  Input == 2
                % Forward and backward
                load(fullfile(ProcPath, sprintf('Sub%d',SubID),'\Test\Player\Backward\',sprintf('Forward_Move_Run%d',iRun)));
                load(fullfile(ProcPath, sprintf('Sub%d',SubID),'\Test\Player\Backward\',sprintf('Backward_Move_Run%d',iRun)));
                Player = [Forward(:,{'LocTime' 'LocX' 'LocY'}) ; Backward(:,{'LocTime' 'LocX' 'LocY'})];
                Player = Player(:,{'LocTime' 'LocX' 'LocY'}) ;                
        end
                  
        CSTrialsSub = [];   
        for iTrial = 1:length(Test.TrialStart)
            TimeOfInterest = Player.LocTime >= Test.NaviStart(iTrial) & Player.LocTime <= Test.Drop(iTrial);
            PlayerTrial = Player(TimeOfInterest,:);

            Central     = [];  
            Surround    = []; 
            
            % Find centre and surround time points for each trial
            X               = [PlayerTrial.LocX PlayerTrial.LocY];
           
            tempC           = pdist2(X,Centers) < HalfRadius;           
            Central         = PlayerTrial(tempC,:);
            tempS           = pdist2(X,Centers) >= HalfRadius;
            Surround        = PlayerTrial(tempS,:);
                        
            CSTrialsSub(iTrial,1)   = height(Central);
            CSTrialsSub(iTrial,2)   = height(Surround);
            
            % Central and surround timepoints for the entire run
            CentralRun      = [CentralRun ; Central] ;
            SurroundRun     = [SurroundRun ; Surround] ;
        end

        % Save the navigation preference for each sub, separated by run    
        save (fullfile(ProcPath, sprintf('Sub%d',SubID),'\Test\Navi_strategy\',sprintf('CentralRun%d',iRun)),'CentralRun');
        save (fullfile(ProcPath, sprintf('Sub%d',SubID),'\Test\Navi_strategy\',sprintf('SurroundRun%d',iRun)),'SurroundRun');
              
        % Both Runs
        CentralBR       = [CentralBR ; CentralRun];
        SurroundBR      = [SurroundBR ; SurroundRun];

    end
    
    % Add subID
    CentralBR(:,4)      = table(SubID);
    CentralBR.SubID     = CentralBR.Var4;
    CentralBR.Var4      = [];
    
    SurroundBR(:,4)     = table(SubID);
    SurroundBR.SubID    = SurroundBR.Var4;
    SurroundBR.Var4     = [];
    
    % Central and surround navi patterns for all subs both runs
    CentralAllSubsBR    = [CentralAllSubsBR ; CentralBR];
    SurroundAllSubsBR   = [SurroundAllSubsBR ; SurroundBR];
    
    PCentral            = height(CentralBR) / (height(CentralBR) + height(SurroundBR));
    PSurround           = height(SurroundBR) / (height(CentralBR) + height(SurroundBR));
    
    % Difference in the probablility of central to surround = navi strategy
    NaviStrategy        = [NaviStrategy; (PCentral - PSurround)];
       
end

save (fullfile(StatsPath,'\Test\Navi_strategy\CentralAllSubsBothRuns'),'CentralAllSubsBR');
save (fullfile(StatsPath,'\Test\Navi_strategy\SurroundAllSubsBothRuns'),'SurroundAllSubsBR');
save (fullfile(StatsPath,'\Test\Navi_strategy\NaviStrategy'),'NaviStrategy');


%% Plot all time points for all trials for both runs with all correct obj loc
load(fullfile(StatsPath,'\Test\Navi_strategy\CentralAllSubsBothRuns'),'CentralAllSubsBR');
load(fullfile(StatsPath,'\Test\Navi_strategy\SurroundAllSubsBothRuns'),'SurroundAllSubsBR');


TestBR = [];
for iSub  = 1:nSubs
    SubID = Subjects(iSub);
    
    for iRun = 1:2
        load(fullfile(ProcPath,sprintf('sub%d',SubID),'\Test',sprintf('Test%d',iRun)))
        % All movements including stand still
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Test\Player', sprintf('PlayerTest%d.mat', iRun)),'PlayerTest');
        Player = PlayerTest(:,{'LocTime' 'LocX' 'LocY'});
        TestBR = [TestBR ; Test];
    end
end


% YOUNG
YoungTest       = TestBR.SubID <200;
YoungCentral    = CentralAllSubsBR.SubID <200;
YoungSurround   = SurroundAllSubsBR.SubID <200;

fH = figure('visible', 'on');
axis off
%title(sprintf('Centre vs. surround time points, young subjects'))
%title('Young')
% Arena circle
hold on
axis equal 
Centers  = [-175 -175];
HalfRadius = Radius/2;
axis off

a = scatter(CentralAllSubsBR.LocX(YoungCentral), CentralAllSubsBR.LocY(YoungCentral), 0.5, [141 85 74]/255, 'MarkerFaceColor',[141 85 74]/255,'Linewidth',0.3);
b = scatter(SurroundAllSubsBR.LocX(YoungSurround), SurroundAllSubsBR.LocY(YoungSurround), 0.5, [141 85 74]/255, 'MarkerFacecolor', [141 85 74]/255,'Linewidth',0.3);
c = scatter(TestBR.CorrectLocX(YoungTest),TestBR.CorrectLocY(YoungTest),100, [89 91 86]/255, 'MarkerFaceColor',[190 188 124]/255,'MarkerEdgeColor',[89 91 86]/255);
%scatter(TestBR.DropLocX(YoungTest),TestBR.fDropLocY(YoungTest),2, 'r', 'MarkerFaceColor', 'r');
d = scatter(TestBR.LMLocX, TestBR.LMLocY,150,[89 91 86]/255,'MarkerFaceColor',[184 139 92]/255);
box('off')
legend([a,b,c,d],'Central navigation','Surround navigation','Correct object locations','Landmark','Location','SouthEastOutside') 
viscircles(Centers,Radius,'color',[89 91 86]/255,'LineWidth',1);
viscircles(Centers,HalfRadius,'color',[89 91 86]/255,'LineWidth',1);

% Save the figure
FigName = fullfile(FigPath,'\Navi_strategy\Young');        
Fig = gcf;
saveas(gcf,FigName ,'pdf')


% OLD
OldTest       = TestBR.SubID >= 200;
OldCentral    = CentralAllSubsBR.SubID >=200;
OldSurround   = SurroundAllSubsBR.SubID >=200;

fH = figure('visible', 'on');
axis off
title(sprintf('Centre vs. surround time points, old subjects'))
% Arena circle
hold on
axis equal 
Centers  = [-175 -175];
axis off

a = scatter(CentralAllSubsBR.LocX(OldCentral), CentralAllSubsBR.LocY(OldCentral), 0.5, [82 124 123]/255, 'MarkerFaceColor',[82 124 123]/255,'Linewidth',0.3);
b = scatter(SurroundAllSubsBR.LocX(OldSurround), SurroundAllSubsBR.LocY(OldSurround), 0.5, [82 124 123]/255, 'MarkerFacecolor', [82 124 123]/255,'Linewidth',0.3); 
c = scatter(TestBR.CorrectLocX(OldTest),TestBR.CorrectLocY(OldTest),100,  [89 91 86]/255, 'MarkerFaceColor', [190 188 124]/255,'MarkerEdgeColor',[89 91 86]/255);
%scatter(TestBR.DropLocX(OldTest),TestBR.DropLocY(OldTest),2, 'r', 'MarkerFaceColor', 'r')
d = scatter(TestBR.LMLocX, TestBR.LMLocY,150,[89 91 86]/255,'MarkerFaceColor',[184 139 92]/255);
box('off')
legend([a,b,c,d],'Central navigation','Surround navigation','Correct object locations','Landmark','Location','SouthEastOutside') 
viscircles(Centers,Radius,'color',[89 91 86]/255,'LineWidth',1);
viscircles(Centers,HalfRadius,'color',[89 91 86]/255,'LineWidth',1);

% Save the figure
FigName = fullfile(FigPath,'\Navi_strategy\Old');        
Fig = gcf;
saveas(gcf,FigName ,'pdf')

end            