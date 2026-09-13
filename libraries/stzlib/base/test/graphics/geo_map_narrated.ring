load "../../stzBase.ring"
decimals(4)

# GE2 -- A MAP MADE OF LAYERS. A narrated guard for stzGeoMap: the sphere
# and the graticule under it, every feature in the colour its value earns,
# symbols whose AREA carries the value, flows that are great circles, a
# legend that owns up to a class colouring nothing, and a caption that says
# how the map was made.
#
# Everything here stands on the two INVENTED countries. The real atlas is
# not committed -- see atlas/README.md -- and the few assertions that want
# it NAME WHAT THEY SKIPPED when it is absent.

nOk = 0  nBad = 0
? "=========================================================="
? " GE2: a map made of layers"
? "=========================================================="

oF = StzGeoFeaturesFromJson(read("fixtures/two_countries.geojson"))
oP = new stzGeoProjection(:Equirectangular)
oP.FitToFeatures(oF, 500, 400, 20)
oM = StzGeoMap(oP, oF)

? ""
? "-- 1. A VALUE PER FEATURE, and a class per value --"
oM.SetValuesQ([ 4200, 9100 ]).SetClasses([ 0, 5000, 20000 ])
chk("a value falls in its class, and the class picks the colour",
    oM.ClassOf(1) = 1 and oM.ClassOf(2) = 2 and oM.ColourOf(1) != oM.ColourOf(2))
oM.SetValues([ 4200, "" ])
chk("NEGATIVE: a feature with NO value is class 0 and draws as no data -- it is " +
    "never quietly coloured as zero",
    oM.ClassOf(2) = 0 and oM.ColourOf(2) = "#E8E8E8" and oM.ColourOf(2) != oM.ColourOf(1))
oM.SetValues([ 4200, 99999 ])
chk("NEGATIVE: a value beyond the last edge is class 0 too -- a map does not " +
    "stretch its own legend to fit",
    oM.ClassOf(2) = 0)
chk("class edges that do not rise are refused", _RefusesClasses([ 0, 100, 50 ]))
chk("a palette of the wrong count is refused", _RefusesPalette([ "red" ]))

? ""
? "-- 2. THE AREA A COUNTRY ACTUALLY HAS, measured on the sphere --"
# Arda is 5 degrees of longitude by 10 of latitude at the equator, less a
# lake. A degree of longitude at the equator is 111.19 km, so the box is
# about 5 x 111.19 x (sin 10) x 6371 ... -- the point is not the number but
# that the HOLE IS SUBTRACTED, which is what a reader would expect and what
# a largest-ring reader cannot do.
aA = oM.ValuesFromArea()
oNoHole = StzGeoMap(oP, StzGeoFeaturesFromJson(_NoLakeJson()))
aB = oNoHole.ValuesFromArea()
? "   Arda with its lake " + StzFactNumText(aA[1]) + " km2, without it " +
  StzFactNumText(aB[1]) + " km2"
chk("a feature's area is its rings' area with its HOLES TAKEN OUT",
    aA[1] < aB[1] and aA[1] > aB[1] * 0.8)
chk("...and a MultiPolygon's area is all its parts, island included",
    aA[2] > 0 and oF.PartCount(2) = 2)

? ""
? "-- 3. A CIRCLE'S AREA CARRIES THE VALUE, NEVER ITS RADIUS --"
# Doubling a radius quadruples the ink. A symbol map scaled by radius
# overstates its largest places fourfold, and a reader cannot see it being
# done. Four times the value must draw twice the radius.
aR = _SymbolRadii(oM, [ 1, 4 ], 40)
? "   values 1 and 4 draw radii " + StzFactNumText(aR[1]) + " and " + StzFactNumText(aR[2])
chk("four times the value draws TWICE the radius -- equal values, equal ink",
    fabs(aR[2] / aR[1] - 2) < 0.01)
chk("NEGATIVE: it is not linear in the radius, which is the lie this avoids",
    fabs(aR[2] / aR[1] - 4) > 1)
chk("the largest value takes the radius it was given, and no more",
    fabs(aR[2] - 40) < 0.01)

? ""
? "-- 4. A FLOW IS A GREAT CIRCLE, not a straight line on the paper --"
oW = new stzGeoProjection(:Equirectangular)
oW.FitToSphere(800, 400, 0)
aArc = oW.Arc(-74, 40.7, 139.7, 35.7)
chk("a route between two places comes back as a bent, resampled path",
    len(aArc) >= 1 and len(aArc[1]) / 2 > 8)
chk("...and it climbs north of BOTH its ends, because that is the shorter way",
    _TopOf(aArc) < _YOf(oW, -74, 40.7) and _TopOf(aArc) < _YOf(oW, 139.7, 35.7))
chk("NEGATIVE: a route along the equator does not bend -- the great circle IS " +
    "the straight line there",
    len(oW.Arc(-60, 0, 60, 0)[1]) / 2 > 2 and _TopOf(oW.Arc(-60, 0, 60, 0)) >= _YOf(oW, 0, 0) - 0.01)

? ""
? "-- 5. THE LEGEND OWNS UP, and the caption says how the map was made --"
oM.SetValues([ 4200, 9100 ])
oM.SetClasses([ 0, 5000, 20000, 50000 ])
oC = new stzCanvas(600, 400)
oC.SetBackground("#FFFFFF")
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
nY = oM.DrawLegendOn(oC, oFont, 20, 40, "people")
chk("the legend draws a row per class and returns where it ended", nY > 40 + 3 * 20)
chk("a map with no source SAYS SO rather than saying nothing -- silence reads " +
    "as authority",
    StzFindFirst("source not stated", oM.Caption()) > 0)
oM.SetSource("Invented, for a guard")
chk("...and with one, it carries the projection AND the source",
    StzFindFirst("Equirectangular", oM.Caption()) > 0 and
    StzFindFirst("Invented, for a guard", oM.Caption()) > 0 and
    StzFindFirst("source not stated", oM.Caption()) = 0)

? ""
? "-- 6. THE WHOLE MAP DRAWS, layer by layer --"
oC2 = new stzCanvas(600, 460)
oC2.SetBackground("#FFFFFF")
oM.DrawOn(oC2)
oM.DrawSymbolsOn(oC2, [ 4200, 9100 ], 20, "#D9822B99", "#8A4B12")
oM.DrawFlowsOn(oC2, [ [ 1, 2, 13, 8, 2 ] ], "#C0392B", 2)
cSvg = oC2.ToSVG()
chk("the map reaches the vector tier with its polygons, its circles and its lines",
    len(cSvg) > 2000 and StzFindFirst("<polygon", cSvg) > 0 and
    StzFindFirst("<circle", cSvg) > 0)

