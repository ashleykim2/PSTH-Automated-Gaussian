%% generatePlot.m
% This script loads the .mat file containing HistPeriod and other variables,
% and creates PSTH plots for all 16 channels.
%
% Required Variables:
%   - HistPeriod         : The 5D PSTH data.
%   - details            : A structure containing experiment details (e.g., inLevels, artLengthSamp).
%   - PeriodEdges4Plotting: Time edges for plotting.
%
% Make sure your .mat file is in the Data folder (located in the parent folder).

clc;
clear;
close all;

%% Load Data from the Data folder (one level up)
load(fullfile('..','Data','VA_21_04_20-Trial017.mat'));  

% Check if the 'details' structure is properly loaded
if ~exist('details', 'var')
    error('The details structure is missing or not loaded properly.');
end

% Define rangeIn based on the number of levels in the details structure
rangeIn = 1:length(details.inLevels);  % Using all stimulation levels

% Check the size of HistPeriod before processing
disp('Size of HistPeriod before processing:');
disp(size(HistPeriod));  % Expected: 1x15x16x19x250

% Compute the mean of HistPeriod along the 4th (repetitions) and 3rd (channels) dimensions
% This should collapse to a 15 x 250 matrix
meanHist = squeeze(nanmean(nanmean(HistPeriod(1, rangeIn, :, :, :), 4), 3));

% Ensure meanHist is 15 x 250
disp('Size of meanHist after processing:');
disp(size(meanHist));  % Expected: 15 x 250

% Check that the dimensions of PeriodEdges4Plotting and meanHist are compatible
if size(PeriodEdges4Plotting, 2) ~= size(meanHist, 2)
    error('The number of time points in PeriodEdges4Plotting and meanHist do not match.');
end

% Create the PSTH plot
figure; % Open a new figure

% Set up a 4x4 grid of subplots
for ch = 1:16
    subplot(4, 4, ch);  % Create a 4x4 grid of subplots, select the ch-th subplot
    
    % Title for each subplot (Channel)
    title(['Channel ' num2str(ch)]);
    
    % Plot the PSTH for the current channel using the function plotHistPeriod
    plotHistPeriod(details, PeriodEdges4Plotting, squeeze(nanmean(nanmean(HistPeriod(1, rangeIn, ch, :, :), 4), 3))); 
    % Adjust the axis limits for x-axis (from 0 to 20) 
    xlim([0 20]); % Adjust x-axis limits to range from 0 to 20
end

% Add a global title to the entire figure
sgtitle('Period PSTH for 16 Channels');
