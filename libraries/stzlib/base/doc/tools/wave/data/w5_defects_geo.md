# Wave 5, the geo group -- defects found by calling the methods (2026-10-05)

366 roots in nine classes (stzGeoMap 113, stzGeoProjection 53, stzGeoEllipsoid 44, stzGeoField 33, stzGeoFeatures 32,
stzGeoPoints 30, stzGeoProcess 25, stzGeoSamples 23, stzGeoAtlas 13) were called with real data before their brief was
written: Niger's eight admin-1 regions (`test/graphics/niger_adm1.geojson`), the two invented fixture countries
(`test/graphics/fixtures`), the 110m world atlas and Tunisia's 23 governorates (the caller's atlas folder), and invented
points, gauges and fields. None was fixed (comments only). Each defect below was confirmed with a second call on
different data. Format: method: symptom: cause.

## Raises or answers wrongly today

- stzGeoProcess.PatternIn: raises "stzGeoPoints: the window is a stzGeoFeatures ..." for every process: it passes
  `poPoints.WindowRings()` (a list of rings) to `StzGeoPoints`, which takes the stzGeoFeatures window. Seen with SSI and
  MaternCluster on the fixtures and Poisson on Niger. Cure: `StzGeoPoints(GenerateIn(...), poPoints.Window())`.
- stzGeoProcess.ExpectedCount (Inhomogeneous): 191.9 for a surface whose integral over Niger's window is 144.3 and whose
  generator draws 149.4 on average over 40 seeds (a constant surface agrees: 177.5 against 178.3): the engine answers the
  mean of ALL the grid values times the window area, not the integral over the window. The other kinds agree on average
  over 60 seeds (MaternCluster 190.1 against 189.4, Thomas 187.9 against 189.4, Poisson 179.6 against 177.5), with a
  standard deviation of about 90 for one cluster pattern.
- stzGeoMap.ClassOf, ColourOf, DrawRegionsOn, DrawSheetOn, DrawOn, DrawLegendOn: raise error R2 "Array Access (Index out
  of range)" when SetValues was called and SetClasses was not: `ClassOf` computes `_n_ = len(@aEdges) - 1 = -1` and reads
  `@aEdges[_n_ + 1]`, index 0. Same on the fixtures. Findings does not see it (the map is "sound").
- stzGeoMap.SetPalette: before SetClasses raises "-1 classes need -1 colours -- 3 given." (the same empty edges).
- stzGeoMap.DrawInsetsOn: an inset takes values, edges and palette from the parent but NOT SetOpenTop, so a region above
  the last edge (Niamey, 1844 per km2 on a scale ending at 100) is drawn as no data in the inset while the parent paints
  it in the top colour. Found by the picture `gallery/stzGeoMap/niger_density.png`, not by any counter.
- stzGeoMap.ScaleVariation, ScaleBarAt, DrawScaleBarOn, DrawStreamDensityOn without SetPaper: the sheet is guessed by
  `_FitBox` as plus and minus pi times the scale, for Niger [ -5478, -2071, 6086, 3711 ]: ScaleVariation answers 57.85
  instead of 1.009, DrawScaleBarOn refuses (answers 0) and the stream-density raster would cover a box thousands of pixels
  wide. With SetPaper(30, 50, 570, 470) the bar is drawn.
- stzGeoMap.DensityPointsIn: the source comment says per square kilometre; the code multiplies by 10000, so the answer is
  per 10000 km2 (0.0189 for one place in a 529383 km2 region).
- stzGeoMap.LabelPointOf(0), IsOnPaper(0): raise error R2 (no range check on the position).
- stzGeoFeatures.IndicesWithin, Within: Fiji (a feature across the antimeridian, box -180 to 180) has its middle on the
  prime meridian and is taken by a window around Africa (-20, -36, 52, 38): 64 features, one of them in the Pacific. It
  also makes FitFeaturesIn fit the whole sphere: the first Africa sheet was a speck in the middle of a conic fan.
