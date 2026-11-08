# Exercise 6 – Parts 1, 2 and 3: what was changed, why, and what you still need to run

Read this first: **I could not open MATLAB or Simulink here.** I edited the `.slx` files directly (they are zip files with XML inside), checked that every XML part is well formed and that every block input is connected exactly once, and I simulated the physics with a small Python model to get the expected trends. Every number below marked "offline" must be confirmed by running the scripts in MATLAB. Section 6 lists the exact clicks if you want to do or check the Simulink part by hand.

## 0. File overview (all in your `exercise_6_claude` folder)

Your original files were restored and are untouched except for the first copies I wrote earlier (see below). Every changed file has a `_Part1`, `_Part2` or `_Part3` suffix, and each script calls the renamed files, so each part runs on its own.

| Part | New file | Based on | What changed |
|---|---|---|---|
| 1 | `NREL5MWDefaultParameter_FBSWE_AvancedTorqueController_Part1.m` | original parameter file | `kp`, `Ti` set; function renamed |
| 1 | `NREL5MW_FBSWE_SLOW2DOF_AdvancedTorqueController_Part1.slx` | original model | embedded function `LimitsAndReferenceValueTC` implemented |
| 1 | `Exercise06_AdvancedTorqueControllerTest_Part1.m` | original test script | calls the `_Part1` names |
| 2 | `NREL5MWDefaultParameter_FBSWE_SetPointFading_Part2.m` | original parameter file | fading values set, filter cut-off fixed, function renamed |
| 2 | `NREL5MW_FBSWE_SLOW2DOF_SetPointFading_Part2.slx` | original model | Set Point Fading block built, Pitch Controller reference changed, torque limit chart changed |
| 2 | `Exercise06_SetPointFadingTest_Part2.m` | original test script | calls `_Part2` names, mode switch added |
| 3 | `Exercise06_SetPointFadingFineTuning_Part3.m` | original fine-tuning script | AEP and DEL equations added, optimum selection added, calls `_Part2` names |

Unchanged originals are still in the folder: `Exercise06_GenerateDisturbance.m`, `GenerateRotorEffectiveWindSpeed.m`, `Calculation_S_RR.m`, and the original `Exercise06_*` scripts. The originals of the two Part 1 files are in `original_backup`.

## 1. Part 1 recap (what was done and why)

**Parameter file (`..._Part1.m`).** `Parameter.VSC.kp` changed from 0 to 2972.8 Nm/(rad/s), and `Parameter.VSC.Ti` from 1 to 2.555 s. The Simulink PI computes `M_g = kp·e + (kp/Ti)·∫e`, so the integral gain is `K_I = kp/Ti = 1163 Nm/rad`. The values come from the lecture's closed-loop shaping formulas: `K_P = −(2Dω + a)/(b₁c)` and `K_I = −ω²/(b₁c)` with D = 0.7, ω = 0.5 rad/s, and the linearized plant at 11 m/s. The characteristic polynomial was checked to be s² + 0.700 s + 0.250.

**Model (`..._Part1.slx`), embedded function `LimitsAndReferenceValueTC`.** The empty stub was replaced with:
- Switch speed `Ω_R2switch = ½(Ω_1.5 + Ω_rated)`.
- Below the switch (Region 1.5): reference `Ω_1.5` (776 rpm), limits `0 ≤ M_g ≤ kΩ_G²`.
- Above the switch (Region 2.5): reference `Ω_rated` (1174 rpm), limits `kΩ_G² ≤ M_g ≤ min(M_rated·Ω_rated/Ω_G, M_max)`.

Why: the lecture's reference and limit rules. The lower limit keeps the torque on the optimal Region 2 curve, and the upper limit gives rated power above rated speed. The PI anti-windup uses these limits so the integrator does not wind up.

