function hexagi_behaviour_plots_encoding(Subjects,ProcPath,FigPath)
% Plot paths

% This function makes plots over paths for the encoding phase. 
% Comment out subplots to get separate plots for each trial 

close all
if  nargin<1
    Subjects =  load('hexagi_46subjects')';
    ProcPath = '\\mh-fil02.win.ntnu.no\kin\doeller\AnneMerete\MasterThesis\Data\Hexagi\Behaviour\Processed';
    FigPath  = '\\mh-fil02.win.ntnu.no\kin\doeller\AnneMerete\MasterThesis\Data\Hexagi\Behaviour\Figures';  
end
nSubs = length(Subjects);
   

%% Loop over all subjects and all phases
for iSub = 1:nSubs
    
    % current subject
    subID = Subjects(iSub);
    fprintf('Now making plots over paths for subject %d, encoding phase \n',subID)
    
    % Create output folder for each subject
    if ~exist(fullfile(FigPath,'\Subjects',sprintf('Sub%d',subID)),'dir') 
        mkdir(fullfile(FigPath,'\Subjects',sprintf('Sub%d',subID))); end
    
    for iRun = 1:2
        
        %% ENCODING PHASE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % load the data from the hexagi_phase_splitting_behaviour script
        load(fullfile(ProcPath, sprintf('Sub%d', subID), 'Encoding', sprintf('Encoding%d.mat', iRun)));
        
        %% Plot the paths
        fH = figure('visible', 'off');
        title(sprintf('Encoding phase, sub%d, run %d',subID,iRun))

        for iTrial = 1:length(Encoding.TrialStart)
            
            %subplot(2,3,iTrial)       %comment this out and I get one plot with all locations  
            hold on
            %draw a circle of the arena
            X = -175;                                                                 
            Y = -175; 
            Center = [X Y];
            Radius = 5175;
            axis equal 
            %display the circle
            viscircles(Center,Radius,'color',[0.4,0.4,0.4],'linewidth',1);
            axis off
            
            %fill in the path for the time of interest
            TimeOfInterest = EncodingPlayerLoc > Encoding.TrialStart(iTrial) & EncodingPlayerLoc < Encoding.TrialEnd(iTrial);
    
            % Plot the player locations                  
            a = plot(EncodingPlayer.LocX(TimeOfInterest), EncodingPlayer.LocY(TimeOfInterest),'-', 'linewidth', 1, 'color', [0.3,0.3,0.3]);
            
            % Mark the location where the object was shown and grabbed                                                       
            b = scatter(Encoding.ObjectLocX(iTrial), Encoding.ObjectLocY(iTrial), 50, [0.4 0.2 0.2] , 'MarkerFaceColor', [0.4 0.2 0.2] );           
            
            % Mark the landmark location
            c = scatter(LMLoc1(1), LMLoc1(2),50,[0.0,0.5,0.5],'MarkerFaceColor', [0.0 0.8 0.8]); 
        end

        legend([a,b,c],'Player path','Correct object locations','Landmark','Location','SouthEastOutside') 
             
        %Save the figure
        figName = fullfile(FigPath,'\Subjects',sprintf('Sub%d',subID), sprintf('EncodingPath%d',iRun'));        
        fig = gcf;
        saveas(gcf,figName ,'png')
        close all
    end
end
end
