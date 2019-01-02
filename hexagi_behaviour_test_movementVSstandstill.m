function hexagi_behaviour_test_movementVSstandstill(Subjects, ProcPath)
% Get player locations and yaw only for movement timepoints, i.e. take out standing still
% Only for the test phase
% Includes times between the trials (it's the entire run)
% Player test move includes backward movements

if  nargin <1
    Subjects = load('hexagi_46subjects')';
    ProcPath = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
end

nSubs = length(Subjects);

for iSub  = 1:nSubs
    SubID = Subjects(iSub);
    
    for iRun = 1:2
        
        fprintf('Get movement and stand still timepoints for Sub%d, run%d, test phase \n', SubID,iRun)

        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Test\Player\', sprintf('PlayerTest%d.mat', iRun)));

        MoveIdx          = [false; logical(abs(diff(PlayerTest.LocX)) + abs(diff(PlayerTest.LocY)))];
        PlayerTestMove   = PlayerTest(MoveIdx,:); 
        PlayerStandStill = PlayerTest(~MoveIdx,:);
        
        % Save the movement time points for the run
        save(fullfile(ProcPath, sprintf('Sub%d',SubID), 'Test\Player', sprintf('PlayerTestMove%d',iRun)),'PlayerTestMove');
        
        % Save the stand still time points for the run
        save(fullfile(ProcPath, sprintf('Sub%d',SubID), 'Test\Player', sprintf('PlayerStandStill%d',iRun)),'PlayerStandStill');
        
        
    end
end
end
