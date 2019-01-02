function hexagi_behaviour_player_backward_transfer(Subjects,TimePoints,ProcPath,StatsPath,FigPath)

% Gets player location and yaw (orientation) for the trials in the transfer phase, from fixation end to drop, and checks if they are equally long
% Identifies backward and forward movements
% Normalises the backward time points 
% Check if there is a difference in backward movements for young vs. old
% Plot player locations and yaw

% Not updated to load only movement time points from the movementVSstandstill function!!

if  nargin<1
    Subjects  = load('hexagi_subjects')';
    
    TimePoints  = 'Movement';                    % Only evaluate time points when the sub is moving
    %TimePoints  = 'Movement_and_StandStill';     % Evaluate all time points including stand still
    %TimePoints  = 'StandStill';                  % Evaluate only stand still time points = only viewing ahead or not?? %aka, StandStill_nonBackward
    
    ProcPath    = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
    StatsPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Stats';
    FigPath     = 'C:\MasterThesis\Data\Hexagi\Behaviour\Figures';    
end

nSubs = length(Subjects);


%% Get equal number of player locations and yaw - including stand still
% Only player locations occuring after the cue is no longer visible:
% if yaw is included this one has to be used because there is no
% yaw when the cue is present.

Trial          = []; 
nonEqualTrials = [];

for iSub    = 1:nSubs
    SubID   = Subjects(iSub);
    
    for iRun = 1:2
        fprintf('Check which trials have unequal number of player locations and yaw, sub%d, run%d \n', SubID, iRun)
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Transfer', sprintf('Transfer%d.mat', iRun)),'Transfer');
        
        % Player locations also include standing still
        load(fullfile(ProcPath, sprintf('sub%d',SubID), 'Transfer\Player', sprintf('PlayerTransfer%d',iRun)),'PlayerTransfer')
        
        for iTrial = 1:length(Transfer.CueStart)
            
            TimeOfInterest  = PlayerTransfer.LocTime >= Transfer.FixEnd(iTrial) & PlayerTransfer.LocTime <= Transfer.Drop(iTrial);
            Trial           = PlayerTransfer(TimeOfInterest,:);
            
            % Find time points that don't have equal length of loc and yaw
            nonEqualIdx   = ismissing(Trial.YawTime);
            nonEqual      = Trial(nonEqualIdx,:);
            
            % Location starts 100ms before yaw: delete the location row
            if  height(nonEqual) == 1
                Trial(1,:)       = [];
            end

            % Double check 
            if  ~isempty(nonEqual)
                nonEqualTrials  = [nonEqualTrials ; SubID iRun iTrial height(nonEqual)];
            end
        end        
    end
end

SomethingWentWrong = nonEqualTrials(:,4) ~= 1;
if  SomethingWentWrong == 1
    error('The difference in location and yaw time points is > 1')
end


%% Backward & forward movement

nBackwardSubs = [];
nForwardSubs  = [];
for iSub  = 1:nSubs
    SubID = Subjects(iSub);
    
    % Create output folder for each sub
    if  ~exist(fullfile(ProcPath,sprintf('Sub%d',SubID),'\Transfer\Player\Backward'),'dir')
    mkdir(fullfile(ProcPath,sprintf('Sub%d',SubID),'\Transfer\Player\Backward')); end

    for iRun = 1:2
        fprintf('Get forward and backward movements for sub%d,run%d \n', SubID,iRun)
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Transfer', sprintf('Transfer%d.mat', iRun)),'Transfer');

        switch  TimePoints
            case 'Movement'
                % Only evaluate time points when the sub is moving
                load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Transfer\Player', sprintf('PlayerTransferMove%d.mat', iRun)),'PlayerTransferMove'); 
                Player = PlayerTransferMove;
                
            case 'Movement_and_StandStill'
                % Evaluate all time points including stand still
                load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Transfer\Player', sprintf('PlayerTransfer%d.mat', iRun)),'PlayerTransfer'); 
                Player = PlayerTransfer;
            
            case 'StandStill'
                % Evaluate all time points including stand still
                load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Transfer\Player', sprintf('PlayerStandStill%d.mat', iRun)),'PlayerStandStill'); 
                Player = PlayerStandStill;
        end
                
        DiffLocX                = [nan(1,1) ; diff(Player.LocX)];
        DiffLocY                = [nan(1,1) ; diff(Player.LocY)];
        % TH for player locations
        [MoveDir, ~]            = cart2pol(DiffLocX,DiffLocY); 
        
        % TH for yaw
        [Yaw]                   = cart2pol(Player.YawX,Player.YawY);

        % Compare angular differences for movement and yaw   
        AngDiff                 = circ_dist(MoveDir,Yaw);
        
        % Add to the table for the entire run to get the locations and times
        Player.AngDiff          = AngDiff;
        
                    
        %% Get backward movements
        % = the player moves in opposite direction to viewing direction 
            
        % Differences in circular angles > radians for 170deg (abs)             
        UpperTresh              = deg2rad(170);
            
        % Get time points that are > than 170 degrees
        BackwardIdx             = abs(Player.AngDiff) >= UpperTresh ; 
            
        % The backward movements for the run
        Backward                = Player(BackwardIdx,:);
            
            
        %% Get forward movement for each run 
        ForwardIdx              = abs(Player.AngDiff) < UpperTresh ; 

        % The forward movements for the trial
        Forward                 = Player(ForwardIdx,:);
        
        % Save forward and backward movements for the run
        switch  TimePoints
            case 'Movement'
                save(fullfile(ProcPath, sprintf('Sub%d',SubID),'\Transfer\Player\Backward',sprintf('Backward_Move_Run%d',iRun)),'Backward');
                save(fullfile(ProcPath, sprintf('Sub%d',SubID),'\Transfer\Player\Backward',sprintf('Forward_Move_Run%d',iRun)),'Forward');
            
            case 'Movement_and_StandStill'
                save(fullfile(ProcPath, sprintf('Sub%d',SubID),'\Transfer\Player\Backward',sprintf('Backward_Move_and_StandStill_Run%d',iRun)),'Backward');
                save(fullfile(ProcPath, sprintf('Sub%d',SubID),'\Transfer\Player\Backward',sprintf('Forward_Move_and_StandStill_Run%d',iRun)),'Forward');
            
            case 'StandStill' %aka, StandStill_nonBackward  
                save(fullfile(ProcPath, sprintf('Sub%d',SubID),'\Transfer\Player\Backward',sprintf('Backward_StandStill_Run%d',iRun)),'Backward');
                save(fullfile(ProcPath, sprintf('Sub%d',SubID),'\Transfer\Player\Backward',sprintf('Forward_StandStill_Run%d',iRun)),'Forward');
        end
    
    end
        
    % Total for both runs
    nBackwardSubs   = [nBackwardSubs ; height(Backward)];
    nForwardSubs    = [nForwardSubs ; height(Forward)];   
