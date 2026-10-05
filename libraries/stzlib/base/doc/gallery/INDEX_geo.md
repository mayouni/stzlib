# Geo gallery -- what each picture showed (DOCREFORM wave 5)

Every picture below was rendered by the short `.ring` script beside it and then OPENED (the PNG read back by a model).
**Perceived by: 'stzlib-docs visual pass (a model reading the PNG)', 2026-10-05, for every row.** No human has looked at
these yet: *unperceived by a person* is a state, and a verdict here is a model's reading, not an author's ruling.

Run any script from `libraries/stzlib/base/test/reflect` (the engine DLL path needs it), for example
`ring ../../doc/gallery/stzGeoMap/niger_density.ring`. The scripts that draw land need the caller's world atlas, which this
library does not vendor (`test/graphics/atlas/README.md`); they say `SKIPPED, by name` without it, and read
`STZ_ATLAS` when the folder is elsewhere. Niger (`test/graphics/niger_adm1.geojson`) and the two invented countries
(`test/graphics/fixtures`) are shipped. Every picture is under 150 KB. All people, places and measurements in the pictures
are INVENTED unless a table says otherwise (Niger's population is the RGPH 2012 census from `niger_density.ring`).
Verdicts: RIGHT = looks as the plane's doctrine says it should, WRONG = the picture shows something the code or the
doc text says differently (see `FINDINGS_geo.md`), UNCERTAIN = a picture cannot decide it.

## stzGeoMap

| picture | call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `stzGeoMap/niger_density.png` | `SetValues`, `SetClasses`, `SetOpenTop`, `SetRamp`, `AddInsetXT`, `DrawSheetOn`, `DrawLabelsOn`, `DrawInsetsOn`, `DrawRampLegendOn`, `DrawScaleBarOn`, `DrawNorthArrowOn` | Niger with its eight regions in the right shape (the south-west tail toward Burkina), coloured pale yellow for Agadez, orange for Diffa, red-orange for Tahoua, Tillaberi, Zinder, dark red for Dosso and Maradi: the classes match the densities. Names inside every region in a readable ink (white on the dark ones). A ramp legend with an arrow end for the open top, a scale bar, a north arrow, a caption naming the projection and the source. **The Niamey inset is filled pale grey (no data) while the locator square on the main map shows the capital dark red.** | WRONG (inset colour), RIGHT otherwise | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoMap/world_area.png` | `ValuesFromArea`, `SetValues`, `SetClasses`, `SetRamp(:Viridis)`, `DrawSheetOn`, `DrawRampLegendOn` | The world on Equal Earth with coastlines and borders right: Russia, Canada, the USA, China, Brazil, Australia and India yellow (above 3 million km2), Kazakhstan, Algeria, Greenland green, small states purple. Antarctica hatched as no data, the legend swatch hatched the same way. No wrong hemisphere, no mirrored axis. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoMap/africa_blocs.png` | `SetGroups`, `DrawSheetOn`, `DrawLabelsOn`, `DrawGroupKeyOn`, `UnresolvedMembers` | Africa on a conic equal-area, everything outside the groups hatched grey; Mali, Niger and Burkina Faso red, the other West African members blue, the key at the right. Three names fit (Mali, Niger, Nigeria), eleven were dropped by design. The caption prints the parallels as "-22.78N". | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoMap/daynight_world.png` | `SunAt`, `DrawNightOn`, `DrawTwilightOn`, `IsDaylightAt` | The land on Natural Earth with the night side as dark caps either side of a lit band about 180 degrees wide, centred just west of the Greenwich meridian where the yellow sun marker sits on the Gulf of Guinea (declination -4.85, equation of time 11.6 minutes, right for 5 October). Niamey day, Los Angeles (05:00 local) night, Tokyo (21:00) night. The caps join across the antimeridian. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoMap/hexbin_flows.png` | `HexBin`, `DrawHexBinsOn`, `CountPointsIn`, `DrawSymbolsOn`, `DrawFlowsOn`, `DrawSymbolAt` | Three panels of Niger: hexagon bins in the clusters' places, circles whose area follows the count of each region (the largest in the west, 240), and three great circles from Niamey that reach other regions as straight-looking lines. The captions below are one line. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoMap/wind_streams.png` | `DrawStreamDensityOnXT` | An invented wind field: a raster of speed in six classes, yellow bands at the equator and at 60 degrees (where the formula is strongest) and dark purple rows at 30 degrees (zero), with evenly spaced streamlines and coastlines in white. The lines close into counter-rotating gyres exactly where the field has them. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoMap/wind_arrows.png` | `DrawVectorsRampedOn` | The same field as 629 arrows: westward and long at the equator, eastward at 60 degrees, tiny vertical ticks at 30 degrees, colour and length growing together. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |

## stzGeoProjection

| picture | call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `stzGeoProjection/projections_compared.png` | `FitSphereIn`, `DrawSphereOn`, `DrawGraticuleOn`, `DrawFeaturesOn`, `DrawTissotOn`, `Distortion` | Six projections of the land: Mercator (circles swell toward the poles, mean area x3.11, 0 degrees bent), Equal Earth and Mollweide (every circle the same size and squashed, area x1.00), Winkel Tripel (x1.06, 23 degrees), an Orthographic globe and an Azimuthal Equidistant map centred on Niamey (ellipses stretched at the rim). The captions state equal-area or conformal where it holds. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoProjection/globe_routes.png` | `CenterOn`, `DrawFeaturesOn`, `DrawRingOn(StzGeoCircleKm)`, `DrawLineOn(StzGeoArc)`, `Project`, `Center`, `Invert` | A globe centred on Niamey: Europe at the top, South America at the left, Arabia at the right, concentric 1000 km rings, straight lines through the centre to Paris (3919 km), Cairo, Lagos (784), Nairobi, Cape Town and Rio, labelled with the distance. Africa is the right way up, nothing mirrored. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoProjection/niger_conic_utm.png` | `StzGeoConicFor`, `FitFeaturesIn`, `ArealScaleAt`, `Project`, `Invert`, `Caption`, `StzGeoUtmZoneOf` | Niger on its equal-area conic and on a Mercator, the same shape at this size; Niamey in the south-west on both; the printed area scales are 1.00 and 1.00 for the conic and 1.06 and 1.18 for the Mercator, which are the secant squared of 13.5 and 23 degrees. The pixel of Niamey inverts back to 2.13, 13.51. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |

## stzGeoEllipsoid

| picture | call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `stzGeoEllipsoid/geodesic_vs_rhumb.png` | `DistanceKm`, `RhumbDistanceKm`, `GeodesicFlat`, `RhumbFlat`, `Azimuth`, `RhumbAzimuth` | A Mercator world with New York to London and Niamey to Tokyo: the rhumb line (red) is a straight line, the geodesic (blue) bows toward the pole, much more on the long route. Labels give 5585 against 5809 km and 12973 against 14024 km. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoEllipsoid/rings_and_areas.png` | `DestinationKm`, `AreaKm2`, `DegreeOfLongitudeKm` | Rings every 1000 km around Niamey on an azimuthal equidistant map are concentric true circles; beside them bars for a one-degree cell at 0, 30, 60, 80 and 89 degrees (12308, 10642, 6122, 2058, 108 km2) shrinking with the cosine. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoEllipsoid/ellipsoids_compared.png` | `InverseFlattening`, `QuarterMeridianKm`, `DistanceKm`, `AreaKm2` | A chart of six ellipsoids: WGS84 and GRS80 one metre apart, Airy, Bessel and Clarke 127 to 410 m shorter on Niamey to Paris, the Sphere 10.8 km longer and 20 km2 smaller on the cell. The Sphere bars are cut at the scale and one bar covers a column heading (my layout). | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |

## stzGeoField

| picture | call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `stzGeoField/rain_kriging.png` | `IDWField`, `KrigeFields`, `SetClassesEvery`, `SetRamp`, `DrawOn`, `DrawLegendOn` | Three Niger panels over 70 invented gauges: inverse distance weighting with the bullseyes round gauges, ordinary kriging smoother, and the kriging variance, light (low) at every gauge and darkest in the gaps and at the edges. Rasters clipped at the border; legends in the field's own units. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoField/density_and_contours.png` | `StzGeoDensityField`, `Stats`, `LevelsEvery`, `DrawXT`, `DrawContoursOn` | 427 invented places in clusters, their kernel density (red where they are thick, in the west and two smaller spots) and five contour levels that ring the same spots; legend in places per million km2. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoField/ascii_grid_terrain.png` | `StzGeoFieldFromAsciiGrid`, `SetClassesEvery`, `SetClipTo`, `DrawOn`, `DrawContoursOn` | An invented relief read from an ASCII grid: two hills (a large one and a smaller one), a white square for the NODATA nodes, contour rings round the hills, and the raster clipped to Niger on the third panel. **A scatter of white pixels across the lowest class**, which should be uniform. | WRONG (specks) | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |

## stzGeoFeatures

| picture | call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `stzGeoFeatures/parts_holes_lookup.png` | `PartCount`, `HoleCountOf`, `IndexAt`, `DrawFeatureOn` | The two invented countries (one with a white lake, one with an island as its second part, the dots in the lake reading 0), Niger rasterised by IndexAt into seven colours (Niamey is too small for the grid), and South Africa with Lesotho as its hole. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoFeatures/window_and_areas.png` | `IndicesWithin`, `BoundsOf`, `AreaKm2Of`, `AreaKm2` | An Africa window on Equal Earth with Africa and its neighbours in blue and **a red mark in the Pacific: Fiji, taken by the window**; beside it Niger's eight regions with their measured areas (Agadez 621917 km2 ... Niamey 556 km2, total 1183623). | WRONG for the window (Fiji), RIGHT for the areas | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoFeatures/lines_points_kinds.png` | `StzGeoFeaturesFromJson`, `KindOf`, `PartCount`, `DrawFeatureOn` | An invented GeoJSON: a blue river polyline, three red wells as circles, a lake polygon with a white hole; the empty geometry collection is counted as skipped. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |

## stzGeoPoints

| picture | call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `stzGeoPoints/three_patterns.png` | `Sample`, `SampleClustered`, `SampleDispersed`, `ClarkEvans`, `Ellipse`, `EllipseRing`, `MeanCentre`, `SpatialMedian` | Three Niger panels: random places (R 0.98, "random"), clusters in four spots (R 0.19, "clustered", the red mean centre sits in empty ground between the clusters and the yellow spatial median inside the biggest one), and evenly spaced places (R 1.25, "dispersed"). The verdicts are the ones the patterns were made to give. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoPoints/ripley_g_f.png` | `L`, `EnvelopeL`, `G`, `F` | L(r) for the same patterns with the grey band of 39 simulations: the uniform one runs through the band, the clustered one climbs far above it, the dispersed one dips below at 20 to 40 km; G is zero under the hard-core distance for the dispersed pattern and 1 almost at once for clusters, F rises slowly for clusters. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoPoints/outside_the_window.png` | `Outside`, `Findings`, `DensityPerKm2`, `stzGeoMap.AssignPoints` | Sixty places inside Niger in blue and five red ones outside it (three in the west, one south, one north); the text beside says 5 outside, a warning, the pattern still sound. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |

## stzGeoProcess

| picture | call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `stzGeoProcess/seven_processes.png` | `GenerateIn`, `ExpectedCount`, `IsClustering`, `IsInhibiting` | Seven panels: Poisson and Binomial scatter, an inhomogeneous pattern thick in the south-west where its field is, MaternCluster and Thomas clumps, MaternII and SSI evenly spaced. The captions show 144 drawn against 191 expected for the inhomogeneous one. | RIGHT as a picture, the 144 against 191 is the defect | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoProcess/null_models.png` | `EnvelopeOf`, `VerdictOn` | One clustered pattern against three nulls: the red L curve is far above the narrow Poisson and Binomial bands at every radius and inside the very wide MaternCluster band that made it ("consistent ... at every radius"). | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoProcess/matern_ii_ceiling.png` | `GenerateIn`, `StzGeoMaternIICeiling` | Survivors against proposal rate: MaternII rises then levels off near 250 points, SSI keeps rising to 523, about twice as many. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |

## stzGeoSamples

| picture | call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `stzGeoSamples/variogram_and_fit.png` | `Variogram`, `FitVariogram`, `GammaAt`, `IDWField` | Eighty gauges over an IDW surface and the variogram: ten black bins, rising then falling (the invented field is periodic), and the three fitted curves rising to a plateau at 6000 with ranges of 258 to 315 km. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoSamples/kriging_transect.png` | `FitAndUse`, `KrigeFields`, `KrigeAt`, `DrawContoursOn` | The kriged estimate with four isohyets round the high and low spots and a west-east transect at 15 N whose plus/minus two standard error band is narrow near gauges and wide in the gaps. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoSamples/kriging_on_a_trend.png` | `FitAndUse(:Best)`, `KrigeFields`, `Findings` | Left, stationary gauges: a smooth estimate inside 263 to 681. Right, gauges with a north-south trend: swirls and **white patches inside the country where the kriged value is outside every class** (-30825 to 29761 for gauges of 180 to 799), and Findings says only warning. | WRONG | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |

## stzGeoAtlas

| picture | call | what I SAW | verdict | perceived by | date |
|---|---|---|---|---|---|
| `stzGeoAtlas/table_to_map.png` | `ValuesFor`, `Unresolved`, `Uncovered`, `SetValues` | A 16-row table of typed names (USA, Ivory Coast, Burma, NE, fr, Czechia ...) drawn on the world: the United States, Russia, India, Brazil, Mexico, Nigeria, Egypt, Australia, France, Niger, Cote d'Ivoire, Czechia, Korea and Myanmar coloured by their classes, the rest hatched; "did not bind (2): Brasil, Atlantis" printed. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoAtlas/how_a_key_resolves.png` | `IndexOf`, `NameOf`, `StzGeoNormalizeName` | A page of 21 keys: Niger by name, blanks, id 562, NE, NER, ne; USA and United States; Ivory Coast and Cote d'Ivoire; Burma; The Gambia; Czechia; Holland; UK all found (green); Cape Verde, Brasil, Atlantis and a stray quote not found (red, "not guessed"). | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
| `stzGeoAtlas/niger_regions_table.png` | `ValuesFor`, `Unresolved`, `Uncovered`, `Names` | Niger's regions coloured from a typed table in which Tillaberi is spelt "Tillabery" and Niamey has no row: both hatched, both named in the margin, nothing guessed. | RIGHT | stzlib-docs visual pass (a model reading the PNG) | 2026-10-05 |
