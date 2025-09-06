%% extractFitMetrics.m
% Computes and visualizes Gaussian fit metrics: AUC, peak latency, and peak distance
% Displays summary heatmaps and prints values for one example Level x Channel pair

clc;
clear;
close all;

%% Set file paths
dataFile = fullfile('..', 'Data', 'VA_21_04_20-Trial016.mat');
fitFile = 'autoFitResults.mat';

% Extract trial name for labeling
[~, trialName, ~] = fileparts(dataFile);  % e.g., 'VA_21_04_20-Trial016'

%% Load data
load(fitFile, 'autoFitResults');         % load fit results
load(dataFile, 'PeriodEdges4Plotting');  % for time axis

% Sanity check
if ~exist('autoFitResults', 'var')
    error('autoFitResults not found in %s', fitFile);
end

%% Dimensions
numLevels = size(autoFitResults, 1);
numCh     = size(autoFitResults, 2);

%% Time vector
t = PeriodEdges4Plotting(1,:)';

%% Preallocate metric matrices
aucEarly  = zeros(numLevels, numCh);
aucLate   = zeros(numLevels, numCh);
latEarly  = zeros(numLevels, numCh);
latLate   = zeros(numLevels, numCh);
peakDist  = zeros(numLevels, numCh);
peakAmpE  = zeros(numLevels, numCh);
peakAmpL  = zeros(numLevels, numCh);

%% Compute metrics
for lvl = 1:numLevels
    for ch = 1:numCh
        fit = autoFitResults{lvl, ch};
        if isempty(fit)
            continue;
        end

        % Early and late fit curves
        early = fit.g1.amp * exp(-((t - fit.g1.center).^2) / (2 * fit.g1.sigma^2));
        late  = fit.g2.amp * exp(-((t - fit.g2.center).^2) / (2 * fit.g2.sigma^2));

        % Metrics
        aucEarly(lvl, ch) = trapz(t, early);
        aucLate(lvl, ch)  = trapz(t, late);
        latEarly(lvl, ch) = fit.g1.center;
        latLate(lvl, ch)  = fit.g2.center;
        peakDist(lvl, ch) = abs(fit.g2.center - fit.g1.center);
        peakAmpE(lvl, ch) = fit.g1.amp;
        peakAmpL(lvl, ch) = fit.g2.amp;
    end
end

%% Example output for one level/channel
exampleLevel = 10;
exampleChannel = 8;
fit = autoFitResults{exampleLevel, exampleChannel};

fprintf('\n📊 Example — Trial: %s | Level %d, Channel %d\n', trialName, exampleLevel, exampleChannel);
fprintf('Early Peak:  %.2f | Latency: %.2f ms | AUC: %.2f\n', ...
    fit.g1.amp, fit.g1.center, aucEarly(exampleLevel, exampleChannel));
fprintf('Late Peak:   %.2f | Latency: %.2f ms | AUC: %.2f\n', ...
    fit.g2.amp, fit.g2.center, aucLate(exampleLevel, exampleChannel));
fprintf('Distance between Peaks: %.2f ms\n\n', ...
    peakDist(exampleLevel, exampleChannel));

%% Heatmap Visualizations
figure('Name','Fit Metric Heatmaps','Color','w');

subplot(2,3,1);
imagesc(aucEarly); title('AUC – Early'); xlabel('Channel'); ylabel('Level'); colorbar;

subplot(2,3,2);
imagesc(aucLate); title('AUC – Late'); xlabel('Channel'); ylabel('Level'); colorbar;

subplot(2,3,3);
imagesc(peakDist); title('Peak Distance (ms)'); xlabel('Channel'); ylabel('Level'); colorbar;

subplot(2,3,4);
imagesc(latEarly); title('Latency – Early (ms)'); xlabel('Channel'); ylabel('Level'); colorbar;

subplot(2,3,5);
imagesc(latLate); title('Latency – Late (ms)'); xlabel('Channel'); ylabel('Level'); colorbar;

subplot(2,3,6);
imagesc(peakAmpE + peakAmpL); title('Peak Amp Sum'); xlabel('Channel'); ylabel('Level'); colorbar;

sgtitle(['Gaussian Fit Metrics — ', trialName], 'FontWeight','bold');
