%% final.m — Overlayed Skewed + Normal Gaussian Fits (16 Subplots in One Figure)
clc; clear; close all;

%% Specify which trial to analyze
dataFile = 'VA_21_04_20-Trial016.mat';       % change this per dataset
fitFile  = 'autoFitResults.mat';             % change if needed

%% Load data and fit results
load(fitFile);                               % contains autoFitResults
load(fullfile('..','Data', dataFile));       % contains HistPeriod, details, PeriodEdges4Plotting

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
figure('Name', sprintf('Overlayed Fits: %s', dataFile), ...
       'NumberTitle', 'off', 'Position', [100 100 1600 900], ...
       'Color', 'w');

for ch = 1:numChannels
    subplot(4, 4, ch); hold on;

    for lvl = 1:numLevels
        if ~isAboveThreshold(lvl, ch)
            continue;
        end

        psth = squeeze(HistPeriodtoPlot(lvl, ch, :));
        params = autoFitResults{lvl, ch};

        if isempty(params) || ...
           any(structfun(@(x) any(isnan(x)), params.g1)) || ...
           any(structfun(@(x) any(isnan(x)), params.g2))
            continue;
        end

        % Plot PSTH (gray)
        bar(t, psth, 'FaceColor', [0.6 0.6 0.6], 'EdgeColor', 'none', 'FaceAlpha', 0.05);

        % Early skewed Gaussian (solid)
        early = params.g1.amp * exp(-((t - params.g1.center).^2) / (2 * params.g1.sigma^2)) ...
                .* normcdf(t, params.g1.skewCenter, params.g1.skewSlope);

        % Late normal Gaussian (dashed)
        late = params.g2.amp * exp(-((t - params.g2.center).^2) / (2 * params.g2.sigma^2));

        % Plot fits
        plot(t, early, '-',  'Color', colors(lvl,:), 'LineWidth', 1.5);
        plot(t, late,  '--', 'Color', colors(lvl,:), 'LineWidth', 1.5);
    end

    xlabel('Time [ms]');
    ylabel('Spike Count');
    title(sprintf('%s Channel:%d', strrep(details.fn, '_', '-'), ch), 'FontSize', 9);
    xlim([0 20]);
    ylim([0 inf]);
    set(gca, 'FontSize', 9);
end

sgtitle(sprintf('Overlayed Skewed Early and Normal Late Gaussian Fits — %s', dataFile), 'FontSize', 13);
