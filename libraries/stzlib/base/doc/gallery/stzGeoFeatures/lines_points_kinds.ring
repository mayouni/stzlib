# stzGeoFeatures: a GeoJSON written in this script (INVENTED: a river, three wells and a lake polygon) read
# by ReadGeoJson through StzGeoFeaturesFromJson, with KindOf, PartCount and BoundsOf printed; each feature drawn
# by stzGeoProjection.DrawFeatureOn -- polygons filled, lines stroked, points as circles of twice the stroke width.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoFeatures/lines_points_kinds.ring
load "../../stzBase.ring"
decimals(2)
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
q = char(34)
cJ = '{"type":"FeatureCollection","features":[' +
     '{"type":"Feature","id":"R1","properties":{"name":"River Aram"},"geometry":{"type":"LineString","coordinates":[[0,0],[1.5,1.2],[2.4,1.0],[3.5,2.6],[4.8,3.1]]}},' +
     '{"type":"Feature","id":"W1","properties":{"name":"Wells"},"geometry":{"type":"MultiPoint","coordinates":[[1.0,1.4],[2.8,2.2],[3.9,1.6]]}},' +
     '{"type":"Feature","id":"L1","properties":{"name":"Lake Ro"},"geometry":{"type":"Polygon","coordinates":[[[2.0,2.4],[3.0,2.8],[3.2,3.6],[2.2,3.9],[2.0,2.4]],[[2.5,3.0],[2.8,3.1],[2.7,3.4],[2.5,3.0]]]}},' +
     '{"type":"Feature","id":"X1","properties":{"name":"A bad one"},"geometry":{"type":"GeometryCollection"}}' +
     ']}'
oF = StzGeoFeaturesFromJson(cJ)
? "count " + oF.Count() + ", skipped " + oF.SkippedCount()
for i = 1 to oF.Count()
	? oF.NameOf(i) + ": " + oF.KindOf(i) + ", parts " + oF.PartCount(i) + ", holes " + oF.HoleCountOf(i) + ", bounds " + @@( oF.BoundsOf(i) )
next

oC = new stzCanvas(700, 420)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oBold, 20).AddTextQ("Lines, points and a polygon with a hole, read from GeoJSON", 20, 30).Fill("#111111")
oC.Flush()
oP = new stzGeoProjection(:Equirectangular)
oP.FitFeaturesIn(oF, 30, 60, 470, 380, 12)
aFill = [ "#00000000", "#C0392B", "#AED6F1" ]
aInk = [ "#1B4F72", "#C0392B", "#2E86C1" ]
aW = [ 3, 4, 1.5 ]
for i = 1 to oF.Count()
	oP.DrawFeatureOn(oC, oF, i, aFill[i], aInk[i], aW[i])
next
y = 80
for i = 1 to oF.Count()
	oC.SetFontQ(oBold, 15).AddTextQ(oF.NameOf(i), 500, y).Fill(aInk[i])
	oC.Flush()
	oC.SetFontQ(oFont, 14).AddTextQ(oF.KindOf(i) + ", " + oF.PartCount(i) + " part(s)", 500, y + 18).Fill("#333333")
	oC.Flush()
	y += 52
next
oC.SetFontQ(oFont, 14).AddTextQ("" + oF.SkippedCount() + " geometry skipped, counted", 500, y).Fill("#7B241C")
oC.Flush()
oC.SetFontQ(oFont, 13).AddTextQ("invented data; the white triangle is a hole", 30, 405).Fill("#555555")
oC.Flush()
chdir("../../doc/gallery/stzGeoFeatures")
oC.ToPNGXT("lines_points_kinds.png", 9)
? "-> lines_points_kinds.png"
