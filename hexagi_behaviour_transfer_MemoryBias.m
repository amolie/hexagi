function hexagi_behaviour_transfer_MemoryBias(Subjects,ProcPath,StatsPath,FigPath)
% Memory bias analysis - Doeller 2008

% Evaluates whether objects are rememered according to the landmark positions (LM bias) or to the boundaries (boundary bias) of the arena 

% Estimates correct object locations for the transfer phase based on the test phase:
% the distance from the old LM loc to the correct object locations are added to the moved LM location (NewLMLoc). 
% If a drop locations in the transfer phase, i.e., if the remembered object location is closer to the original LM location this will be a LM bias in memory: 
% the object locations are remembered relative to the LM. 
% If the drop locations are closer to the new/moved LM locations the locations are remembered relative to the boundary of the arena. 


if  nargin<1
    Subjects  = load('hexagi_subjects')';
    ProcPath  = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
    StatsPath = 'C:\MasterThesis\Data\Hexagi\Behaviour\Stats';
    FigPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Figures';
end

nSubs         = length(Subjects);
YoungIdx      = Subjects < 200;
OldIdx        = Subjects >= 200;
fprintf('Evaluating LM vs. boundary based memory for young and old \n')


%% LM loc test and new LM loc in transfer: different positions for run 1 and run 2 (counterbalanced between subs)

StandardBoundaryAllSubs = [];
for iSub = 1:nSubs
    SubID = Subjects(iSub);
    for iRun = 1:2
        load(fullfile(ProcPath,sprintf('Sub%d',SubID),'\Transfer',sprintf('Transfer%d',iRun)));
        
        Standard = Transfer(Transfer.Boundary == 1,{'SubID' 'Object' 'DropLocX' 'DropLocY'});
        StandardBoundaryAllSubs = [StandardBoundaryAllSubs ; Standard];
    end
end


TestBR = []; % Test both runs
TranBR = []; % Transfer both runs

for iRun = 1:2       

    TranDropLoc = StandardBoundaryAllSubs;
    
    TestLMLoc   = [];
    TranLMLoc   = [];
    TestCorrLoc = [];
    
    for iSub = 1:nSubs
        SubID = Subjects(iSub);
        
        %LM loc test and transfer
        load(fullfile(ProcPath,sprintf('Sub%d',SubID), sprintf('Run%d.mat', iRun)),'LMLoc1','NewLMLoc1')  
        TestLMLoc = [TestLMLoc ; [SubID LMLoc1(1) LMLoc1(2)]];
        TranLMLoc = [TranLMLoc ; [SubID NewLMLoc1(1) NewLMLoc1(2)]];
        
        %Correct object locations test
        load(fullfile(ProcPath,sprintf('Sub%d',SubID),'\Test', sprintf('Test%d.mat', iRun)),'Test');
        temp = Test(:,{'SubID', 'Object', 'CorrectLocX', 'CorrectLocY'}); %sub 108 is excluded
        TestCorrLoc = [TestCorrLoc ; temp];
    end  
      
    %Test
    TestLMLoc = repmat(TestLMLoc,30,1);    
    TestLMLoc = table(TestLMLoc(:,1),TestLMLoc(:,2),TestLMLoc(:,3),'VariableNames',{'SubID','OldLMLocX', 'OldLMLocY'});
    TestLMLoc = sortrows(TestLMLoc,'SubID');

    TestLMLoc = TestLMLoc(:,[2 3]); %should use join here
    Test      = [TestCorrLoc TestLMLoc];
    TestBR    = [TestBR ; Test];

    %Transfer
    TranLMLoc = repmat(TranLMLoc,10,1);
    TranLMLoc = table(TranLMLoc(:,1),TranLMLoc(:,2),TranLMLoc(:,3),'VariableNames',{'SubID', 'NewLMLocX','NewLMLocY'});
    TranLMLoc = sortrows(TranLMLoc,'SubID');

    TranLMLoc = TranLMLoc(:,{'NewLMLocX' 'NewLMLocY'});
    Transfer  = [TranDropLoc TranLMLoc];
    Run       = zeros(height(Transfer),1);
    Run(:,:)  = iRun;        
    TranBR    = [TranBR ; array2table(Run) Transfer];

