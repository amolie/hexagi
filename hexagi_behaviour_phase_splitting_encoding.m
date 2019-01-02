function hexagi_behaviour_phase_splitting_encoding(Subjects,ProcPath)

% Structure the data from reading the behavioural log files into the encoding phase

% Participants are shown 5 different objects in the arena in each run 
% They move around and walk over the objects (grab) = learning object locations
% For each trial they start from the centre of the arena
% Each object is shown only once


%% List of subjects
if  nargin<1
    Subjects = load('hexagi_subjects')';
    ProcPath  = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
end
nSubs = length(Subjects);


%% Loop over all subjects
for iSub = 1:nSubs  
    
        % Loop over both runs
        for iRun = 1:2
        
            % Current subject
            SubID = Subjects(iSub);
            fprintf('Structuring variables into the encoding phase for subject %d run%d \n',SubID, iRun)
            
            % Create output folder for each subject
            PhaseName = {'Encoding', 'Test', 'Transfer'};
            for iPhaseName = 1:3
            if ~exist(fullfile(ProcPath, sprintf('Sub%d',SubID), sprintf('%s',PhaseName{iPhaseName})),'dir') 
                mkdir(fullfile(ProcPath, sprintf('Sub%d',SubID), sprintf(PhaseName{iPhaseName}))); end
            end
            
            % Load data
            load(fullfile(ProcPath, sprintf('sub%d',SubID), sprintf('Run%d.mat', iRun)))
            
            % Player repositions for the entire run
            PlayerRepos = table(PlayerRepos, PlayerReposX, PlayerReposY, PlayerReposZ, PlayerReposYaw, 'VariableNames', {'Time' 'PosX' 'PosY' 'PosZ' 'PosYaw'});
            
 
            %% Timestamps for start and end of phase
            EncodingStart               = StartPhase(1);              %This is similar to TrialStart(1) end TrialEnd(5)
            EncodingEnd                 = Grab(5); 
            
            % Object type shown and found (grabbed) in the arena
            Encoding                    = table;
            Encoding.Object             = categorical(ShowObject(1:5));
            % Object locations
            Encoding.ObjectLocX         = ShowLocX(1:5);        
            Encoding.ObjectLocY         = ShowLocY(1:5);         

            % Timestamps for start and end of trials
            Encoding.TrialStart         = ShowTime(1:5);                                 
            Encoding.TrialEnd           = Grab(1:5);                               
            
            % Time spent navigating to the objects
            Encoding.NaviTime           = Encoding.TrialEnd - Encoding.TrialStart;
            
            % Keep track of the subject
            clear Temp
            Temp(5,1)                   = zeros;
            Temp(:)                     = SubID;
            Temp                        = array2table(Temp,'VariableNames',{'SubID'});
            Encoding                    = [Temp Encoding];        
                        
            % Player location times
            TimeOfInterest              = PlayerLoc > EncodingStart & PlayerLoc < EncodingEnd;  
            EncodingPlayerLoc           = PlayerLoc(TimeOfInterest);
            
            % Player locations
            EncodingPlayer              = table;
            EncodingPlayer.LocX         = PlayerLocX(TimeOfInterest); 
            EncodingPlayer.LocY         = PlayerLocY(TimeOfInterest);
            EncodingPlayer.LocZ         = PlayerLocZ(TimeOfInterest);
            
            % Scanner pulses                                
            FirstEncodingPulse          = FirstScannerPulse(1);
            TimeOfInterest              = ScannerPulse >= FirstEncodingPulse & ScannerPulse <= EncodingEnd;
            EncodingPulses              = ScannerPulse(TimeOfInterest);
            LastEncodingPulse           = EncodingPulses(end);
            
            EncodingPulses0 = EncodingPulses -FirstEncodingPulse;
            LastEncodingPulse0 = EncodingPulses0(end);
            EncodingRelevantTRs = LastEncodingPulse0 / 2.4;
                        
            % Save all data from the encoding phase in one .m file
            save(fullfile(ProcPath, sprintf('Sub%d',SubID), 'Encoding', sprintf('Encoding%d',iRun)), 'Encoding*','PlayerRepos','LMLoc*','EncodingRelevantTRs') 
            
            
        end        
end 

end


