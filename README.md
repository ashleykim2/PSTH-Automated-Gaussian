# PSTH-Automated-Gaussian  
## BiGaussian Fitting Pipeline for Neural PSTH Data

This repository automates the process of fitting early and late neural responses using bi-Gaussian models. The scripts are designed for peri-stimulus time histogram (PSTH) data recorded from multichannel brainstem stimulation experiments.

---

## Files

### `automatedGaussianFit.m`  
This script performs **automated curve fitting** on multichannel PSTH data. For each stimulation level and electrode channel:

- It fits a **bi-Gaussian model** to the PSTH, representing the early and late neural response components.
- The early peak is modeled using a symmetric Gaussian.
- The late peak is also Gaussian, with parameter constraints to suppress unrealistic amplitudes or widths.
- Fits are performed **from high to low stimulation levels**, promoting monotonic trends in peak latency (based on auditory physiology).
- Outputs are saved to `autoFitResults.mat`.

**Key Features:**
- Preprocessing includes baseline subtraction using late trial windows.
- All fitting uses `lsqcurvefit` with constraints to avoid overfitting.
- Example plots are generated for quick verification.

---

### `final.m`  
This script visualizes the automated fit results across **all 16 channels** in a single figure. For each channel:

- It overlays early and late fitted Gaussians on top of the raw PSTH curves.
- Only **above-threshold** levels are shown (i.e., levels with a response ≥ 4× baseline standard deviation).
- Colors differentiate different stimulus levels, with early fits shown as solid lines and late fits as dashed lines.

**Key Features:**
- Data is thresholded to exclude low-level/noisy responses.
- Uses `subplot(4, 4, ch)` to compile all channel fits in one figure.
- Useful for cross-channel comparison and batch QC.

---
### `biGaussian.m`  
Defines the **bi-Gaussian model** used during fitting. This is the core model used in `lsqcurvefit` to capture the dual-peak structure of PSTH responses.

```matlab
function y = biGaussian(p, x)
    y1 = p(1) * exp(-((x - p(2)).^2) / (2 * p(3)^2));  % Early Gaussian
    y2 = p(4) * exp(-((x - p(5)).^2) / (2 * p(6)^2));  % Late Gaussian
    y = y1 + y2;
end

---

### 'final.m'

This script visualizes the automated fit results across all 16 channels in a single figure.

For each channel:

Overlays raw PSTH (gray bars), early Gaussian fits (solid colored lines), and late Gaussian fits (dashed lines)

Only displays above-threshold responses (≥ 4× baseline standard deviation)

Uses color to indicate stimulus level (parula colormap)

Key Features:

Uses subplot(4, 4, ch) to display all channels in one window

Consistent time axis (0–20 ms) for easier comparison

Great for batch QC and visual inspection

plotAllChannelsWithFits.m

Generates and saves a separate PNG figure for each channel showing all stimulus levels and their fitted curves.

Key Features:

Saves plots to a channel_fit_figures/ folder

Each figure shows:

Raw PSTH (bar)

Early fit (solid line)

Late fit (dashed line)

Color-coded by stimulus level

Designed for publication-quality visuals or detailed per-channel analysis

Output folder structure:

channel_fit_figures/
├── Channel_01_Fits.png
├── Channel_02_Fits.png
...
├── Channel_16_Fits.png

extractFitMetrics.m

Extracts and quantifies metrics from the automated fits in autoFitResults.mat. It computes several key values and generates heatmaps for each.

📊 Extracted Metrics:

AUC (Area Under the Curve) of early and late responses

Latency (center of the Gaussian peak) for early and late fits

Distance between the two peaks (early vs late)

Peak amplitude (height of each Gaussian)

📈 Outputs:

Four heatmaps:

AUC - Early

AUC - Late

Latency - Early

Peak Distance

One example console summary for a specific channel/level

🖥️ Example printed output:

📊 Example — Trial: VA_21_04_20-Trial016 | Level 10, Channel 8
Early Peak:  3.27 | Latency: 3.62 ms | AUC: 14.43
Late Peak:   0.40 | Latency: 6.00 ms | AUC: 1.72
Distance between Peaks: 2.38 ms
