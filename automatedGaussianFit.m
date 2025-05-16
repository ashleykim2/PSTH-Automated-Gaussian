
%% automatedGaussianFit.m
% Fits bi-Gaussian curves to PSTH data with improved late/early balance
clc; clear; close all;

%% Load Data
load(fullfile('..','Data','VA_21_04_20-Trial017.mat'));
if ~exist('HistPeriod','var') || ~exist('details','var') || ~exist('PeriodEdges4Plotting','var')
    error('Required variables missing in MAT file.');
end

%% Preprocess PSTH
rangeIn = 1:length(details.inLevels);
HistPeriodtoPlot = squeeze(mean(HistPeriod(:,:,:,1:end/2+1,:), 4));
spont = squeeze(mean(mean(HistPeriod(:,1,:,1:end/2+1, details.artLengthSamp+20:end-20), 4), 5));
for ch = 1:16
    HistPeriodtoPlot(:,ch,:) = HistPeriodtoPlot(:,ch,:) - spont(ch);
end
HistPeriodtoPlot(HistPeriodtoPlot < 0) = 0;

%% Setup
t = PeriodEdges4Plotting(1,:)';
[numLevels, numChannels, ~] = size(HistPeriodtoPlot);
autoFitResults = cell(numLevels, numChannels);
opts = optimoptions('lsqcurvefit','Display','off');

% [amp1, mu1, sigma1, amp2, mu2, sigma2]
lb = [0, 1, 0.5, 0, 6, 0.5];
ub = [Inf, 6, 5.0, Inf, 12, 5.0];

%% Fitting Loop
for lvl = numLevels:-1:1  % Fit from high to low levels
    for ch = 1:numChannels
        psth = squeeze(HistPeriodtoPlot(lvl, ch, :));
        psth = psth(:);

        initialGuess = [max(psth)*0.8, 4, 1.5, max(psth)*0.5, 9, 2.0];

        try
            p_est = lsqcurvefit(@biGaussian, initialGuess, t, psth, lb, ub, opts);
        catch
            warning('Fit failed: level %d, channel %d', lvl, ch);
            p_est = NaN(1,6);
        end

        result.g1.amp = p_est(1); result.g1.center = p_est(2); result.g1.sigma = p_est(3);
        result.g2.amp = p_est(4); result.g2.center = p_est(5); result.g2.sigma = p_est(6);
        result.g1.div = 2 * p_est(3)^2; result.g2.div = 2 * p_est(6)^2;

        if result.g1.sigma < 0.5, result.g1.amp = 0; end
        if result.g2.sigma < 0.5, result.g2.amp = 0; end
        if result.g2.amp > 3 * result.g1.amp
            result.g2.amp = result.g2.amp * 0.6;
        end

        autoFitResults{lvl, ch} = result;
    end
end

save('autoFitResults.mat', 'autoFitResults');

%% Example Plot
exampleLevel = 10; exampleChannel = 8;
psth = squeeze(HistPeriodtoPlot(exampleLevel, exampleChannel, :));
fit = autoFitResults{exampleLevel, exampleChannel};

early = fit.g1.amp * exp(-((t - fit.g1.center).^2) / (2 * fit.g1.sigma^2));
late  = fit.g2.amp * exp(-((t - fit.g2.center).^2) / (2 * fit.g2.sigma^2));

figure;
bar(t, psth, 'FaceColor', [0.6 0.6 0.6], 'EdgeColor', 'none'); hold on;
plot(t, early, 'b-', 'LineWidth', 2);
plot(t, late, 'g-', 'LineWidth', 2);
legend('PSTH', 'Early', 'Late');
xlabel('Time [ms]'); ylabel('Spike Count');
title(sprintf('Level %d, Channel %d', exampleLevel, exampleChannel));
xlim([0 20]);