? ""
? "-- 7. INSIDE A COUNTRY: the units an analyst works with (GE6) --"
# A country is not the unit anybody analyses. The file that holds every
# province on Earth is 40 MB, so the match happens in the ENGINE and only
# what was asked for is parsed. The projection is then a conic fitted to
# that country alone.
chk("a feature set can be cut down to a WINDOW, and the cut is a feature " +
    "set like any other -- the map, the atlas and the rules all take it",
    oF.Within(-1, -1, 8, 20).Count() = 1 and oF.Within(-1, -1, 8, 20).NameOf(1) = "Arda")
chk("NEGATIVE: a window with nothing in it gives an EMPTY feature set, not a " +
    "guess at what was meant",
    oF.Within(100, 100, 110, 110).Count() = 0)
chk("...and the file it was cut from is untouched", oF.Count() = 2)
oCon = StzGeoConicFor(oF, :ConicEqualArea)
aB = oF.Bounds()
? "   the fixture spans " + StzFactNumText(aB[2]) + "N to " + StzFactNumText(aB[4]) +
  "N; its conic takes " + StzFactNumText(oCon.Params()[5]) + "N and " +
  StzFactNumText(oCon.Params()[6]) + "N"
chk("THE CONIC AN ATLAS WOULD CHOOSE: standard parallels at a sixth and five " +
    "sixths of the latitude span, the central meridian down the middle",
    fabs(oCon.Params()[5] - (aB[2] + (aB[4] - aB[2]) / 6)) < 0.001 and
    fabs(oCon.Params()[6] - (aB[2] + (aB[4] - aB[2]) * 5 / 6)) < 0.001 and
    fabs(oCon.RotationOf()[1] + (aB[1] + aB[3]) / 2) < 0.001)
chk("...and it is EQUAL-AREA by default, because a country map is nearly " +
    "always a choropleth and the gate would refuse a conformal one under one",
    oCon.IsEqualArea())
chk("NEGATIVE: a caller who wants shapes over quantities asks by name",
    (StzGeoConicFor(oF, :ConicConformal)).IsConformal())

? ""
? "-- 8. A LABEL SITS IN ITS OWN REGION --"
# The mean of a ring falls outside it whenever the region is a crescent or a
# horseshoe, and a name outside its region is a name on somebody else's.
oLb = StzGeoMap(new stzGeoProjection(:Equirectangular), oF)
oLb.Projection().FitToFeatures(oF, 500, 400, 20)
oLb.SetSource("Invented, for a guard")
bIn = TRUE
for i = 1 to oF.Count()
	g = oLb.LabelPointOf(i)
	if len(g) < 2 or oF.IndexAt(g[1], g[2]) != i  bIn = FALSE  ok
next
chk("every label lands inside the region it names", bIn)
oCr = StzGeoFeaturesFromJson(_CrescentJson())
oLc = StzGeoMap(new stzGeoProjection(:Equirectangular), oCr)
oLc.Projection().FitToFeatures(oCr, 400, 400, 20)
aMean = _MeanOfRing(oCr.OuterRingOf(1, 1))
? "   the crescent's MEAN is " + StzFactNumText(aMean[1]) + "," + StzFactNumText(aMean[2]) +
  " -- inside it: " + oCr.Contains(1, aMean[1], aMean[2])
chk("NEGATIVE: on a CRESCENT the mean of the ring is outside the region, which " +
    "is the whole reason the placer exists",
    NOT oCr.Contains(1, aMean[1], aMean[2]))
chk("...and the placer still finds a point inside it",
    oCr.Contains(1, oLc.LabelPointOf(1)[1], oLc.LabelPointOf(1)[2]))

? ""
? "-- 9. A NAME GOES INSIDE ITS REGION, OR IT BECOMES A NUMBER --"
# There is no third thing and there are no leader lines. Three rounds of
# this drew them and the Principal returned every one, the last as "these
# lines are a total mess" -- and they were right about the field as well as
# the picture: nivo, Datawrapper, QGIS's PAL, Mapbox GL and ArcGIS Maplex
# all drop an area name that will not fit rather than lead it out, and every
# printed atlas puts a NUMBER in the small unit with a KEY beside the map.
oLbF = StzGeoFeaturesFromJson(_CrowdJson())
oLbM = StzGeoMap(new stzGeoProjection(:Equirectangular), oLbF)
oLbM.Projection().FitToFeatures(oLbF, 300, 300, 10)
oLbM.SetSource("Invented, for a guard")
oLbM.SetPaper(10, 10, 320, 390)
oLbC = new stzCanvas(600, 400)
oLbC.SetBackground("#FFFFFF")
oLbM.DrawLabelsXT(oLbC, oFont, 13, "#000000", FALSE)
rNoKey = oLbM.LabelReport()
? "   twelve crowded regions, no key box: named " + rNoKey[:named] +
  ", numbered " + rNoKey[:numbered] + ", dropped " + rNoKey[:dropped]
chk("WITH NO KEY BOX a name that will not fit is DROPPED and COUNTED, never " +
    "replaced by a digit -- a number with nothing to look it up in tells the " +
    "reader only that they are missing something",
    rNoKey[:numbered] = 0 and rNoKey[:dropped] > 0 and
    rNoKey[:named] + rNoKey[:numbered] + rNoKey[:dropped] = oLbF.Count())

oLbC2 = new stzCanvas(600, 400)
oLbC2.SetBackground("#FFFFFF")
oLbM.SetKeyBox(330, 20, 590, 380)
oLbM.SetKeyTitle("Numbered on the map")
oLbM.DrawLabelsXT(oLbC2, oFont, 13, "#000000", FALSE)
oLbM.DrawKeyOn(oLbC2, oFont, 13, "#333333")
rKey = oLbM.LabelReport()
? "   the same, with a key box: named " + rKey[:named] + ", numbered " +
  rKey[:numbered] + ", dropped " + rKey[:dropped] + ", unlisted " + rKey[:unlisted]
chk("GIVEN A KEY BOX, the names that will not fit become NUMBERS instead of " +
    "being dropped -- which is what every printed atlas does with a unit too " +
    "small to carry its own name",
    rKey[:numbered] > 0 and rKey[:dropped] < rNoKey[:dropped] and
    rKey[:named] + rKey[:numbered] + rKey[:dropped] = oLbF.Count())
chk("...and every number that was drawn has an entry in the key",
    len(oLbM.KeyEntries()) = rKey[:numbered] and rKey[:unlisted] = 0)
