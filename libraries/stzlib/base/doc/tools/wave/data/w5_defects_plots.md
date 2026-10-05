# Wave 5 -- defects found in the plot family (probed 2026-10-05; none fixed)

Format: Class.method: symptom: cause. Every row was seen by calling the method (a scenario script, then a second call on other data). `text` = the ToString picture, `pixel` = ToSVG / ToPNG.

## stzBarPlot
- stzBarPlot.init: an empty list raises R14 "Calling Method without definition: capitalised" instead of a message: the empty list falls into the hash-list branch and calls Capitalised on the keys.
- stzBarPlot.init: a hash list with a non-number value raises R2 (Array Access, index out of range) instead of "must be numbers": the branch leaves the values empty and the metrics then take max of an empty list.
- stzBarPlot.SetWidth / SetMaxWidth: store a number and change nothing in any picture: ToString and the pixel output never read them (SetSize's width part likewise).
- stzBarPlot.SetMaxLabelWidth: does not truncate: a long label is drawn whole and overwritten by the next label ("January_long_Febel"); it only reserves room.
- stzBarPlot.SetLabelChar: replaces every label, even those taken from the keys ("Jan, Feb" becomes "Q1, Q2"); a text of several characters silently becomes X1, X2.
- stzBarPlot.AddPercent / SetPercent / WithoutAxis* / SetLabels / SetBarChar / SetHeight / SetSize: text picture only, the pixel output ignores them (documented in the class block and in ToCanvasQ).

## stzHBarPlot
- stzHBarPlot.SetBarHeight: SetBarHeight(2) does not thicken the bars: the bar stays one row and a blank row follows; ToStringInRing puts the blank rows after the last bar instead, so the two renderers disagree for any height above 1: the engine route spaces the rows and the Ring route does not.
- stzHBarPlot.SetBarInterSpace / SetBarSpace / SetInterBarSpace: the value is stored; neither renderer reads it.
- stzHBarPlot.SetHeight: stored, never read: the picture has one row per bar.
- stzHBarPlot.SetMaxHeight: bars beyond the limit are dropped without a message (the scale still counts them).
- stzHBarPlot (inherited AddAverage): the average line is not drawn in the text picture.
- stzHBarPlot (pixel): a label longer than the fixed 132 pixel label column is clipped at the left edge of the picture ("er_support_tickets"): the column is a constant in stzPlotCanvas, not measured.

## stzMBarPlot
- stzMBarPlot.SetAverage / SetAverageLine / AddAverage / AddAverageLine: always raise "Unsupported feature in the current version." (the body is a StzRaise); the pixel option :ShowAverage = 1 does draw an average line.
- stzMBarPlot.SetLegendLayout: only ToStringInRing obeys it; ToString (engine) and the pixel output always draw a horizontal legend, because the engine options carry only the legend switch. "Horizontal", "Vertical" and "H" with capitals raise the layout error: the value is looked up case-sensitively.
- stzMBarPlot (inherited AddValues / AddPercent): draw nothing in the text picture; the pixel output never writes values above multi-bars either, and :ShowValues is not read.
- stzMBarPlot.Categories / SeriesNames: return the keys in lower case, while the text picture capitalises them and the pixel picture shows them lower case.
- stzMBarPlot.init: categories come from the first series only; a series with other category names is drawn under the first one's names without a message.
- stzMBarPlot (pixel): the legend sits inside the plot area and touches the last bar when it is tall.

## stzHistogram
- stzHistogram.SetBinRange / SetClassRange: give ceil((largest count - smallest count) / n) bins instead of bins n wide: SetBinRange reads @nMaxValue and @nMinValue, which _processBinnedData has overwritten with the largest and smallest BAR HEIGHT. 20 values from 12 to 70: SetBinRange(10) gives 1 bin, (3) gives 2, (1) gives 6.
- stzHistogram.SetValues / AddValues / IncludeValues: change nothing in ToString: the engine route reads @bShowFrequency, which no method sets; only ToStringInRing (reached by statistics on or the horizontal axis off) draws the counts.
- stzHistogram.SetHeight / SetMaxWidth: ignored by the engine route (the height is a fixed 10); obeyed by the Ring route, where a too wide picture raises "Histogram width (n) exceeds maximum (m)".
- stzHistogram.SetAggregation: only the exact lower-case names work; "median" or "SUM" raise R2 from max() inside _processBinnedData (no `other` branch, so the bins stay empty), and the histogram is left unusable: AggregationType already answers the new name and ToString raises "the engine could not render this histogram".
- stzHistogram.SetBinCount: a non-integer count such as 2.5 builds edges from 2.5 but loops over 2 bins, so the top values fall outside the last bin (the last label ends at 58.4, not 70).
- stzHistogram.init: constant data (for example [ 5 ] or [ 5, 5, 5 ]) gives five bins whose edges run 5, 6, 7, 8, 9 and a last bin labelled "9-5" (upper edge below the lower one); an empty list raises "paData must contain only numbers".
- stzHistogram.SetXAxis / AddXAxis / IncludeXAxis / WithoutXAxis: act on the VERTICAL axis, and the Y names on the HORIZONTAL one: the reverse of the usual meaning ("kept for backward compatibility").
- stzHistogram.Mode: answers the lower and upper edge of the fullest BAR, and after UseSum the bar with the largest sum, not the most frequent value.
- stzHistogram (pixel): percentages, label switch, bar characters and spacing do not reach pixels.

## stzScatterPlot
- stzScatterPlot.SetHVLetters (and the X/Y letter methods): the letter above the vertical axis is X and the one at the end of the horizontal axis is Y, the reverse of the H = horizontal, X = horizontal convention of the class's own data names.
- stzScatterPlot.SetHLetter / SetVLetter and their aliases: ToString drives both letters from one flag (H or V on = both drawn); only ToStringInRing (grid or point labels on) obeys each one.
- stzScatterPlot.ToString: with more than about ten distinct x values the tick labels (one per point) overlap into unreadable digits ("711111222228.3365 4348555566666771.").
- stzScatterPlot.ToSVG / ToPNG (pixel): no x tick labels at all; the y axis is forced to start at 0 for positive data (the bar rule); the axes sit at the minimum, not through zero; the extreme points sit on the frame; the y ticks are minimum plus equal steps (-2, -0.80, 0.40 ...), not round numbers; grid, labels, letters and point character are not carried; the labels P1 ... are never drawn.
- stzScatterPlot.SetWidth: raised to 50, while SetMaxSize raises to 40: two minimums for the same value.

## stzSurfacePlot
- stzSurfacePlot (class): it is a treemap (composition plot), not a function surface; there is no way to draw a 20 by 20 function with it.
- stzSurfacePlot.ToString: a name wider than its cell is cut at BOTH ends ("Support" prints "upport" or "upp.", "Admin" prints "dmin", "Legal" prints "egal"); values together with percentages run into each other ("0 (1.", "5 (.").
- stzSurfacePlot.init: an empty list is accepted; ToString then raises "the engine could not render this plot".
- stzSurfacePlot.Sum / IsListOfNumbers / IsListOfPositiveNumbers / IsHashList: internal helpers reachable as public methods; they test their argument, answer 1 / 0, and accept an empty list as TRUE.
- stzSurfacePlot (pixel): parts too small for a label get none, so a plot of twelve parts leaves seven unnamed slivers; percentages show two decimals when fractional and none when whole; borders, labels, values and percent switches do not reach pixels (:ShowValues = 0 removes all text).

## stzSoundPlot
- stzSoundPlot.DrawSpectra: a starting frequency of 0 raises R51 (log10 of 0); no check.
- stzSoundPlot.SetNote: only the first two wrapped lines are drawn, the rest silently dropped.
- stzSoundPlot.SetTitle / SetNote: take effect only when set before a Draw method; set afterwards they change nothing, silently.
- stzSoundPlot.SaveAsPNG: answers nothing (the PNG bytes are discarded) and writes no file when no graphics device exists, without a message.
- stzSoundPlot.DrawSpectrogram: the time axis ends at rows x seconds-per-row (0.96 s for a one second sound), so MarkTimeAt with the sound's duration lands about 4 percent to the right.
- stzSoundPlot.MarkTimeAt: a time past the span is drawn outside the plot area without an error.
- stzSoundPlot.Canvas: shapes added through the returned canvas appear in the plot only after its Flush.
- stzSoundPlot.DrawWave: thin dark hairlines show inside the filled band (a drawing artefact, shape unchanged).
- stzSoundPlot (labels): number formatting follows Ring's default (1.50k next to 3k).

## Documentation machinery
- Misplaced comments become `#@ aka` retrieval text: stzHistogram.ToCanvasQ carries "THE ONE PLACE A BIN EDGE BECOMES TEXT." (the rationale of the private _BinLabelFor, which sits above it); stzSurfacePlot.init carries "NO LEGEND HERE ..." (a class-level remark). The applier keeps the first old paragraph of any block as an aka and has no option to drop one.
