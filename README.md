ow-signal conditions automatically

**Output:** `autoFitResults.mat`, containing the fit parameters for each `(level, channel)` pair.

---

### `skewedBiGaussian.m`

Defines the combined model used for curve fitting:

```matlab
function y = skewedBiGaussian(p, x)
    g1 = p(1) * exp(-((x - p(2)).^2) / (2 * p(3)^2)) .* normcdf(x, p(5), p(4));   % Skewed early
    g2 = p(6) * exp(-((x - p(7)).^2) / (2 * p(8)^2));                             % Normal late
    y = g1 + g2;
end

### 'final.m'

Generates a single figure with all 16 channels (subplot(4, 4, ch)) overlaid with:

Raw PSTH (gray bars)

Early fit (solid colored line)

Late fit (dashed colored line)

Key Features:

Only plots above-threshold responses (≥4× baseline STD)

Uses consistent time axis for all plots (0–20 ms)

Color indicates stimulus level (parula colormap)

Useful for batch quality control and comparison across channels

plotAllChannelsWithFits.m

Generates separate PNG figures for each channel, showing all levels on one plot.

Key Features:

Saves to channel_fit_figures/ folder

PSTH shown as bars

Early fits (solid), Late fits (dashed), color-coded by level

Great for publication-quality visuals or detailed inspection

Output:

channel_fit_figures/
├── Channel_01_Fits.png
├── Channel_02_Fits.png
...
├── Channel_16_Fits.png


extractFitMetrics.m

Extracts and visualizes quantitative metrics from autoFitResults.mat.

📊 Extracted Metrics:

AUC (Area Under the Curve) for early and late responses

Latency (Gaussian center) for early and late peaks

Distance between peaks (in ms)

Peak height (from Gaussian amplitude)

📈 Output:

Heatmaps for AUC (early/late), latency, and peak distance

Console summary for a specified example level/channel (defaults to Level 10, Channel 8)

Example console output:

📊 Example — Trial: VA_21_04_20-Trial016 | Level 10, Channel 8
Early Peak:  3.27 | Latency: 3.62 ms | AUC: 14.43
Late Peak:   0.40 | Latency: 6.00 ms | AUC: 1.72
Distance between Peaks: 2.38 ms


You can modify the exampleLevel and exampleChannel variables to print any combination you want.

🧠 Usage Summary
% Step-by-step pipeline
run('automatedGaussianFit.m');        % Fit PSTH curves
run('final.m');                       % Plot all 16 channels in a single figure
run('plotAllChannelsWithFits.m');     % Save per-channel PNGs
run('extractFitMetrics.m');           % Extract AUC/latency + show heatmaps

🧾 Input Requirements

Each dataset .mat file must contain:

HistPeriod (5D PSTH data)

PeriodEdges4Plotting (time bins)

details (artifact length, etc.)

Make sure to update the dataFile path in each script to match your .mat file.

📦 Output Summary
Output File/Folder	Description
autoFitResults.mat	Stores skewed + normal Gaussian parameters
final.m figure	16-subplot overlay of fits
channel_fit_figures/	Individual PNG plots per channel
Heatmaps (extractFitMetrics)	AUC, latency, and peak separation
👩‍💻 Maintainer

Ashley Kim
