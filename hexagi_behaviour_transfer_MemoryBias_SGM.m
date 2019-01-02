function hexagi_behaviour_transfer_MemoryBias_SGM(Subjects,ProcPath,StatsPath,FigPath)
% Memory bias analysis - SGM

% Calculate LM and boundary bias according to the SGM model by Schuck et al., 2015.
% Boundaries: 1=Standard, 2=Large, 3=small
% Plot the differences
% Correlate memory bias and navigational preference
% Plot the correlations

if  nargin<1
    Subjects  = load('hexagi_subjects');
    ProcPath  = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
    StatsPath = 'C:\MasterThesis\Data\Hexagi\Behaviour\Stats';
    FigPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Figures';
end

nSubs       = length(Subjects);
YoungIdx    = Subjects < 200;
OldIdx      = Subjects >= 200;

fprintf(' Evaluating LM vs. boundary based memory for young and old using SGM \n')


%% Variables and equations needed

% Boundary bias: 
% Ym      = predicted angle of change
% Yo      = observed angle
%
% P       = the drop location of the last object in the last feedback trial
% Pm      = the predicted transfer location / predicted memorised object location
% Po      = the drop location of the same object in the transfer phase 
%
% Ym - Yo = predicted angle of change(Ym) - observed angle(Yo)
%           (tan-1(P-Pm)) - (tan-1(P-Po))   
%           tan-1 = inverse tangens

%
% P - Pm  = compare the difference in the angles of the vectors that connect the original memory location (P) 
%           with the predicted memorised object locations (Pm) 
%
% P - Po  = compare the difference in the angles of the vectors that connect the original memory location (P) 
%           with the observed memory locations for the same object in the transfer phase 
%       
% Pm      = (1 +/- RadiusChange/RadiusStandard^2.*abs(P)).*P
%           + for the large arena
%           - for the small arena
%           transformation of each point, P, to Pm according to the change in radius in a radial direction


% Landmark bias:
% VLM      = the angle from the old LM location to the new LM location 
% P - Po   = the angle from the original memory location to the observed memory location
% LMBias   = the difference between LM movement angle (VLMAng) and the angle from original memory location (test phase) to the observed
%            memory location (transfer phase)



