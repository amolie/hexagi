function hexagi_behaviour_plots_test(Subjects,ProcPath,FigPath)
% Plot paths

% This function makes plots over paths for the test phase.
% Comment out subplots to get separate plots for each trial 

close all
if  nargin<1
    Subjects  =  load('hexagi_subjects')';
    ProcPath  = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
    FigPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Figures';
end
nSubs = length(Subjects);
  


%% Loop over all subjects and all phases
% Plots all trials in one plot
%{
for iSub = 1:nSubs
    
    % current subject
    SubID = Subjects(iSub);
    fprintf('Now making plots over paths for subject %d, test phase \n',SubID)
    
    % Create output folder for each subject
    if ~exist(fullfile(FigPath,'\Subjects',sprintf('Sub%d',SubID)),'dir'); mkdir(fullfile(FigPath,'\Subjects',sprintf('sub%d',SubID))); end
    
    for iRun = 1:2
        
        %% TEST PHASE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Load the data from the test phase(hexagi_phase_splitting_behaviour script)
        load(fullfile(ProcPath, sprintf('Sub%d',SubID), 'Test\Player', sprintf('PlayerTest%d',iRun)),'PlayerTest');
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Test', sprintf('Test%d.mat', iRun)),'Test');
        
        % Plot the paths
        fH = figure('visible', 'on');
        axis off
        title(sprintf('Test phase, sub%d, run %d',SubID,iRun)) %dissapears when using subplot
        
        % Organize the subplots
        pageHeight = 21; % A4 paper
        pageWidth = 29.7;
        spCols = 5;
        spRows = length(Test.TrialStart)/5; %5;
        leftEdge = 1.5;
        rightEdge = 1.5;
        topEdge = 1.5;
        bottomEdge = 0.1;
        spaceX = 1;
        spaceY = 0.1;
        sub_pos = hexagi_subplot_pos(pageWidth,pageHeight,leftEdge,rightEdge,topEdge,bottomEdge,spCols,spRows,spaceX,spaceY);
        
        %figure;
        set(gcf,'PaperUnits','cent','PaperSize',[pageWidth pageHeight],'PaperPos',[0 0 pageWidth pageHeight]);   
                
        iTrialCount = 1; 
            for i = 1:spRows
                for j = 1:spCols
                    axes('pos',sub_pos{i,j});
                    iTrial = iTrialCount; %Test.TrialStart(iTrialCount);
                    %subplot(6,5,iTrial)       %comment this out and I get one plot for every trial, move fH = figure into the loop. 
                    hold on
                    %draw a circle of the arena
                    X = -175;                                                                       
                    Y = -175;
                    Center = [X Y];
                    Radius = 5175;
                    axis equal 
                    %display the circle, colour is in RGB
                    viscircles(Center,Radius,'color',[0.4,0.4,0.4],'linewidth',1);
                    axis off

                    % Fill in the path from movement start to drop
                    TimeOfMovement              = PlayerTest.LocTime > Test.FixEnd(iTrial) & PlayerTest.LocTime < Test.Drop(iTrial); 
                    Move2Drop                   = PlayerTest(TimeOfMovement,:);
                    a = plot(Move2Drop.LocX, Move2Drop.LocY,'linewidth', 1, 'color',[0.3,0.3,0.3]);

                    % Add time info to the paths
                    %scatter(Move2Drop.LocX, Move2Drop.LocY,100,Move2Drop.Time, 'Marker', '.')

                    % Path from show to grab loc
                    TimeOf2ndMovement           = PlayerTest.LocTime > Test.Show(iTrial) & PlayerTest.LocTime < Test.Grab(iTrial);  
                    Move2Grab                   = PlayerTest(TimeOf2ndMovement,:);
                    b = plot(Move2Grab.LocX, Move2Grab.LocY, 'linewidth', 1, 'color',[0.7,0.4,0.0]);

                    % Mark the location where the object was dropped                                  
                    c = scatter(Test.DropLocX(iTrial), Test.DropLocY(iTrial),20, [0.7,0.4,0.0], 'MarkerFaceColor',[0.7,0.4,0.0]);    

                    % Mark the correct location of the object
                    d = scatter(Test.CorrectLocX(iTrial),Test.CorrectLocY(iTrial),30, [0.4 0.2 0.2], 'MarkerFaceColor', [0.4 0.2 0.2]);

                    % Mark the landmark location
                    e = scatter(Test.LMLocX, Test.LMLocY,30,[0.0,0.5,0.5],'MarkerFaceColor', [0.0 0.8 0.8]);
                    
                    iTrialCount = iTrialCount + 1;               
                end
            end
        
            %legend([a,b,c,d,e],'Player path', 'Player path','Drop location','Correct object location','Landmark','Location','SouthEastOutside'); 
  
            % Save the figure
            FigName = fullfile(FigPath,'\Subjects',sprintf('Sub%d',SubID), sprintf('TestPath%d',iRun'));        
            Fig = gcf;
            saveas(gcf,FigName ,'png')           
            close all
    end
end
%}

%% Plots 1 trial from 1 sub 
for iSub = 9
    
    % current subject
    SubID = Subjects(iSub);
    fprintf('Now making plots over paths for subject %d, test phase \n',SubID)
    
    % Create output folder for each subject
    if ~exist(fullfile(FigPath,'\Subjects',sprintf('Sub%d',SubID)),'dir'); mkdir(fullfile(FigPath,'\Subjects',sprintf('Sub%d',SubID))); end
    
    for iRun = 1:2
        iTrial = 20;
        %% TEST PHASE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Load the data from the test phase(hexagi_phase_splitting_behaviour script)
        load(fullfile(ProcPath, sprintf('Sub%d',SubID), 'Test\Player', sprintf('PlayerTest%d',iRun)),'PlayerTest');
        load(fullfile(ProcPath, sprintf('Sub%d', SubID), 'Test', sprintf('Test%d.mat', iRun)),'Test');
        
        % Plot the paths
        fH = figure('visible', 'on');
        axis off
        %title(sprintf('Test phase, sub%d, run %d, trial',SubID,iRun,iTrial)) %dissapears when using subplot
                                
        %draw a circle of the arena
        X = -175;                                                                       
        Y = -175;
        Center = [X Y];
        Radius = 5175;
        axis equal 
        %display the circle, colour is in RGB
        viscircles(Center,Radius,'color',[0.4,0.4,0.4],'linewidth',1);
        axis off
        
        hold on
        % Fill in the path from movement start to drop
        TimeOfMovement              = PlayerTest.LocTime > Test.FixEnd(iTrial) & PlayerTest.LocTime < Test.Drop(iTrial); 
        Move2Drop                   = PlayerTest(TimeOfMovement,:);
        a = plot(Move2Drop.LocX, Move2Drop.LocY,'linewidth', 1, 'color',[0.3,0.3,0.3]);

        % Add time info to the paths
        %scatter(Move2Drop.LocX, Move2Drop.LocY,100,Move2Drop.Time, 'Marker', '.')
       
        % Path from show to grab loc
        TimeOf2ndMovement           = PlayerTest.LocTime > Test.Show(iTrial) & PlayerTest.LocTime < Test.Grab(iTrial);  
        Move2Grab                   = PlayerTest(TimeOf2ndMovement,:);
        b = plot(Move2Grab.LocX, Move2Grab.LocY, 'linewidth', 1, 'color',[0.7,0.4,0.0]);

        % Mark the location where the object was dropped                                  
        c = scatter(Test.DropLocX(iTrial), Test.DropLocY(iTrial),20, [0.7,0.4,0.0], 'MarkerFaceColor',[0.7,0.4,0.0]);    

        % Mark the correct location of the object
        d = scatter(Test.CorrectLocX(iTrial),Test.CorrectLocY(iTrial),30, [0.4 0.2 0.2], 'MarkerFaceColor', [0.4 0.2 0.2]);

        % Mark the landmark location
        e = scatter(Test.LMLocX, Test.LMLocY,30,[0.0,0.5,0.5],'MarkerFaceColor', [0.0 0.8 0.8]);
                    
        
        %legend([a,b,c,d,e],'Player path', 'Player path','Drop location','Correct object location','Landmark','Location','SouthEastOutside'); 

        % Save the figure
        FigName = fullfile(FigPath,'\Subjects',sprintf('Sub%d',SubID), sprintf('TestPath%d_Trial%d',iRun,iTrial));        
        Fig = gcf;
        saveas(gcf,FigName ,'epsc')           
        close all
    end
end

end