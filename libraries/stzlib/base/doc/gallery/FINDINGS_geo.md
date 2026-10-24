# Geo gallery: what the pictures showed

Written 2026-10-05 from the report of the geo wave (STZLIB-DOCREFORM-01, wave 5). 31 pictures, one folder per
class under `doc/gallery/`, indexed with what was seen in `INDEX_geo.md`. Every verdict below is by a model
reading the PNG, **not by a person**: the perception gate (CENTRAL-PERCEPTGATE-01) is still open for all 31.

RIGHT for 27 of 31 (one picture, `stzGeoMap/niger_density.png`, CORRECTED 2026-10-16: see its row). WRONG for four, each a defect in the library, not in the picture script. The full list with
causes is `tools/wave/data/w5_defects_geo.md`; each defect is also a `Defect:` warning in its method's doc block.

| picture | what is wrong |
|---|---|
| `stzGeoMap/niger_density.png` | **CORRECTED 2026-10-16.** The Niamey inset was grey while the parent map showed it red: `DrawInsetsOn` ignored `SetOpenTop`, so Niamey (1844 people per km2 on a scale ending at 100) was class 0 in the inset and the top class on the parent. `DrawInsetsOn` now gives the inset the parent's open top; the picture was redrawn and the inset is dark red like the locator mark. Held by `test/geo/stzGeoMap_defects_narrated.ring` |
| `stzGeoFeatures/window_and_areas.png` | `Within` takes Fiji (box -180..180, middle longitude 0) into an Africa window; the areas panel is right. FIXED IN CODE 2026-10-24 (the picture was not redrawn and still shows the old behaviour) |
| `stzGeoField/ascii_grid_terrain.png` | white specks: a bilinear read of a constant field is one ulp under the node value about 6% of the time, so pixels at the first class edge draw as no data |
| `stzGeoSamples/kriging_on_a_trend.png` | kriging on trended gauges gives a range of 1858 km on a 2128 km window and estimates from -30825 to 29761 for data 180..799; `Findings` only warns and `IsSound` answers TRUE |
| `stzGeoProcess/seven_processes.png` | the picture is right, the caption is not: 144 points drawn against 191.9 expected (`ExpectedCount` of an inhomogeneous process multiplied the mean of all grid values by the window area). FIXED 2026-10-24: the picture was re-rendered through `ExpectedCountIn` and its caption reads 152; the new label was read by a model (the agent that made it), no person has looked at it |

Found by probes, with no picture:

- `StzGeoProcess.PatternIn` raises always: it passes `WindowRings()` to `StzGeoPoints`, which wants the features window.
- FIXED 2026-10-16 in `stzGeoMap`: `ClassOf`, `ColourOf`, `DrawOn`, `DrawRegionsOn`, `DrawSheetOn`, `DrawLegendOn` raised R2 when values were set and classes were not; they now raise an error that names `SetClasses` (the edges are the author's, so no default scheme). `SetPalette` before classes now says to set the classes first instead of "-1 classes need -1 colours".
- FIXED 2026-10-16 in `stzGeoMap`: `ScaleVariation`, `ScaleBarAt`, `DrawScaleBarOn`, `DrawStreamDensityOn` without `SetPaper` guessed the sheet as plus or minus pi times the scale (variation 57.85, not 1.009; the bar was refused); they now use the extent the features have on the paper (variation 1.006 for Niger).
- `DensityPointsIn`: the comment said per km2, the code multiplies by 10000. DECIDED 2026-10-16: the code is kept, its callers' class edges are written for that unit, and the doc says per 10000 km2. FIXED in `stzGeoMap`: `LabelPointOf(0)` and `IsOnPaper(0)` (and past the last) answer `[ ]` and FALSE. NOT FIXED here: `Samples.ValueOf` and `PlaceOf` do no range check (stzGeoSamples).
- FIXED 2026-10-16 in `stzGeoMap`: the unknown-name error of `StzGeoRamp` (so of `SetRamp` on a map and, through it, a field) lists all 13 ramps, read from the table. Still open: `Projection.Caption` prints a south parallel as "-22.78N" (stzGeoProjection).

Traps documented as traps, not defects: the ellipsoid point methods take latitude first while flat lists, `Projection`
and `Features` take longitude first; `Project` grows y downward; `StzGeoUtmProjection` units are unit-sphere radians,
not metres; Ring copies an object stored in a list.

Not seen: no person has looked at any of the 31 pictures. The cosmetic flaw in `ellipsoids_compared.png` (a bar covers a heading) is the picture script's, not the library's.
