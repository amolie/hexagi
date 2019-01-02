function hexagi_behaviour_phase_splitting_transfer(Subjects,ProcPath)
% Structure the data into the transfer phase

% In this phase there are 3 different conditions: standard (same as previous phases), large and small boundary. 
% The trials are 3x3x2x2 for the boudaries, and varies between boundary 1&2, or 1&3.
% When the boundary stays the same as in the test phase, the LM moves to a new location. 


%% List of subjects
if  nargin<1
    Subjects = load('hexagi_subjects')';
    ProcPath = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
end
nSubs = length(Subjects);


%% Loop over all subjects
for iSub = 1:nSubs 
    
        % Loop over both runs
        for iRun = 1:2
        
            % Current subject
            SubID = Subjects(iSub);
            fprintf('Structuring variables into transfer phase for subject %d run%d \n',SubID, iRun)
            
            % Load data
            load(fullfile(ProcPath, sprintf('Sub%d',SubID), sprintf('Run%d.mat', iRun)))

            
            %% Times                       
            % Timestamps for start and end of phase
            TransferStart               = Cue(31);
            TransferEnd                 = Drop(40);

            % Object type cued
            Transfer                    = table(categorical(CueObject(31:40)),'VariableNames', {'Object'}); 
            
            % Timestamps for start and end of trials
            Transfer.TrialStart         = Cue(31:40);
            Transfer.TrialEnd           = Drop(31:40);
            
            % Timestanps for cue, fix, drop
            % Cue: the trial start, info about what object will be shown
            Transfer.Cue                = Cue(31:40);        %is cue always 40 for all participants?
            Transfer.CueNumber          = CueNumber(31:40);
            
            % CueStart: when the object is shown to the participant
            if  length(CueStart) ~= 40
                warning 'Missing trials'
                Transfer.CueStart           = nan(length(Transfer.TrialStart),1);
                      
                TimeOfInterest              = CueStart > Transfer.Cue(1) & CueStart < Transfer.Cue(end);
                CueStart                    = CueStart(TimeOfInterest);
            
                for i = 1:length(CueStart)
                    for j = 1:length(Transfer.TrialStart)
                        if  Transfer.TrialStart(j)<= CueStart(i) && Transfer.TrialStart(j+1)> CueStart(i) 
                            Transfer.CueStart(j) = CueStart(i);
                        end
                    end
                end
            else
                Transfer.CueStart           = CueStart(31:40);                
            end
             
            % Fixation (period between cue and when they start to navigate. 6second FIX is an ITI.                       
            % Changed the name from Fixstart to Fixend - bacause it is the end of fixation and start of navigation
            Transfer.FixEnd             = nan(length(Transfer.TrialEnd),1);           
            for i = 1:length(FixStart)
                for j = 1:length(Transfer.TrialStart)
                    if  Transfer.TrialStart(j) < FixStart(i) && Transfer.TrialEnd(j) >= FixStart(i)
                        Transfer.FixEnd(j) = FixStart(i);
                    end
                end
            end
            
            % Time from Cue to Fix (includes ITI every 5th trial)
            Transfer.FixTime = Transfer.FixEnd - Transfer.Cue;
                        
            % Navigation start 
            if  length(NaviStart) ~= 40
                warning 'Missing trials'
                Transfer.NaviStart          = nan(length(Transfer.TrialStart),1);
                      
                TimeOfInterest              = NaviStart > Transfer.Cue(1) & NaviStart < Transfer.Cue(end);
                NaviStart                   = NaviStart(TimeOfInterest);
            
                for i = 1:length(NaviStart)
                    for j = 1:length(Transfer.TrialStart)
                        if  Transfer.TrialStart(j)<= NaviStart(i) && Transfer.TrialStart(j+1)> NaviStart(i) 
                            Transfer.NaviStart(j) = NaviStart(i);
                        end
                    end
                end
            else
                Transfer.NaviStart = NaviStart(31:40);                
            end
                                               
            % Change the order of the columns
            Transfer = Transfer(:,{'Object','TrialStart','TrialEnd','Cue','CueNumber','CueStart', 'FixTime', 'FixEnd', 'NaviStart'});
            
            % Drop
            Transfer.Drop               = Drop(31:40);
            TransferDrop                = Drop(31:40);    
            
            % Time out trials (after 60 seconds)
            Transfer.TimeOutTrial = nan(length(Transfer.TrialStart),1);            
            for i = 1:length(TimeOutTrial)
                for j = 1:length(Transfer.TrialStart)
                    if  Transfer.TrialStart(j) < TimeOutTrial(i) && Transfer.TrialEnd(j) >= TimeOutTrial(i)  
                        Transfer.TimeOutTrial(j) = TimeOutTrial(i);
                    end
                end
            end
            
            
            %% Object locations            
            % Remembered object locations (drop)
            Transfer.DropLocX           = DropLocX(31:40);
            Transfer.DropLocY           = DropLocY(31:40);
            
            % Correct object location: use current obj loc           
            CorrObjLoc       = unique([CorrectObjectLocX CorrectObjectLocY CorrectObjectNumber],'rows');
            
            for iCueNumber = 1:length(Transfer.CueNumber)
                CueNumber = Transfer.CueNumber(iCueNumber);
                for iObject = 1:length(CorrObjLoc)
                    Object = CorrObjLoc(iObject,3);
                    if CueNumber == Object
                       Transfer.CorrectLocX(iCueNumber) = CorrObjLoc(iObject,1);
                       Transfer.CorrectLocY(iCueNumber) = CorrObjLoc(iObject,2);
                    end
                end
            end
            
            % Drop errors  - euclidian distance
            X                           = [Transfer.DropLocX Transfer.DropLocY];
            Y                           = [Transfer.CorrectLocX  Transfer.CorrectLocY];  %%This is the correct object locations from the test phase
            Transfer.DropError          = diag(pdist2(X,Y));
            
            % Keep track of the subject
            clear Temp
            Temp(10,1)                   = zeros;
            Temp(:)                     = SubID;
            Temp                        = array2table(Temp,'VariableNames',{'SubID'});
            Transfer                    = [Temp Transfer];        

            
            %% Boundary
            Transfer.Boundary           = Environment(31:40);
            
            
            %% Old and new LM locations
            % There's only a new LM pos for the standard boundary!
            StandardLMLoc               = LMLoc1; 
            LargeLMLoc                  = LMLoc2;
            SmallLMLoc                  = LMLoc3; 
                        
            for iBoundary = 1:length(Transfer.Boundary)
                if  Transfer.Boundary(iBoundary) == 1
                    
                    Transfer.OldLMLocX(iBoundary) = StandardLMLoc(1);
                    Transfer.OldLMLocY(iBoundary) = StandardLMLoc(2);
                    Transfer.NewLMLocX(iBoundary) = NewLMLoc1(1);   
                    Transfer.NewLMLocY(iBoundary) = NewLMLoc1(2);
                end
                
                if  Transfer.Boundary(iBoundary) == 2
                    
                    Transfer.OldLMLocX(iBoundary) = LargeLMLoc(1);
                    Transfer.OldLMLocY(iBoundary) = LargeLMLoc(2);
                end
                
                if Transfer.Boundary(iBoundary) == 3
                    
                    Transfer.OldLMLocX(iBoundary) = SmallLMLoc(1);
                    Transfer.OldLMLocY(iBoundary) = SmallLMLoc(2);
                end
            end
 
            
            %% Get the correct timings (time diff. between the logfiles and images)
            ScannerPulse            = ScannerPulse          *1.0011;
      
            TransferStart           = TransferStart         *1.0011; 
            TransferEnd             = TransferEnd           *1.0011;
      
            Transfer.TrialStart     = Transfer.TrialStart   *1.0011; 
            Transfer.TrialEnd       = Transfer.TrialEnd     *1.0011; 
            Transfer.Cue            = Transfer.Cue          *1.0011;
            Transfer.CueStart       = Transfer.CueStart     *1.0011;
            Transfer.FixEnd         = Transfer.FixEnd       *1.0011;
            Transfer.NaviStart      = Transfer.NaviStart    *1.0011; 
            Transfer.Drop           = Transfer.Drop         *1.0011;
            Transfer.TimeOutTrial   = Transfer.TimeOutTrial *1.0011;
            
            PlayerLoc               = PlayerLoc             *1.0011;
            PlayerYawTime           = PlayerYawTime         *1.0011;
            PlayerRepos             = PlayerRepos           *1.0011;
            
            
            %%  Find the relevant pulses for the phase            
            % There are 3 pulses before the task begins
            % The first of the 3 scanner pulses before the log entry "Start Final Tranfer"
            temp                    = ScannerPulse <= (StartFinalTransfer *1.0011);
            tempPulses              = ScannerPulse(temp);            
            FirstTransferPulse      = tempPulses(end-2);
            LastTransferPulse       = Transfer.Drop(end); 
                      
            TransferRelevantTRs     = (LastTransferPulse-FirstTransferPulse)/2.4;            
            
            TimeOfInterest          = ScannerPulse >= FirstTransferPulse & ScannerPulse <= LastTransferPulse;
            TransferPulses          = ScannerPulse(TimeOfInterest);
            
            
            %% Extract the time before the first pulse / set the first scanner pulse to 0 
            TransferPulses          = TransferPulses        - FirstTransferPulse;
            
            TransferStart           = TransferStart         - FirstTransferPulse; 
            TransferEnd             = TransferEnd           - FirstTransferPulse;
            
            Transfer.TrialStart     = Transfer.TrialStart   - FirstTransferPulse;
            Transfer.TrialEnd       = Transfer.TrialEnd     - FirstTransferPulse; 
            Transfer.Cue            = Transfer.Cue          - FirstTransferPulse;
            Transfer.CueStart       = Transfer.CueStart     - FirstTransferPulse;
            Transfer.FixEnd         = Transfer.FixEnd       - FirstTransferPulse;
            Transfer.NaviStart      = Transfer.NaviStart    - FirstTransferPulse; 
            Transfer.Drop           = Transfer.Drop         - FirstTransferPulse;
            Transfer.TimeOutTrial   = Transfer.TimeOutTrial - FirstTransferPulse;
            
            PlayerLoc               = PlayerLoc             - FirstTransferPulse;
            PlayerYawTime           = PlayerYawTime         - FirstTransferPulse;               
            PlayerRepos             = PlayerRepos           - FirstTransferPulse;
                       
                        
            %% Save phase information in one .m file
            save(fullfile(ProcPath, sprintf('Sub%d',SubID), 'Transfer', sprintf('Transfer%d',iRun)), 'Transfer','TransferStart','TransferEnd','TransferPulses')
            
            
            %% Player information
            
            % Create output folder for each subject
            if ~exist(fullfile(ProcPath, sprintf('Sub%d',SubID),'/Transfer/Player'),'dir'); mkdir(fullfile(ProcPath, sprintf('Sub%d',SubID),'/Transfer/Player')); end
            
            % Player locations
                        
            TimeOfInterest              = PlayerLoc >= Transfer.CueStart(1) & PlayerLoc <= Transfer.Drop(end);
            PlayerLocTransfer           = table;
            PlayerLocTransfer.Time      = PlayerLoc(TimeOfInterest);
            PlayerLocTransfer.LocX      = PlayerLocX(TimeOfInterest);
            PlayerLocTransfer.LocY      = PlayerLocY(TimeOfInterest);
            
            % Player Yaw                            
            TimeOfInterest              = PlayerYawTime >= Transfer.CueStart(1) & PlayerYawTime <= Transfer.Drop(end);
            PlayerYawTransfer           = table;
            PlayerYawTransfer.Time      = PlayerYawTime(TimeOfInterest);             
            PlayerYawTransfer.YawX      = PlayerYawX(TimeOfInterest);
            PlayerYawTransfer.YawY      = PlayerYawY(TimeOfInterest);
            PlayerYawTransfer.Yaw       = PlayerYaw(TimeOfInterest);   
            PlayerYawTransfer.Orient    = PlayerOrient(TimeOfInterest);
            
            % For sub 227 (only run2) separate log files are probably concatenated, so the time starts again after the test phase
            if  iRun == 2 && SubID == 227 
                PlayerLocTransfer = PlayerLocTransfer(344:end,:);
            end
            
            % Concatenate player location and yaw - fill in with nans for time points there are no yaw
            PlayerTransfer              = outerjoin(PlayerLocTransfer, PlayerYawTransfer);
            Yaw                         = rmmissing(PlayerTransfer);
            if  height(Yaw) ~= height(PlayerYawTransfer)
                error('Outerjoin did not work!')
            else
                
            % Rename the time variables = keep both
            PlayerTransfer.LocTime      = PlayerTransfer.Time_PlayerLocTransfer;
            PlayerTransfer.YawTime      = PlayerTransfer.Time_PlayerYawTransfer;
            PlayerTransfer              = PlayerTransfer(:,{'LocTime' 'LocX' 'LocY' 'YawTime' 'YawX' 'YawY' 'Yaw' 'Orient'});   
            
            end
            
            
            %% Player repositions
                        
            TimeOfInterest              = PlayerRepos >= Transfer.CueStart(1) & PlayerRepos < Transfer.Drop(end);
            Repos                       = PlayerRepos(TimeOfInterest,:); %time
            ReposX                      = PlayerReposX(TimeOfInterest,:);
            ReposY                      = PlayerReposY(TimeOfInterest,:);
            ReposYaw                    = PlayerReposYaw(TimeOfInterest,:);

            TransferRepos               = table(Repos, ReposX, ReposY, ReposYaw, 'VariableNames', {'Time' 'LocX' 'LocY' 'Yaw'});
              
            
            %% Save player information in one .m file
            save(fullfile(ProcPath, sprintf('Sub%d',SubID), 'Transfer\Player', sprintf('PlayerTransfer%d',iRun)),'PlayerTransfer','TransferRepos');
       
            
        end
end
end