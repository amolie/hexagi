function hexagi_behaviour_transfer_movementVSstandstill(Subjects, ProcPath)
% Get player locations and yaw only for movement timepoints, i.e. take out standing still
% Only for the transfer phase
% Includes times between the trials (it's the entire run)
% Player transfer move includes backward movements

if  nargin <1
    Subjects = load('hexagi_46subjects')';
    ProcPath = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
end

nSubs = length(Subjects);

for iSub  = 1:nSubs
    SubID = Subjects(iSub);
    
    for iRun = 1:2
        
        fprintf('Get movement and stand still timepoints for Sub%d, run%d, transfer phase \n', SubID,iRun)

        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Transfer\Player\', sprintf('PlayerTransfer%d.mat', iRun)));

        MoveIdx             = [false; logical(abs(diff(PlayerTransfer.LocX)) + abs(diff(PlayerTransfer.LocY)))];
        PlayerTransferMove  = PlayerTransfer(MoveIdx,:); 
        PlayerStandStill    = PlayerTransfer(~MoveIdx,:);
        
        % Save the movement time points for the run
        save(fullfile(ProcPath, sprintf('Sub%d',SubID), 'Transfer\Player', sprintf('PlayerTransferMove%d',iRun)),'PlayerTransferMove');
        
        % Save the stand still time points for the run
        save(fullfile(ProcPath, sprintf('Sub%d',SubID), 'Transfer\Player', sprintf('PlayerStandStill%d',iRun)),'PlayerStandStill');
        
        
    end
end
end
