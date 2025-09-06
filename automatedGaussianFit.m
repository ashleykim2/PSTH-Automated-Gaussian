%% automatedGaussianFit.m — Fits Early Skewed + Late Normal Gaussians
clc; clear; close all;

%% Load Data
dataFile = 'VA_21_04_20-Trial016.mat';  % CHANGE AS NEEDED
load(fullfile('..','Data', dataFile));

if ~exist('HistPeriod','var') || ~exist('details','var') || ~exist('PeriodEdges4Plotting','var')
    error('Required variables missing in MAT file.');
end

%% Preprocess PSTH
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

% Fit model: [amp1, mu1, sigma1, skewSlope, skewCenter, amp2, mu2, sigma2]
lb = [0, 1, 0.5, 0.1, 1, 0, 6, 0.5];
ub = [Inf, 6, 5.0, 5, 8, Inf, 12, 5.0];

%% Fitting Loop
for lvl = 1:numLevels
    for ch = 1:numChannels
        psth_raw = squeeze(HistPeriodtoPlot(lvl, ch, :));

        % Skip bad PSTHs
        if max(psth_raw) < 2
            autoFitResults{lvl, ch} = [];
            continue;
        end

        % Normalize
        normFactor = max(psth_raw);
        psth = psth_raw / normFactor;

        % Initial guess
        [~, earlyIdx] = max(psth(t >= 2 & t <= 6));
        earlyIdx = earlyIdx + find(t >= 2, 1) - 1;
        [~, lateIdx] = max(psth(t >= 8 & t <= 15));
        lateIdx = lateIdx + find(t >= 8, 1) - 1;

        p0 = [ ...
            1, t(earlyIdx), 1.0, 0.5, t(earlyIdx)+1.5, ...
            0.5, t(lateIdx), 1.5 ...
        ];

        try
            p_est = lsqcurvefit(@skewedBiGaussian, p0, t, psth, lb, ub, opts);

            g1.amp        = p_est(1) * normFactor;
            g1.center     = p_est(2);
            g1.sigma      = p_est(3);
            g1.skewSlope  = p_est(4);
            g1.skewCenter = p_est(5);

            g2.amp    = p_est(6) * normFactor;
            g2.center = p_est(7);
            g2.sigma  = p_est(8);

            g1.div = 2 * g1.sigma^2;
            g2.div = 2 * g2.sigma^2;

            autoFitResults{lvl, ch} = struct('g1', g1, 'g2', g2);

        catch
            autoFitResults{lvl, ch} = [];
        end
    end
end

%% Save results
save('autoFitResults.mat', 'autoFitResults');
fprintf('Saved skewed fits to autoFitResults.mat\n');
