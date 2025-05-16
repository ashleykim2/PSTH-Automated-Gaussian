# PSTH-Automated-Gaussian
# BiGaussian Fitting Pipeline for Neural PSTH Data

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

## Notes

- You can switch datasets by updating the `.mat` file path inside each script.
- The pipeline assumes data is stored in a standard format with variables: `HistPeriod`, `details`, and `PeriodEdges4Plotting`.
- This method supports reproducible, large-scale PSTH analysis with minimal manual tuning.

---

## Example Output

The resulting figure from `final.m` shows early and late responses across all 16 channels for a given trial. This allows intuitive visual inspection of the quality and consistency of the fits.

---

## Dependencies
- MATLAB R2020a or later
- Curve Fitting Toolbox (for `lsqcurvefit`)

---

## Author
Ashley Kim 