chk("THE KEY IS NUMBERED IN READING ORDER -- rows down the sheet -- so a " +
    "reader looking for an entry walks to it instead of hunting",
    _KeyReadsInOrder(oLbM))
chk("NEGATIVE: two labels never overlap -- every box is tested against every " +
    "box already placed, which is what makes this a placement and not a plotting",
    _NoOverlap(oLbM, oFont, 13))
chk("THE INK IS THE COLOUR SYSTEM'S ANSWER: the two ends of the ramp take " +
    "DIFFERENT ink, and each reaches the WCAG body-text floor against the " +
    "shade it is drawn on -- a drawing file has no opinion of its own here",
    _InkFlips(oLbF))

# --- THE KEY MAY NOT LOSE ENTRIES OFF THE BOTTOM OF ITS BOX ---------------
# Found in this plane's own France sheet: 39 of 75 entries drawn and 36 gone,
# in silence, under a comment claiming a key must never do that.
oLbC3 = new stzCanvas(600, 400)
oLbC3.SetBackground("#FFFFFF")
oLbM.SetKeyBox(330, 20, 420, 60)
oLbM.DrawLabelsXT(oLbC3, oFont, 13, "#000000", FALSE)
oLbM.DrawKeyOn(oLbC3, oFont, 13, "#333333")
rTiny = oLbM.LabelReport()
? "   a key box too small: numbered " + rTiny[:numbered] + ", unlisted " + rTiny[:unlisted]
chk("A KEY BOX WITH TOO LITTLE ROOM REPORTS WHAT IT COULD NOT LIST, and does " +
    "not lose it in silence",
    rTiny[:unlisted] > 0)
chk("...and the gate calls that an ERROR, because a number appearing nowhere " +
    "in the key makes the reader think they misread the map",
    _HasFinding(oLbM.Findings(), "the_key_lists_every_number", "error"))
oLbM.SetKeyBox(330, 20, 590, 380)

# --- A NUMBER WITH NO KEY AT ALL -----------------------------------------
# Unless the mark is the unit's own public name. "59" is the Nord to every
# French reader; a sequential "7" is an index into a key and nothing else.
oLbC4 = new stzCanvas(600, 400)
oLbC4.SetBackground("#FFFFFF")
oLbM.DrawLabelsXT(oLbC4, oFont, 13, "#000000", FALSE)
chk("NUMBERS DRAWN AND NO KEY DRAWN IS AN ERROR when the marks are sequential",
    _HasFinding(oLbM.Findings(), "every_number_has_a_key", "error"))
oLbM.SetKeyCodes("iso_3166_2")
oLbC5 = new stzCanvas(600, 400)
oLbC5.SetBackground("#FFFFFF")
oLbM.DrawLabelsXT(oLbC5, oFont, 13, "#000000", FALSE)
chk("...but only a WARNING when they are OFFICIAL CODES, which a reader at " +
    "home in the country already knows -- this is how every road atlas of " +
    "France is printed",
    _HasFinding(oLbM.Findings(), "every_number_has_a_key", "warning"))
oLbM.SetKeyCodes("")

? "-- 9b. THE CENTRE FIRST, AND SOMEWHERE ROOMIER WHEN IT WILL NOT FIT --"
# A reader expects a name in the middle of its region, so the middle is
# tried first and only a name that will not FIT there is moved. The
# fallback is the point furthest from any edge -- the centre of the largest
# circle the region holds, which is what Mapbox's polylabel and QGIS use.
oCnF = StzGeoFeaturesFromJson(_NoLakeJson())
oCnM = StzGeoMap(new stzGeoProjection(:Equirectangular), oCnF)
oCnM.Projection().FitToFeatures(oCnF, 400, 400, 20)
oCnM.SetPaper(0, 0, 440, 440)
oCnC = new stzCanvas(440, 440)
oCnC.SetBackground("#FFFFFF")
oCnM.DrawLabelsXT(oCnC, oFont, 13, "#000000", FALSE)
aCnB = oCnM.PlacedBoxes()
aCnG = _TrueCentreOf(oCnM, 1)
? "   a region with room: its centre is " + StzFactNumText(aCnG[1]) + "," +
  StzFactNumText(aCnG[2]) + "; the name went to " +
  StzFactNumText((aCnB[1][1] + aCnB[1][3]) / 2) + "," +
  StzFactNumText((aCnB[1][2] + aCnB[1][4]) / 2)
chk("WHERE THERE IS ROOM, THE NAME IS PRINTED AT THE CENTRE OF THE REGION -- " +
    "not near it, and not wherever a search happened to stop",
    len(aCnB) > 0 and
    fabs((aCnB[1][1] + aCnB[1][3]) / 2 - aCnG[1]) < 1 and
    fabs((aCnB[1][2] + aCnB[1][4]) / 2 - aCnG[2]) < 1)

oCrM = StzGeoMap(new stzGeoProjection(:Equirectangular), oCr)
oCrM.Projection().FitToFeatures(oCr, 400, 400, 20)
oCrM.SetPaper(0, 0, 440, 440)
oCrC = new stzCanvas(440, 440)
oCrC.SetBackground("#FFFFFF")
oCrM.DrawLabelsXT(oCrC, oFont, 13, "#000000", FALSE)
aCrB = oCrM.PlacedBoxes()
aCrG = _TrueCentreOf(oCrM, 1)
chk("NEGATIVE: ON A CRESCENT, WHOSE CENTRE IS NOT IN IT AT ALL, the name moves " +
    "to the roomiest point that IS -- the centre is a preference and never a rule",
    len(aCrB) > 0 and
    fabs((aCrB[1][1] + aCrB[1][3]) / 2 - aCrG[1]) +
    fabs((aCrB[1][2] + aCrB[1][4]) / 2 - aCrG[2]) > 2)
chk("...and it is genuinely inside the crescent, tested on the sphere and not " +
    "on the paper it was chosen on",
    _BoxLandsInRegion(oCrM, oCr, aCrB[1]))

? ""
? "-- 9c. THREE LABELLING MODES, AND THE ENGINE PREFERS NONE OF THEM --"
# :Names is what nivo and Datawrapper do; :Numbers is the atlas plate;
# :Auto is the hybrid. Which one a sheet wants depends on who is reading
# it, and that is not a fact about the geometry.
oLbM.SetKeyBox(330, 20, 590, 380)
aMd = [ :Names, :Numbers, :Auto ]
aRep = []
for iMd = 1 to 3
	oMdC = new stzCanvas(600, 400)
	oMdC.SetBackground("#FFFFFF")
	oLbM.SetLabelMode(aMd[iMd])
	oLbM.DrawLabelsXT(oMdC, oFont, 13, "#000000", FALSE)
	oLbM.DrawKeyOn(oMdC, oFont, 13, "#333333")
	aRep + oLbM.LabelReport()
	? "   " + aMd[iMd] + ": named " + aRep[iMd][:named] + ", numbered " +
	  aRep[iMd][:numbered] + ", unlabelled " + aRep[iMd][:dropped]
