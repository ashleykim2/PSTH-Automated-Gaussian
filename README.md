# PSTH-Automated-Gaussian  
## BiGaussian Fitting Pipeline for Neural PSTH Data

This repository provides a MATLAB-based pipeline for automated curve fitting of neural peri-stimulus time histogram (PSTH) data across stimulation levels and electrode channels.

---

## 📁 Key Files

### **`automatedGaussianFit.m`**
Performs automated dual-Gaussian curve fitting across all stimulation levels and channels.

**🔧 Functionality:**
- Fits early and late responses using a skewed + normal Gaussian model.
- Processes each `(level, channel)` pair from **high to low** to encourage physiologically realistic fits (e.g., latency shifts).
- Automatically skips poor or low-signal conditions based on defined constraints.

**💾 Output:**
- Saves all fit results into `autoFitResults.mat`, containing peak amplitudes, latencies, sigmas, and fitting error.

---

### **`skewedBiGaussian.m`**
Defines the **asymmetric bi-Gaussian** model used for fitting:

```matlab
function y = skewedBiGaussian(p, x)
    g1 = p(1) * exp(-((x - p(2)).^2) / (2 * p(3)^2)) .* normcdf(x, p(5), p(4));   % Skewed early
    g2 = p(6) * exp(-((x - p(7)).^2) / (2 * p(8)^2));                             % Normal late
    y = g1 + g2;
end
```

---

### **`final.m`**
This script visualizes the automated fit results across **all 16 channels** in a single figure.

**Features:**
- Overlays raw PSTH (**gray bars**), early Gaussian fits (**solid colored lines**), and late Gaussian fits (**dashed lines**).
- Only displays **above-threshold responses** (≥ 4× baseline standard deviation).
- Uses color to indicate stimulus level (**parula colormap**).
- Uses `subplot(4, 4, ch)` to display all channels in one window.
- Consistent time axis (**0–20 ms**) for easier comparison.
- Great for **batch QC and visual inspection**.

---

### **`plotAllChannelsWithFits.m`**
Generates and saves a separate PNG figure for each channel showing all stimulus levels and their fitted curves.

**Features:**
- Saves plots to a `channel_fit_figures/` folder.
- Each figure shows:
  - Raw PSTH (**bar**)
  - Early fit (**solid line**)
  - Late fit (**dashed line**)
  - Color-coded by stimulus level
- Designed for **publication-quality visuals** or detailed per-channel analysis.

**Output folder structure:**
```text
channel_fit_figures/
├── Channel_01_Fits.png
├── Channel_02_Fits.png
...
├── Channel_16_Fits.png
```

---

### **`extractFitMetrics.m`**
Extracts and quantifies metrics from the automated fits in `autoFitResults.mat`. Computes several key values and generates heatmaps.

**Extracted Metrics:**
- **AUC** (Area Under the Curve) of early and late responses
- **Latency** (center of the Gaussian peak) for early and late fits
- **Distance between the peaks** (early vs late)
- **Peak amplitude** (height of each Gaussian)

**Outputs:**
- Four heatmaps:
  - **AUC - Early**
  - **AUC - Late**
  - **Latency - Early**
  - **Peak Distance**
- Example console summary for a specific channel/level:

```text
📊 Example — Trial: VA_21_04_20-Trial016 | Level 10, Channel 8
Early Peak:  3.27 | Latency: 3.62 ms | AUC: 14.43
Late Peak:   0.40 | Latency: 6.00 ms | AUC: 1.72
Distance between Peaks: 2.38 ms
```

---
