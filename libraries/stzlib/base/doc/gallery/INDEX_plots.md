# Plot gallery -- what the pictures show

*Seven classes of the plot family (STZLIB-DOCREFORM-01, wave 5, 2026-10-05). Every PNG here was drawn by the script beside it (run from `libraries/stzlib/base/test/reflect`, `ring ../../doc/gallery/<Class>/<name>.ring`) and then opened with the Read tool, which shows the image to a model. **Nobody looked at these pictures but a model**: the column "perceived by" says so on every row, and a model is not a human. Terminal pictures (`terminal.txt`) are text; they were read as text, not as images, and are marked so.*

Verdict words: RIGHT = what the picture shows is what the data and the doc say; WRONG = the picture contradicts the data, the doc, or loses information a reader needs; UNCERTAIN = correct data, a layout fault a person should judge.

Pictures that differ from what the doc text of the same class says are listed in `FINDINGS_plots.md`.

## stzBarPlot

| picture | call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `stzBarPlot/basic.png` | `StzPlotQ(:VBar, [ :Jan = 34 ... :Jul = 61 ])`, `AddAverage()`, `ToPNG(path, [ :Font, :Title, :Width = 700, :Height = 420 ])` | Dark plate, title "Monthly throughput" top-left. Seven bars Jan to Jul with a blue-to-violet gradient (blue at the top). Y axis 0 to 100 in steps of 20 with faint gridlines; month labels under the bars. Heights read about 34, 58, 47, 72, 65, 88, 61. An amber line crosses the plot at about 60.7 with the text "avg 60.71" above its right end, over the Jul bar. No values on the bars (AddValues was not called). No clipping, no overlap other than the average text sitting close to the Jul bar top. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzBarPlot/values.png` | `new stzBarPlot([ :Jan = 12 ... :Dec = 14 ])`, `AddValues()`, `ToPNG(path, [ :Font, :Title, :Color = "#e0a030", :Width = 800, :Height = 460 ])` | Twelve bars, title "Rainfall by month (mm)", the value written above each bar (12, 19, 24, 31, 38, 45, 52, 49, 41, 33, 21, 14), matching the data. Y axis 0 to 60 in steps of 12. The :Color option colours only the top of each gradient bar; the bottom stays violet whatever the colour. Labels all readable, nothing clipped. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzBarPlot/nofont.png` | `new stzBarPlot([ 5, 9, 3, 12, 7 ])`, `ToPNG(path, [ :Width = 600, :Height = 360 ])` (no :Font) | Five gradient bars of the right relative heights, five horizontal gridlines, the left and bottom axis lines. No title, no tick numbers, no labels. As the doc says: without a font the plot draws and carries no text. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzBarPlot/terminal.txt` | `StzPlotQ(:VBar, data)`, `AddAverage()`, `SetHeight(10)`, `ToString()` (read as TEXT, not as an image) | Block-character bars with `▲` and `►` axes, month labels in a row under the axis, a dashed average line at 60.7 with its value at the right. Bar heights follow the values. | RIGHT | stzlib-docs visual pass (a model reading the text output) | 2026-10-05 |

## stzHBarPlot

| picture | call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `stzHBarPlot/ranked.png` | `new stzHBarPlot([ :Niamey = 1300 ... :Dosso = 90 ])`, `AddValues()`, `ToPNG(path, [ :Font, :Title, :Width = 800, :Height = 420 ])` | Six horizontal gradient bars with the six city names in a column at the left and the value at the end of each bar (1300, 450, 400, 140, 120, 90). X axis 0 to 1500 in steps of 300 with vertical gridlines. Bar lengths are proportional to the values (1300 reaches 87 percent of the width). Nothing clipped. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzHBarPlot/longlabels.png` | `new stzHBarPlot([ :Customer_support_tickets = 128, :Billing_questions = 64, :Feature_requests = 31, :Bug_reports_closed = 0 ])`, `ToPNG(path, [ :Font, :Title, ... ])` | The first label reads "er_support_tickets" and the fourth "ug_reports_closed": the beginnings are cut off at the left edge of the picture, because the label column has a fixed width. The two shorter labels fit. The bar of 0 draws nothing (correct, but with its label cut it is easy to miss). | WRONG | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzHBarPlot/terminal.txt` | `new stzHBarPlot(...)`, `AddValues()`, `ToString()` (read as TEXT) | One row of `▇` blocks per bar, city names right-aligned at the left of a `│` axis, the value after each bar, a `►` axis below. | RIGHT | stzlib-docs visual pass (a model reading the text output) | 2026-10-05 |

## stzMBarPlot

| picture | call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `stzMBarPlot/quarters.png` | `new stzMBarPlot([ :Sales = [ :Q1 = 25 ... ], :Costs = ..., :Profit = ... ])`, `ToPNG(path, [ :Font, :Title, :Width = 800, :Height = 460 ])` | Four groups of three bars (blue Sales 25, 35, 30, 40; amber Costs 15, 20, 18, 22; green Profit 10, 15, 12, 18), heights matching the data. Y axis 0 to 40 in steps of 8. Category labels "q1" to "q4" and legend names "sales", "costs", "profit" are in lower case (the text picture capitalises them). Legend at the top right, beside the tallest bar. No values above the bars. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzMBarPlot/twoseries.png` | `new stzMBarPlot([ :Visits = [ :Jan = 820 ... ], :Orders = ... ])`, `ToPNG(path, [ :Font, :Title, :ShowValues = 0, ... ])` | Six pairs of bars, Visits (blue) tall and Orders (amber) small, the scale 0 to 1500 in steps of 300, month labels in lower case. The legend sits inside the plot area at the top right and the amber "orders" swatch touches the Jun visits bar. May's bar reaches the top gridline. | UNCERTAIN | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzMBarPlot/terminal.txt` | `new stzMBarPlot(...)`, `ToString()` (read as TEXT) | Clusters of three bars per quarter drawn with `█ ▒ ▓`, `Q1` to `Q4` under them, a blank line, then the legend "██ Sales   ▒▒ Costs   ▓▓ Profit". | RIGHT | stzlib-docs visual pass (a model reading the text output) | 2026-10-05 |