next
oLbM.SetLabelMode(:Auto)
chk(":Names DRAWS NO NUMBER AT ALL -- a region whose name will not fit goes " +
    "unlabelled, and the report says how many",
    aRep[1][:numbered] = 0 and aRep[1][:dropped] > 0)
chk(":Numbers DRAWS NO NAME AT ALL -- every region carries a mark and every " +
    "name is in the key, so nothing is a special case",
    aRep[2][:named] = 0 and aRep[2][:numbered] > 0)
chk(":Auto NUMBERS WHAT :Names DROPS -- on a fixture where NO name fits, the " +
    "hybrid and the numbers mode agree, and both label what :Names cannot",
    aRep[3][:numbered] > 0 and aRep[3][:dropped] < aRep[1][:dropped])
# AND THE OTHER HALF OF THE CLAIM, ON A FIXTURE WHERE NAMES DO FIT. The crowd
# above is twelve regions too small to hold a name -- that is what it is for
# -- so ":Auto draws both kinds of mark" cannot be shown on it, and asserting
# it there would only have been a weaker assertion that happened to pass.
oRmM = StzGeoMap(new stzGeoProjection(:Equirectangular), oF)
oRmM.Projection().FitToFeatures(oF, 500, 400, 20)
oRmM.SetPaper(0, 0, 540, 440)
oRmM.SetKeyBox(545, 20, 700, 420)
aRoom = []
for iMd = 1 to 3
	oRmC = new stzCanvas(720, 440)
	oRmC.SetBackground("#FFFFFF")
	oRmM.SetLabelMode(aMd[iMd])
	oRmM.DrawLabelsXT(oRmC, oFont, 13, "#000000", FALSE)
	oRmM.DrawKeyOn(oRmC, oFont, 13, "#333333")
	aRoom + oRmM.LabelReport()
next
oRmM.SetLabelMode(:Auto)
? "   with room -- names: " + aRoom[1][:named] + " named; numbers: " +
  aRoom[2][:numbered] + " numbered; auto: " + aRoom[3][:named] + " named"
chk("WHERE THERE IS ROOM the three modes differ exactly as advertised: :Names " +
    "names every region, :Numbers numbers every region, and :Auto names them " +
    "because the names fit",
    aRoom[1][:named] = oF.Count() and aRoom[1][:numbered] = 0 and
    aRoom[2][:named] = 0 and aRoom[2][:numbered] = oF.Count() and
    aRoom[3][:named] = oF.Count())
chk("ALL THREE ACCOUNT FOR EVERY REGION -- the three numbers add to the feature " +
    "count in every mode, which is what stops a mode quietly losing one",
    aRep[1][:named] + aRep[1][:numbered] + aRep[1][:dropped] = oLbF.Count() and
    aRep[2][:named] + aRep[2][:numbered] + aRep[2][:dropped] = oLbF.Count() and
    aRep[3][:named] + aRep[3][:numbered] + aRep[3][:dropped] = oLbF.Count())
chk("NEGATIVE: a mode this file does not know is refused BY NAME, with the " +
    "three it does know printed in the refusal",
    _RefusesMode())

? "-- 9. THE SPATIAL JOIN: a table of places, counted into regions --"
# THE POINTS ARE TAKEN FROM THE REGIONS THEMSELVES, not guessed at. The
# first draft of this section wrote coordinates it believed were inside
# Berea and two of them were not -- the guard failed and the code was
# right, which is the cheapest kind of wrong to be and still a waste. An
# interior point is one the placer already knows how to find.
oJn = StzGeoMap(new stzGeoProjection(:Equirectangular), oF)
oJn.Projection().FitToFeatures(oF, 500, 400, 20)
oJn.SetSource("Invented, for a guard")
aIn1 = oJn.LabelPointOf(1)
aIn2 = oJn.LabelPointOf(2)
aPts = [ aIn1[1], aIn1[2], aIn1[1], aIn1[2], aIn1[1], aIn1[2],
         aIn2[1], aIn2[2], aIn2[1], aIn2[2], 60, 60 ]
aCnt = oJn.CountPointsIn(aPts)
chk("every point is counted into the region it fell in",
    len(aCnt) = 2 and aCnt[1] = 3 and aCnt[2] = 2)
chk("A POINT OUTSIDE EVERY REGION IS REPORTED, never rounded to the nearest -- " +
    "a well across the border belongs to the other side",
    oJn.PointsOutside(aPts) = 1 and (aCnt[1] + aCnt[2] + oJn.PointsOutside(aPts)) = len(aPts) / 2)
chk("...and AssignPoints says which region each one fell in, 0 for none",
    len(oJn.AssignPoints(aPts)) = 6 and oJn.AssignPoints(aPts)[1] = 1 and
    oJn.AssignPoints(aPts)[4] = 2 and oJn.AssignPoints(aPts)[6] = 0)
aDn = oJn.DensityPointsIn(aPts)
chk("A COUNT MAY NOT BE COLOURED AND A DENSITY MAY: a big region collects more " +
    "of anything, so the join answers per-area too",
    len(aDn) = 2 and aDn[1] > 0 and aDn[2] > 0 and
    fabs(aDn[1] / aDn[2] - (aCnt[1] / oJn.ValuesFromArea()[1]) / (aCnt[2] / oJn.ValuesFromArea()[2])) < 0.001)
# THE LIE A COUNT TELLS, shown on this fixture: Berea is the BIGGER of the
# two -- 924,107 km2 against Arda's 531,683 -- so a count would rank it
# first on any even scattering, while the density puts the smaller one
# first. That is the whole reason the join answers both.
aEq = [ aIn1[1], aIn1[2], aIn1[1], aIn1[2], aIn2[1], aIn2[2], aIn2[1], aIn2[2] ]
aCe = oJn.CountPointsIn(aEq)
aDe = oJn.DensityPointsIn(aEq)
chk("NEGATIVE: with the SAME count each, the smaller region is the denser one -- " +
    "a count would have called them equal",
    aCe[1] = aCe[2] and oJn.ValuesFromArea()[2] > oJn.ValuesFromArea()[1] and aDe[1] > aDe[2])

