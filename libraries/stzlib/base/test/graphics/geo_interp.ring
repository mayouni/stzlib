load "../../stzBase.ring"
decimals(2)

# GE7c -- HOW MUCH RAIN FELL WHERE THERE IS NO GAUGE? Seventy invented
# stations over Tunisia, and the four things an analyst does with them.
#
#   1. THE GAUGES. Seventy numbers at seventy places. Every method below is
#      a way of not stopping here.
#   2. IDW. Every gauge votes with a weight of 1/d^2. No model, no
#      assumption, and no answer to "how wrong is this". Look for the
#      bullseyes: IDW cannot help making a little crater at each station.
#   3. THE VARIOGRAM, which is the panel almost nobody draws and the reason
#      the fourth is not guesswork. Half the mean squared difference of
#      every pair against how far apart they are: the cloud rises to a
#      plateau, and where it flattens is the distance beyond which two
#      stations tell you nothing about each other.
#   4. ORDINARY KRIGING -- and its VARIANCE, side by side, because that is
#      the only honest way to publish one. The estimate is smooth and
#      bullseye-free; the variance is near zero at every station and climbs
#      in the gaps, which is the map that says which parts of the pretty
#      picture nobody should act on.
#
# THE VARIANCE PANEL DOES NOT KNOW THE RAINFALL. Multiply every reading by
# ten and it does not move a pixel: it is a function of where the stations
# are and of the variogram, and of nothing else. That is worth a panel.

if NOT fexists("atlas/admin1_tunisia.geojson")
	? "SKIPPED, by name: atlas/admin1_tunisia.geojson is not present -- see atlas/README.md."
	return
ok

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oU = StzGeoFeaturesFromJson(read("atlas/admin1_tunisia.geojson"))
oWin = StzGeoPoints([], oU)
nSeed = 20260914

# SEVENTY STATIONS, reading an invented rainfall: wet in the north-west,
# dry in the south, with a coastal band -- the shape Tunisia's rainfall
# actually has, which is why the picture looks like something.
aPlaces = oWin.Sample(70, nSeed)
aGauges = []
for i = 1 to len(aPlaces) / 2
	x = aPlaces[i * 2 - 1]
	y = aPlaces[i * 2]
	aGauges + x  aGauges + y  aGauges + _Rain(x, y)
next
oS = StzGeoSamples(aGauges, oU)
aFit = oS.FitAndUse(:Best)
aBins = oS.Variogram(12, 0)
aCv = oS.CrossValidate()

oIdw = oS.IDWField(6, 2)
aK = oS.KrigeFields(6)
oEst = aK[1]
oVar = aK[2]

# ONE SCALE FOR BOTH ESTIMATES, so the two panels can be compared by eye.
# Two maps of the same quantity on two scales is the oldest way to make a
# difference appear or vanish at will.
nLo = oS.MinValue()
nHi = oS.MaxValue()
aEdges = []
for i = 0 to 6  aEdges + (nLo + (nHi - nLo) * i / 6)  next
oIdw.SetClasses(aEdges)  oIdw.SetRamp(:YlGnBu)
oEst.SetClasses(aEdges)  oEst.SetRamp(:YlGnBu)
oVar.SetClassesEvery(6)  oVar.SetRamp(:Purples)

oC = new stzCanvas(1240, 1000)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oFont, 23).AddTextQ("How much rain fell where there is no gauge? " +
	oS.Count() + " stations, four answers", 30, 44).Fill("#111111")

aPanel = [ [ "The stations", "readings, and nothing between them" ],
           [ "IDW, power 2", "no model, and no doubt either" ],
           [ "Kriging: the estimate", "unbiased, for the variogram below" ],
           [ "Kriging: the VARIANCE", "where the estimate is guesswork" ] ]

