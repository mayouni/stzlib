load "../../stzBase.ring"
decimals(1)

# GE6 -- THE SPATIAL JOIN. The first step of every spatial analysis: a table
# of places, each with a longitude and a latitude, and the question "how many
# in each region".
#
# The left half is the observations -- a stain that says where but not how
# many. The right is the answer, shaded by DENSITY and named with the count,
# because a COUNT MAY NOT BE COLOURED: a big region collects more of
# anything, which is the commonest lie in the genre after the radius one.
#
# The observations are INVENTED -- sampled inside the country by rejection,
# from a fixed seed so this picture does not move between renders, then
# thinned towards seven places people actually are. Four are put over the
# border on purpose, so that "reported, never rounded" has something to
# report. The caption says the word.

if NOT fexists("atlas/admin1_tunisia.geojson")
	? "SKIPPED, by name: atlas/admin1_tunisia.geojson is not present -- see atlas/README.md."
	return
ok

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oU = StzGeoFeaturesFromJson(read("atlas/admin1_tunisia.geojson"))
oP = StzGeoConicFor(oU, :ConicEqualArea)
oP.FitFeaturesIn(oU, 660, 90, 1000, 560, 8)
oM = StzGeoMap(oP, oU)
oM.SetSource("Natural Earth 1:10m; the observations are INVENTED")

aRaw = oM.SamplePointsInside(9000, 20260913)
aHubs = [ [ 10.18, 36.80 ], [ 10.63, 35.83 ], [ 10.76, 34.74 ],
          [ 8.83, 35.17 ], [ 9.50, 33.88 ], [ 10.10, 36.45 ], [ 9.19, 36.55 ] ]
aObs = []
nS = 991
for i = 1 to len(aRaw) - 1 step 2
	nBest = 999
	for h = 1 to len(aHubs)
		d = sqrt(pow(aRaw[i] - aHubs[h][1], 2) + pow(aRaw[i+1] - aHubs[h][2], 2))
		if d < nBest  nBest = d  ok
	next
	nS = (nS * 1103515245 + 12345) % 2147483648
	if (nS % 1000) / 1000 < 1 / (1 + nBest * nBest * 3.5)
		aObs + aRaw[i]
		aObs + aRaw[i+1]
	ok
next
aOut = [ 7.2, 34.0, 7.4, 35.2, 11.9, 33.2, 8.0, 36.9 ]
for i = 1 to len(aOut)  aObs + aOut[i]  next

aCount = oM.CountPointsIn(aObs)
nOut = oM.PointsOutside(aObs)
aDens = oM.DensityPointsIn(aObs)
nTot = 0
for i = 1 to len(aCount)  nTot += aCount[i]  next
? "" + (len(aObs)/2) + " observations: inside " + nTot + ", outside " + nOut

oC = new stzCanvas(1180, 720)
oC.SetBackground("#FFFFFF")
oC.SetFontQ(oFont, 22).AddTextQ("Observations, and the governorates they fell in", 26, 42).Fill("#111111")

oP2 = StzGeoConicFor(oU, :ConicEqualArea)
oP2.FitFeaturesIn(oU, 120, 90, 430, 560, 8)
oM2 = StzGeoMap(oP2, oU)
oM2.DrawRegionsOn(oC, "#B9C6D8", 0.8)
for i = 1 to len(aObs) - 1 step 2
	q = oP2.Project(aObs[i], aObs[i+1])
	if len(q) = 2  oC.AddCircleQ(q[1], q[2], 1.5).FillQ("#C0392B55").Stroke("#00000000", 0)  ok
next
oC.Flush()
oC.SetFontQ(oFont, 17).AddTextQ("where, but not how many", 120, 592).Fill("#555555")

oM.SetValuesQ(aDens).SetClassesQ([ 0, 15, 40, 90, 200, 4000 ])
oM.SetRamp(:YlOrRd)
oM.SetPaper(660, 84, 1000, 566)
oM.SetKeyBox(1015, 90, 1170, 560)
oM.SetKeyTitle("Numbered on the map")
oM.DrawRegionsOn(oC, "#FFFFFF", 0.8)

# THE COUNT IS WHAT THE LABEL SAYS AND THE DENSITY IS WHAT THE SHADE SAYS,
# so the values are swapped for the labelling and swapped back after. The
# key carries the count too, because a governorate that was too small for
# its name is exactly the one whose number a reader wants to look up.
oM.SetValues(aCount)
oM.DrawLabelsWithValuesOn(oC, oFont, 13, "#3A2A12")
oM.DrawKeyOn(oC, oFont, 13, "#333333")
r = oM.LabelReport()
oM.SetValues(aDens)
oC.SetFontQ(oFont, 17).AddTextQ("joined: shaded by DENSITY, named with the count", 500, 592).Fill("#555555")
oM.DrawCaptionOn(oC, oFont, 120, 620)
oC.SetFontQ(oFont, 13).AddTextQ("" + r[:named] + " governorates named on the map, " +
	r[:numbered] + " numbered into the key, " + r[:dropped] + " dropped, " +
	r[:unlisted] + " numbered but not listed.", 120, 648).Fill("#777777")
oC.Flush()
oC.ToPNG("geo_join.png")
? "-> geo_join.png   named " + r[:named] + ", numbered " + r[:numbered] +
	", dropped " + r[:dropped] + ", unlisted " + r[:unlisted]