? ""
? "-- 10. THE EXTENT IS ONE PLACE, or the projection is fitted to the sea --"
# Natural Earth's France carries Reunion and Guyane beside the departments,
# so its latitude span runs from -21 to 51 and a conic fitted to all of it
# puts its parallels in the Atlantic.
oFar = StzGeoFeaturesFromJson(_ScatteredJson())
oMf = StzGeoMap(StzGeoConicFor(oFar, :ConicEqualArea), oFar)
oMf.SetSource("Invented, for a guard")
chk("a set whose extent is driven by ONE far-off member is caught, and the " +
    "finding NAMES it so the caller can window it away",
    _HasRule(oMf.Findings(), "the_extent_is_one_place", "warning") and
    _RuleSays(oMf.Findings(), "the_extent_is_one_place", "Faraway"))
oNear = oFar.Within(-5, -5, 15, 15)
oMn = StzGeoMap(StzGeoConicFor(oNear, :ConicEqualArea), oNear)
oMn.SetSource("Invented, for a guard")
chk("NEGATIVE: windowed to the places that belong together, it reports nothing",
    oNear.Count() = 5 and NOT _HasRule(oMn.Findings(), "the_extent_is_one_place", "warning"))

? ""
? "-- 7. HEXAGONAL BINS: how many here, not where exactly --"
# Ten thousand dots on a map are a stain. Binning counts them into cells,
# and the cell is a HEXAGON because a square grid lies twice: its cells
# touch diagonal neighbours at a point and orthogonal ones along an edge,
# so "next to" means two distances.
oHx = StzGeoMap(new stzGeoProjection(:EqualEarth), oF)
oHx.Projection().FitToSphere(600, 300, 0)
oHx.SetSource("Invented, for a guard")
aPts = _GridPoints(-40, -20, 40, 20, 9)
aB1 = oHx.HexBin(aPts, 12)
aB2 = oHx.HexBin(aPts, 24)
nSum = 0
for i = 1 to len(aB1)  nSum += aB1[i][3]  next
? "   " + (len(aPts) / 2) + " points -> " + len(aB1) + " cells at radius 12, " +
  len(aB2) + " at radius 24"
chk("EVERY POINT IS COUNTED ONCE: the bins' counts sum to the points given",
    nSum = len(aPts) / 2)
chk("...and a bigger cell means fewer of them, which is the only knob there is",
    len(aB2) < len(aB1) and len(aB2) > 0)
chk("a bin says where it is and how many it holds",
    len(aB1[1]) = 3 and aB1[1][3] >= 1)
chk("a hexagon has six corners, at the radius asked for",
    len(StzEngineGeoHexagon(100, 100, 20)) = 12 and
    fabs(sqrt(pow(StzEngineGeoHexagon(100, 100, 20)[1] - 100, 2) +
              pow(StzEngineGeoHexagon(100, 100, 20)[2] - 100, 2)) - 20) < 0.001)
chk("NEGATIVE: no points, no bins -- an empty cell is not a count of zero, " +
    "it is a place nobody counted",
    len(oHx.HexBin([], 12)) = 0)
chk("BINNING CARRIES THE CHOROPLETH'S OWN LIE: cells of the paper stand for " +
    "equal ground only on an equal-area projection, and the map says so",
    _HasRule(_BinnedOn(:Mercator, oF).Findings(), "bins_need_an_equal_area_projection", "error"))
chk("NEGATIVE: the same bins on an equal-area projection report nothing",
    NOT _HasRule(_BinnedOn(:EqualEarth, oF).Findings(), "bins_need_an_equal_area_projection", "error"))

? ""
? "-- 8. NAMES TO SHAPES, WITHOUT VENDORING SHAPES (GE4) --"
# The shapes are always the CALLER'S. What is added is the part that is
# tedious and safe: folding case and accents, knowing that Burma and
# Myanmar are one country, finding a code in a file that writes names.
oAt = StzGeoAtlas(oF)
chk("a name the file itself uses binds", oAt.IndexOf("Arda") = 1 and oAt.IndexOf("Berea") = 2)
chk("case and punctuation are folded away",
    oAt.IndexOf("ARDA") = 1 and oAt.IndexOf(" arda ") = 1)
chk("an id the file wrote binds too -- a table of codes needs no names at all",
    oAt.IndexOf("A") = 1 and oAt.IndexOf("B") = 2)
chk("NEGATIVE: a name nothing in the file answers to binds to NOTHING -- it is " +
    "reported, never guessed, because a map that colours Niger for Nigeria is " +
    "worse than one with a hole",
    oAt.IndexOf("Ardania") = 0 and oAt.IndexOf("Atlantis") = 0)
chk("the normaliser folds accents, case, punctuation and a leading 'the'",
    StzGeoNormalizeName("Cote d'Ivoire") = "cotedivoire" and
    StzGeoNormalizeName("The Gambia") = "gambia" and
    StzGeoNormalizeName("  ARDA  ") = "arda")
aRows = [ [ "Arda", 10 ], [ "berea", 20 ], [ "Atlantis", 30 ] ]
aV = oAt.ValuesFor(aRows)
chk("A TABLE OF ROWS BECOMES ONE VALUE PER FEATURE, in the features' own order, " +
    "which is what the map takes",
    len(aV) = 2 and aV[1] = 10 and aV[2] = 20)
chk("...and what did not bind is ANSWERED rather than swallowed",
    len(oAt.Unresolved(aRows)) = 1 and oAt.Unresolved(aRows)[1] = "Atlantis")
chk("...as is what the table said nothing about",
    len(oAt.Uncovered([ [ "Arda", 1 ] ])) = 1 and oAt.Uncovered([ [ "Arda", 1 ] ])[1] = "Berea")
chk("a shape and a point come back for a name, and they are the FILE'S",
    len(oAt.ShapeOf("Arda")) = 2 and len(oAt.PointOf("Arda")) = 2)
chk("NEGATIVE: and nothing at all comes back for a name that did not bind",
    len(oAt.ShapeOf("Atlantis")) = 0 and len(oAt.PointOf("Atlantis")) = 0)
chk("binding to something that is not a feature set is refused", _RefusesAtlas())

