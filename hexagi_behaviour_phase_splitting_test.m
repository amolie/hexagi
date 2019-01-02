function hexagi_behaviour_phase_splitting_test(Subjects,ProcPath)
% Structure the data into the test phase (previously known as start phase 2)

% 5 objects are cued 6 times - 30 trials in total 
% There are 4 or 6 (inter trial intervals) seconds from when an object is cued until the trial starts and the cue dissapears = fixation time 
% (although it is still possible to navigate during this time 
% The participants navigate around the arena and press a button when they think they are in the correct object location = drop 
% Feedback to the participant is given when object appears in the correct object location at the moment they drop the object = show
% The participants navigate to the object and walk over it = grab
% The distance from the drop location to the grab location is the distance error. 
% The grab location is the start location for the next trial (they are NOT teleported back to the centre) 


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
        fprintf('Structuring variables into the test phase for subject %d run%d \n',SubID, iRun)

        % Load data
        load(fullfile(ProcPath, sprintf('Sub%d',SubID), sprintf('Run%d.mat', iRun)))


        %% Times            
        % Timestamps for start and end of phase
        TestStart       = StartPhase(2);
        TestEnd         = Drop(30);  %%not really the end of the phase - that is Grab = nan

        % Object type cued
        Test            = table(categorical(CueObject(1:30)),'VariableNames', {'Object'});                                                                                

        % Timestamps for start and end of trials 
        Test.TrialStart = Cue(1:30);
        Test.TrialEnd   = [Cue(2:30); TestEnd]; %should be grab, but that is also only for some trials

        % Cue: the trial start, info about what object will be shown 
        Test.Cue        = Cue(1:30);
        Test.CueNumber  = CueNumber(1:30);

        % CueStart: when the object is shown to the participant
        Test.CueStart   = CueStart(1:30);

        % Fixation (period between cue and when they start to navigate. 6second FIX is an ITI.
        Test.FixEnd = nan(length(Test.TrialEnd),1); %changed the name from start to end - because it is the end of fixation and start of navigation
        for i = 1:length(FixStart) 
            for CueNumber = 1:length(Test.TrialStart)
                if  Test.TrialStart(CueNumber) < FixStart(i) && Test.TrialEnd(CueNumber) >= FixStart(i)
                    Test.FixEnd(CueNumber) = FixStart(i);
                end
            end
        end

        % Time from Cue to Fix (inludeds ITI every 5th trial)
        Test.FixTime    = Test.FixEnd - Test.Cue;

        % Navigation start
        Test.NaviStart  = NaviStart(1:30);

        % Change the order of the columns
        Test            = Test(:,{'Object','TrialStart','TrialEnd','Cue','CueNumber','CueStart', 'FixTime', 'FixEnd', 'NaviStart'});

        % Drop
        Test.Drop       = Drop(1:30);

        % Time out trials
        Test.TimeOutTrial = nan(length(Test.TrialStart),1);    
        for i = 1:length(TimeOutTrial)
            for CueNumber = 1:length(Test.TrialStart)
                if  Test.TrialStart(CueNumber) < TimeOutTrial(i) && Test.TrialEnd(CueNumber) >= TimeOutTrial(i)  
                    Test.TimeOutTrial(CueNumber) = TimeOutTrial(i);
                end
            end
        end

        % Show 
        Test.Show = nan(length(Test.TrialEnd),1);      
        for i = 1:length(Test.Drop)
            for CueNumber = 1:length(ShowTime)
                if Test.Drop(i) == ShowTime(CueNumber)
                    Test.Show(i) = ShowTime(CueNumber);  
                end
            end
        end    

        % Grab                
        Test.Grab = nan(length(Test.TrialEnd),1);
        for i = 1:length(Grab) 
            for CueNumber = 1:length(Test.TrialStart)
                if Test.TrialStart(CueNumber) < Grab(i) && Test.TrialEnd(CueNumber) >= Grab(i)
                   Test.Grab(CueNumber) = Grab(i);
                end    
            end
        end

        % Check if the last Grab is nan for every subject
        if  Test.Grab(end) == nan
            error('The last Grab is not nan for this subject and run')
        end

        %% Object locations

        % Remembered object locations (drop)
        Test.DropLocX    = DropLocX(1:30);
        Test.DropLocY    = DropLocY(1:30);

        % Correct object location: use current obj loc           
        CorrObjLoc       = unique([CorrectObjectLocX CorrectObjectLocY CorrectObjectNumber],'rows');

        for iCueNumber = 1:length(Test.CueNumber)
            CueNumber = Test.CueNumber(iCueNumber);
            for iObject = 1:length(CorrObjLoc)
                Object = CorrObjLoc(iObject,3);
                if CueNumber == Object
                   Test.CorrectLocX(iCueNumber) = CorrObjLoc(iObject,1);
                   Test.CorrectLocY(iCueNumber) = CorrObjLoc(iObject,2);
                end
            end
        end

        % Drop errors   - euclidian distance - check this with the navi pattern script! this is not correct!
        X               = [Test.DropLocX Test.DropLocY];
        Y               = [Test.CorrectLocX Test.CorrectLocY];
        Test.DropError  = diag(pdist2(X,Y));

        % Keep track of the subject
        Temp(30,1)      = zeros;
        Temp(:)         = SubID;
        Temp            = array2table(Temp,'VariableNames',{'SubID'});
        Test            = [Temp Test];
        clear Temp

        %% Boundary
        Test.Boundary   = Environment(1:30);


        %% Landmark positions            
        StandardLMLoc   = LMLoc1;

        for iBoundary = 1:length(Test.Boundary)
            if  Test.Boundary(iBoundary) == 1

                Test.LMLocX(iBoundary) = StandardLMLoc(1);
                Test.LMLocY(iBoundary) = StandardLMLoc(2);
            end
        end


        %% Get the correct timings
        ScannerPulse        = ScannerPulse          *1.0011;

        TestStart           = TestStart             *1.0011; 
        TestEnd             = TestEnd               *1.0011;

        Test.TrialStart     = Test.TrialStart       *1.0011; 
        Test.TrialEnd       = Test.TrialEnd         *1.0011; 
        Test.Cue            = Test.Cue              *1.0011;
        Test.CueStart       = Test.CueStart         *1.0011;
        Test.FixEnd         = Test.FixEnd           *1.0011;
        Test.NaviStart      = Test.NaviStart        *1.0011; 
        Test.Drop           = Test.Drop             *1.0011;
        Test.TimeOutTrial   = Test.TimeOutTrial     *1.0011;
        Test.Show           = Test.Show             *1.0011; 
        Test.Grab           = Test.Grab             *1.0011; 

        PlayerLoc           = PlayerLoc             *1.0011;
        PlayerYawTime       = PlayerYawTime         *1.0011;
        StartPhase          = StartPhase            *1.0011;


        %%  Find the relevant pulses for the phase
        temp                = ScannerPulse <= (StartPhase(2) *1.0011);
        tempPulses          = ScannerPulse(temp);
        FirstTestPulse      = tempPulses(end-2);

        LastTestPulse       = Test.Drop(30);

        TestRelevantTRs     = (LastTestPulse-FirstTestPulse)/2.4;            

        TimeOfInterest      = ScannerPulse >= FirstTestPulse & ScannerPulse <= LastTestPulse;
        TestPulses          = ScannerPulse(TimeOfInterest);


        %% Extract the time before the first pulse / set the first scanner pulse to 0 
        TestPulses          = TestPulses        - FirstTestPulse;
        %LastTestPulse       = LastTestPulse     - FirstTestPulse;

        TestStart           = TestStart         - FirstTestPulse; 
        TestEnd             = TestEnd           - FirstTestPulse;

        Test.TrialStart     = Test.TrialStart   - FirstTestPulse; 
        Test.TrialEnd       = Test.TrialEnd     - FirstTestPulse; 
        Test.Cue            = Test.Cue          - FirstTestPulse;
        Test.CueStart       = Test.CueStart     - FirstTestPulse;
        Test.FixEnd         = Test.FixEnd       - FirstTestPulse;
        Test.NaviStart      = Test.NaviStart    - FirstTestPulse; 
        Test.Drop           = Test.Drop         - FirstTestPulse;
        Test.TimeOutTrial   = Test.TimeOutTrial - FirstTestPulse;
        Test.Show           = Test.Show         - FirstTestPulse; 
        Test.Grab           = Test.Grab         - FirstTestPulse;

        PlayerLoc           = PlayerLoc         - FirstTestPulse;
        PlayerYawTime       = PlayerYawTime     - FirstTestPulse;           
        StartPhase          = StartPhase        - FirstTestPulse;  


        %% Save in one .m file
        save(fullfile(ProcPath, sprintf('Sub%02d',SubID), 'Test', sprintf('Test%d',iRun)), 'Test','TestStart','TestEnd','TestPulses')


        %% Player locations and yaw for the phase: from the first cue through all cues,drop,show and grab - ending at the last drop. 

        % Create output folder for each subject
        if ~exist(fullfile(ProcPath, sprintf('Sub%d',SubID),'/Test/Player'),'dir'); mkdir(fullfile(ProcPath, sprintf('Sub%d',SubID),'/Test/Player')); end

        % Player locations  
        % Includes player locations occuring while the cue is still present
        TimeOfInterest          = PlayerLoc >= Test.CueStart(1) & PlayerLoc <= Test.Drop(end); 

        %%since grab is always the same time as the next cue I use this, even though it's the first cue of the transfer phase. ???    
        %TimeOfInterest          = PlayerLoc >= Test.CueStart(1) & PlayerLoc < StartPhase(2);

        PlayerLocTest           = table;
        PlayerLocTest.Time      = PlayerLoc(TimeOfInterest);
        PlayerLocTest.LocX      = PlayerLocX(TimeOfInterest);
        PlayerLocTest.LocY      = PlayerLocY(TimeOfInterest);

        % Player Yaw
        TimeOfInterest          = PlayerYawTime >= Test.CueStart(1) & PlayerYawTime <= Test.Drop(end);

        %%since grab is always the same time as the next cue I use this, even though it's the first cue of the transfer phase. ???    
        %TimeOfInterest          = PlayerYawTime >= Test.CueStart(1) & PlayerYawTime < StartPhase(2);

        PlayerYawTest           = table;
        PlayerYawTest.Time      = PlayerYawTime(TimeOfInterest);
        PlayerYawTest.YawX      = PlayerYawX(TimeOfInterest);
        PlayerYawTest.YawY      = PlayerYawY(TimeOfInterest);
        PlayerYawTest.Yaw       = PlayerYaw(TimeOfInterest); 
        PlayerYawTest.Orient    = PlayerOrient(TimeOfInterest);

        % For sub 213 (only run1) and sub 232 separate log files are probably concatenated, so the time starts again after the encoding phase
        if  iRun == 1 && SubID == 213 
            PlayerLocTest = PlayerLocTest(2492:end,:);
        end

        if  iRun == 1 && SubID == 232
            PlayerLocTest = PlayerLocTest(1888:end,:); 
        end

        if  iRun == 2 && SubID == 232
            PlayerLocTest = PlayerLocTest(2320:end,:); 
        end

        % Concatenate player location and yaw - fill in with nans for time points there are no yaw
        PlayerTest              = outerjoin(PlayerLocTest, PlayerYawTest);
        Yaw                     = rmmissing(PlayerTest);
        if  height(Yaw) ~= height(PlayerYawTest)
            error('Outerjoin did not work!')
        else
        % Rename the time variables = keep both
        PlayerTest.LocTime      = PlayerTest.Time_PlayerLocTest;
        PlayerTest.YawTime      = PlayerTest.Time_PlayerYawTest;
        PlayerTest              = PlayerTest(:,{'LocTime' 'LocX' 'LocY' 'YawTime' 'YawX' 'YawY' 'Yaw' 'Orient'});   

        end

        save(fullfile(ProcPath, sprintf('Sub%d',SubID), 'Test\Player', sprintf('PlayerTest%d',iRun)),'PlayerTest');


    end
end
end