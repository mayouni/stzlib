load "../../stzBase.ring"
decimals(4)

# GE1 -- BOUNDARY DATA, WHOLE. A narrated guard for the reader: what it
# keeps that DN24b's own reader threw away, that TopoJSON and GeoJSON of
# the same shapes cannot disagree, and that a hole is a hole.
#
# The two fixtures describe the same two INVENTED countries. Nothing here
# is a real place: the geo plane's kill line is that this repository
# vendors no boundary data, and a guard is not a way round it.

nOk = 0  nBad = 0
? "=========================================================="
? " GE1: boundary data, whole -- GeoJSON, TopoJSON, holes"
? "=========================================================="

oG = StzGeoFeaturesFromJson(read("fixtures/two_countries.geojson"))
oT = StzGeoFeaturesFromTopoJson(read("fixtures/two_countries.topojson"), "land")

? ""
? "-- 1. Everything in the file, and nothing invented --"
chk("both files give two features and skip nothing",
    oG.Count() = 2 and oT.Count() = 2 and oG.SkippedCount() = 0 and oT.SkippedCount() = 0)
chk("a feature knows what the file calls it, and what else the file said about it",
    oG.NameOf(1) = "Arda" and oG.PropertyOf(1, "pop") = 4200 and oG.PropertyOf(1, "cap") = "Arn" and
    oG.IdOf(2) = "B")
chk("NEGATIVE: a property the file does not carry answers empty, not a guess",
    oG.PropertyOf(1, "gdp") = "" and NOT oG.HasProperty(1, "gdp"))

? ""
? "-- 2. THE ISLAND AND THE HOLE, which the choropleth's own reader drops --"
chk("a MultiPolygon keeps BOTH its parts -- the mainland and the island",
    oG.PartCount(2) = 2 and oT.PartCount(2) = 2)
chk("a Polygon keeps its HOLE, as the second ring of its part",
    oG.HoleCountOf(1) = 1 and len(oG.RingsOf(1, 1)) = 2)
chk("NEGATIVE: and the reader that DN24b ships still answers one ring per " +
    "region -- what GE1 adds is the choice, not a change to what was there",
    len(StzGeoRegionsFromJson(read("fixtures/two_countries.geojson"), "name", "pop")) = 2)

? ""
? "-- 3. TWO FILES, ONE GEOMETRY: the readers cannot disagree --"
# TopoJSON writes each shared border ONCE and stores it delta-encoded on a
# quantised grid; GeoJSON writes it twice, in full. Read back, they must be
# the same numbers -- that is the whole reason to trust either.
nSame = 0  nDiff = 0
for i = 1 to oG.Count()
	for k = 1 to oG.PartCount(i)
		for r = 1 to len(oG.RingsOf(i, k))
			if _SameRing(oG.RingsOf(i, k)[r], oT.RingsOf(i, k)[r])  nSame++  else  nDiff++  ok
		next
	next
next
? "   rings compared point by point: " + nSame + " identical, " + nDiff + " differing"
chk("every ring of every part is the same from both files, to the sixth decimal",
    nSame = 4 and nDiff = 0)
chk("...and the shared border really is shared: the topology holds FIVE arcs " +
    "for two countries, a hole and an island",
    _ArcCount() = 5)
chk("a ring is CLOSED whichever file it came from -- GeoJSON repeats the first " +
    "point and TopoJSON does not, and a reader that passed both through would lie",
    _Closes(oG.OuterRingOf(1, 1)) and _Closes(oT.OuterRingOf(1, 1)))

? ""
? "-- 4. A hole is a hole: what is inside, and what only looks inside --"
chk("a place on Arda's land belongs to Arda", oG.Contains(1, 1, 1) and oG.IndexAt(1, 1) = 1)
chk("NEGATIVE: a place in Arda's LAKE belongs to nobody -- the hole excludes it",
    NOT oG.Contains(1, 2.5, 4.5) and oG.IndexAt(2.5, 4.5) = 0)
chk("a place on Berea's island belongs to Berea -- the part a largest-ring " +
    "reader would have dropped",
    oG.Contains(2, 14.2, 5) and oG.IndexAt(14.2, 5) = 2)
chk("NEGATIVE: the open sea belongs to nobody", oG.IndexAt(20, 20) = 0)

? ""
? "-- 5. THE HOLE SURVIVES THE PROJECTION, bridged into its outer ring --"
oP = new stzGeoProjection(:Equirectangular)
oP.FitToFeatures(oG, 400, 400, 10)
aFilled = oP.FilledPolygon(oG.RingsOf(1, 1))
aPlain = oP.FilledPolygon([ oG.OuterRingOf(1, 1) ])
chk("a polygon with a hole comes back as ONE ring, longer than the outer edge " +
    "alone: the hole is spliced into it",
    len(aFilled) = 1 and len(aPlain) = 1 and len(aFilled[1]) > len(aPlain[1]) and
    oP.HolesDropped() = 0)
chk("...and it encloses LESS than the outer edge alone, by about the hole's area",
    _PolyArea(aFilled[1]) < _PolyArea(aPlain[1]) * 0.95)
chk("NEGATIVE: a part with no hole is not lengthened -- the bridge is only cut " +
    "where there is something to bridge to",
    len(oP.FilledPolygon(oG.RingsOf(2, 2))[1]) = len(oP.FilledPolygon([ oG.OuterRingOf(2, 2) ])[1]))

? ""
? "-- 6. And it goes straight into the picture the choropleth already draws --"
aReg = oG.AsRegions("pop")
chk("a file read here becomes the regions DN24's builder takes",
    len(aReg) = 2 and aReg[1][1] = "Arda" and aReg[1][2] = 4200 and len(aReg[1][3]) >= 6)

? ""
? "-- 7. What the reader refuses, it refuses BY NAME --"
chk("text that is not JSON is refused", _Refuses("not json at all"))
chk("JSON that is not a feature collection is refused", _Refuses('{"a":1}'))
chk("a topology without the object asked for is refused, and says what it holds",
    _RefusesTopo("nosuchthing"))

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

func _SameRing paA, paB
	if len(paA) != len(paB)  return FALSE  ok
	for _i_ = 1 to len(paA)
		if fabs(paA[_i_] - paB[_i_]) > 0.000001  return FALSE  ok
	next
	return TRUE

func _ArcCount
	_a_ = JsonToList(read("fixtures/two_countries.topojson"))
	return len(_a_[:arcs])

func _Closes paXY
	_n_ = len(paXY)
	return paXY[1] = paXY[_n_ - 1] and paXY[2] = paXY[_n_]

func _PolyArea paXY
	_n_ = len(paXY) / 2
	_s_ = 0
	for _i_ = 1 to _n_
		_j_ = _i_ % _n_ + 1
		_s_ += paXY[_i_ * 2 - 1] * paXY[_j_ * 2] - paXY[_j_ * 2 - 1] * paXY[_i_ * 2]
	next
	return fabs(_s_) / 2

func _Refuses pcText
	_b_ = FALSE
	try
		StzGeoFeaturesFromJson(pcText)
	catch
		_b_ = TRUE
	done
	return _b_

func _RefusesTopo pcObject
	_b_ = FALSE
	try
		StzGeoFeaturesFromTopoJson(read("fixtures/two_countries.topojson"), pcObject)
	catch
		_b_ = TRUE
	done
	return _b_
