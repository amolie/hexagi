function hexagi_behaviour_plots_transfer(Subjects,ProcPath,FigPath,StatsPath)
% Plot paths

% This function makes plots over paths for the transfer phase, separated into boundary trials.
% One plot for each run
% In the trials where the boundary stays the same (= 1), the LM moves to a
% new location, and there are 2 estimations of "correct" object locations:
% one by estimating based on Doeller 2008, the other from SGM.


if  nargin<1
    Subjects  =  load('hexagi_46subjects')';
    ProcPath  = '\\mh-fil02.win.ntnu.no\kin\doeller\AnneMerete\MasterThesis\Data\Hexagi\Behaviour\Processed'; 
    FigPath   = '\\mh-fil02.win.ntnu.no\kin\doeller\AnneMerete\MasterThesis\Data\Hexagi\Behaviour\Figures';
    StatsPath = '\\mh-fil02.win.ntnu.no\kin\doeller\AnneMerete\MasterThesis\Data\Hexagi\Behaviour\Stats';
end

nSubs = length(Subjects);


%% TRANSFER PHASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load estimated correct locations from Doeller 2008
load(fullfile(StatsPath,'\Transfer\TranBR'),'TranBR');

for iSub = 1:nSubs    
    SubID = Subjects(iSub);
    fprintf('Now making plots over paths for subject %d, transfer phase \n',SubID)
    
    for iRun = 1:2
        close all
        % Transfer phase 
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Transfer',sprintf('Transfer%d.mat', iRun)));
        Transfer = sortrows(Transfer(:,:),{'Object'});
      
        % P from SGM
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Test',sprintf('Test%d.mat', iRun)));
        TestSorted      = sortrows(Test(:,:),'Object');   
        RelevantObjects = (TestSorted(6:6:end,:)); 
        RelevantTrials  = repmat(RelevantObjects,[2,1]);
        Test            = sortrows(RelevantTrials(:,:),'Object');  
        
        % Pm from SGM
        load(fullfile(ProcPath,sprintf('Sub%d',SubID),'\Transfer\ObjectMemorySGM\',sprintf('PmLocSGMRun%d',iRun)),'Pm');
        
        % Player path transfer phase
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Transfer\Player',sprintf('PlayerTransfer%d.mat', iRun)));   
        
        % Plot all trials in one figure
        fH = figure('visible', 'off');       
        for iTrial = 1:length(Transfer.TrialStart)
           
            subplot(2,5,iTrial);
            hold on
            
            % Standard boundary trials
            if  Transfer.Boundary(iTrial) == 1
                Center = [-175 -175];
                Radius = 5175;
                xlim([-5350 7000]);
                a = scatter(Transfer.NewLMLocX(iTrial), Transfer.NewLMLocY(iTrial),20,[0.0,0.5,0.5],'MarkerFaceColor', [0.0 0.8 0.8]);
                f = scatter(Transfer.OldLMLocX(iTrial), Transfer.OldLMLocY(iTrial),20,[0.0,0.5,0.5]);
                
                % Estimated correct locations from Doeller 2008 (there are no estimations for the boundary change here,only standard boundary)
                ObjLoc = TranBR(TranBR.SubID == SubID & TranBR.Run == iRun & TranBR.Object == Transfer.Object(iTrial),{'PredCorrLocX' 'PredCorrLocY'});
                %e = scatter(ObjLoc.PredCorrLocX, ObjLoc.PredCorrLocY,20, [0.4 0.2 0.2], 'MarkerFaceColor', [0.1 0.1 0.1]);
                
                % Estimated correct locations from SGM
                %b = scatter(Pm.PmLocX(iTrial)-175,Pm.PmLocY(iTrial)-175,20, [1.0 0.0 0.0],'MarkerFaceColor', [1.0 0.0 0.0]);
                
                % Mark the location of the last drop location in the test phase
                g = scatter(Test.DropLocX(iTrial)+175, Test.DropLocY(iTrial)+175, 20, [0.6,0.2,0.2]);
            end

            %Large boundary trials
            if  Transfer.Boundary(iTrial) == 2
                Center = [29825 -300];                                                          
                Radius = 6175;
                xlim([23650 36000]);
                
                % LM location from the test phase
                %f = scatter(Transfer.OldLMLocX(iTrial), Transfer.OldLMLocY(iTrial),20,[0.0,0.5,0.5]);
                
                % Estimated correct locations from SGM
                %b = scatter(Pm.PmLocX(iTrial)+Test.DropLocX(iTrial)+29825,Pm.PmLocY(iTrial)+Test.DropLocY(iTrial)-300,20, [1.0 0.0 0.0],'MarkerFaceColor', [1.0 0.0 0.0]);
                
                % Mark the location of the last drop location in the test phase
                %g = scatter(Test.DropLocX(iTrial)+29825, Test.DropLocY(iTrial)-300, 20, [0.6,0.2,0.2]);
                
            end

            % Small boundary trials
            if  Transfer.Boundary(iTrial) == 3
                Center = [61575 -150];                                              
                Radius = 4175; 
                xlim([57400 69750]);
                
                % LM location from the test phase
                %f = scatter(Transfer.OldLMLocX(iTrial), Transfer.OldLMLocY(iTrial),20,[0.0,0.5,0.5]);
                
                % Estimated correct locations from SGM
                %b = scatter(-Pm.PmLocX(iTrial)+Test.DropLocX(iTrial)+61575,-Pm.PmLocY(iTrial)+Test.DropLocY(iTrial)-150,20, [1.0 0.0 0.0],'MarkerFaceColor', [1.0 0.0 0.0]); 
                
                % Mark the location of the last drop location in the test phase
                %g = scatter(Test.DropLocX(iTrial)+61575, Test.DropLocY(iTrial)-150, 20, [0.6,0.2,0.2]);

            end     

            % Display the circle
            axis equal
            viscircles(Center,Radius,'color',[0.4,0.4,0.4],'LineWidth',0.07);
            axis off
                        
            % Mark the location where the object was dropped                              
            c = scatter(Transfer.DropLocX(iTrial), Transfer.DropLocY(iTrial), 20, [0.6,0.2,0.2], 'MarkerFaceColor',[0.6,0.2,0.2]);  
            
            % Fill in the path for the time of interest
            TimeOfMovement      = PlayerTransfer.LocTime > Transfer.FixEnd(iTrial) & PlayerTransfer.LocTime < Transfer.Drop(iTrial);
            d = plot(PlayerTransfer.LocX(TimeOfMovement), PlayerTransfer.LocY(TimeOfMovement), 'linewidth', 1, 'color',[0.3,0.3,0.3]);
             
        end 
      
        % Add legend and title
        legend([a,c,d,f,g],'Moved landmark','Object drop location', 'Player path', ...    %e  'Estimated "correct" object location - Doeller 2008', %b 'Estimated "correct" object location - SGM',
                             'Old landmark location','Last drop location - test phase'); 
        
        title(sprintf('Transfer phase, sub%d, run %d',SubID,iRun))
        
        % Save the figure
        FigName = fullfile(FigPath,'\Subjects',sprintf('Sub%d',SubID), sprintf('TransferPath_LMbiasSGM_Run%d', iRun));    
        Fig = gcf;
        saveas(gcf,FigName ,'png')

        end
end
end