for m = 1 to 4
	nX0 = 15 + (m - 1) * 307
	oP = StzGeoConicFor(oU, :ConicEqualArea)
	oP.FitFeaturesIn(oU, nX0 + 45, 130, nX0 + 250, 560, 6)
	oM = StzGeoMap(oP, oU)
	oM.SetPaper(nX0, 120, nX0 + 295, 575)

	if m = 1
		oM.DrawRegionsOn(oC, "#FFFFFF", 0.6)
		for i = 1 to oS.Count()
			q = oP.Project(aGauges[i * 3 - 2], aGauges[i * 3 - 1])
			if len(q) = 2
				oC.AddCircleQ(q[1], q[2], 3.4).FillQ(_Shade(aGauges[i * 3], nLo, nHi)).Stroke("#33333388", 0.7)
			ok
		next
	but m = 2
		oIdw.DrawXT(oC, oP, nX0 + 10, 125, nX0 + 285, 570, 250)
	but m = 3
		oEst.DrawXT(oC, oP, nX0 + 10, 125, nX0 + 285, 570, 250)
	else
		oVar.DrawXT(oC, oP, nX0 + 10, 125, nX0 + 285, 570, 250)
		# the stations on top of the variance, because the whole point is
		# that the low ground is exactly where they stand
		for i = 1 to oS.Count()
			q = oP.Project(aGauges[i * 3 - 2], aGauges[i * 3 - 1])
			if len(q) = 2  oC.AddCircleQ(q[1], q[2], 1.6).FillQ("#222222").Stroke("#00000000", 0)  ok
		next
	ok
	oC.Flush()
	oC.SetFontQ(oFont, 16).AddTextQ(aPanel[m][1], nX0 + 8, 84).Fill("#111111")
	oC.SetFontQ(oFont, 12).AddTextQ(aPanel[m][2], nX0 + 8, 102).Fill("#777777")
next

# ---- the variogram, drawn where a geostatistician expects it -----------
_DrawVariogram(oC, oFont, oS, aBins, aFit, 70, 660, 420, 210)

oC.SetFontQ(oFont, 14).AddTextQ("Fitted: " + aFit[:model] + " -- nugget " +
	StzFactNumText(aFit[:nugget]) + ", sill " + StzFactNumText(aFit[:nugget] + aFit[:sill]) +
	", range " + StzFactNumText(aFit[:range]) + " km", 560, 676).Fill("#111111")
oC.SetFontQ(oFont, 13).AddTextQ("The range is the distance beyond which two stations " +
	"tell you nothing about each other. Everything", 560, 702).Fill("#555555")
oC.SetFontQ(oFont, 13).AddTextQ("the kriging panels do is read off this curve.", 560, 720).Fill("#555555")
oC.SetFontQ(oFont, 13).AddTextQ("Leave-one-out cross-validation: bias " +
	StzFactNumText(aCv[:bias]) + " mm, RMSE " + StzFactNumText(aCv[:rmse]) +
	" mm, against a spread of " + StzFactNumText(nHi - nLo) + " mm.", 560, 752).Fill("#555555")

oEst.DrawLegendOn(oC, oFont, 560, 784, "rainfall, mm -- the scale of BOTH estimate panels")
oVar.DrawLegendOn(oC, oFont, 880, 784, "kriging variance")

oC.SetFontQ(oFont, 13).AddTextQ("The variance panel does not know the rainfall: multiply " +
	"every reading by ten and it does not move a pixel. It is a function of where the", 30, 950).Fill("#777777")
oC.SetFontQ(oFont, 13).AddTextQ("stations are and of the variogram, and of nothing else.   " +
	"Natural Earth 1:10m; the stations and their readings are INVENTED.", 30, 970).Fill("#777777")
oC.Flush()
oC.ToPNG("geo_interp.png")

? "" + oS.Count() + " stations, readings " + StzFactNumText(nLo) + " to " + StzFactNumText(nHi) + " mm"
? "   variogram: " + len(aBins) + " lags; best fit " + aFit[:model] + ", nugget " +
	StzFactNumText(aFit[:nugget]) + ", sill " + StzFactNumText(aFit[:sill]) +
	", range " + StzFactNumText(aFit[:range]) + " km"
? "   cross-validation: bias " + StzFactNumText(aCv[:bias]) + ", rmse " + StzFactNumText(aCv[:rmse])
? "   kriging variance runs " + StzFactNumText(oVar.Min()) + " to " + StzFactNumText(oVar.Max())
for g in oS.Findings()  ? "   gate: " + g[:severity] + " " + g[:rule]  next
? "-> geo_interp.png"

# AN INVENTED RAINFALL WITH THE SHAPE TUNISIA'S HAS, and with structure at
# more than one scale -- which the first version of this file did not have,
# and the gate said so.
#
# That version was two wide humps over a country 800 km across, so the
# fitted range came out at 825 km, longer than the window's own diagonal,
# and the kriging variance collapsed to zero everywhere: a field that
# smooth is perfectly predictable from any few points, and the variance
# panel went blank. the_range_is_inside_the_data fired, correctly, on the
# DEMO's data rather than on the engine. Real rainfall has a regional
# gradient AND weather at a hundred kilometres; this has both.
func _Rain pnLon, pnLat
	# the regional picture: wet north-west, drier south
	_r_ = 120 + 150 * exp(-(pow(pnLon - 8.8, 2) * 1.4 + pow(pnLat - 36.6, 2) * 0.9) / 3.2)
	# and weather at about a hundred kilometres. THE BALANCE WAS MEASURED,
	# not chosen: at a regional amplitude of 300 against 55 the fitted range
	# came out at 617 km with the gate warning; at 150 against 110 it is
	# 76 km, the nugget is zero and the gate reports nothing. A field whose
	# trend dominates has no sill inside its own window -- that is a real
	# situation, and it wants universal kriging rather than this.
	_r_ += 110 * sin(pnLon * 3.1 + 0.7) * cos(pnLat * 2.6 - 0.4)
	_r_ += 60 * sin(pnLat * 4.3 + 1.9)
	if _r_ < 40  _r_ = 40  ok
	return _r_

