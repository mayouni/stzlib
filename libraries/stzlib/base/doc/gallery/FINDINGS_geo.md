# Geo gallery: what the pictures showed

Written 2026-10-05 from the report of the geo wave (STZLIB-DOCREFORM-01, wave 5). 31 pictures, one folder per
class under `doc/gallery/`, indexed with what was seen in `INDEX_geo.md`. Every verdict below is by a model
reading the PNG, **not by a person**: the perception gate (CENTRAL-PERCEPTGATE-01) is still open for all 31.

RIGHT for 26 of 31. WRONG for five, each a defect in the library, not in the picture script. The full list with
causes is `tools/wave/data/w5_defects_geo.md`; each defect is also a `Defect:` warning in its method's doc block.

| picture | what is wrong |
|---|---|
| `stzGeoMap/niger_density.png` | the Niamey inset is grey while the parent map shows it red: `DrawInsetsOn` ignores `SetOpenTop` |
| `stzGeoFeatures/window_and_areas.png` | `Within` takes Fiji (box -180..180, middle longitude 0) into an Africa window; the areas panel is right |
| `stzGeoField/ascii_grid_terrain.png` | white specks: a bilinear read of a constant field is one ulp under the node value about 6% of the time, so pixels at the first class edge draw as no data |
| `stzGeoSamples/kriging_on_a_trend.png` | kriging on trended gauges gives a range of 1858 km on a 2128 km window and estimates from -30825 to 29761 for data 180..799; `Findings` only warns and `IsSound` answers TRUE |
| `stzGeoProcess/seven_processes.png` | the picture is right, the caption is not: 144 points drawn against 191.9 expected (`ExpectedCount` of an inhomogeneous process multiplies the mean of all grid values by the window area) |

Found by probes, with no picture:

- `StzGeoProcess.PatternIn` raises always: it passes `WindowRings()` to `StzGeoPoints`, which wants the features window.
- `StzGeoMap.ClassOf`, `ColourOf`, `DrawOn`, `DrawRegionsOn`, `DrawSheetOn`, `DrawLegendOn` raise R2 when values are set and classes are not; `SetPalette` before classes says "-1 classes need -1 colours".
- `ScaleVariation`, `ScaleBarAt`, `DrawScaleBarOn`, `DrawStreamDensityOn` without `SetPaper` guess the sheet as plus or minus pi times the scale (variation 57.85, not 1.009; the bar is refused).
- `DensityPointsIn`: the comment says per km2, the code multiplies by 10000. `LabelPointOf(0)`, `IsOnPaper(0)`, `Samples.ValueOf` and `PlaceOf` do no range check.
- `SetRamp` on a map or a field: the unknown-name error lists 9 of the 13 ramps. `Projection.Caption` prints a south parallel as "-22.78N".

Traps documented as traps, not defects: the ellipsoid point methods take latitude first while flat lists, `Projection`
and `Features` take longitude first; `Project` grows y downward; `StzGeoUtmProjection` units are unit-sphere radians,
not metres; Ring copies an object stored in a list.

Not seen: no person has looked at any of the 31 pictures. The cosmetic flaw in `ellipsoids_compared.png` (a bar covers a heading) is the picture script's, not the library's.
