function hexagi_behaviour_transfer_viewing(Subjects,Movement,ProcPath,StatsPath,FigPath)
% Viewing distributions / facing directions

% Choose input = 1 to evaluate the entire phase: movement starts from cue, through drop, show, and grab, for all trials in the phase
% Choose input = 2 to evaluate only re-learning / feedback, i.e. from show to grab

% The circle is in 2 halves from 0 to pi(180), and -pi(-180) to 0(360) --> Degrees = [-180 -150 -120 -90 -60 -30 0 30 60 90 120 150 180] 
% Mod is used to convert it to a full circle

% Checks how much time the young are facing (yaw) the LM compared to the old
% Checks how many times do the young check where the LM is (= turn toward it) compared to old

% Default binning for yaw is 30 degrees
% Default definition for LM Bound yaw: LMCircRad = +-30 degrees

% Evaluates only the standard boundary - when the LM moves 


if  nargin<1
    Subjects    = load('hexagi_subjects'); 
    
    % Define what kind of movements to include 
    Movement    = 'Move_Backward';              %all movements (includes standing still and backward movements)
    %Movement    = 'Move_nonBackward';          %all movements, but not backward (include standing still)
    %Movement    = 'StandStill_Backward';       %only stand still (include backwards) 
    %Movement    = 'StandStill_nonBackward';    %only stand still (exclude backwards)
        
    ProcPath    = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
    FigPath     = 'C:\MasterThesis\Data\Hexagi\Behaviour\Figures';
    StatsPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Stats';
end

fprintf('Evaluating LM viewing and the distribution of viewing directions from the transfer phase \n')

nSubs        = length(Subjects);
YoungIdx     = Subjects < 200;
OldIdx       = Subjects >= 200;


%% TRANSFER PHASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checks how much time the young are facing (yaw) the LM compared to the old
% LMCircRad is set to degrees on each side of the LM (DgAroundLM): if yaw is within this range it is defined as LM bound yaw (i.e. facing the LM)

BinsDeg          = 30;
Bins             = 0:BinsDeg:360;          
BinEdges         = deg2rad(Bins);

mBinCounts       = [];
PLMBoundYaw      = [];

mLMBoundYaw      = [];

for iSub = 1:nSubs
    
    YawSub        = [];
    LMBoundYawSub = [];
    BinCountsSub  = [];
    
    for iRun  = 1:2    
        SubID = Subjects(iSub);

        %% Get LM locations: counterbalanced between the runs
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Transfer', sprintf('Transfer%d.mat', iRun)),'Transfer');

        
        %% Use the previously defined movements 
        switch Movement
            case 'Move_Backward'
                % Get yaw and player locations for all movements (includes standing still and backward movements)
                load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Transfer\Player', sprintf('PlayerTransfer%d.mat', iRun)),'PlayerTransfer')
                Player = PlayerTransfer;
                
            case 'Move_nonBackward'
                % Get yaw and player locations for all movements, but not backward (include standing still)
                load(fullfile(ProcPath, sprintf('Sub%d',SubID),'\Transfer\Player\Backward',sprintf('Forward_Move_and_StandStill_Run%d',iRun)));
                Player = Forward;
                
            case 'StandStill_Backward'  
                % Get yaw and player locations for only stand still (include backwards)
                load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Transfer\Player', sprintf('PlayerStandStill%d.mat', iRun)),'PlayerStandStill')
                Player = PlayerStandStill;
        
            case 'StandStill_nonBackward'  
                % Get yaw and player locations for only stand still (exclude backwards)
                load(fullfile(ProcPath, sprintf('Sub%d',SubID),'\Transfer\Player\Backward',sprintf('Forward_StandStill_Run%d',iRun)),'Forward');
                Player = Forward;
        end
        
        % Evaluate only the standard boundary - when the LM moves 
        Bound1Idx = Transfer.Boundary == 1;
        Transfer  = Transfer(Bound1Idx,:);
        
        % Rename
        Transfer.LMLocX = Transfer.NewLMLocX;
        Transfer.LMLocY = Transfer.NewLMLocY;
               
        % Evaluate only testing / i.e., from NaviStart to drop
        Temp   = [];
        for iTrial          = 1:length(Transfer.TrialStart) 
            TimeOfInterest  = Player.LocTime >= Transfer.NaviStart(iTrial) & Player.LocTime <= Transfer.Drop(iTrial);
            PlayerTransferTrial = Player(TimeOfInterest,:);
            Temp            = [Temp ; PlayerTransferTrial];
        end
        Player          = Temp;    
              
        % Get the angle (radians) for the distances from the LM to the player locations        
        XDiff                = [double(Transfer.LMLocX(1)) - Player.LocX ];
        YDiff                = [double(Transfer.LMLocY(1)) - Player.LocY ];
        [PlayerLMAng]        = cart2pol(XDiff,YDiff);
        
        % Get the angle (radians) for yaw
        [Yaw]                = cart2pol(Player.YawX,Player.YawY);        
        % Get rid of missing yaw time points
        Idx                  = ~isnan(Yaw);
        Yaw                  = Yaw(Idx);
        
        % Distance between the LM to the player (PlayerLMAng) and yaw
        DiffYawLMAng         = circ_dist(PlayerLMAng(Idx),Yaw);
        
        % Get the differences between the angles that are smaller than the threshold set around the LM (BinsDeg),
        % i.e the time points when the sub is looking at the LM +/- BinsDeg
        LMBoundYaw        	 = Yaw(abs(DiffYawLMAng) < deg2rad(BinsDeg));   
        % Both runs      
        LMBoundYawSub        = [LMBoundYawSub ; LMBoundYaw];
        
        % Yaw both runs - converted to a full circle
        Yaw                  = mod(Yaw,2*pi);
        YawSub               = [YawSub ; Yaw];
           
        % Normalised number of timepoint within each bin, edges (can add indicies (e.g Yaw == 1))
        [BinCountsRun, BinEdges, ~] =  histcounts(Yaw, BinEdges,'Normalization','probability');
        
        % Bin counts both runs
        BinCountsSub         = [BinCountsSub ; BinCountsRun];
    end
    
    % Viewing directions close to the LM for both runs
    
    % Not normalised, just the mean LMBound viewing, to check if they spend more time looking at the LM
    mLMBoundYaw               = [mLMBoundYaw ; mean(LMBoundYawSub)];
    
    % Probability (normalised) of LM based viewing direction for the sub
    PLMBoundYawSub           = length(LMBoundYawSub) / length(YawSub); %use all yaw that are not nans
    % All subs
    PLMBoundYaw              = [PLMBoundYaw ; PLMBoundYawSub];
   
    % Viewing times at each directional bin for all subs, mean time points of both runs (normalised when binned)
    mBinCounts               = [mBinCounts ; mean(BinCountsSub)];