end


 %% Add distance between OldLM to correct object loc from the test phase
 
 % Distance from (old/test)LM loc to correct loc test 
 
 X = TestBR.CorrectLocX - double(TestBR.OldLMLocX); 
 Y = TestBR.CorrectLocY - double(TestBR.OldLMLocY);
 [TestBR.TH,TestBR.R] = cart2pol(X,Y);
 
 % Extract participants that have the same objects in both runs to be able to get 10 unique object positions
 temp         = TestBR.SubID ~= 102 & TestBR.SubID ~= 202 & TestBR.SubID ~= 203;
 ExclTestSubs = TestBR(~temp,:);
 TestBR       = TestBR(temp,:);
 
 temp         = TranBR.SubID ~= 102 & TranBR.SubID ~= 202 & TranBR.SubID ~= 203;
 ExclTranSubs = TranBR(~temp,:);
 TranBR       = TranBR(temp,:);

 % Get the unique objects
 TestUnique   = sortrows(unique(TestBR(:,(2:end)),'rows'),'Object');
 TranUnique   = sortrows(unique(TranBR(:,[ 3 6 7]),'rows'),'Object');
 
 % Include all subjects again
 TestBR       = [TestBR ; ExclTestSubs];
 TranBR       = [TranBR ; ExclTranSubs];
  
 TestBR       = sortrows(TestBR,'Object');
 TranBR       = sortrows(TranBR,'Object');
 
 Objects      = categorical({'bucket' 'candlestick' 'pumpkin' 'rubber_duck' 'straw_hat_8' ...
                        'accordion' 'alarm_clock' 'baguette' 'basketball' 'briefcase'})';

 % Find the object from the test phase and add their values to the transfer phase
 for iObject                                = 1:length(Objects)
     ObjectType                             = Objects(iObject);
         
     ObjectTest                             = find(TestUnique.Object == ObjectType);    
     ObjectTran                             = find(TranBR.Object == ObjectType);
     
     TranBR.OldLMLocX(ObjectTran)           = TestUnique.OldLMLocX(ObjectTest);
     TranBR.OldLMLocY(ObjectTran)           = TestUnique.OldLMLocY(ObjectTest);
     TranBR.CorrLocX(ObjectTran)            = TestUnique.CorrectLocX(ObjectTest);
     TranBR.CorrLocY(ObjectTran)            = TestUnique.CorrectLocY(ObjectTest);
     TranBR.OldLM_CorrObjLoc_TH(ObjectTran) = TestUnique.TH(ObjectTest);
     TranBR.OldLM_CorrObjLoc_R(ObjectTran)  = TestUnique.R(ObjectTest);

 end
 
 
%% Distances for both runs
  
% Distance from drop location to OLD LMPos
X = [TranBR.DropLocX TranBR.DropLocY];
Y = [TranBR.OldLMLocX TranBR.OldLMLocY];
TranBR.OldLM_DropLoc = diag(pdist2(X,Y));

% Distance from drop location to NEW LMPos 
X = [TranBR.DropLocX TranBR.DropLocY];
Y = [TranBR.NewLMLocX TranBR.NewLMLocY];
TranBR.NewLM_DropLoc = diag(pdist2(X,Y));

% Distance from drop loc transfer to correct loc test: Boundary based
X = [TranBR.DropLocX TranBR.DropLocY];
Y = [TranBR.CorrLocX TranBR.CorrLocY];
TranBR.Drop_Corr_BoundaryBias = diag(pdist2(X,Y));

% Predicted "correct" locations transfer
[TranBR.PredCorrLocX, TranBR.PredCorrLocY] = pol2cart(TranBR.OldLM_CorrObjLoc_TH,TranBR.OldLM_CorrObjLoc_R);
TranBR.PredCorrLocX = TranBR.PredCorrLocX + TranBR.NewLMLocX;
TranBR.PredCorrLocY = TranBR.PredCorrLocY + TranBR.NewLMLocY;

% Distance from drop loc transfer to predicted correct loc test: LM based
X = [TranBR.DropLocX TranBR.DropLocY];
Y = [TranBR.PredCorrLocX TranBR.PredCorrLocY];
TranBR.Drop_predCorr_LMBias = diag(pdist2(X,Y)); 

% Save for the plots of the transfer phase
if ~exist(fullfile(StatsPath,'\Transfer'),'dir'); mkdir(fullfile(StatsPath,'\Transfer')); end
save(fullfile(StatsPath,'\Transfer\TranBR'),'TranBR');

 
%% LM / Boundary bias

DLM         = TranBR.Drop_predCorr_LMBias;
DB          = TranBR.Drop_Corr_BoundaryBias;
TranBR.Bias = DLM ./(DB + DLM);

% Mean for each participant
MemoryBias     = [];
for iSub       = 1:nSubs
    SubID      = Subjects(iSub);
    
    SubIdx     = TranBR.SubID == SubID;
    MemoryBias = [MemoryBias ; SubID  [mean(TranBR.Bias(SubIdx))]]; 