**Test results (offline, 1-DOF model, not Simulink).** At 11 m/s with a 0.1 m/s step, the speed peaks at about 1.95 rpm about 2.2 s after the step. The linear design model predicts 1.95 rpm at 2.23 s, so the reaction matches the design. At 5 m/s the peak is about 0.74 rpm with the same timing. The response is smaller at 5 m/s because the sensitivity to wind (G₀ ≈ 3.3 versus 8.9 rpm per m/s) is lower there.

**Part 1 answers:**
- a) The test script now runs with a working torque PI (with `kp = 0` the torque went to zero).
- b) Region 2.5 gains: K_P = 2973, Ti = 2.56 s. Region 1.5 gains: K_P = 3147, Ti = 2.71 s. K_I is identical, and the 6 % difference in K_P is not significant, so one set of gains works for both regions.
- c) Implemented as described above.
- d) Yes, close enough to the design (offline).
- e) The shape is the same and the amplitude is smaller because the wind sensitivity is about 2.7 times lower at 5 m/s.

## 2. Part 2 – Set-point fading (Simulink)

### 2.1 Why the fading exists
Near rated wind (about 11.4 m/s) the pitch controller and the torque controller both try to hold the rated speed. Without coordination the pitch controller reacts while the wind is still below rated, which wastes energy and increases pitch activity. Set-point fading adds a bias `ΔΩ_G` to the speed reference. The bias is negative below rated, so the pitch controller's reference moves up and it stays quiet. It is positive above rated, so the torque controller's reference moves down and the torque controller takes over the speed regulation in Region 3.

### 2.2 The original model was incomplete
When I opened the original `NREL5MW_FBSWE_SLOW2DOF_SetPointFading.slx`, the block `FBSWE/Set Point Fading` had only a constant `0` driving the output, and all its blocks were **greyed out (commented)**. So there was no fading at all. There were also two problems in the parameter file:
- `Parameter.Filter.LowPass2.f_cutoff = 0`. With a cut-off of zero the first-order low-pass integrator never moves, so the filtered `ΔΩ_G` stays at zero even when the block is wired. I changed it to **0.1 Hz** (time constant about 1.6 s).
- All fading parameters were zero, so the logic would switch off. I set rule-of-thumb values (see 2.4).

### 2.3 Simulink changes in detail

**(a) `FBSWE/Set Point Fading` (system with the blocks `Product1` to `Product4`, `Sum3`, `Sum5`, `Saturation Dynamic1`).** I removed the commented flags, removed the dummy constant and the three terminators, and wired the following signal flow:

1. `x_θ = (θ − θ_min) / Δθ`: `Sum5` computes θ − θ_min, `Product2` divides by `Parameter.SPF.Delta_theta`. This is the pitch part: it is 0 at minimum pitch and grows when the pitch opens, which only happens above rated.
2. `P = M_g · Ω_G` (`Product3`), `P_rated = M_g_rated · Ω_rated` (`Product4`), and `x_P = (P − P_rated) / Δ P` (`Sum3` then `Product1`). This is the power part: it is negative below rated and positive above. Using `M_g_rated·Ω_rated` (5.30 MW mechanical) keeps the reference exactly 0 at rated electrical power of 5 MW.
3. A new `Sum_xTheta_xP` adds the two parts: `x_θ + x_P`. The sign is chosen so that below rated (pitch at minimum, power below rated) the sum is negative, and above rated it is positive.
4. A new `Product_dOmega` multiplies by `Parameter.SPF.Delta_Omega_g` (the maximum allowed over-/under-speed, ΔΩ_max).
5. The `Saturation Dynamic1` block limits the result to `[−ΔΩ_max, +ΔΩ_max]`. The upper limit is `Constant6` (`Delta_Omega_g`). A new constant `Minus_Delta_Omega_g` (value `-Parameter.SPF.Delta_Omega_g`) gives the lower limit.
6. The saturated signal goes to the outport `Delta_Omega_g`.

Why this structure: it follows the lecture (slide 22: deviation from minimum pitch and deviation from rated power, each normalized, multiplied and saturated with the maximum over-speed). The check I did: with the rule-of-thumb values, the offline model gives `ΔΩ_G` between about −4.6 rpm and 0 at 11.2 m/s. Figure 1 in the exercise shows about −4 to 0 rpm on the fourth panel, so the signal has the expected size and sign.