end


%% Outliers
PLMBoundYawYoung    = PLMBoundYaw(YoungIdx);
OutIdxYoung         = isoutlier(PLMBoundYawYoung, 'median');
PLMBoundYawYoung    = PLMBoundYawYoung(~OutIdxYoung);

PLMBoundYawOld      = PLMBoundYaw(OldIdx);
OutIdxOld           = isoutlier(PLMBoundYawOld, 'median');
PLMBoundYawOld      = PLMBoundYawOld(~OutIdxOld);

PLMBoundYaw         = [];

% Save LM viewing
if ~exist(fullfile(StatsPath,'Transfer\Viewing'),'dir') 
    mkdir(fullfile(StatsPath,'Transfer\Viewing')); 
end
save(fullfile(StatsPath,'\Transfer\Viewing\PLMBoundYaw'),'PLMBoundYaw')


%% Test the viewing directions compared to the LM location %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Is there a difference between the groups for looking at the LM?
% Do old spend more time checking back at the LM?

% Normalised 
[p,stats]       = vartestn([PLMBoundYawYoung,[PLMBoundYawOld;nan(3,1)]],'TestType','LeveneQuadratic','display','on'); 
[h,p,ci,stats]  = ttest2(PLMBoundYawOld,PLMBoundYawYoung) %'VarType','Unequal'

SEMYoung        = std(PLMBoundYawYoung) / sqrt(length(PLMBoundYawYoung));
SEMOld          = std(PLMBoundYawOld) / sqrt(length(PLMBoundYawOld));
CohensD         = abs(mean(PLMBoundYawYoung) - mean(PLMBoundYawOld)) /std(PLMBoundYawOld);


%% Barplot showing the probability of run 1 compared to run2 for old

data = [ PLMBoundYawYoung [PLMBoundYawOld;nan(3,1)] ];

plotoptions                     = [];
%plotoptions.title               = sprintf('Temporal stability of navigational strategy for old');
plotoptions.fontSize            = 20;
plotoptions.fontName            = 'Gill Sans MT';
plotoptions.indMeas             = 'dots';               % leave as dots if you have uneven number of datapoints per condition
plotoptions.ylabel              = 'Landmark viewing';
plotoptions.xticklabel          = {'Young','Old'};
% plotoptions.ylim                = [0 1];
plotoptions.ytick               = (0:0.1:0.4);
plotoptions.yticklabel          = (0:0.1:0.4);
plotoptions.barcolor            = [[0.0,0.5,0.5];[0 0.5 0.3]];

fHandle = hexagi_barplotscript(data, plotoptions);

% Save the figure 
if ~exist(fullfile(FigPath,'\Viewing\Transfer'),'dir'); mkdir(fullfile(FigPath,'\Viewing\Transfer')); end

switch Movement
    case 'Move_Backward'
        FigName = fullfile(FigPath,'\Viewing\Transfer','LandmarkViewing_Move_Backward');
    case 'Move_nonBackward'
        FigName = fullfile(FigPath,'\Viewing\Transfer','LandmarkViewing_Move_nonBackward');
    case 'StandStill_Backward'
        FigName = fullfile(FigPath,'\Viewing\Transfer','LandmarkViewing_StandStill_Backward');
    case 'StandStill_nonBackward'
        FigName = fullfile(FigPath,'\Viewing\Transfer','LandmarkViewing_StandStill_nonBackward');
end

saveas(fHandle, FigName,'epsc')

 
end



