%% final.m — Overlayed Gaussian Fits (16 Subplots in One Figure)
clc; clear; close all;

%% Load data and fit results
load('autoFitResults.mat');  % contains autoFitResults
load(fullfile('..','Data','VA_21_04_20-Trial016.mat'));  % or change to Trial016.mat if needed

% Preprocess PSTH
HistPeriodtoPlot = squeeze(mean(HistPeriod(:,:,:,1:end/2+1,:), 4));
spont = squeeze(mean(mean(HistPeriod(:,1,:,1:end/2+1, details.artLengthSamp+20:end-20), 4), 5));
for ch = 1:16
    HistPeriodtoPlot(:, ch, :) = HistPeriodtoPlot(:, ch, :) - spont(ch);
end
HistPeriodtoPlot(HistPeriodtoPlot < 0) = 0;

%% Setup
t = PeriodEdges4Plotting(1,:)';
numLevels = size(HistPeriodtoPlot, 1);
numChannels = size(HistPeriodtoPlot, 2);
colors = parula(numLevels);

%% Thresholding logic
baselineWindow = details.artLengthSamp + 20 : size(HistPeriod, 5);
baselineSTD = squeeze(std(mean(HistPeriod(:,1,:,1:end/2+1, baselineWindow), 4), 0, 5));
peakPSTH = squeeze(max(HistPeriodtoPlot, [], 3));
isAboveThreshold = peakPSTH > 4 * baselineSTD';

%% Create one figure with all channels
figure('Name', 'Overlayed Fits for All Channels', 'NumberTitle', 'off', 'Position', [100 100 1600 900]);

for ch = 1:numChannels
    subplot(4, 4, ch); hold on;

    for lvl = 1:numLevels
        if ~isAboveThreshold(lvl, ch)
            continue;
        end

        psth = squeeze(HistPeriodtoPlot(lvl, ch, :));
        params = autoFitResults{lvl, ch};

        if isempty(params) || any(structfun(@(x) any(isnan(x)), params.g1)) || any(structfun(@(x) any(isnan(x)), params.g2))
            continue;
        end

        early = params.g1.amp * exp(-((t - params.g1.center).^2) / (2 * params.g1.sigma^2));
        late  = params.g2.amp * exp(-((t - params.g2.center).^2) / (2 * params.g2.sigma^2));

        bar(t, psth, 'FaceColor', [0.5 0.5 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.05);
        plot(t, early, '-',  'Color', colors(lvl,:), 'LineWidth', 1.5);
        plot(t, late,  '--', 'Color', colors(lvl,:), 'LineWidth', 1.5);
    end

    xlabel('Time [ms]');
    ylabel('Spike Count');
    title(sprintf('%s Channel:%d', strrep(details.fn, '_', '-'), ch), 'FontSize', 9);
    xlim([0 20]);
    ylim([0 inf]);
end

sgtitle('Overlayed Early (solid) and Late (dashed) Gaussian Fits Across All Channels');