**(b) `FBSWE/Pitch Controller`.** The reference speed must become `Ω_rated − min(ΔΩ_G, 0)`: when `ΔΩ_G` is negative the pitch set point goes up, otherwise it stays at rated. I did this without a new if-block:
- The `Sum` block was changed from 2 to 3 inputs with signs `|-++`: `−Ω_rated + Ω_G + min(ΔΩ_G, 0)`.
- A new `MinMax` block (function `min`, 2 inputs) takes `Delta_Omega_g_f` on its first input and a new constant `0` on its second input, and feeds the third input of the `Sum`.
- The old terminator on `Delta_Omega_g_f` was removed.

**(c) `FBSWE/Torque Controller/LimitsAndReferenceValueTC` (embedded MATLAB function in `chart_47`).** Only one line changed, in the "above switch" branch:

```matlab
Omega_g_ref = Omega_g_rated - max(Delta_Omega_g,0);
```

Why: the torque controller should only lower its speed reference when the fading signal is positive (above rated). Below rated the reference stays at rated, which is what the lecture slide 23 says. The rest of the function (Mode 1 constant power, Mode 2 constant torque, the switch speed, the limits) was already there and is unchanged.

**(d) Parameters (`..._SetPointFading_Part2.m`).**

| Parameter | Original | Part 2 | Reason (rule of thumb from lecture slide 24) |
|---|---|---|---|
| `SPF.Delta_Omega_g` | 0 | 0.1·Ω_rated = 12.3 rad/s (117 rpm) | maximum over-/under-speed, about 10 % of rated |
| `SPF.Delta_theta` | 0 | 25° | pitch angle close to cut-out |
| `SPF.Delta_P` | 0 | 5 MW | power change close to rated |
| `Filter.LowPass2.f_cutoff` | 0 | 0.1 Hz | a zero cut-off freezes the filter (see 2.2) |

Important: with `Delta_P = 0` or `Delta_theta = 0` the division would produce infinity, so these values must not be zero.

### 2.4 Test script (`Exercise06_SetPointFadingTest_Part2.m`)
Same as the original, with three changes: the `_Part2` names, a line `Parameter.VSC.Mode = 1;` (constant power in Region 3), and a comment telling you how to change the wind for question e.

For **question 2e** change these three lines in the script before running it:
```matlab
URef    = 11.6;
DeltaU  = -0.1;
Parameter.VSC.Mode = 2;    % constant torque in Region 3
```

### 2.5 Answers to Part 2 (offline check; confirm in MATLAB)

- **a) Power at 11.3 m/s without fading (pitch interferes):** the pitch controller is active about 99.8 % of the time after the step, peaking at about 0.37°. The power at the end is about **4.91 MW**. The second panel of your Figure 1 (theta) shows the same kind of pitch activity.
- **d) With the fading implemented:** the pitch stays at 0° throughout, so the pitch controller is not interfering. The fading signal reaches about −4.6 rpm and then settles near −1.5 rpm. The power at the end, at 11.3 m/s, is about **4.94 MW**. This is below 5 MW because 11.3 m/s is below rated (11.4 m/s).
- **e) At 11.6 m/s with a −0.1 m/s step and constant-torque mode:** the fading signal is positive (up to about +9.7 rpm), so the torque reference is lowered. The torque controller then sits at its upper limit (the rated torque, 43.1 kNm) for the whole time after the step. Because it is held at its limit it does not fight the pitch controller, so **the torque controller is not interfering**. The pitch goes up to about 2°, and the power settles at 5.0 MW. Constant-power mode (Mode 1) gives the same answer in this check.

Please check these in MATLAB by looking at the plots of `Delta_Omega_g` and `theta`. If the pitch in your plot is not exactly zero in (d), check the wiring in section 6.

## 3. Part 3 – Fine tuning of the set-point fading

