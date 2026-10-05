# stzGeoEllipsoid: the same measurements on six of the fifteen ellipsoids -- Niamey to Paris (DistanceKm) and the
# area of a one-degree cell at 45 N (AreaKm2) -- drawn as the difference from WGS84 in metres and in square
# kilometres. Flattening and the quarter meridian are printed beside each. A chart, not a map.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoEllipsoid/ellipsoids_compared.ring
load "../../stzBase.ring"
decimals(1)
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
aNames = [ "WGS84", "GRS80", "Airy1830", "Bessel1841", "Clarke1866", "Sphere" ]
oW = new stzGeoEllipsoid("WGS84")
nD0 = oW.DistanceKm(13.5116, 2.1254, 48.8566, 2.3522)
nA0 = oW.AreaKm2([ 0, 45, 1, 45, 1, 46, 0, 46 ])

oC = new stzCanvas(900, 440)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("Six ellipsoids, the same two measurements, as the gap from WGS84", 20, 32).Fill("#111111")
oC.Flush()
oC.SetFontQ(oBold, 14).AddTextQ("ellipsoid", 20, 70).Fill("#555555")
oC.Flush()
oC.SetFontQ(oBold, 14).AddTextQ("1 / flattening", 140, 70).Fill("#555555")
oC.Flush()
oC.SetFontQ(oBold, 14).AddTextQ("quarter meridian km", 260, 70).Fill("#555555")
oC.Flush()
oC.SetFontQ(oBold, 14).AddTextQ("Niamey - Paris: metres from WGS84", 440, 70).Fill("#555555")
oC.Flush()
oC.SetFontQ(oBold, 14).AddTextQ("1-degree cell at 45 N: km2 from WGS84", 440, 250).Fill("#555555")
oC.Flush()
for i = 1 to len(aNames)
	oE = new stzGeoEllipsoid(aNames[i])
	nD = oE.DistanceKm(13.5116, 2.1254, 48.8566, 2.3522)
	nA = oE.AreaKm2([ 0, 45, 1, 45, 1, 46, 0, 46 ])
	y = 100 + (i - 1) * 30
	oC.SetFontQ(oFont, 15).AddTextQ(aNames[i], 20, y).Fill("#111111")
	oC.Flush()
	oC.SetFontQ(oFont, 15).AddTextQ("" + oE.InverseFlattening(), 140, y).Fill("#333333")
	oC.Flush()
	oC.SetFontQ(oFont, 15).AddTextQ("" + oE.QuarterMeridianKm(), 260, y).Fill("#333333")
	oC.Flush()
	# the bars: metres gap of the distance (+-1200 m scale) and km2 gap of the cell (+-20 km2)
	nDm = (nD - nD0) * 1000
	nX0 = 640
	nW = nDm / 1200 * 150
	if nW > 160  nW = 160  ok
	if nW < -160  nW = -160  ok
	if nW >= 0
		oC.AddRectQ(nX0, y - 12, nW, 16).FillQ("#2E86C1")
	else
		oC.AddRectQ(nX0 + nW, y - 12, 0 - nW, 16).FillQ("#C0392B")
	ok
	oC.SetFontQ(oFont, 13).AddTextQ("" + floor(nDm) + " m", 800, y).Fill("#333333")
	oC.Flush()
	nW2 = (nA - nA0) / 20 * 150
	if nW2 > 160  nW2 = 160  ok
	if nW2 < -160  nW2 = -160  ok
	y2 = 280 + (i - 1) * 24
	if nW2 >= 0
		oC.AddRectQ(nX0, y2 - 12, nW2, 14).FillQ("#2E86C1")
	else
		oC.AddRectQ(nX0 + nW2, y2 - 12, 0 - nW2, 14).FillQ("#C0392B")
	ok
	oC.SetFontQ(oFont, 13).AddTextQ(aNames[i] + "  " + (nA - nA0), 440, y2).Fill("#333333")
	oC.Flush()
	? aNames[i] + ": distance " + nD + " km, cell " + nA + " km2, 1/f " + oE.InverseFlattening() + ", quarter meridian " + oE.QuarterMeridianKm()
next
oC.AddLineQ(640, 90, 640, 230).Stroke("#999999", 1)
oC.AddLineQ(640, 262, 640, 420).Stroke("#999999", 1)
oC.SetFontQ(oFont, 13).AddTextQ("blue: larger than WGS84, red: smaller; bars are cut at 160 px: scale 1200 m and 20 km2, the Sphere is off it", 20, 425).Fill("#555555")
oC.Flush()
chdir("../../doc/gallery/stzGeoEllipsoid")
oC.ToPNGXT("ellipsoids_compared.png", 9)
? "-> ellipsoids_compared.png"
