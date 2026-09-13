load "../../stzBase.ring"
decimals(1)

# GE6b -- THE THREE WAYS TO LABEL A MAP, on one country so the difference is
# the labelling and nothing else. Tunisia's twenty-three governorates range
# from Tataouine, which has room for its name ten times over, to Tunis,
# which has room for none of it -- which is exactly the spread that makes
# the choice matter.
#
#   :Names    the name, or nothing. No key, no number, no decoding. The
#             regions too small to hold a name are simply unlabelled and
#             the report says how many. This is what nivo, Datawrapper and
#             Flourish do, and it is right when the reader knows the country
#             or when only the big units matter.
#
#   :Numbers  a number for every region and every name in the key. The map
#             reads as one clean figure and the legend is a single ordered
#             column. Nothing is a special case, so nothing looks like one.
#             This is the atlas plate.
#
#   :Auto     the name where it fits and a number where it does not. Fewest
#             names to look up, but the map carries two kinds of mark at
#             once, which is a cost the other two do not pay.
#
# NONE OF THE THREE IS THE RIGHT ONE. The engine holds no opinion about
# which a caller should want, because the answer depends on who is reading
# the sheet, and that is not a fact about the geometry.

if NOT fexists("atlas/admin1_tunisia.geojson")
	? "SKIPPED, by name: atlas/admin1_tunisia.geojson is not present -- see atlas/README.md."
	return
ok

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oU = StzGeoFeaturesFromJson(read("atlas/admin1_tunisia.geojson"))

oC = new stzCanvas(1200, 760)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oFont, 23).AddTextQ("The same country, the same engine, three labelling modes", 30, 44).Fill("#111111")

aMode = [ [ :Names,   "SetLabelMode(:Names)",   "the name, or nothing at all" ],
          [ :Numbers, "SetLabelMode(:Numbers)", "a number for every region, every name in the key" ],
          [ :Auto,    "SetLabelMode(:Auto)",    "the name where it fits, a number where it does not" ] ]

for m = 1 to len(aMode)
	nL = 20 + (m - 1) * 395
	oP = StzGeoConicFor(oU, :ConicEqualArea)
	oP.FitFeaturesIn(oU, nL + 10, 112, nL + 235, 622, 6)
	oM = StzGeoMap(oP, oU)
	oM.SetSource("Natural Earth 1:10m")
	oM.SetValuesQ(oM.ValuesFromArea()).SetClassesQ([ 0, 1500, 3000, 5000, 8000, 40000 ])
	oM.SetRamp(:YlGnBu)
	oM.SetPaper(nL, 104, nL + 243, 630)
	oM.SetKeyBox(nL + 250, 112, nL + 388, 630)
	oM.SetLabelMode(aMode[m][1])
	oM.DrawRegionsOn(oC, "#FFFFFF", 0.9)
	oM.DrawLabelsOn(oC, oFont, 13, "#1B2B44")
	oM.DrawKeyOn(oC, oFont, 13, "#333333")
	r = oM.LabelReport()
	oC.SetFontQ(oFont, 16).AddTextQ(aMode[m][2], nL, 78).Fill("#111111")
	oC.SetFontQ(oFont, 13).AddTextQ(aMode[m][3], nL, 96).Fill("#777777")
	oC.SetFontQ(oFont, 13).AddTextQ("named " + r[:named] + "   numbered " + r[:numbered] +
		"   unlabelled " + r[:dropped], nL, 660).Fill("#555555")
	oC.Flush()
	? "" + aMode[m][2] + " -- named " + r[:named] + ", numbered " + r[:numbered] +
		", dropped " + r[:dropped] + ", unlisted " + r[:unlisted]
next

oC.SetFontQ(oFont, 13).AddTextQ("Every mode accounts for all 23 governorates. " +
	"The engine holds no opinion about which one a sheet should use -- that depends on " +
	"who is reading it, which is not a fact about the geometry.", 20, 700).Fill("#777777")
oC.Flush()
oC.ToPNG("geo_modes.png")
? "-> geo_modes.png"
