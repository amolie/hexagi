function hexagi_behaviour_read_logs(Subjects, RawPath, ProcPath)
% Read behavioural log files for all subs and save the variables


%% List of subjects
if  nargin<1
    Subjects  = load('hexagi_subjects')';
    RawPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Raw';
    ProcPath  = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
end
nSubs   = length(Subjects);

for iSub = 1:nSubs
    
    % Current subject
    SubID = Subjects(iSub);
        
    % Create output folder for each subject
    if ~exist(fullfile(ProcPath, sprintf('Sub%d',SubID)),'dir'); mkdir(fullfile(ProcPath, sprintf('Sub%d',SubID))); end
      
    
    %% SEARCH OBJECT LOCATION TASK LOGFILES FOR BOTH RUNS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                                                                                                                                                                                                
    % 2 runs per subject                                                                    
    for iRun = 1:2                                                                          
                                                                                              
        % Open the logfile, read text to cell, and close logfile
        % Find names of logfiles for the subject and run (differs between subjects)
        FileList = dir(fullfile(RawPath, sprintf('SAM%d*run%d*',SubID,iRun)));
        
        % Define the name of the file to read                                              
        InFile  = fullfile(RawPath, FileList.name);                                  
        
        % Check if the file exists                                                                
        if ~exist(InFile,'file')    
            error('Log file for subject %d, run %d is missing',SubID, iRun)
        else
            fprintf('Reading logfiles for subject %d run %d. InFile: %s\n',SubID,iRun, InFile)
        end
        
        % Read the file
        Fid     = fopen(InFile, 'r');
        TxtData  = textscan(Fid, '%s', 'Delimiter', '\n');
        fclose(Fid);

        
        %% Define terms to look for in the logfile
        % (Make sure that these are unique)
        Searchterms={
                % Player
                'Location'
                'YawUnit'                   %rotation of player
                
                % Trial
                'Grab'
                'Cue'                       
                'Drop|'                     
                'current obj loc'           
                'Show'
                'dist:'                     %this might be drop error
                '|TimeOutTrial|'             
                
                % Phases                          
                'Start Trial'                
                'current environment'       %trial info is on the same line
                'StartPhase'                % 1 - 2
                'Begin Phase2'
                'ITI_start'                 % inter trial intervals   
                'CUE_start'                 
                'FIX_start'
                'NAVI_start'
                'Start Final Tranfer'
                
                % Scanner
                '|Scanner Pulse'
                'First Scanner Pulse'
                
                % Boundaries & landmark
                'Landmark environment'
                'LMLoc'
                'New Position'
                
                % Player repositioning
                'Reposition|'        
                };

            
        %% Define what to get from the lines containing the searchterms
        Formats={
                % Player
                'ScriptLog: %f|%f|Location|X|%f|Y|%f|Z|%f'
                'ScriptLog: %f|%f|YawUnit|X|%f|Y|%f|Yaw|%f|Orient|%f'
                
                % Trial
                'ScriptLog: %f|%f|Grab|Neuro2.Obj.t_%s|X|%f|Y|%f'           
                'ScriptLog: %f|%f|Cue|%f|Neuro2.Obj.t_%s'          
                'ScriptLog: %f|%f|Drop|Neuro2.Obj.t_%s|X|%f|Y|%f'  
                'ScriptLog: current obj loc = %f,%f,%f Obj = %f'
                'ScriptLog: %f|%f|Show|Neuro2.Obj.t_%s|X|%f|Y|%f'  
                'ScriptLog: dist:%f'
                'ScriptLog: %f|%f|TimeOutTrial|'
                
                % Phases
                'ScriptLog: %f|%f|Start Trial %f'
                'ScriptLog: %f|current environment = %f curr trial = %f'
                'ScriptLog: %f|%f|StartPhase%f'
                'ScriptLog: %f|Begin Phase2'
                'ScriptLog: %f|%f|ITI_start|'
                'ScriptLog: %f|%f|CUE_start|'
                'ScriptLog: %f|%f|FIX_start|'
                'ScriptLog: %f|%f|NAVI_start'
                'ScriptLog: %f|%f|Start Final Tranfer'
                
                % Scanner
                'ScriptLog: %f|%f|Scanner Pulse'
                'ScriptLog: %f|%f|First Scanner Pulse'
                
                % Boundaries & landmark
                'ScriptLog: Landmark environment%f|X|%f|Y|%f'
                'ScriptLog: LMLoc = %d,%d,%d'
                'ScriptLog: New Position: X = %f, Y = %f'
                
                % Player repositioning
                'ScriptLog: %f|%f|Reposition|X|%f|Y|%f|Z|%f|Yaw|%f'
                };

        % Initialize counters and storage variable
        SearchtermCountersRun = zeros(size(Searchterms,1),1); 
        SearchtermStorageRun  = cell(size(Searchterms,1),1);

        % Go through all lines of the log file and decide what to do with it
        for i = 1:size(TxtData{1,1},1)            
            for j = 1:size(Searchterms,1)
                tempstr = TxtData{1,1}(i);
                tempsearchterm = Searchterms{j,1};
                k = strfind(tempstr{1}, tempsearchterm);
                if isempty(k) == 0     %check if one of the searchterms is in this line. Returns logical 0 if k=strfind find the tempsearchterm in the tempstr.
                    SearchtermCountersRun(j) = SearchtermCountersRun(j)+1; 
                    SearchtermStorageRun{j}(SearchtermCountersRun(j),:) = textscan(tempstr{1},Formats{j},'Delimiter', ' ','MultipleDelimsAsOne',1); 
                end
            end
        end
        
        
        %% Create a table over the currents steps to not loose track
        Steps                       = cell2table(Searchterms);       
        Steps.Formats               = Formats;         
        Steps.StorageRun            = SearchtermStorageRun;
        NewVariableNames            = categorical({
                                                'PlayerLoc, PlayerLocX, PlayerLocY, PlayerLocZ' ...
                                                'PlayerYawTime, PlayerYawX, PlayerYawY, PlayerYaw, PlayerOrient' ...
                                                'Grab, GrabObject, GrabLocX, GrabLocY' ...
                                                'Cue, CueNumber, CueObject' ...
                                                'Drop, DropObject, DropLocX, DropLocY' ...
                                                'CorrectObjectLocX, CorrectObjectLocY, CorrectObjectNumber' ...
                                                'Show, ShowObject, ShowLocX, ShowLocY' ... 
                                                'DropError' ...
                                                'TimeOutTrial' ...
                                                'StartTrial, StartTrialNumber' ...
                                                'Environment, Trial' ...
                                                'StartPhase, StartPhaseNumber' ...
                                                'BeginPhase2' ...
                                                'ITIStart' ... 
                                                'CueStart' ...
                                                'FixStart' ...
                                                'NaviStart' ...
                                                'StartFinalTransfer' ...
                                                'ScannerPulse' ...
                                                'FirstScannerPulse' ...
                                                'Env1, Env2 Env3' ...
                                                'LMLoc1, LMLoc2, LMLoc3' ...
                                                'NewLMLoc1, NewLMLoc2' ... 
                                                'PlayerPos'
                                                })';
        
        Steps.NewVariableNames      = NewVariableNames; 
 
        
        %% Move information of interest from cell arrays to matrices
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Player location
        PlayerLoc           = cell2mat(SearchtermStorageRun{1}(:,2));                       %time
        PlayerLocX          = cell2mat(SearchtermStorageRun{1}(:,3));               
        PlayerLocY          = cell2mat(SearchtermStorageRun{1}(:,4));   
        PlayerLocZ          = cell2mat(SearchtermStorageRun{1}(:,5));
        
        %Player Yaw
        PlayerYawTime       = cell2mat(SearchtermStorageRun{2}(:,2));                       %time
        PlayerYawX          = cell2mat(SearchtermStorageRun{2}(:,3));
        PlayerYawY          = cell2mat(SearchtermStorageRun{2}(:,4));
        PlayerYaw           = cell2mat(SearchtermStorageRun{2}(:,5));
        PlayerOrient        = cell2mat(SearchtermStorageRun{2}(:,6));
        
        % Trial: Grab
        for iTrial = 1:length(SearchtermStorageRun{3})
            
            currString = SearchtermStorageRun{3}{iTrial,3}{:};                              %the third position of iTrial is the %s position, the object. 
            idx = strfind(currString,'|');                                                  %finds every position of |
            
            Grab                    = cell2mat(SearchtermStorageRun{3}(:,2));               %time %Had to use a loop because of %S on line 99  
            GrabObject{iTrial,1}    = currString(1:idx(1)-1);                               %grab object is everything up to the character before the first | %takes out position 1 of current string to position 1 of idx, minus | 
            GrabLocX(iTrial,1)      = str2num(currString(idx(2)+1:idx(3)-1));               %x-loc of object is between 2nd and 3rd |
            GrabLocY(iTrial,1)      = str2num(currString(idx(4)+1:length(currString)));     %y-loc of object is between 3nd and 4rd |
                
        end
       
        % Trial: Cue
        Cue                 = cell2mat(SearchtermStorageRun{4}(:,2));                       %time               
        CueNumber           = cell2mat(SearchtermStorageRun{4}(:,3));
        CueObject           = string(SearchtermStorageRun{4}(:,4));
       
        % Trial: Drop
        for iTrial = 1:length(SearchtermStorageRun{5})                                      %the first two drop searchwords are script warnings. Excluded.
            
            currString = SearchtermStorageRun{5}{iTrial,3}{:}; 
            idx = strfind(currString,'|');
            
            Drop                    = cell2mat(SearchtermStorageRun{5}(:,2));               %time
            DropObject{iTrial,1}    = currString(1:idx(1)-1);                            
            DropLocX(iTrial,1)      = str2num(currString(idx(2)+1:idx(3)-1));          
            DropLocY(iTrial,1)      = str2num(currString(idx(4)+1:length(currString)));   
        end     
   
        % Correct object locations and object number
        CorrectObjectLocX   = cell2mat(SearchtermStorageRun{6}(:,1));                       %took out column 3=Z becuase they are all zero
        CorrectObjectLocY   = cell2mat(SearchtermStorageRun{6}(:,2));
        CorrectObjectNumber = cell2mat(SearchtermStorageRun{6}(:,4));

        % Trial: Show
        for iTrial = 1:length(SearchtermStorageRun{7})
            
            currString = SearchtermStorageRun{7}{iTrial,3}{:};  
            idx = strfind(currString,'|');
            
            ShowTime                = cell2mat(SearchtermStorageRun{7}(:,2));               %cannot remove time from this to make it equal to the other varialbles because show is a function
            ShowObject{iTrial,1}    = currString(1:idx(1)-1);                                
            ShowLocX(iTrial,1)      = str2num(currString(idx(2)+1:idx(3)-1));               
            ShowLocY(iTrial,1)      = str2num(currString(idx(4)+1:length(currString))); 
        end
        
        % Dist - potentially drop error
        DropError           = cell2mat(SearchtermStorageRun{8});
        
        % Time out trials
        if  ~isempty(SearchtermStorageRun{9})
            TimeOutTrial    = cell2mat(SearchtermStorageRun{9}(:,2));
        else
            TimeOutTrial = [];
        end
            
        % Phases
        StartTrial          = cell2mat(SearchtermStorageRun{10}(:,2));                      %time  
        StartTrialNumber    = cell2mat(SearchtermStorageRun{10}(:,3));
                      
        Environment         = cell2mat(SearchtermStorageRun{11}(:,2));                      %don't have time for this one. 
        Trial               = cell2mat(SearchtermStorageRun{11}(:,3));                      %this one neither   
        StartPhase          = cell2mat(SearchtermStorageRun{12}(:,2));                      %time
        StartPhaseNumber    = cell2mat(SearchtermStorageRun{12}(:,3));
        BeginPhase2         = cell2mat(SearchtermStorageRun{13}(:,1));
        ITIStart            = cell2mat(SearchtermStorageRun{14}(:,2));                      %time
        CueStart            = cell2mat(SearchtermStorageRun{15}(:,2));                      %time                                      
        FixStart            = cell2mat(SearchtermStorageRun{16}(:,2));
        NaviStart           = cell2mat(SearchtermStorageRun{17}(:,2));
        StartFinalTransfer  = cell2mat(SearchtermStorageRun{18}(:,2));                      %time
        
        % Scanner
        ScannerPulse        = cell2mat(SearchtermStorageRun{19}(:,2));                      %time      
        FirstScannerPulse   = cell2mat(SearchtermStorageRun{20}(:,2));                      %time
        
        % Check if the 40th trial is in environment 0 for all participants and then take it out (experiment over)
        % Environments will later be known as boundaries
        if Environment(end)       == ~ 0
           error('Environment for trial 40 is not 0')
        else
           Environment(end)       = [];
           Trial(end)             = []; 
        end
            
        % Take out duplicate trials
        if Trial([6:6:42])        == Trial([7:6:43])
           Trial([6:6:42])        = [];
           Environment([6:6:42])  = [];
        else
            error('The duplicates are not for every 5th trial for this subject')
        end
        
        % Boundaries 
        Env1                = cell2mat(SearchtermStorageRun{21}(1,2:3));                    % Standard boundary   
        Env2                = cell2mat(SearchtermStorageRun{21}(2,2:3));                    % Large boundary
        Env3                = cell2mat(SearchtermStorageRun{21}(3,2:3));                    % Small boundary
        
        % Landmark locations                                                             
        LMLoc1              = cell2mat(SearchtermStorageRun{22}(1,1:2));                    % LM loc in the standard environment
        LMLoc2              = cell2mat(SearchtermStorageRun{22}(2,1:2));                    % LM loc in large  environment
        LMLoc3              = cell2mat(SearchtermStorageRun{22}(3,1:2));                    % LM Loc in small environment
        
        % New position after the landmark has been moved in the transfer phase, the boundary stays the same
        NewLMLoc1           = cell2mat(SearchtermStorageRun{23}(1,:));                
        NewLMLoc2           = cell2mat(SearchtermStorageRun{23}(2,:));                    
              
        % Player repositioning
        PlayerRepos         = cell2mat(SearchtermStorageRun{24}(:,2));                      %time
        PlayerReposX        = cell2mat(SearchtermStorageRun{24}(:,3));
        PlayerReposY        = cell2mat(SearchtermStorageRun{24}(:,4));
        PlayerReposZ        = cell2mat(SearchtermStorageRun{24}(:,5));
        PlayerReposYaw      = cell2mat(SearchtermStorageRun{24}(:,6));
        
        % Save the necessary variables
        save(fullfile(ProcPath, sprintf('sub%02d',SubID), sprintf('Run%d', iRun)), 'Player*', 'Grab*', 'Cue*', 'Fix*', 'Drop*', 'Show*', 'Steps', 'Start*', ... 
                                        '*ScannerPulse', 'LM*', 'NewLM*', 'Environment', 'Trial', 'Correct*', 'NaviStart', 'TimeOutTrial', 'Begin*','First*')
             
        
    end
    
end   
end