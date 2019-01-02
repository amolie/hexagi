function hexagi_behaviour_plots_backward_test(Subjects,ProcPath,FigPath)

% Plot player locations and yaw
% First plots one trial at a time (Input = 1), 
% then all trials in one plot (Input = 2).


if  nargin<1
    Subjects = load('hexagi_46subjects')';
    ProcPath  = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
    FigPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Figures';
end

nSubs = length(Subjects);


%% Plot all trials for the run in one plot

for iSub  = 1:nSubs
    SubID = Subjects(iSub);
    fprintf('Plot movement and yaw, sub%d \n',SubID)

    for iRun = 1:2
        load(fullfile(ProcPath, sprintf('sub%d', SubID), 'Test', sprintf('Test%d.mat', iRun)),'Test');
        load(fullfile(ProcPath, sprintf('Sub%d',SubID),'\Test\Player\Backward',sprintf('Backward_Move_Run%d',iRun)),'Backward');
        load(fullfile(ProcPath, sprintf('Sub%d',SubID),'\Test\Player\Backward',sprintf('Forward_Move_Run%d',iRun)),'Forward');
        
        fH = figure('visible', 'on');
        hold on;
        
        % Plot each trial separately
        for iTrial = 1:length(Test.TrialStart)
            ForwardTrial = Forward(Forward.LocTime >= Test.FixEnd(iTrial) & Forward.LocTime < Test.Grab(iTrial),:);
            BackwardTrial = Backward(Backward.LocTime >= Test.FixEnd(iTrial) & Backward.LocTime < Test.Grab(iTrial),:);
        
            % Mark the start location of the player
            if ~isempty(BackwardTrial)
                if  ForwardTrial.LocTime(1) < BackwardTrial.LocTime(1)
                    a = scatter(ForwardTrial.LocX(1),ForwardTrial.LocY(1),50, [89 91 89]/255, 'MarkerFaceColor',[90 119 97]/255); 
                else 
                    a = scatter(BackwardTrial.LocX(1),BackwardTrial.LocY(1),50, [89 91 89]/255, 'MarkerFaceColor',[90 119 97]/255);
                end
            else
                if ~isempty(ForwardTrial)
                    a = scatter(ForwardTrial.LocX(1),ForwardTrial.LocY(1),50, [89 91 89]/255, 'MarkerFaceColor',[90 119 97]/255);
                else
                    a = [];
                end
            end
        end
        
        % Orientation converted from cartesian to polar coordinates, only keeping the angle(theta)
        OrientRad   = cart2pol(Forward.YawX,Forward.YawY); % == Yaw.* 0.000096

        % Convert the theta to cartesian coordinates to be able to add the line 
        LineLength  = 35;
        [x,y]       = pol2cart(OrientRad, LineLength); 
        LineX       = Forward.LocX + x;
        LineY       = Forward.LocY + y;

        % Plot all trials in one figure        
        hold on 
        d = plot(Forward.LocX, Forward.LocY,'.','LineWidth',3,'color',[89 91 86]/255);
        plot([Forward.LocX, LineX]', [Forward.LocY, LineY]','-','LineWidth',1,'color',[89 91 86]/255);

        OrientRad   = cart2pol(Backward.YawX,Backward.YawY); 

        LineLength  = 35;
        [x,y]       = pol2cart(OrientRad, LineLength); 
        LineX       = Backward.LocX + x;
        LineY       = Backward.LocY + y;

        e = plot(Backward.LocX, Backward.LocY,'.','LineWidth',3,'color',[120 158 158]/255);
        plot([Backward.LocX, LineX]', [Backward.LocY, LineY]','-','LineWidth',1,'color',[120 158 158]/255);

        % Fit to areana size
        xlim([-5175 5175]);
        ylim([-5175 5175]);
        xticks([-5175 0 5175])
        yticks([-5175 0 5175])
        
        % Mark the start location of the player
        b = scatter(Test.DropLocX, Test.DropLocY, 50, [89 91 89]/255, 'MarkerFaceColor',[160 162 143]/255);
        % Mark the true object locations
        c = scatter(Test.CorrectLocX, Test.CorrectLocY, 50, [89 91 89]/255, 'MarkerFaceColor',[190 188 124]/255);      
        
        legend([a,b,c,d,e],'Player start','Player drop location','True object location','Forward movement','Backward movement');
                
        title(sprintf('Player locations and yaw, sub%d, run%d',SubID,iRun));
        
        if ~exist(fullfile(FigPath,'\Subjects\',sprintf('Sub%d',SubID),'Backward'),'dir') 
            mkdir(fullfile(FigPath,'\Subjects\',sprintf('Sub%d',SubID),'Backward')); end

        box off
        FigName = fullfile(FigPath,'\Subjects\',sprintf('Sub%d',SubID),'Backward',sprintf('Backward_Run%d',iRun));
        Fig     = gcf;
        saveas(gcf,FigName ,'epsc')

        close all
    end
end

   

%% Plot one trial at a time

for iSub  = 17%38 1:nSubs
    SubID = Subjects(iSub);
    fprintf('Plot movement and yaw, sub%d \n',SubID)

    for iRun = 1%1:2
        load(fullfile(ProcPath, sprintf('sub%d', SubID), 'Test', sprintf('Test%d.mat', iRun)),'Test');
        load(fullfile(ProcPath, sprintf('Sub%d',SubID),'\Test\Player\Backward',sprintf('Backward_Move_Run%d',iRun)),'Backward');
        load(fullfile(ProcPath, sprintf('Sub%d',SubID),'\Test\Player\Backward',sprintf('Forward_Move_Run%d',iRun)),'Forward');

        % Plot each trial separately
        for iTrial = 22%14%1:length(Test.TrialStart)
            ForwardTrial = Forward(Forward.LocTime >= Test.FixEnd(iTrial) & Forward.LocTime < Test.Grab(iTrial),:);
            BackwardTrial = Backward(Backward.LocTime >= Test.FixEnd(iTrial) & Backward.LocTime < Test.Grab(iTrial),:);

            fH = figure('visible', 'on');
            hold on
            
            % Mark the start location of the player
            if ~isempty(BackwardTrial)
                if  ForwardTrial.LocTime(1) < BackwardTrial.LocTime(1)
                    a = scatter(ForwardTrial.LocX(1),ForwardTrial.LocY(1),80, [89 91 89]/255, 'MarkerFaceColor',[90 119 97]/255); 
                else 
                    a = scatter(BackwardTrial.LocX(1),BackwardTrial.LocY(1),80, [89 91 89]/255, 'MarkerFaceColor',[90 119 97]/255);
                end
            else
                if ~isempty(ForwardTrial)
                    a = scatter(ForwardTrial.LocX(1),ForwardTrial.LocY(1),80, [89 91 89]/255, 'MarkerFaceColor',[90 119 97]/255);
                else
                    a = [];
                end
            end
                        
            % Mark the drop location
            b = scatter(Test.DropLocX(iTrial), Test.DropLocY(iTrial), 80, [89 91 89]/255, 'MarkerFaceColor',[160 162 143]/255);
            % Correct object locations
            c = scatter(Test.CorrectLocX(iTrial), Test.CorrectLocY(iTrial), 80, [89 91 89]/255, 'MarkerFaceColor',[190 188 124]/255);
            
            % Forward
            % Orientation converted from cartesian to polar coordinates, only keeping the angle(theta)
            OrientRad   = cart2pol(ForwardTrial.YawX,ForwardTrial.YawY); % == Yaw.* 0.000096

            % Convert the theta to cartesian coordinates to be able to add the line 
            LineLength  = 30;
            [x,y]       = pol2cart(OrientRad, LineLength); 
            LineX       = ForwardTrial.LocX + x;
            LineY       = ForwardTrial.LocY + y;
            
            d = plot(ForwardTrial.LocX, ForwardTrial.LocY,'.','LineWidth',3,'color',[89 91 86]/255);
            plot([ForwardTrial.LocX, LineX]', [ForwardTrial.LocY, LineY]','-','LineWidth',1,'color',[89 91 86]/255);
            
            % Backward
            OrientRad   = cart2pol(BackwardTrial.YawX,BackwardTrial.YawY); 

            LineLength  = 35;
            [x,y]       = pol2cart(OrientRad, LineLength); 
            LineX       = BackwardTrial.LocX + x;
            LineY       = BackwardTrial.LocY + y;
 
            e = plot(BackwardTrial.LocX, BackwardTrial.LocY,'.','LineWidth',3,'color',[120 158 158]/255);
            plot([BackwardTrial.LocX, LineX]', [BackwardTrial.LocY, LineY]','-','LineWidth',1,'color',[120 158 158]/255);
                        
            % Add legend and title
            %legend([a,b,c,d,e],'Player start','Player drop location','True object location', 'Forward movement','Backward movement', 'Location','SouthEast');
            %title(sprintf('Player locations and yaw, sub%d, run%d, trial%d',SubID,iRun,iTrial));
            
            xticks([1600 2600 3600]);
            xticklabels([1600 2600 3600]);
            yticks([-2500 0 2000]);
            yticklabels([-2500 0 2000]);
            box off
            
            % Save the figure
            if ~exist(fullfile(FigPath,'\Subjects\',sprintf('Sub%d',SubID),'Backward'),'dir') 
                mkdir(fullfile(FigPath,'\Subjects\',sprintf('Sub%d',SubID),'Backward')); end

            FigName = fullfile(FigPath,'\Subjects\',sprintf('Sub%d',SubID),'Backward',sprintf('Backward_Run%d_Trial%d',iRun,iTrial));
            Fig     = gcf;
            saveas(gcf,FigName ,'png')
% 
%             close all
        end
    end
end

  
end
