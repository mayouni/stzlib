# stzGeoProjection: six ways to flatten the Earth, each with the land, a graticule and Tissot's circles
# (DrawTissotOn), captioned with what Distortion() measures: the mean area scale and the mean angle bent.
# Needs the world atlas (test/graphics/atlas/README.md); set STZ_ATLAS to its folder if it is elsewhere.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoProjection/projections_compared.ring
load "../../stzBase.ring"
decimals(2)
cAtlas = sysget("STZ_ATLAS")
if cAtlas = ""  cAtlas = "../graphics/atlas/"  ok
if NOT fexists(cAtlas + "land-110m.json")
	? "SKIPPED, by name: " + cAtlas + "land-110m.json is not present -- see test/graphics/atlas/README.md."
	return
ok
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oLand = StzGeoFeaturesFromTopoJson(read(cAtlas + "land-110m.json"), "land")

aKinds = [ :Mercator, :EqualEarth, :Mollweide, :WinkelTripel, :Orthographic, :AzimuthalEquidistant ]
oC = new stzCanvas(1000, 700)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 22).AddTextQ("Six projections, the same land, the same circles of 600 km", 20, 32).Fill("#111111")
oC.Flush()
for i = 1 to len(aKinds)
	nCol = (i - 1) % 2
	nRow = floor((i - 1) / 2)
	nX = 15 + nCol * 490
	nY = 50 + nRow * 215
	oP = new stzGeoProjection(aKinds[i])
	if oP.IsAzimuthal()  oP.CenterOn(2.12, 13.5)  ok
	oP.FitSphereIn(nX, nY, nX + 470, nY + 170, 4)
	oP.DrawSphereOn(oC, "#EAF1FB", "#8FA8C8", 1)
	oP.DrawGraticuleOn(oC, 30, "#C9D6E8", 0.7)
	oP.DrawFeaturesOn(oC, oLand, "#E9DFC4", "#9C8F6A", 0.4)
	oP.DrawTissotOn(oC, 5.4, 40, "#D9822B66", "#B3601A")
	oP.DrawOutlineOn(oC, "#6F8AB0", 1)
	aD = oP.Distortion()
	cCap = oP.Name()
	if oP.IsEqualArea()  cCap += ", equal-area"  ok
	if oP.IsConformal()  cCap += ", conformal"  ok
	cCap += "   area x" + StzFactNumText(aD[:arealMean]) + "   bend " + StzFactNumText(aD[:angularMean]) + " deg"
	oC.SetFontQ(oFont, 15).AddTextQ(cCap, nX + 4, nY + 190).Fill("#222222")
	oC.Flush()
	? aKinds[i] + ": " + @@( aD )
next
chdir("../../doc/gallery/stzGeoProjection")
oC.ToPNGXT("projections_compared.png", 9)
? "-> projections_compared.png"