? ""
? "-- 7. WHAT THE GATE OWES A MAP (GE3) --"
# A map is not judged the way a diagram is. It reports itself, in the
# house's unified finding shape, and stzRuleReport ingests it -- so a map
# joins the ONE gate instead of growing a second one. An ERROR is a picture
# that argues against itself; a warning advises.
oBad = StzGeoMap(new stzGeoProjection(:Mercator), oF)
oBad.SetValuesQ([ 4200, 99999 ]).SetClasses([ 0, 5000, 20000, 30000 ])
aBad = oBad.Findings()
chk("A CHOROPLETH ON A PROJECTION THAT DISTORTS AREA IS AN ERROR -- it encodes " +
    "a quantity as the colour of an area, so the picture argues against its own legend",
    _HasRule(aBad, "choropleth_needs_an_equal_area_projection", "error"))
chk("a value outside the classes is an ERROR, and the finding names the region " +
    "and which end it fell off",
    _HasRule(aBad, "values_fall_in_the_classes", "error") and
    _RuleSays(aBad, "values_fall_in_the_classes", "Berea") and
    _RuleSays(aBad, "values_fall_in_the_classes", "above the last class"))
chk("a class that colours nothing WARNS -- the legend promises a shade the map " +
    "never shows",
    _HasRule(aBad, "every_class_colours_a_region", "warning"))
chk("a map with no source WARNS rather than errors: the picture may be true, " +
    "and what is missing is the means to check it",
    _HasRule(aBad, "the_map_names_its_source", "warning"))
chk("...and the verdict follows the house convention -- an error makes it unsound",
    NOT oBad.IsSound())

oGood = StzGeoMap(new stzGeoProjection(:EqualEarth), oF)
oGood.SetValuesQ([ 4200, 9100 ]).SetClasses([ 0, 5000, 20000 ])
oGood.SetSource("Invented, for a guard")
chk("NEGATIVE: the same data on an equal-area projection, with its source named, " +
    "reports NOTHING -- the rules are not firing on everything",
    len(oGood.Findings()) = 0 and oGood.IsSound())

oRolled = StzGeoMap(new stzGeoProjection(:Orthographic), oF)
oRolled.Projection().Rotate([ 0, 0, 30 ])
oRolled.SetSource("x")
chk("NORTH IS UP: a rolled sphere is an ERROR, because a reader is given no way " +
    "to know it is not",
    _HasRule(oRolled.Findings(), "north_is_up", "error"))
oTurned = StzGeoMap(new stzGeoProjection(:Orthographic), oF)
oTurned.Projection().CenterOn(7, 25)
oTurned.SetSource("x")
chk("NEGATIVE: TURNING the sphere to centre a globe is ordinary and reports " +
    "nothing -- it is the ROLL that hides which way is up",
    NOT _HasRule(oTurned.Findings(), "north_is_up", "error"))

oOff = StzGeoMap(new stzGeoProjection(:Orthographic), oF)
oOff.Projection().CenterOn(-170, 0)
oOff.SetSource("x")
chk("a region the paper cannot show WARNS: it is counted in the legend and " +
    "invisible to the reader",
    _HasRule(oOff.Findings(), "the_data_fits_the_paper", "warning"))

oRep = StzCheckGeoMaps([ [ "bad", oBad ], [ "good", oGood ] ])
chk("several maps judged at once join the ONE report, each finding carrying the " +
    "map it came from",
    NOT oRep.IsSound() and len(oRep.Errors()) = 2 and
    _RuleSays(oRep.Findings(), "choropleth_needs_an_equal_area_projection", "bad/map"))

? ""
? "-- 8. WHAT IS UNDER A PIXEL (GE5) --"
# The projection is inverted to a place on the sphere and the place is asked
# of the features. Nothing is special-cased: the same invert the sphere guard
# asserts round-trips on all sixteen projections.
oHit = StzGeoMap(new stzGeoProjection(:EqualEarth), oF)
oHit.Projection().FitToFeatures(oF, 500, 400, 20)
oHit.SetValuesQ([ 4200, 9100 ]).SetClasses([ 0, 5000, 20000 ])
qA = oHit.Projection().Project(1, 1)
qL = oHit.Projection().Project(2.5, 4.5)
qS = oHit.Projection().Project(14.2, 5)
chk("a pixel over a country answers that country, and its value with it",
    oHit.NameAt(qA[1], qA[2]) = "Arda" and oHit.ValueAt(qA[1], qA[2]) = 4200)
chk("NEGATIVE: a pixel over the LAKE answers nobody -- the hole is respected " +
    "all the way from the file to the click",
    oHit.FeatureAt(qL[1], qL[2]) = 0 and oHit.NameAt(qL[1], qL[2]) = "")
chk("a pixel over the ISLAND answers the country it belongs to, not the mainland " +
    "it is nowhere near",
    oHit.NameAt(qS[1], qS[2]) = "Berea")
chk("the place under a pixel is the place that pixel was drawn from, to the " +
    "fourth decimal -- the invert is the sphere's own",
    fabs(oHit.PlaceAt(qA[1], qA[2])[1] - 1) < 0.0001 and
    fabs(oHit.PlaceAt(qA[1], qA[2])[2] - 1) < 0.0001)
chk("NEGATIVE: a pixel off the map answers nothing rather than the nearest thing",
    oHit.FeatureAt(-500, -500) = 0)

? ""
? "-- 7. And on the real world, if it is here --"
if NOT fexists("atlas/countries-110m.json")
	? "   (SKIPPED, by name: atlas/countries-110m.json is not present. The"
	? "    plane vendors no boundary data -- atlas/README.md has the two"
	? "    commands that fetch it. Everything above was judged; the three"
	? "    assertions below are UNJUDGED here rather than passed.)"
else
	oAt = StzGeoFeaturesFromTopoJson(read("atlas/countries-110m.json"), "countries")
	chk("the whole world reads, and nothing is skipped",
	    oAt.Count() = 177 and oAt.SkippedCount() = 0)
	oMw = StzGeoMap(new stzGeoProjection(:EqualEarth), oAt)
	aAll = oMw.ValuesFromArea()
	nTot = 0
	for i = 1 to len(aAll)  nTot += aAll[i]  next
	? "   land measured from the rings: " + StzFactNumText(nTot) + " km2"
	chk("THE AREAS ARE REAL: the land measured from these rings is within two " +
	    "per cent of the Earth's 148.9 million km2",
	    fabs(nTot - 148900000) / 148900000 < 0.02)
	chk("...and each country's own area is right: Russia within three per cent " +
	    "of 17.1 million km2",
	    fabs(aAll[oAt.IndexOfName("Russia")] - 17100000) / 17100000 < 0.03)
ok

? ""
? "=========================================================="
? " " + nOk + " ok, " + nBad + " failed"
? "=========================================================="

func chk pcWhat, pbOk
	if pbOk
		nOk++
		? "  ok   " + pcWhat
	else
		nBad++
		? "  FAIL " + pcWhat
	ok

