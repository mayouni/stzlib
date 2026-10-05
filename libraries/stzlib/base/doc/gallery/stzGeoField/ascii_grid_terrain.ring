# stzGeoField: an ESRI ASCII grid (written here, invented: two hills and a hole of NODATA) read by
# StzGeoFieldFromAsciiGrid, then shown three ways -- the raster (DrawOn), its contours (DrawContoursOn) and the
# raster clipped to Niger (SetClipTo). The NODATA nodes read as unknown, never as a depth of -9999.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoField/ascii_grid_terrain.ring
load "../../stzBase.ring"
decimals(1)
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oN = StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson"))

# an ESRI ASCII grid: 40 x 30 cells of 0.5 degree from (0 E, 11 N); the first text row is the NORTH row
nC = 40
nR = 30
cTxt = "ncols " + nC + char(10) + "nrows " + nR + char(10) + "xllcorner 0" + char(10) + "yllcorner 11" + char(10) +
       "cellsize 0.5" + char(10) + "NODATA_value -9999" + char(10)
for r = nR - 1 to 0 step -1
	cRow = ""
	for c = 0 to nC - 1
		nLon = 0.25 + c * 0.5
		nLat = 11.25 + r * 0.5
		nZ = 220 + 700 * exp(-((nLon - 6) * (nLon - 6) + (nLat - 17) * (nLat - 17)) / 6) + 450 * exp(-((nLon - 13) * (nLon - 13) + (nLat - 14) * (nLat - 14)) / 4)
		if nLon > 9 and nLon < 11 and nLat > 19 and nLat < 21  nZ = -9999  ok
		cRow += "" + floor(nZ) + " "
	next
	cTxt += cRow + char(10)
next
oF = StzGeoFieldFromAsciiGrid(cTxt)
aS = oF.Stats()
? "grid " + @@( oF.Grid() ) + " stats " + @@( aS ) + " source " + oF.Source()
oF.SetUnit("metres")
oF.SetClassesEvery(6)
oF.SetRamp(:Earth)
aLev = oF.LevelsEvery(5)
? "findings " + @@( oF.Findings() ) + ", value at (6, 17): " + oF.ValueAt(6, 17) + ", at the hole (10, 20): [" + oF.ValueAt(10, 20) + "]"

oC = new stzCanvas(1000, 440)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("An ASCII grid, with a NODATA hole, read three ways", 20, 32).Fill("#111111")
oC.Flush()
aT = [ "the raster", "five contour levels", "clipped to Niger" ]
for m = 1 to 3
	nX0 = 10 + (m - 1) * 330
	oP = new stzGeoProjection(:Equirectangular)
	oP.FitPointsIn([ 0, 11, 20, 26 ], nX0 + 8, 90, nX0 + 312, 280, 2)
	if m = 1
		oF.DrawOn(oC, oP, nX0 + 8, 90, nX0 + 312, 280)
	but m = 2
		oP.DrawFeaturesOn(oC, oN, "#F4F4F4", "#BBBBBB", 0.5)
		oF.DrawContoursOn(oC, oP, aLev, "#7B4A12", 1.2)
	else
		oF.SetClipTo(oN)
		oF.DrawOn(oC, oP, nX0 + 8, 90, nX0 + 312, 280)
		oP.DrawFeaturesOn(oC, oN, "#00000000", "#FFFFFF", 0.6)
	ok
	oC.SetFontQ(oBold, 15).AddTextQ(aT[m], nX0 + 8, 76).Fill("#111111")
	oC.Flush()
next
oF.DrawLegendOn(oC, oFont, 20, 310, "")
oC.SetFontQ(oFont, 13).AddTextQ("invented relief; the white square in the raster is nine nodes of NODATA", 330, 330).Fill("#555555")
oC.Flush()
chdir("../../doc/gallery/stzGeoField")
oC.ToPNGXT("ascii_grid_terrain.png", 9)
? "-> ascii_grid_terrain.png"