## stzHistogram

| picture | call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `stzHistogram/normal.png` | `new stzHistogram(200 values)`, `ToPNG(path, [ :Font, :Title, :Width = 800, :Height = 460 ])` | Nine touching bars with the count above each (5, 9, 21, 26, 44, 39, 33, 16, 7: they add up to 200), a bell shape peaking at 93.6-100.4, a longer tail on the left. Bin labels "66.7-73.4" to "120.6-127.3" in small grey type under the bars. Y axis 0 to 50. The last bar runs to the right edge of the frame. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzHistogram/bins20.png` | same data, `SetBinCount(20)` | Twenty touching bars, counts above each (they add up to 200), labels under every second bar only ("66.7-69.7", "72.8-75.8", ...) so they do not collide. Y axis 0 to 25. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzHistogram/sums.png` | same data, `UseSum()` | Nine bars whose heights are the sum of the values in each bin; the values written above them are 355.60, 692, 1766.60, 2360.80, 4273.10, 4046.30, 3639.90, 1870.30, 863.60 (total 19868, which is 200 times the mean of 99.3). The number format is uneven: "692" without decimals next to "355.60". Y axis 0 to 5000. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzHistogram/terminal.txt` | same data, `AddPercent()`, `ToString()` (read as TEXT) | Nine bars of `██`, a percentage above each (2.5% ... 22.0%), the bin edges in two rows under a `►` axis. | RIGHT | stzlib-docs visual pass (a model reading the text output) | 2026-10-05 |

## stzScatterPlot

| picture | call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `stzScatterPlot/clusters.png` | `new stzScatterPlot(80 [ h, v ] pairs)`, `ToPNG(path, [ :Font, :Title, :Width = 800, :Height = 520 ])` | Two clusters of blue dots, lower left (y 20 to 40) and upper right (y 60 to 78), clearly separated. The left axis carries 0, 16, 32, 48, 64, 80. **The horizontal axis carries no numbers at all.** The leftmost dot sits on the vertical axis line and the rightmost on the right edge of the frame, half outside the plot. The vertical axis starts at 0 although the lowest value is about 19, leaving the bottom quarter empty. | WRONG | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzScatterPlot/negative.png` | `new stzScatterPlot([ :a = [ -3, 4 ] ... ])`, `ToPNG(path, [ :Font, :Title, ... ])` | Five dots under the title "Points around the origin". Left axis ticks 4, 2.80, 1.60, 0.40, -0.80, -2: steps of 1.2, not round numbers. No numbers on the horizontal axis. The horizontal axis is drawn at the lowest value (-2), not at zero, so nothing crosses at the origin. The point at (-3, 4) sits on the corner where the axes meet. The point labels a to e are not drawn. | WRONG | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzScatterPlot/terminal.txt` | same clusters, `ToString()` (read as TEXT) | A `▲` axis with the letter X above it, rows with y values at the left, `●` for each point (dense in two clusters), a `►` axis ending in "Y". **The x tick labels run into each other** ("711111222228.3365 4348555566666771."): one label is written per point and they overlap. | WRONG | stzlib-docs visual pass (a model reading the text output) | 2026-10-05 |

## stzSurfacePlot

*The class is a treemap (a composition plot), not a function surface: no 20 by 20 function was drawn, because the class cannot take one. The pictures show parts of a whole.*

| picture | call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `stzSurfacePlot/budget.png` | `new stzSurfacePlot([ :Engineering = 45, :Sales = 25, :Support = 15, :Admin = 10, :Legal = 5 ])`, `ToPNG(path, [ :Font, :Title, :Width = 800, :Height = 480 ])` | Five coloured rectangles with thin dark borders. Engineering (blue) takes the full height and 45 percent of the width, Sales (amber) 25 percent, Support (green) the top right, Admin (violet) below it, Legal (red) the smallest. Each cell has its name in lower case and its share ("engineering 45%", "sales 25%"); the Legal label is cut to "legal ...". Areas follow the values. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzSurfacePlot/manyparts.png` | twelve parts from `:Salaries = 120` down to `:Misc = 2` | Salaries (orange, 45.45%), Rent (blue, 14.39%), Marketing (8.33%), Software (6.44%) and Taxes (11.74%) are labelled; the other seven parts are narrow coloured slivers with **no label**, and colours repeat, so they cannot be told apart or named. Shares are written with two decimals here and with none for the budget picture. | UNCERTAIN | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzSurfacePlot/terminal.txt` | same five parts as budget.png, `SetSize(60, 16)`, `AddPercent()`, `ToString()` (read as TEXT) | A box-drawing frame split into cells with the name and the percentage centred in each. **"Support" is printed as "upport"**: the first letter is cut off in its narrow cell. | WRONG | stzlib-docs visual pass (a model reading the text output) | 2026-10-05 |

## stzSoundPlot

| picture | call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `stzSoundPlot/spectrogram.png` | one second sweep from 200 to 4000 Hz, `ToSpectrogram()`, `SetTitle`, `SetNote`, `DrawSpectrogram(grid, 6000)`, `SaveAsPNG` | A bright diagonal band rising from about 300 Hz at 0 s to about 4 kHz at 0.96 s on a black field; a small "quiet to loud" colour ramp at the top right; frequency ticks 0, 1.50k, 3k, 4.50k, 6k (the label format is uneven); time ticks 0s to 0.96s; title, subtitle and a one-line note all readable. The time axis ends at 0.96 s although the sound lasts 1 s. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzSoundPlot/spectra.png` | a loud 220 Hz and a quiet 880 Hz tone, `DrawSpectra([ [label, grid], ... ], 100, 8000)`, `MarkFrequencyAt(440, ...)`, `SaveAsPNG` | Two narrow peaks on a log frequency axis (100, 200, 500, 1k, 2k, 5k): blue at 220 Hz reaching 0 dB, orange at 880 Hz at about -13 dB, as expected for a tone a fifth the size. Decibel ticks 0 to -72. A red vertical line at 440 Hz carries its label; a two-item legend at the top right; the note under the plot. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzSoundPlot/wave.png` | 440 Hz plus 444 Hz, `DrawWave(sound)`, `MarkTimeAt(0.5, 1, "half way")`, `SaveAsPNG` | A blue band whose width swells and shrinks four times in the second, with nulls near 0.125, 0.375, 0.625 and 0.875 s: the 4 Hz beat. Amplitude ticks 1, 0, -1; time ticks 0s to 1s; a red line labelled "half way" at 0.5 s. Thin dark vertical hairlines run through the filled band, a drawing artefact that does not change the shape. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
