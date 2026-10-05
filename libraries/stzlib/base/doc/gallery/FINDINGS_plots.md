# Visual pass, plots -- what the pictures show that the text did not

Perceived by the stzlib-docs visual pass: **a model reading the PNGs, not a human** (2026-10-05). 20 PNGs were opened with Read;
the six `terminal.txt` were read as text, not as images. Judgements per picture: `INDEX_plots.md`. Each class block's detail
paragraph carries the gallery paths and verdicts. None of the code defects below is fixed.

| class | picture | verdict | what is wrong or doubtful |
|---|---|---|---|
| stzBarPlot | basic, values, nofont | RIGHT x3 | the pixel picture writes two decimals where the text form writes the raw value (block corrected) |
| stzHBarPlot | ranked | RIGHT | -- |
| stzHBarPlot | longlabels | WRONG | labels are clipped at the left edge ("er_support_tickets"): a fixed 132 px label column |
| stzMBarPlot | quarters | RIGHT | -- |
| stzMBarPlot | twoseries | UNCERTAIN | the legend touches the last bar; labels are lower case in pixels; no values are drawn (the first draft of the block said they were: corrected; `:ShowAverage` is the working option) |
| stzHistogram | normal, bins20, sums | RIGHT x3 | counts sum to 200 |
| stzScatterPlot | clusters, negative, terminal | WRONG x3 | the pixel picture has no x tick labels; the y axis starts at 0 and the axes sit at the minimum; y ticks are not round numbers; in the text picture x labels run together |
| stzSurfacePlot | budget | RIGHT | areas follow values; one long label is truncated |
| stzSurfacePlot | manyparts | UNCERTAIN | 7 of 12 parts have no label |
| stzSurfacePlot | terminal | WRONG | a name wider than its cell is cut at both ends ("upport"); the class is a treemap, not a function plot (block corrected) |
| stzSoundPlot | spectrogram, spectra, wave | RIGHT x3 | thin dark hairlines in the wave; the spectrogram time axis ends at 0.96 s for a 1 s sound |

Code defects found while rendering (documented in the blocks, listed with causes in `doc/tools/wave/data/w5_defects_plots.md`):
stzHistogram SetBinRange/SetClassRange read the range of the bar heights, not of the data; SetAggregation accepts only exact
lower-case names and leaves the histogram unusable otherwise; SetValues/AddValues draw nothing in ToString; X and Y axis names act
on the opposite axis in stzHistogram and stzScatterPlot; stzMBarPlot SetAverage/AddAverage always raise; stzHBarPlot SetBarHeight
spaces instead of thickening; stzBarPlot SetWidth/SetMaxWidth are stored and never read; stzSoundPlot DrawSpectra at 0 Hz raises R51,
SetTitle/SetNote do nothing after a Draw method, SaveAsPNG answers nothing.

Retrieval noise: stzHistogram.ToCanvasQ carries a stray `#@ aka` ("THE ONE PLACE A BIN EDGE BECOMES TEXT", the rationale of
a helper) and stzSurfacePlot.init one ("NO LEGEND HERE ..."): the applier has no option to drop an aka.

Not rendered: ToStringInRing, the scatter grid and point labels, histogram statistics, a vertical MBar legend (read as text only).
