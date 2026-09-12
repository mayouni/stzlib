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
	_a_ = JsonToList(StzJsonAsciiSafe(_c_))
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