end


%% Compare backward movements for young and old
YoungIdx            = Subjects < 200;
OldIdx              = Subjects >= 200;

% Normalise - number of backward time point to number of total movement time points 
PBackwardYoung      = nBackwardSubs(YoungIdx)./(nBackwardSubs(YoungIdx) + nForwardSubs(YoungIdx));
PBackwardOld        = nBackwardSubs(OldIdx)./(nBackwardSubs(OldIdx) + nForwardSubs(OldIdx));

[p,stats]           = vartestn([PBackwardYoung, [PBackwardOld;nan(4,1)]], 'TestType','LeveneQuadratic'); %n.s
[h,p,ci,stats]      = ttest2(PBackwardYoung, PBackwardOld)
CohensD             = (mean(PBackwardYoung) - mean(PBackwardOld)) /std(PBackwardOld)
SEMYoung            = std(PBackwardYoung) /sqrt(length(PBackwardYoung));
SEMOld              = std(PBackwardOld) /sqrt(length(PBackwardOld));


% Save the probabilities of backward movement or backward facing
if ~exist(fullfile(StatsPath,'\Transfer\Backward\'),'dir')
    mkdir(fullfile(StatsPath,'\Transfer\Backward\')); end

switch  TimePoints
        case 'Movement'
            save(fullfile(StatsPath,'\Transfer\Backward\PBackwardYoung_Move'),'PBackwardYoung','nBackwardSubs');
            save(fullfile(StatsPath,'\Transfer\Backward\PBackwardOld_Move'),'PBackwardOld')
        
        case 'Movement_and_StandStill'
            save(fullfile(StatsPath,'\Transfer\Backward\PBackwardYoung_Movement_and_StandStill'),'PBackwardYoung','nBackwardSubs');
            save(fullfile(StatsPath,'\Transfer\Backward\PBackwardOld_Movement_and_StandStill'),'PBackwardOld')
            
        case 'StandStill'
            save(fullfile(StatsPath,'\Transfer\Backward\PBackwardYoung_StandStill'),'PBackwardYoung','nBackwardSubs');
            save(fullfile(StatsPath,'\Transfer\Backward\PBackwardOld_StandStill'),'PBackwardOld')
end


%% Barplots 
    
data = [PBackwardYoung  [PBackwardOld;nan(4,1)]];

plotoptions                     = [];
plotoptions.title               = sprintf('Backward movements');
plotoptions.fontSize            = 20;
plotoptions.fontName            = 'Gill Sans MT';
plotoptions.indMeas             = 'dots';               % leave as dots if you have uneven number of datapoints per condition
plotoptions.ylabel              = 'Probability of backward movements';
plotoptions.xticklabel          = {'Young' 'Old'};
plotoptions.barcolor            = [[0.0,0.5,0.5];[0 0.5 0.3]];

fHandle = hexagi_barplotscript(data, plotoptions);

if ~exist(fullfile(FigPath,'Backward\Transfer'),'dir')
    mkdir(fullfile(FigPath,'\Backward\Transfer'))
end


switch  TimePoints
        case 'Movement'
              FigName = fullfile(FigPath,'\Backward\Transfer','BackwardMovement_Move');
        case 'Movement_and_StandStill'
              FigName = fullfile(FigPath,'\Backward\Transfer','BackwardMovement_Move_and_StandStill');
        case 'StandStill'
              FigName = fullfile(FigPath,'\Backward\Transfer','BackwardMovement_StandStill');
end

saveas(fHandle, FigName,'png')
 

end