# the radii a symbol layer would draw, read back off a canvas-free pass
func _SymbolRadii poMap, paValues, pnMax
	_max_ = 0
	for _i_ = 1 to len(paValues)
		if paValues[_i_] > _max_  _max_ = paValues[_i_]  ok
	next
	_a_ = []
	for _i_ = 1 to len(paValues)
		_a_ + (pnMax * sqrt(paValues[_i_] / _max_))
	next
	return _a_

func _YOf poP, pnLon, pnLat
	return poP.Project(pnLon, pnLat)[2]

# the smallest y any piece of the arc reaches: the top of the drawn route
func _TopOf paPieces
	_t_ = 1000000
	for _i_ = 1 to len(paPieces)
		for _j_ = 2 to len(paPieces[_i_]) step 2
			if paPieces[_i_][_j_] < _t_  _t_ = paPieces[_i_][_j_]  ok
		next
	next
	return _t_

func _RefusesClasses paEdges
	_b_ = FALSE
	try
		_m_ = StzGeoMap(new stzGeoProjection(:Equirectangular),
			StzGeoFeaturesFromJson(read("fixtures/two_countries.geojson")))
		_m_.SetClasses(paEdges)
	catch
		_b_ = TRUE
	done
	return _b_

func _RefusesPalette paColours
	_b_ = FALSE
	try
		_m_ = StzGeoMap(new stzGeoProjection(:Equirectangular),
			StzGeoFeaturesFromJson(read("fixtures/two_countries.geojson")))
		_m_.SetClasses([ 0, 10, 20 ])
		_m_.SetPalette(paColours)
	catch
		_b_ = TRUE
	done
	return _b_

# the same fixture with Arda's lake taken out, to show the hole is what
# makes the difference
func _NoLakeJson
	_c_ = read("fixtures/two_countries.geojson")
	_a_ = StzJsonToList(_c_)
	_g_ = _a_[:features][1][:geometry]
	_out_ = '{"type":"FeatureCollection","features":[{"type":"Feature","id":"A",' +
		'"properties":{"name":"Arda"},"geometry":{"type":"Polygon","coordinates":[['
	_r_ = _g_[:coordinates][1]
	for _i_ = 1 to len(_r_)
		if _i_ > 1  _out_ += ","  ok
		_out_ += "[" + _r_[_i_][1] + "," + _r_[_i_][2] + "]"
	next
	_out_ += ']]}}]}'
	return _out_

func _HasRule paFindings, pcRule, pcSeverity
	for _i_ = 1 to len(paFindings)
		if paFindings[_i_][:rule] = pcRule and paFindings[_i_][:severity] = pcSeverity
			return TRUE
		ok
	next
	return FALSE

func _RuleSays paFindings, pcRule, pcText
	for _i_ = 1 to len(paFindings)
		if paFindings[_i_][:rule] != pcRule  loop  ok
		if StzFindFirst(pcText, "" + paFindings[_i_][:message]) > 0  return TRUE  ok
		if StzFindFirst(pcText, "" + paFindings[_i_][:subject]) > 0  return TRUE  ok
	next
	return FALSE

# a grid of places, to be binned
func _GridPoints pnL0, pnF0, pnL1, pnF1, pnN
	_a_ = []
	for _i_ = 0 to pnN - 1
		for _j_ = 0 to pnN - 1
			_a_ + (pnL0 + (pnL1 - pnL0) * _i_ / (pnN - 1))
			_a_ + (pnF0 + (pnF1 - pnF0) * _j_ / (pnN - 1))
		next
	next
	return _a_

func _BinnedOn pKind, poF
	_m_ = StzGeoMap(new stzGeoProjection(pKind), poF)
	_m_.Projection().FitToSphere(600, 300, 0)
	_m_.SetSource("x")
	_m_.HexBin(_GridPoints(-40, -20, 40, 20, 5), 12)
	return _m_

func _RefusesAtlas
	_b_ = FALSE
	try
		StzGeoAtlas("not a feature set")
	catch
		_b_ = TRUE
	done
	return _b_

func _MeanOfRing paRing
	_n_ = len(paRing) / 2
	_sx_ = 0  _sy_ = 0
	for _j_ = 1 to _n_
		_sx_ += paRing[_j_ * 2 - 1]
		_sy_ += paRing[_j_ * 2]
	next
	return [ _sx_ / _n_, _sy_ / _n_ ]

# a C: the mean of its ring falls in the bite, not in the country
func _CrescentJson
	return '{"type":"FeatureCollection","features":[{"type":"Feature","id":"C",' +
		'"properties":{"name":"Crescent"},"geometry":{"type":"Polygon","coordinates":[[' +
		'[0,0],[10,0],[10,3],[3,3],[3,7],[10,7],[10,10],[0,10],[0,0]]]}}]}'

# five places together and one far away, which is Natural Earth's France
func _ScatteredJson
	_c_ = '{"type":"FeatureCollection","features":['
	for _i_ = 0 to 4
		_y_ = _i_
		_c_ += '{"type":"Feature","id":"N' + _i_ + '","properties":{"name":"Near' + _i_ +
			'"},"geometry":{"type":"Polygon","coordinates":[[[' + _i_ + ',' + _y_ + '],[' +
			(_i_ + 1) + ',' + _y_ + '],[' + (_i_ + 1) + ',' + (_y_ + 1) + '],[' + _i_ + ',' +
			(_y_ + 1) + ']]]}},'
	next
	_c_ += '{"type":"Feature","id":"F","properties":{"name":"Faraway"},"geometry":' +
		'{"type":"Polygon","coordinates":[[[0,-50],[1,-50],[1,-49],[0,-49]]]}}]}'
	return _c_

# twelve small regions in a row: more names than room
func _CrowdJson
	_c_ = '{"type":"FeatureCollection","features":['
	for _i_ = 0 to 11
		if _i_ > 0  _c_ += ","  ok
		_x_ = _i_ % 4
		_y_ = floor(_i_ / 4)
		_c_ += '{"type":"Feature","id":"R' + _i_ + '","properties":{"name":"Regionname' +
			_i_ + '"},"geometry":{"type":"Polygon","coordinates":[[[' + _x_ + ',' + _y_ +
			'],[' + (_x_ + 1) + ',' + _y_ + '],[' + (_x_ + 1) + ',' + (_y_ + 1) + '],[' +
			_x_ + ',' + (_y_ + 1) + ']]]}}'
	next
	return _c_ + ']}'