### 3.1 a) How the rotor-effective wind speed is generated
The script `GenerateRotorEffectiveWindSpeed.m` uses the spectral representation method, which is a standard way to produce turbulent wind:

1. **Target spectrum.** The longitudinal turbulence spectrum is the IEC Kaimal spectrum, with length scale `L₁ = 8.1·42 m = 340 m` and turbulence standard deviation `σ₁ = I_ref·(0.75·U + 5.6)` (Class A, `I_ref = 0.16`).
2. **Rotor averaging.** A single point spectrum is not what the rotor sees. `Calculation_S_RR.m` builds the rotor-effective spectrum by summing an exponential coherence `exp(−κ·d)` over every pair of grid points inside the rotor disc (radius 63 m, grid 8 m). The coherence decay `κ` depends on frequency and wind speed. The result is the spectrum `S_RR(f)`, which is smaller than the point spectrum at high frequencies because the rotor averages out fast gusts.
3. **Amplitudes.** Each frequency bin `f = 1/T ... 1/(2·dt)` (with `T = 3600 s`, `dt = 0.1 s`) gets amplitude `A = √(2·S_RR·Δf)`.
4. **Random phases.** Each bin gets a random phase `Φ`, generated with `rng(Seed)` where the seed is the mean wind speed, so each wind speed has a different but repeatable series.
5. **Inverse FFT.** The bins are combined as `A·e^{iΦ}` and transformed back to time with `ifft(..., 'symmetric')`. The mean `URef` is added. The result is one 3600 s time series per mean wind speed.

The result is one realistic turbulent rotor-effective wind speed per mean wind speed, for 4 to 24 m/s in steps of 2 m/s (11 files).

### 3.2 b) Equations added (lines 69–71 of `..._Part3.m`)

```matlab
% Annual energy production [Wh]: mean power at each wind speed x 8760 h x probability of that wind speed
AEP(iDelta_P)  = 8760*sum(P_mean.*Weights);

% Lifetime-weighted damage equivalent load [Nm]: Miner's rule over all wind speeds, weighted by probability
DEL(iDelta_P)  = (sum(DEL_MyT.^WoehlerExponent.*Weights)).^(1/WoehlerExponent);
```

Why each part:
- `P_mean` is the average power for each mean wind speed from the simulation (in W). Multiplying by 8760 hours gives the energy per year at that wind speed (Wh). Multiplying by `Weights` (the Weibull probability of each mean wind speed, already computed above the loop) and summing gives the annual energy. The plot divides by 1e9, so the AEP is shown in GWh.
- `DEL_MyT` is the damage equivalent load of the tower-bottom bending moment at each wind speed, computed by rainflow counting in the loop. The damage of a load case scales with the 4th power (Wöhler exponent `m = 4`), so the lifetime damage is the probability-weighted sum of `DEL^m`. Taking the 4th root gives one equivalent load for the whole turbine life, in Nm. The plot divides by 1e6 and compares with the 42 MNm limit.

### 3.3 Optimum selection (added at the end of the script)
The script now finds the Delta_P with the highest AEP among all Delta_P values whose lifetime DEL is below 42 MNm, and prints it. If none are below 42 MNm it gives a warning.