end

% These subs have more LM bias
LMBias = MemoryBias(MemoryBias(:,2) >0.5,:); 

% These subs have more boundary bias than LM bias
BBias = MemoryBias(MemoryBias(:,2) < 0.5,:); 

% Don't need SubID anymore
MemoryBias = MemoryBias(:,2);

if ~exist(fullfile(StatsPath,'\Transfer\MemoryBias_Doeller2008'),'dir') 
    mkdir(fullfile(StatsPath,'\Transfer\MemoryBias_Doeller2008')); 
end
save(fullfile(StatsPath,'\Transfer\MemoryBias_Doeller2008\MemoryBias'),'MemoryBias');


%% Difference for the groups
[p,stats]       = vartestn([MemoryBias(YoungIdx),[MemoryBias(OldIdx); nan(4,1)]],'TestType','LeveneQuadratic');
[h,p,ci,stats]  = ttest2(MemoryBias(OldIdx),MemoryBias(YoungIdx),'VarType','Unequal');

SEMYoung        = std(MemoryBias(YoungIdx)) / sqrt(length(MemoryBias(YoungIdx))); 
SEMOld          = std(MemoryBias(OldIdx)) / sqrt(length(MemoryBias(OldIdx))); 
CohensD         = abs(mean(MemoryBias(YoungIdx)) - mean(MemoryBias(OldIdx))) / std(MemoryBias(YoungIdx)); %based on the largest std


%% Barplot of memory bias

data = [ MemoryBias(YoungIdx) [MemoryBias(OldIdx);nan(4,1)] ];

plotoptions                     = [];
plotoptions.title               = sprintf('Memory bias (Doeller 2008)');
plotoptions.fontSize            = 20;
plotoptions.fontName            = 'Gill Sans MT';
plotoptions.indMeas             = 'dots';               % leave as dots if you have uneven number of datapoints per condition
plotoptions.ylabel              = 'Bias score: <0.5 = LM Bias, >0.5 = Boundary bias';
%plotoptions.xlabel              = '';
% plotoptions.xticklabel          = {'Young' 'Old'};
plotoptions.barcolor            =  [[0.0,0.5,0.5];[0 0.5 0.3]];
plotoptions.ylim                = ([0 1]);
plotoptions.ytick              = (0:0.5:1);
plotoptions.yticklabel          = (0:0.5:1);

fHandle = hexagi_barplotscript(data, plotoptions);

% Save the figure
if ~exist(fullfile(FigPath,'MemoryBias'),'dir') 
    mkdir(fullfile(FigPath,'MemoryBias')); 
end

fileName = fullfile(FigPath,'\MemoryBias\MemoryBias_Doeller2008');
saveas(fHandle, fileName,'epsc')


%% Correlate memory bias and navigation strategy

% Get navigational strategy
load(fullfile(StatsPath,'\Test\Navi_strategy\NaviStrategy')); % = PCentral - PSurround

% Correlations for all subs
[rAll,pAll]     = corr(MemoryBias,NaviStrategy);
r2All           = rAll^2;

% Young and old
[rYoung,pYoung] = corr(MemoryBias(YoungIdx),NaviStrategy(YoungIdx));
r2Young         = rYoung^2;
[rOld,pOld]     = corr(MemoryBias(OldIdx),NaviStrategy(OldIdx));
r2Old           = rOld^2;


%% Plot
figure;
a = scatter(MemoryBias(YoungIdx),NaviStrategy(YoungIdx),'MarkerEdgeColor',[0.4 0.8 0.6],'MarkerFaceColor',[0.4 0.8 0.6]);
lsline
hold on
b = scatter(MemoryBias(OldIdx),NaviStrategy(OldIdx),'MarkerEdgeColor',[0 0.5 0.3],'MarkerFaceColor',[0 0.5 0.3]);
lsline
%title(sprintf('Correlations (Doeller 2008), r = %.3f, r2 = %.3f, p = %.3f',rAll,r2All,pAll));
xlabel('Memory bias (>0.5 = LM bias)'); 
ylabel('Navigation strategy (>0 = central)');
legend([a,b],'Young','Old');

% Save the figure
if ~exist(fullfile(FigPath,'\Memory_vs_NaviStrategy'),'dir')
    mkdir(fullfile(FigPath,'\Memory_vs_NaviStrategy')); end
box off
figName = fullfile(FigPath,'\Memory_vs_NaviStrategy\CorrelationsDoeller2008');
fig = gcf;
saveas(gcf,figName ,'epsc')
            

end