func _Shade pnV, pnLo, pnHi
	_a_ = StzGeoRamp(:YlGnBu, 6)
	_k_ = floor((pnV - pnLo) / (pnHi - pnLo) * 6) + 1
	if _k_ < 1  _k_ = 1  ok
	if _k_ > 6  _k_ = 6  ok
	return _a_[_k_]

# THE CLOUD AND THE CURVE FITTED TO IT. The dots are what the data says;
# the line is the model kriging will use. A reader who can see both can
# judge the fit, which is the entire purpose of showing it.
func _DrawVariogram poC, poFont, poS, paBins, paFit, pnX, pnY, pnW, pnH
	_hmax_ = paBins[len(paBins)][1] * 1.05
	_gmax_ = 0
	for _i_ = 1 to len(paBins)
		if paBins[_i_][2] > _gmax_  _gmax_ = paBins[_i_][2]  ok
	next
	_sill_ = paFit[:nugget] + paFit[:sill]
	if _sill_ > _gmax_  _gmax_ = _sill_  ok
	_gmax_ *= 1.15

	# the sill and the range, named on the picture
	_ys_ = pnY + pnH - pnH * _sill_ / _gmax_
	poC.AddLineQ(pnX, _ys_, pnX + pnW, _ys_).Stroke("#BBBBBB", 1)
	poC.SetFontQ(poFont, 11).AddTextQ("sill", pnX + pnW - 24, _ys_ - 4).Fill("#888888")
	if paFit[:range] < _hmax_
		_xr_ = pnX + pnW * paFit[:range] / _hmax_
		poC.AddLineQ(_xr_, pnY, _xr_, pnY + pnH).Stroke("#BBBBBB", 1)
		poC.SetFontQ(poFont, 11).AddTextQ("range", _xr_ + 4, pnY + 12).Fill("#888888")
	ok

	# the fitted curve
	_line_ = []
	for _k_ = 0 to 80
		_h_ = _hmax_ * _k_ / 80
		_line_ + (pnX + pnW * _h_ / _hmax_)
		_line_ + (pnY + pnH - pnH * poS.GammaAt(_h_) / _gmax_)
	next
	poC.AddPolylineQ(_line_).Stroke("#A93226", 2)

	# the cloud, each dot sized by how many pairs it rests on
	for _i_ = 1 to len(paBins)
		_x_ = pnX + pnW * paBins[_i_][1] / _hmax_
		_y_ = pnY + pnH - pnH * paBins[_i_][2] / _gmax_
		_r_ = 2.2 + sqrt(paBins[_i_][3]) / 7
		if _r_ > 7  _r_ = 7  ok
		poC.AddCircleQ(_x_, _y_, _r_).FillQ("#1B4F72CC").Stroke("#FFFFFF", 0.8)
	next

	poC.AddLineQ(pnX, pnY, pnX, pnY + pnH).Stroke("#444444", 1)
	poC.AddLineQ(pnX, pnY + pnH, pnX + pnW, pnY + pnH).Stroke("#444444", 1)
	poC.SetFontQ(poFont, 12).AddTextQ("distance between two stations, km", pnX + pnW - 190, pnY + pnH + 30).Fill("#555555")
	poC.SetFontQ(poFont, 12).AddTextQ("gamma(h)", pnX + pnW - 62, pnY + 14).Fill("#555555")
	poC.SetFontQ(poFont, 16).AddTextQ("The variogram", pnX - 40, pnY - 34).Fill("#111111")
	poC.SetFontQ(poFont, 12).AddTextQ("each dot is a lag bin, sized by the pairs it rests on",
		pnX - 40, pnY - 16).Fill("#777777")
	poC.SetFontQ(poFont, 11).AddTextQ("0", pnX - 8, pnY + pnH + 14).Fill("#777777")
	poC.SetFontQ(poFont, 11).AddTextQ("" + floor(_hmax_), pnX + pnW - 14, pnY + pnH + 14).Fill("#777777")
	poC.Flush()