### 3.4 What you must run and what I could not do
- Create a folder named `wind` in the working directory (the scripts write to `wind\`).
- Run `Exercise06_GenerateDisturbance.m` once. It creates the 11 files `URef_04_Disturbance.mat` ... `URef_24_Disturbance.mat`. The script is random-seeded per wind speed, so the files are repeatable, but MATLAB's random generator gives different numbers than Python, so I did not generate them myself.
- Run `Exercise06_SetPointFadingFineTuning_Part3.m`. It runs 11 wind speeds × 5 Delta_P values (`3:1:7` MW) at 3600 s each. Expect several hours; you can reduce `Delta_P_v` or `TMax` to test first.
- Look at the two plots and the printed optimum. Send me the printed AEP/DEL table if you want me to explain the trade-off for your numbers.

**Answer to 3b (the optimal ΔP):** I cannot give you a validated value. It needs the MATLAB run. What to expect from the lecture: AEP increases with Delta_P up to a point and DEL increases with it too, so the best value is the largest Delta_P that keeps the DEL under 42 MNm.

## 4. Changes that need to be checked in MATLAB
1. Open `NREL5MW_FBSWE_SLOW2DOF_SetPointFading_Part2.slx`. Press Ctrl+D (Update Diagram). There should be no errors and no unconnected-port warnings. If a block shows as greyed out, right-click it and choose Uncomment.
2. Check the `Set Point Fading` subsystem: it should have the new `Sum_xTheta_xP`, `Product_dOmega`, and `Minus_Delta_Omega_g` blocks, and `Saturation Dynamic1` output going to the outport.
3. Check the `Pitch Controller` sum now has three inputs.
4. Run `Exercise06_SetPointFadingTest_Part2.m` first, then the same with URef = 11.6 and DeltaU = −0.1 and Mode = 2.

## 5. Limitations
- All simulation numbers here come from a 1-DOF Python model without the tower (2-DOF model in Simulink). Expect differences of a few percent.
- The Part 1 model had `Delta_Omega_g` connected but not used, as the exercise requires.
- I wrote the Simulink changes as XML. This is reliable for the standard blocks I used, but the only real test is opening the model in MATLAB.

## 6. If you want to make or check the Simulink changes by hand (exact steps)

**Part 1 (`..._Part1.slx`):** open `LimitsAndReferenceValueTC` (Torque Controller). Double-click the MATLAB Function block, replace its code with the text in section 1 of this document (the function body after `%% Internals`). Save.

**Part 2 (`..._SetPointFading_Part2.slx`):**
1. Open `FBSWE → Set Point Fading`. Select all greyed-out blocks, right-click and choose Uncomment.
2. Delete the Constant `0` and the three Terminators.
3. Add a Sum block named `Sum_xTheta_xP` with inputs `|++`. Connect `Product2` output to input 1 and `Product1` output to input 2.
4. Add a Product block `Product_dOmega`. Connect `Sum_xTheta_xP` to input 1 and `Constant6` (Delta_Omega_g) to input 2.
5. Add a Constant `Minus_Delta_Omega_g` with value `-Parameter.SPF.Delta_Omega_g`.
6. Connect: `Product_dOmega` → `Saturation Dynamic1` input 1; `Constant6` → `Saturation Dynamic1` input 2; `Minus_Delta_Omega_g` → input 3; `Saturation Dynamic1` output → outport `Delta_Omega_g`.
7. Wire the rest as in section 2.3(a): Omega_g → Product3 input 2; M_g → Product3 input 1; theta → Sum5 input 2; Constant4 (theta_min) → Sum5 input 1; Sum5 → Product2 input 1; Constant5 (Delta_theta) → Product2 input 2; Product3 → Sum3 input 1; Constant2 (M_g_rated) → Product4 input 1; Constant3 (Omega_g_rated) → Product4 input 2; Product4 → Sum3 input 2; Sum3 → Product1 input 1; Constant1 (Delta_P) → Product1 input 2.
8. Set `Product1` and `Product2` to two inputs with operators `*/`.
9. Open `FBSWE → Pitch Controller`. Set the Sum block to three inputs `|-++`. Add a MinMax block (function min, 2 inputs), a Constant `0`, connect `Delta_Omega_g_f` → MinMax input 1, Constant 0 → MinMax input 2, MinMax → Sum input 3. Delete the terminator on `Delta_Omega_g_f`.
10. Open the MATLAB Function block in `LimitsAndReferenceValueTC` (Torque Controller). In the `else` branch replace `Omega_g_ref = Omega_g_rated;` with `Omega_g_ref = Omega_g_rated - max(Delta_Omega_g,0);`. Save.
11. Make sure the parameter file's `Filter.LowPass2.f_cutoff` is not zero.