%% BOUNDARY BIAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BBias = [];
for iSub   = 1:nSubs
    SubID  = Subjects(iSub);
        
    StandardBBiasSub = [];
    LargeBBiasSub    = [];
    SmallBBiasSub    = [];
    BBiasSub         = [];    
    for iRun = 1:2 
        
        %% Get P: the drop location of the last of each object in the test phase - the original memory location
        load(fullfile(ProcPath,sprintf('Sub%d',SubID),'\Test',sprintf('Test%d',iRun)),'Test');
        
        % Sort alphabetically to be able to compare objects
        Test        = sortrows(Test(:,:),'Object');   
        P           = table2array(Test(6:6:end,{'DropLocX' 'DropLocY'})); 
        P           = [(P(:,1) + 175) (P(:,2) + 175)];
        
        
        %% Get Po: the drop location for the same objects in the transfer phase
        load(fullfile(ProcPath,sprintf('sub%d',SubID),'\Transfer',sprintf('Transfer%d',iRun)),'Transfer');
        Transfer   = sortrows(Transfer(:,:),{'Object'});
           
        Standard   = Transfer.Boundary == 1;
        Large      = Transfer.Boundary == 2;
        Small      = Transfer.Boundary == 3;
                
        PoStandard = table2array(Transfer(Transfer.Boundary == 1,{'DropLocX' 'DropLocY'}));
        PoLarge    = table2array(Transfer(Transfer.Boundary == 2,{'DropLocX' 'DropLocY'}));
        PoSmall    = table2array(Transfer(Transfer.Boundary == 3,{'DropLocX' 'DropLocY'}));       
        
        % Bring the coordinates from the three arenas into the same coordinate frame, subtracting the x and y coordinates of the respective arenas 
        % from the coordinates P and Po. This shifts the arena centers on top of each other.        
        PoStandard  = [(PoStandard(:,1) + 175) (PoStandard(:,2) + 175)];
        PoLarge     = [(PoLarge(:,1) - 29825) (PoLarge(:,2) + 300)];
        PoSmall     = [(PoSmall(:,1) - 61575) (PoSmall(:,2) + 150)];
        
        
        %% Calculate P - Po 
        % The difference in the angles of the vectors that connect the original memory location (P) 
        % with the observed memory locations for the same object in the transfer phase         

        XDiff                = [P(:,1) - PoStandard(:,1)];
        YDiff                = [P(:,2) - PoStandard(:,2)];
        [StandardP_PoAng,~]  = cart2pol(XDiff,YDiff);
        
        if  any(Large)
            XDiff            = [P(:,1) - PoLarge(:,1)];
            YDiff            = [P(:,2) - PoLarge(:,2)];
            [LargeP_PoAng,~] = cart2pol(XDiff,YDiff);
        end
        
        if  any(Small)
            XDiff            = [P(:,1) - PoSmall(:,1)];
            YDiff            = [P(:,2) - PoSmall(:,2)];
            [SmallP_PoAng,~] = cart2pol(XDiff,YDiff);
        end

        % Save P_PoAng to use for LM bias 
        if ~exist(fullfile(ProcPath,sprintf('Sub%d',SubID),'\Test\SGM'),'dir') 
            mkdir(fullfile(ProcPath,sprintf('Sub%d',SubID),'\Test\SGM')); end
        
        save(fullfile(ProcPath,sprintf('Sub%d',SubID),'\Test\SGM\StandardP_PoAng'),'StandardP_PoAng');
        
        
        %% Get Pm: the predicted transfer location / predicted memorised object locations
        RStandard   = 5175;
        RChange     = 1000;
                
        PmStandard  = P;
        PmLarge     = (1+RChange/RStandard^2.*abs(P)).*P; 
        PmSmall     = (1-RChange/RStandard^2.*abs(P)).*P ;

               
        %% Calculate P - Pm 
        % The difference in the angles of the vectors that connect the original memory location (P) 
        % with the predicted memorised object locations (Pm) 
               
        XDiff                = [P(:,1) - PmStandard(:,1)]; 
        YDiff                = [P(:,2) - PmStandard(:,2)];
        [StandardP_PmAng,~]  = cart2pol(XDiff,YDiff);
        
        if  any(Large)
            XDiff            = [P(:,1) - PmLarge(:,1)];
            YDiff            = [P(:,2) - PmLarge(:,2)];
            [LargeP_PmAng,~] = cart2pol(XDiff,YDiff);
        end
        
        if  any(Small)
            XDiff            = [P(:,1) - PmSmall(:,1)];
            YDiff            = [P(:,2) - PmSmall(:,2)];
            [SmallP_PmAng,~] = cart2pol(XDiff,YDiff);
        end
        
        
        %% Ym - Yo = predicted angle of change(Ym) - observed angle(Yo)
        % Compare the difference in the angles of the vectors that connect the original memory location (P) 
        % with the predicted/observed memory locations for the same object in the transfer phase 
        
        % Use circular distance as the difference measure since the angles are in radians 
        
        StandardBBias             = abs(circ_dist(StandardP_PmAng, StandardP_PoAng));
        if any(Large); LargeBBias = abs(circ_dist(LargeP_PmAng, LargeP_PoAng)); end
        if any(Small); SmallBBias = abs(circ_dist(SmallP_PmAng, SmallP_PoAng)); end
        
        
        %% Both runs
        StandardBBiasSub             = [StandardBBiasSub ; StandardBBias];
        if any(Large); LargeBBiasSub = [LargeBBiasSub ; LargeBBias]; end
        if any(Small); SmallBBiasSub = [SmallBBiasSub ; SmallBBias]; end

        
        %% Save to use for the plots 
        % Add the distance here for the plots?
        Transfer.PmLocX(Standard) = PmStandard(:,1);
        Transfer.PmLocY(Standard) = PmStandard(:,2);
        
        if  any(Large) 
            Transfer.PmLocX(Large) = PmLarge(:,1);
            Transfer.PmLocY(Large) = PmLarge(:,2);   
        end
       
        if  any(Small) 
            Transfer.PmLocX(Small) = PmSmall(:,1);
            Transfer.PmLocY(Small) = PmSmall(:,2);
        end
        
        % Add object to Pm for plotting
        Pm = Transfer(:,{'Object' 'PmLocX' 'PmLocY'});
        
        if ~exist(fullfile(ProcPath,sprintf('Sub%d',SubID),'\Transfer\ObjectMemorySGM'),'dir')
           mkdir(fullfile(ProcPath,sprintf('Sub%d',SubID),'\Transfer\ObjectMemorySGM')); end
        
        
        save(fullfile(ProcPath,sprintf('Sub%d',SubID),'\Transfer\ObjectMemorySGM\',sprintf('PmLocSGMRun%d',iRun)),'Pm');
                             
    end
    
    
    %% Angular difference for all trials from both runs - both large and small boundary
    BBiasSub    = [BBiasSub ; LargeBBiasSub ; SmallBBiasSub]; % Standard is the landmark trials
     
    %% All subs mean angular difference
    BBias   = [BBias ; mean(BBiasSub)];
    
end
if ~exist(fullfile(StatsPath,'\Transfer\MemoryBiasSGM'),'dir')
    mkdir(fullfile(StatsPath,'\Transfer\MemoryBiasSGM'))
end
save(fullfile(StatsPath,'\Transfer\MemoryBiasSGM\BBias'),'BBias'); 

%% Compare boundary bias for the groups
[p,stats]       = vartestn([BBias(YoungIdx),[BBias(OldIdx); nan(4,1)]],'TestType','LeveneQuadratic'); 
[h,p,ci,stats]  = ttest2(BBias(YoungIdx),BBias(OldIdx)); %sig

SEMYoung        = std(BBias(YoungIdx))/sqrt(length(BBias(YoungIdx)));
SEMOld          = std(BBias(OldIdx))/sqrt(length(BBias(OldIdx)));
CohensD         = abs(mean(BBias(YoungIdx)) - mean(BBias(OldIdx))) / std(BBias(OldIdx)); %based on the largest std


%% LANDMARK BIAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LMBias = [];
for iSub = 1:nSubs
    SubID = Subjects(iSub);
    
    LMBiasSub = [];
    for iRun = 1:2
        
        % Get VLM = the vector (angle and distance) from the old LM location to the new LM location
        load(fullfile(ProcPath,sprintf('sub%d',SubID),'\Transfer',sprintf('Transfer%d',iRun)),'Transfer');
        Transfer    = Transfer(Transfer.Boundary == 1,:);
        XDiff       = [double(Transfer.OldLMLocX) - Transfer.NewLMLocX];
        YDiff       = [double(Transfer.OldLMLocY) - Transfer.NewLMLocY];
        [VLMAng,~]  = cart2pol(XDiff,YDiff);    
        
        % Get the angle from P to Po
        load(fullfile(ProcPath,sprintf('Sub%d',SubID),'\Test\SGM\StandardP_PoAng'));
          
        % Get the difference between LM movement angle (VLMAng) and the angle from original memory location (test phase) to the observed
        % memory location (transfer phase)
        LMBiasRun   = abs(circ_dist(VLMAng,StandardP_PoAng));
        
        % Both runs
        LMBiasSub   = [LMBiasSub ; LMBiasRun];
    
    end
    
    % All subs
    LMBias = [LMBias ; mean(LMBiasSub)];   
end
save(fullfile(StatsPath,'\Transfer\MemoryBiasSGM\LMBias'),'LMBias'); 


%% Compare landmark bias for the groups
[p,stats]       = vartestn([LMBias(YoungIdx),[LMBias(OldIdx); nan(4,1)]],'TestType','LeveneQuadratic'); 
[h,p,ci,stats]  = ttest2(LMBias(OldIdx),LMBias(YoungIdx)); %sig

SEMYoung        = std(LMBias(YoungIdx))/sqrt(length(LMBias(YoungIdx)));
SEMOld          = std(LMBias(OldIdx))/sqrt(length(LMBias(OldIdx)));
CohensD         = abs(mean(LMBias(YoungIdx)) - mean(LMBias(OldIdx))) / std(LMBias(OldIdx)); %based on the largest std


%% Barplot illustration boundary and landmark bias (as Shuck et al., 2015)

% Convert to degrees
BBias   = rad2deg(BBias);
LMBias  = rad2deg(LMBias);

data    = [ BBias(YoungIdx) [BBias(OldIdx);nan(4,1)] LMBias(YoungIdx) [LMBias(OldIdx);nan(4,1)] ]; 

plotoptions                     = [];
plotoptions.title               = sprintf('Memory Bias (SGM)');
plotoptions.fontSize            = 30;
plotoptions.fontName            = 'Gill Sans MT';
plotoptions.indMeas             = 'dots';               % leave as dots if you have uneven number of datapoints per condition
plotoptions.ylabel              = '   ';
plotoptions.xticklabel          = {'Bbias young' 'Bbias old' 'LM young' 'LM old'};
plotoptions.barcolor            = [[0.0,0.5,0.5];[0 0.5 0.3];[0.0,0.5,0.5];[0 0.5 0.3]];
plotoptions.ylim                = [0 160];
plotoptions.ytick               = (0:50:150);
plotoptions.yticklabel          = (0:50:150);

fHandle = hexagi_barplotscript(data, plotoptions);

% Save the figure
if ~exist(fullfile(FigPath,'\MemoryBias'),'dir')
           mkdir(fullfile(FigPath,'\MemoryBias')); end

FigName = fullfile(FigPath,'\MemoryBias','MemoryBiasSGM');
Fig     = gcf;
box off
saveas(gcf,FigName,'epsc')


%% Correlate boundary bias and navigation strategy

% Get navigational strategy
load(fullfile(StatsPath,'\Test\Navi_strategy\NaviStrategy')); % = PCentral - PSurround

% Correlate boundary bias for all subs
[rAll,pAll]     = corr(BBias,NaviStrategy); %sig.  %Something else than differences between old and young is going on!
r2All           = rAll^2;

% Boundary bias young and old
[rYoung,pYoung] = corr(BBias(YoungIdx),NaviStrategy(YoungIdx)); %n.s
[rOld,pOld]     = corr(BBias(OldIdx),NaviStrategy(OldIdx)); %n.s





%% Correlate LM bias and navigational strategy
[rAll,pAll]     = corr(LMBias,NaviStrategy); %n.s

% LM bias young and old
[rYoung,pYoung] = corr(LMBias(YoungIdx),NaviStrategy(YoungIdx)); %n.s
[rOld,pOld]     = corr(LMBias(OldIdx),NaviStrategy(OldIdx)); %n.s




end