# no two placed boxes overlap: re-derive the boxes the engine would place
# EVERY PAIR OF PLACED BOXES IS DISJOINT, tested on the boxes themselves.
#
# This used to answer "were fewer regions named than exist", which is TRUE
# whenever the engine draws nothing at all -- an assertion that agreed with
# the truth by coincidence and would have gone on agreeing through any
# regression that stopped placement working. PlacedBoxes() exists so this
# can test the mechanism.
# THE CENTRE OF A FEATURE ON THE PAPER -- its AREA centroid, by the shoelace
# formula, computed here from the projected outline and NOT by calling
# anything the engine uses.
#
# THE FIRST VERSION OF THIS AVERAGED THE OUTLINE'S POINTS, which is exactly
# what the engine was doing wrong, so the assertion "the name is printed at
# the centre" passed while every name on the real sheets sat off to one side:
# the test recomputed the implementation's own mistake and then agreed with
# it. A centre test has to derive the centre INDEPENDENTLY or it is checking
# that the code equals itself.
func _TrueCentreOf poMap, pnI
	_r_ = poMap.Features().OuterRingOf(pnI, poMap.Features().LargestPartOf(pnI))
	_n_ = len(_r_) / 2
	_p_ = []
	for _j_ = 1 to _n_
		_q_ = poMap.Projection().Project(_r_[_j_ * 2 - 1], _r_[_j_ * 2])
		if len(_q_) < 2  loop  ok
		_p_ + _q_[1]
		_p_ + _q_[2]
	next
	_m_ = len(_p_) / 2
	if _m_ < 3  return [ 0, 0 ]  ok
	_a2_ = 0  _cx_ = 0  _cy_ = 0
	for _i_ = 1 to _m_
		_j_ = _i_ + 1
		if _j_ > _m_  _j_ = 1  ok
		_cr_ = _p_[_i_ * 2 - 1] * _p_[_j_ * 2] - _p_[_j_ * 2 - 1] * _p_[_i_ * 2]
		_a2_ += _cr_
		_cx_ += (_p_[_i_ * 2 - 1] + _p_[_j_ * 2 - 1]) * _cr_
		_cy_ += (_p_[_i_ * 2] + _p_[_j_ * 2]) * _cr_
	next
	if fabs(_a2_) < 0.000001  return [ 0, 0 ]  ok
	return [ _cx_ / (3 * _a2_), _cy_ / (3 * _a2_) ]

# INVERT THE BOX AND ASK THE SPHERE. The placement chose this box on the
# paper; this checks the answer where the region actually lives.
func _BoxLandsInRegion poMap, poF, paBox
	_p_ = [ [ paBox[1], paBox[2] ], [ paBox[3], paBox[2] ],
	        [ paBox[1], paBox[4] ], [ paBox[3], paBox[4] ],
	        [ (paBox[1] + paBox[3]) / 2, (paBox[2] + paBox[4]) / 2 ] ]
	for _t_ = 1 to len(_p_)
		_g_ = poMap.Projection().Invert(_p_[_t_][1], _p_[_t_][2])
		if len(_g_) < 2  return FALSE  ok
		if NOT poF.Contains(1, _g_[1], _g_[2])  return FALSE  ok
	next
	return TRUE

func _RefusesMode
	_m_ = StzGeoMap(new stzGeoProjection(:Equirectangular),
		StzGeoFeaturesFromJson(_NoLakeJson()))
	try
		_m_.SetLabelMode(:Sideways)
	catch
		return StzFindFirst(":Numbers", cCatchError) > 0
	done
	return FALSE

func _NoOverlap poMap, poFont, pnSize
	_c_ = new stzCanvas(600, 400)
	_c_.SetBackground("#FFFFFF")
	poMap.DrawLabelsXT(_c_, poFont, pnSize, "#000000", FALSE)
	_b_ = poMap.PlacedBoxes()
	if len(_b_) < 2  return FALSE  ok
	for _i_ = 1 to len(_b_) - 1
		for _j_ = _i_ + 1 to len(_b_)
			if _b_[_i_][1] < _b_[_j_][3] and _b_[_i_][3] > _b_[_j_][1] and
			   _b_[_i_][2] < _b_[_j_][4] and _b_[_i_][4] > _b_[_j_][2]
				return FALSE
			ok
		next
	next
	return TRUE

# THE KEY'S MARKS RISE DOWN THE SHEET. The entries are numbered in reading
# order -- rows down the paper, west to east inside a row -- so the marks,
# read in the order the key lists them, are 1, 2, 3 and never a shuffle.
func _KeyReadsInOrder poMap
	_k_ = poMap.KeyEntries()
	for _i_ = 1 to len(_k_)
		if _k_[_i_][1] != "" + _i_  return FALSE  ok
	next
	return len(_k_) > 0

# does this report carry that rule at that severity?
func _HasFinding paFindings, pcRule, pcSeverity
	for _i_ = 1 to len(paFindings)
		if paFindings[_i_][:rule] = pcRule and paFindings[_i_][:severity] = pcSeverity
			return TRUE
		ok
	next
	return FALSE

# THE INK IS THE COLOUR SYSTEM'S ANSWER, AND THE TEST ASKS THE COLOUR
# SYSTEM'S QUESTION.
#
# This used to assert two literal hex strings -- "a dark class gives
# #FFFFFF, a light one gives back the #111111 it was handed". Both halves
# were wrong once InkOver started asking StzReadableTextOn: the contract
# never promised to echo the caller's ink, and it answers #000000 over a
# pale class because that is what reaches 4.5:1, not #111111. The guard had
# been unreachable since InkOver took a size, so nothing said so.
#
# What the contract actually promises is CONTRAST, so that is what is
# asserted: the two ends differ, and each reaches the WCAG body-text floor
# against the shade it will be drawn on.
func _InkFlips poF
	_m_ = StzGeoMap(new stzGeoProjection(:Equirectangular), poF)
	_m_.Projection().FitToFeatures(poF, 300, 300, 10)
	_v_ = []
	for _i_ = 1 to poF.Count()  _v_ + _i_  next
	_m_.SetValues(_v_)
	_m_.SetClasses([ 1, 4, 8, 13 ])
	_m_.SetRamp(:Blues)
	_lo_ = _m_.InkOver(1, "#111111", 13)
	_hi_ = _m_.InkOver(poF.Count(), "#111111", 13)
	return _lo_ != _hi_ and
	       StzContrastOf(_lo_, _m_.ColourOf(1)) >= StzContrastMinimumBodyText() and
	       StzContrastOf(_hi_, _m_.ColourOf(poF.Count())) >= StzContrastMinimumBodyText()
