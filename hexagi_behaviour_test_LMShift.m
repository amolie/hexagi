function hexagi_behaviour_test_LMShift(Subjects,ProcPath,StatsPath,FigPath)
% Evaluates if the drop locations are shifted in the DIRECTION of the landmark in the test phase ~= landmark bias in memory for the test phase

% Checks if the angular difference of the vectors
% 1) the correct object location to the LM  
% 2) the correct object location to the drop location
% is clustered around 0 and different from the groups, 
% ~= the memory is shifted in the direction of the LM


if  nargin <1
    Subjects    = load('hexagi_subjects')';
    ProcPath    = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
    StatsPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Stats';
    FigPath     = 'C:\MasterThesis\Data\Hexagi\Behaviour\Figures';
end

nSubs       = length(Subjects); 
YoungIdx    = Subjects <200;
OldIdx      = Subjects >=200;


%% Calculate LM shift %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AngDiffAllSubs = [];
for iSub  = 1:nSubs
    SubID = Subjects(iSub);
    
    AngDiffSub  = [];
    
    for iRun = 1:2
        % Get locations from the test phase
        load(fullfile(ProcPath,sprintf('Sub%d',SubID),'Test\',sprintf('Test%d',iRun)),'Test');
   
        % 1 Distance from the correct object location to the LM 
        X = double(Test.LMLocX) - Test.CorrectLocX;
        Y = double(Test.LMLocY) - Test.CorrectLocY;
        [Ang1,~] = cart2pol(X,Y);
                
        % 2 Distance from the correct object locations to the drop locations
        X = double(Test.DropLocX) - Test.CorrectLocX;
        Y = double(Test.DropLocY) - Test.CorrectLocY;
        [Ang2,~] = cart2pol(X,Y);
          
        % Angular difference between distance 1 and 2
        AngDiffSub = [AngDiffSub ; circ_dist(Ang1,Ang2)];
        
    end
    % All trials of both runs for all subs - for plotting
    AngDiffAllSubs = [AngDiffAllSubs ; AngDiffSub];    
    
    % Mean of both runs for all subs
    % Using abs makes the angular difference not circular anymore
    AngDiff(iSub,:) = mean(abs(AngDiffSub)); %for analysis
    %AngDiff(iSub,:) = circ_mean(AngDiffSub); %for plots
       
end

if ~exist(fullfile(StatsPath,'\Test\LMShift'),'dir')
    mkdir(fullfile(StatsPath,'\Test\LMShift'))
end
save(fullfile(StatsPath,'\Test\LMShift\AngDiff'),'AngDiff')


%% Outliers
AngDiffYoung    = AngDiff(YoungIdx);
OutIdxYoung     = isoutlier(AngDiffYoung, 'median');
AngDiffYoung    = AngDiffYoung(~OutIdxYoung);

AngDiffOld      = AngDiff(OldIdx);
OutIdxOld       = isoutlier(AngDiffOld, 'median');
AngDiffOld      = AngDiffOld(~OutIdxOld);


%% Compare the groups using absolute values == the data is not circular anymomre
[h,p,ci,stats] = ttest2(AngDiffOld, AngDiffYoung);
CohensD        = abs(mean(AngDiffOld) - mean(AngDiffYoung)) /std(AngDiffYoung); %based on the largest std


%% Polar histogram of all trials
AngDiffDeg = rad2deg(AngDiffAllSubs); 
FullCircle = AngDiffDeg + (AngDiffDeg < 0)*360;

% Young
figure;
YoungIdx   = Subjects < 200;
FullCircleYoung = deg2rad(FullCircle(1:length(Subjects(YoungIdx))*60));

h = polarhistogram(FullCircleYoung);
h.DisplayStyle = 'stairs';

figName = fullfile(FigPath,'\LMShift\LMShift_PolarYoung');
fig = gcf;
saveas(gcf,figName,'epsc')

% Old
figure;
OldIdx = Subjects >=200;
FullCircleOld = deg2rad(FullCircle(1560:end));
h = polarhistogram(FullCircleOld);
h.DisplayStyle = 'stairs';

figName = fullfile(FigPath,'\LMShift\LMShift_PolarOld');
fig = gcf;
saveas(gcf,figName,'epsc')


%% Compare against 0, i.e., if the data is clustered around 0
% Only for circular data!

% Give the test the direction we think the distribution should deviate in (in radians). 
% This makes it more powerful than a test that would just test for deviation from uniformity
%H0: The angles are not clustered around 0 (not unimodal, but uniform)
%H1: The angular data is clustered around 0 (unimodal)

[pYoung,v] = circ_vtest(AngDiffYoung, 0);
[pOld,v] = circ_vtest(AngDiffOld, 0);


%% Check differences in angular difference between the groups 

% First test the distribution of the data - is it unimodal?
% The circular analog to the normal distribution is the Von Mises distribution, V M (mu,kappa)   
r = circ_vmpar(AngDiff(YoungIdx));
[mu kappa] = circ_vmpar(AngDiff(YoungIdx));
pVM = circ_vmpdf(AngDiff(YoungIdx),mu,kappa); % only one of these are <0.05. = not unimodal for the rest?

r = circ_vmpar(AngDiff(OldIdx));
[mu kappa] = circ_vmpar(AngDiff(OldIdx));
pVM = circ_vmpdf(AngDiff(OldIdx),mu,kappa);

% Control for potential heteroskedasticity
VarYoung = circ_var(AngDiff(YoungIdx));
VarOld = circ_var(AngDiff(OldIdx));

% Non parametric multi-sample test for equal medians. Similar to a Kruskal-Wallis test for linear data
% Use this test because the data is not von Mises distributed
% H0: Any of samples share a common median direction
% H1: Not all samples have a common median direction
[pval, table]  = circ_wwtest(AngDiffYoung, AngDiffOld);

% Test the spread of the distributions against each other
% The Kuiper's test: a circular analogue of the Kolmogorov-Smirnov test  
% H0: The two distributions are identical
% H1: The two distributions are different
% res= resolution at which the cdf is evaluated
% CDF = Cumulative Distribution Function
%[pDistribution, k, K] = circ_kuipertest(AngDiffYoung, AngDiffOld, 100, 'vis_on')


%% Circular rose plots
% Young
figure; 
a = rose(AngDiffYoung);
a.Color = [0.86 0.54 0.45];
a.MarkerFaceColor = [0.86 0.54 0.45];

if ~exist(fullfile(FigPath,'\LMShift'),'dir')
    mkdir(fullfile(FigPath,'\LMShift'))
end

figName = fullfile(FigPath,'\LMShift\LMShift_roseYoung');
fig = gcf;
saveas(gcf,figName,'epsc')

% Old 
figure; b = rose(AngDiffOld);   
b.Color = [0.61 0.73 0.73];
B.MarkerFaceColor = [0.61 0.73 0.73];

figName = fullfile(FigPath,'\LMShift\LMShift_roseYoung');
fig = gcf;
saveas(gcf,figName,'epsc')
 

%% Barplot - can be used for both circular data and not (if so, remember to change the ylabel)
% Plot in radians - two half circles
data = [rad2deg(AngDiffYoung) [rad2deg((AngDiffOld));nan(2,1)]];

% Plot in degrees a full circle  Yaw = mod(Yaw,2*pi); - use instead!!
AngDiffDeg = rad2deg(AngDiff); 
FullCircle = AngDiffDeg + (AngDiffDeg < 0)*360;
data = [(FullCircle(YoungIdx)) [(FullCircle(OldIdx));nan(4,1)]];

plotoptions                     = [];
plotoptions.fontSize            = 20;
plotoptions.fontName            = 'Gill Sans MT';
plotoptions.indMeas             = 'dots';               % leave as dots if you have uneven number of datapoints per condition
%plotoptions.ylabel              = 'Angular difference';
plotoptions.xticklabel          = {'Young' 'Old'};
plotoptions.barcolor            = [[0.86 0.54 0.45];[0.61 0.73 0.73]];
% plotoptions.ytick               = ([-1 0 1.5]);
% % plotoptions.ylim                = [-45 45];
% plotoptions.yticklabel          = ([-1 0 1.5]);

fHandle = hexagi_barplotscript(data, plotoptions);

if ~exist(fullfile(FigPath,'\LMShift'),'dir')
    mkdir(fullfile(FigPath,'\LMShift'))
end

figName = fullfile(FigPath,'\LMShift\LMShift');
fig = gcf;
saveas(gcf,figName,'epsc')


end