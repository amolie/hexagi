%% Main hexagi behaviour script
% Re-analysis of young and ageing data collected by Nico Schuck - published in NeuroImage 2015: 
% Human ageing alters the neural computation and representation of space


% Reads behavioural log files received from Nico
% Structures the data into phases
% Finds forward and backward movements
% Finds and evaluates wall bumping differences for the groups
% Finds central and surround time points (navigational preference/strategy)
% Evaluates and plots navigational preference
% Evaluates viewing directions

% Evaluates memory bias based on all movements (forward and backward) or only forward movements) in 2 different ways (Distance: Doeller 2008 or angle(SGM): Shuck 2015).
% Checks distribution of yaw in the arena
% Plot paths for all phases with estimated "correct" object locations for the transfer phase

% Remember to change visibility to "on" to see the plots while the script is running!

clear 
clc

% Comment out or run script
warning(sprintf('Remember to choose:\n 1 only movement timepoints, or including standing still for the movementVSstandstill function \n'));

% Input 1 or 2
warning(sprintf('\n 2 only forward, or including backward movements, for the navi_strategy function'))
warning(sprintf('\n 3 choose to include or exclude wall bumping in the central surround function'))
warning(sprintf('\n 4 Choose only re-learning, or the entire phase, for the viewing function'))
warning(sprintf('\n 5 Choose all movements (incl.stand still), or only forward for the LMBound navigation function'))



%% BEHAVIOURAL ANALYSES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Define paths for all scripts
RawPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Raw';
ProcPath  = 'C:\MasterThesis\Data\Hexagi\Behaviour\Processed';
StatsPath = 'C:\MasterThesis\Data\Hexagi\Behaviour\Stats';
FigPath   = 'C:\MasterThesis\Data\Hexagi\Behaviour\Figures';


%% List of subjects
Subjects  = load('hexagi_subjects')';
nSubs     = length(Subjects);


%% Read behavioural log files
hexagi_behaviour_read_logs(Subjects,RawPath,ProcPath)


%% Structure the data into the 3 phases: encoding, test and transfer
hexagi_behaviour_phase_splitting_encoding(Subjects,ProcPath)
hexagi_behaviour_phase_splitting_test(Subjects,ProcPath)
hexagi_behaviour_phase_splitting_transfer(Subjects,ProcPath)


%% Get player locations and yaw only for movement timepoints
% Comment out to include standing still time points
hexagi_behaviour_test_movementVSstandstill(Subjects,ProcPath)
hexagi_behaviour_transfer_movementVSstandstill(Subjects, ProcPath)

 
%% Backward and forward player movements
TimePoints  = 'Movement';                    % Only evaluate time points when the sub is moving
%TimePoints  = 'Movement_and_StandStill';     % Evaluate all time points including stand still
%TimePoints  = 'StandStill';                  % Evaluate only stand still time points = only viewing ahead or not??

hexagi_behaviour_player_backward_test(Subjects,TimePoints,ProcPath,StatsPath,FigPath)
hexagi_behaviour_plots_backward_test(Subjects,ProcPath,FigPath)

hexagi_behaviour_player_backward_transfer(Subjects,TimePoints,ProcPath,StatsPath,FigPath)


%% Wall bumping
hexagi_behaviour_wall_bumping(Subjects,ProcPath,StatsPath,FigPath)


%% Split the test phase into central and surround time points and plot the paths
%Input = 1; % Forward 
Input  = 2; % AllMove  
hexagi_behaviour_navi_strategy(Input,Subjects,ProcPath,StatsPath,FigPath)


%% Do central vs. surround analysis, incl. barplot
Bump = 0;
%Bump = 1; % exclude
hexagi_behaviour_test_centralVSsurround(Subjects,Bump,ProcPath,StatsPath,FigPath)


%% Learning
hexagi_behaviour_learning(Subjects,ProcPath,StatsPath,FigPath)
hexagi_behaviour_reg_learning(Subjects,StatsPath,FigPath)


%% Memory scores
hexagi_behaviour_chance(Subjects,ProcPath,StatsPath,FigPath)


%% Performance
hexagi_behaviour_performance(Subjects,ProcPath,FigPath,StatsPath)
hexagi_behaviour_reg_performance(Subjects,StatsPath,FigPath)


%% Viewing directions
% Define time periode to include
%Input      = 1;                            % Evaluates the entire phase
%Input      = 2;                            % Evaluate only re-learning / feedback, i.e. from show to grab
Input       = 3;                             % Evaluate only testing / i.e., from NaviStart to drop

% Define what kind of movements to include 
Movement    = 'Move_Backward';               % All movements (includes standing still and backward movements)
%Movement    = 'Move_nonBackward';          % All movements, but not backward (include standing still)
%Movement    = 'StandStill_Backward';       % Only stand still (include backwards) 
%Movement    = 'StandStill_nonBackward';    % Only stand still (exclude backwards)

% Test phase
hexagi_behaviour_test_viewing(Subjects,Input,Movement,ProcPath,FigPath)

% Transfer phase
hexagi_behaviour_transfer_viewing(Subjects,Movement,ProcPath,StatsPath,FigPath)


%% LM shift for the test phase
hexagi_behaviour_test_LMShift(Subjects,ProcPath,StatsPath)


%% Memory bias analysis - Doeller 2008
 hexagi_behaviour_transfer_MemoryBias(Subjects,ProcPath,StatsPath,FigPath)


%% Memory bias analysis - Shuck et al 2015 / SGM
hexagi_behaviour_transfer_LM_Boundary_SGM(Subjects,ProcPath,StatsPath,FigPath)


%% Correlate LM shift and memory bias (2008)
hexagi_behaviour_LMShift_MemoryBias(Subjects,StatsPath,FigPath)