- stzGeoField.ValueAt / DrawOn / DrawXT: bilinear interpolation of a constant field answers values one rounding step
  below the node value in about 6 per cent of reads (238 of 3950 at 220); with SetClassesEvery, whose first edge is the
  minimum exactly, those pixels fall below the first class and draw as no data: white specks across the lowest class
  (`gallery/stzGeoField/ascii_grid_terrain.png`). FindingsOn checks the nodes only and reports nothing.
- stzGeoSamples.FitAndUse(:Best), KrigeFields, KrigeAt on gauges with a strong trend: the Gaussian model fits a range of
  1858 km on a window 2128 km across; the kriged field runs from -30825 to 29761 for gauges of 180 to 799, and
  CrossValidate answers a bias of 2525 and an rmse of 16055. Findings only warns (over half the diagonal), so IsSound is
  TRUE. Also on a 80 km grid: -9098 to 17423. A stationary field behaves (263.8 to 681.2 for gauges of 361 to 664,
  rmse 27.9).
- stzGeoSamples.ValueOf, PlaceOf: raise error R2 for a position past the last (no range check).
- stzGeoMap.SetRamp, stzGeoField.SetRamp (via StzGeoRamp): the error for an unknown name lists nine ramps; there are
  thirteen (Viridis, Magma, Cividis and Flow are missing from the message).

## Reads as a trap, not a defect

- stzGeoEllipsoid: every point method takes LATITUDE FIRST and answers [ lat, lon ] (DistanceKm, Azimuth, DestinationKm,
  MidpointOf, ToEnu), but GeodesicBetween and RhumbLineBetween answer [ lon, lat ] pairs and the flat lists (AreaKm2,
  PathLengthKm, GeodesicFlat) are longitude first, as is every stzGeoProjection and stzGeoFeatures method. Swapped
  arguments raise nothing: Niamey to Paris is 3919.43 km, with the arguments swapped 3931.58 km.
- stzGeoProjection.Project: answers paper units with y growing DOWN; for the projection `StzGeoUtmProjection(31)` builds
  (scale 0.9996, no translation) Niamey projects to [ -0.0148, -0.2358 ], radians of the unit sphere and not metres.
- stzGeoProjection.Caption: the parallels of a conic always carry an N, so 22.78 degrees south prints "-22.78N"
  (`gallery/stzGeoMap/africa_blocs.png`).
- stzGeoProjection.DrawFeatureOn: a point is a circle of radius twice the stroke width, so a width of 0 draws no point.
- stzGeoMap.SetGroups: names match a feature's own name only (ignoring case): no alias, so "Cabo Verde" is unresolved
  where stzGeoAtlas would try its table.
- stzGeoMap.DrawLabelsOn: with a key box missing and :Auto, a region too small for its name is dropped and counted (11 of
  14 members on the Africa sheet), by design.
- stzGeoProcess setters share three slots: SetIntensity, SetCount and SetParentIntensity write the same number, and so do
  SetRadiusKm, SetSigmaKm and SetHardCoreKm (Content shows a, b, c).
- stzGeoPoints.SampleClustered: the number of children is a mean, so 8 parents of 25 gave 182 places.
- Ring: an object put in a list or iterated by `for x in list` is a COPY: classes set through the list never reach the
  original (the first rain_kriging script drew nothing). Set everything before listing the objects.
- A first Ring run of `ripley_g_f.ring` died once at its first line and ran clean three times after: an unattended
  hiccup, not reproduced.

## Stale comments seen in the sources

- stzGeoMap.ValuesFromArea says "measured on the SPHERE"; since GE8 it is WGS84.
- stzGeoFeatures.AreaKm2Of carries two successive comment blocks, the older one saying sphere.
- stzGeoMap file header: "WHAT IS NOT HERE ... no label placement": labels, insets and keys exist.
