load "../../stzBase.ring"
load "../_narrated.ring"
decimals(4)

# stzGeoMap -- the defects the documenting wave found, reproduced with real data and held shut.
# DOCREFORM follow-up, 2026-10-16. Run from inside test/geo:  ring stzGeoMap_defects_narrated.ring
#
# Data: Niger's eight admin-1 regions (test/graphics/niger_adm1.geojson, shipped), the two invented
# countries Arda and Berea (test/graphics/fixtures, shipped), and invented values. No atlas needed.
#
# What each scenario holds, and the rule it answers to:
#   1. values without classes       -> a clear refusal that names the cure; NEVER an index error
#   2. the open top                 -> a value above the last edge belongs to the top class
#   3. the inset                    -> it draws a region EXACTLY as the parent does (SetOpenTop too)
#   4. the sheet of a map           -> with no SetPaper the sheet is the real extent of the features
#   5. out-of-range positions       -> an answer, never an index error
#   6. the unit of a density        -> per 10000 km2, said as such
#   7. the ramp names               -> the error lists every ramp that exists
# Every positive carries a negative sibling: what must still be refused, still be unclassed, still
# not drawn.

cNiger = read("../graphics/niger_adm1.geojson")
cFix   = read("../graphics/fixtures/two_countries.geojson")
oFont  = new stzFont("C:/Windows/Fonts/segoeui.ttf")

# --- a Niger map fitted the way the gallery fits it ------------------------------------------
Scenario("Values without classes: a refusal that says what to do, not an index error")
	oM = NigerMap()
	oM.SetValues(NigerDensity(oM))
	aCalls = [ "ClassOf", "ColourOf", "DrawOn", "DrawRegionsOn", "DrawSheetOn", "DrawLegendOn" ]
	for i = 1 to len(aCalls)
		cE = ErrOf(oM, aCalls[i])
		Then(aCalls[i] + " raises when values are set and classes are not", cE != "", 1)
		Then(aCalls[i] + " does not leak the index error R2", Has(cE, "R2") or Has(cE, "Index out of range"), 0)
		Then(aCalls[i] + " names the cure, SetClasses", Has(cE, "SetClasses"), 1)
	next
	Then("SetPalette before the classes names the cure", Has(ErrOf(oM, "SetPalette3"), "SetClasses"), 1)
	Then("SetPalette before the classes no longer says -1 classes", Has(ErrOf(oM, "SetPalette3"), "-1"), 0)
	Then("SetRamp before the classes still names the cure (the unchanged sibling)",
		Has(ErrOf(oM, "SetRampBlues"), "set the classes before the ramp"), 1)
EndScenario()

Scenario("The same map once its classes are set answers and draws")
	oM = NigerMap()
	oM.SetValues(NigerDensity(oM))
	oM.SetClasses([ 0, 2, 10, 50, 100 ])
	Then("ClassOf no longer raises", ErrOf(oM, "ClassOf"), "")
	Then("ColourOf no longer raises", ErrOf(oM, "ColourOf"), "")
	Then("DrawRegionsOn no longer raises", ErrOf(oM, "DrawRegionsOn"), "")
	Then("DrawSheetOn no longer raises", ErrOf(oM, "DrawSheetOn"), "")
	Then("DrawOn no longer raises", ErrOf(oM, "DrawOn"), "")
	Then("DrawLegendOn no longer raises", ErrOf(oM, "DrawLegendOn"), "")
	Then("Agadez, 0.78 per km2, is in class 1", oM.ClassOf(1), 1)
	Then("Maradi, 86.5 per km2, is in class 4", oM.ClassOf(4), 4)
	Then("SetPalette with the wrong number of colours is still refused (3 classes needed: 4 here)",
		Has(ErrOf(oM, "SetPalette3"), "4 classes need 4 colours -- 3 given"), 1)
EndScenario()

Scenario("A map with nothing to colour is not an error: no values, no classes")
	oM = NigerMap()
	Then("ClassOf is 0 for a map with no values", oM.ClassOf(1), 0)
	Then("ColourOf is the no-data colour", oM.ColourOf(1), "#E8E8E8")
	Then("the base map draws", ErrOf(oM, "DrawRegionsOn"), "")
	Then("and a legend with no classes draws", ErrOf(oM, "DrawLegendOn"), "")
	oM.SetValues([ "", "", "", "", "", "", "", "" ])
	Then("values that are all no-data need no classes either", ErrOf(oM, "ClassOf"), "")
	oF = FixtureMap()
	oF.SetValues([ 4200, 9100 ])
	Then("on the fixture countries values without classes are refused too", Has(ErrOf(oF, "ColourOf"), "SetClasses"), 1)
EndScenario()

Scenario("The open top: the value above the last edge belongs to the top class")
	oM = NigerMap()
	oM.SetValues(NigerDensity(oM))
	oM.SetClasses([ 0, 2, 10, 50, 100 ])
	Then("Niamey is 1847 people per km2, far above the scale's 100", floor(oM.ValueOf(8) + 0.5), 1844)
	Then("with a closed top it is class 0, no data", oM.ClassOf(8), 0)
	Then("...and drawn in the no-data colour", oM.ColourOf(8), "#E8E8E8")
	oM.SetOpenTop(1)
	Then("with an open top it is the top class, 4", oM.ClassOf(8), 4)
	Then("...and drawn in the top colour of the ramp", oM.ColourOf(8), "#08519C")
EndScenario()

# ---------------------------------------------------------------------------------------------
Scenario("The inset draws a region as its parent does, open top included")
	oM = NigerMap()
	oM.SetValues(NigerDensity(oM))
	oM.SetClasses([ 0, 2, 10, 50, 100 ])
	oM.SetRamp(:YlOrRd)
	oM.SetPaper(20, 60, 700, 590)
	oM.AddInsetXT([ 1.9, 13.3, 2.4, 13.75 ], [ 740, 400, 960, 560 ], "Niamey")
	oM.SetOpenTop(1)
	cTop = oM.ColourOf(8)
	Then("the parent paints Niamey in the top colour of YlOrRd", cTop, "#BD0026")
	oC = new stzCanvas(1000, 640)
	oM.DrawInsetsOn(oC, oFont, 14, "#222222")
	cSvg = oC.ToSVG()
	Then("the inset holds Niamey, and only Niamey", len(oM.Insets()[1][:idx]), 1)
	Then("the inset draws Niamey in the parent's colour", CountOf(cSvg, 'fill="' + RgbOf(cTop) + '"'), 1)
	Then("...and not in the no-data grey", CountOf(cSvg, 'fill="' + RgbOf("#E8E8E8") + '"'), 0)

	# the negative sibling: the same map with its top closed has no class for Niamey, in the inset too
	oK = NigerMap()
	oK.SetValues(NigerDensity(oK))
	oK.SetClasses([ 0, 2, 10, 50, 100 ])
	oK.SetRamp(:YlOrRd)
	oK.SetPaper(20, 60, 700, 590)
	oK.AddInsetXT([ 1.9, 13.3, 2.4, 13.75 ], [ 740, 400, 960, 560 ], "Niamey")
	oC2 = new stzCanvas(1000, 640)
	oK.DrawInsetsOn(oC2, oFont, 14, "#222222")
	cSvg2 = oC2.ToSVG()
	Then("with a closed top the parent has Niamey as no data", oK.ColourOf(8), "#E8E8E8")
	Then("...and so does the inset: the two agree", CountOf(cSvg2, 'fill="' + RgbOf("#E8E8E8") + '"'), 1)
	Then("...and the top colour is not in the inset", CountOf(cSvg2, 'fill="' + RgbOf("#BD0026") + '"'), 0)
EndScenario()

# ---------------------------------------------------------------------------------------------
Scenario("The scale without SetPaper is measured over the real extent of the features")
	oM = NigerMap()
	aB = oM._FitBox()
	# Niger is taller than the 660 x 510 box allows, so the fit is limited by the height: the box
	# 70 to 580 less the pad of 10 is 80 to 570, and the width is centred in the box (360).
	Then("the sheet is the box Niger was fitted to, less the pad: top edge 80", floor(aB[2] + 0.5), 80)
	Then("...bottom edge 570", floor(aB[4] + 0.5), 570)
	Then("...centred on the box, at x = 360", floor((aB[1] + aB[3]) / 2 + 0.5), 360)
	Then("...and inside the fitted box horizontally (30 to 690)", aB[1] >= 30 and aB[3] <= 690, 1)
	Then("...and nowhere near the whole-sphere guess, 14000 pixels wide", (aB[3] - aB[1]) < 700, 1)

	nV = oM.ScaleVariation()
	# hand computation: Albers k(phi) = sqrt(C - 2 n sin phi) / cos phi, parallels 13.67 and 21.56,
	# over Niger's latitudes 11.70 to 23.53: k runs 0.9977 .. 1.0031, so the ratio is 1.0055 at
	# least, 1.0062 with the meridian scale, and a little more on a sheet that carries padding.
	Then("the variation of Niger's own extent is near 1, not 57.85", nV > 1.005 and nV < 1.0095, 1)
	Then("...and the bar is therefore not refused", oM.ScaleBarAt(120, 16)[:variation] < 1.01, 1)

	# the independent figure: 200 km at 16 N, on the conic, in pixels
	nP1 = 13.669673 * 3.14159265358979 / 180
	nP2 = 21.560484 * 3.14159265358979 / 180
	nN = (sin(nP1) + sin(nP2)) / 2
	nC = cos(nP1) * cos(nP1) + 2 * nN * sin(nP1)
	nPhi = 16 * 3.14159265358979 / 180
	nK = sqrt(nC - 2 * nN * sin(nPhi)) / cos(nPhi)
	nExpect = 200 / 6371.0088 * 2373.515706 * nK
	aBar = oM.ScaleBarAt(120, 16)
	Then("a bar of 200 km", aBar[:km], 200)
	Then("...is 74.26 pixels wide, as the hand computation says (to 0.5 per cent)",
		fabs(aBar[:pixels] - nExpect) / nExpect < 0.005, 1)

	oC = new stzCanvas(1000, 640)
	nY = oM.DrawScaleBarOn(oC, oFont, 13, 40, 575, 120, 16, "#4A3A22")
	Then("DrawScaleBarOn draws the bar and answers the y it ended at", nY > 575, 1)

	oM.SetPaper(30, 50, 570, 470)
	Then("with the shipped sheet set by hand the variation is 1.009", floor(oM.ScaleVariation() * 1000 + 0.5) / 1000, 1.009)
	Then("a set sheet is used, not the features' extent", oM.ScaleVariation() > nV, 1)

	# negative sibling: a sheet that really is the world on Mercator keeps being refused
	oWp = new stzGeoProjection(:Mercator)
	oWp.FitToSphere(800, 600, 10)
	oW = StzGeoMap(oWp, StzGeoFeaturesFromJson(cNiger))
	oW.SetPaper(0, 0, 800, 600)
	Then("a world Mercator sheet, poles and all, varies far past the 1.25 a bar tolerates", oW.ScaleVariation() > 1.25, 1)
	oC3 = new stzCanvas(800, 600)
	Then("...and DrawScaleBarOn still refuses it (answers 0)", oW.DrawScaleBarOn(oC3, oFont, 13, 40, 575, 120, 16, "#222222"), 0)
EndScenario()

Scenario("The stream-density raster covers the features, not a box thousands of pixels wide")
	oM = NigerMap()
	aGrid = [ 0, 11, 2, 2, 9, 7 ]
	aU = []  aV = []
	for i = 1 to 9 * 7
		aU + (1 + (i % 9) * 0.25)  aV + (0.5 - floor(i / 9) * 0.1)
	next
	oC = new stzCanvas(720, 600)
	nT0 = clock()
	nLines = oM.DrawStreamDensityOn(oC, aGrid, aU, aV, 1.2, :Viridis)
	nMs = (clock() - nT0) / clockspersecond() * 1000
	Then("the streamlines are drawn without SetPaper", nLines > 0, 1)
	Then("...in a time a 660 pixel sheet earns, not a 10000 pixel one (under 20 s)", nMs < 20000, 1)
	Then("a field of too few values draws nothing (the unchanged sibling)",
		oM.DrawStreamDensityOn(oC, aGrid, [ 1 ], [ 1 ], 1.2, :Viridis), 0)
EndScenario()

# ---------------------------------------------------------------------------------------------
Scenario("A position outside the features gets an answer, not an index error")
	oM = NigerMap()
	Then("LabelPointOf(0) answers an empty list", LabelCount(oM, 0), 0)
	Then("LabelPointOf past the last answers an empty list", LabelCount(oM, 9), 0)
	Then("LabelPointOf of a negative position answers an empty list", LabelCount(oM, -1), 0)
	Then("LabelPointOf(8), Niamey, still answers a place", LabelCount(oM, 8), 2)
	aL = oM.LabelPointOf(8)
	Then("...and the place is inside Niamey", oM.Features().IndexAt(aL[1], aL[2]), 8)
	Then("IsOnPaper(0) is false", PaperOf(oM, 0), 0)
	Then("IsOnPaper past the last is false", PaperOf(oM, 99), 0)
	Then("IsOnPaper(1) is true on a conic of Niger", PaperOf(oM, 1), 1)
	# a FALSE that means something else: Niger is on the far side of a globe centred on Asia
	oG = new stzGeoProjection(:Orthographic)
	oG.CenterOn(120, 30)
	oG.FitToSphere(400, 400, 10)
	oGM = StzGeoMap(oG, oM.Features())
	Then("a feature on the far side of a globe is not on the paper either (a real false)", PaperOf(oGM, 1), 0)
EndScenario()

Scenario("DensityPointsIn is places per 10000 km2, and says so")
	oM = NigerMap()
	aAreas = oM.ValuesFromArea()
	aD = oM.DensityPointsIn([ 2.1, 13.5 ])
	Then("one place in Niamey (556.87 km2) is 17.96 per 10000 km2", floor(aD[8] * 100 + 0.5) / 100, 17.96)
	Then("by hand: 1 / area * 10000", fabs(aD[8] - 1 / aAreas[8] * 10000) < 0.000001, 1)
	Then("per square kilometre it would be 0.0018: the code is not that", aD[8] > 1, 1)
	Then("a region with no place has density 0, not no data", aD[1], 0)
	Then("density times area over 10000 gives the count back", floor(aD[8] * aAreas[8] / 10000 + 0.5), 1)
	oF = FixtureMap()
	oF.Projection().FitToFeatures(oF.Features(), 500, 400, 20)
	aIn1 = oF.LabelPointOf(1)
	aPts = [ aIn1[1], aIn1[2], aIn1[1], aIn1[2], aIn1[1], aIn1[2], 60, 60 ]
	aDf = oF.DensityPointsIn(aPts)
	Then("three places in Arda and one outside every region: 3 / area * 10000 for Arda",
		fabs(aDf[1] - 3 / oF.ValuesFromArea()[1] * 10000) < 0.000001, 1)
	Then("...and the one outside counts nowhere: Berea is 0", aDf[2], 0)
EndScenario()

# ---------------------------------------------------------------------------------------------
Scenario("The unknown-ramp error lists every ramp there is")
	aRamps = StzGeoRamps()
	Then("there are thirteen ramps", len(aRamps), 13)
	cE = ""
	try
		StzGeoRamp("NoSuchRamp", 5)
	catch
		cE = cCatchError
	done
	for i = 1 to len(aRamps)
		Then("the message names " + aRamps[i][1], Has(StzLower(cE), StzLower("" + aRamps[i][1])), 1)
	next
	Then("the message names the ramp that was asked for", Has(cE, "nosuchramp") or Has(cE, "NoSuchRamp"), 1)
	oM = NigerMap()
	oM.SetValues(NigerDensity(oM))
	oM.SetClasses([ 0, 2, 10, 50, 100 ])
	Then("SetRamp with an unknown name raises", ErrOf(oM, "SetRampNope") != "", 1)
	Then("...and the message there lists Viridis, which it did not", Has(StzLower(ErrOf(oM, "SetRampNope")), "viridis"), 1)
	oM.SetRamp(:Viridis)
	Then("SetRamp(:Viridis) gives class 1 the first stop", oM.ColourOf(1), "#440154")
	oM.SetOpenTop(1)
	Then("...and the top class the last stop", oM.ColourOf(8), "#FDE725")
	oM.SetRamp(:Blues)
	Then("the first of the older nine still works: Blues, class 1", oM.ColourOf(1), "#EFF3FF")
EndScenario()

Summary()


# --- helpers (after the main code: in Ring a func swallows what follows it) ---
func NigerMap()
	oN = StzGeoFeaturesFromJson(cNiger)
	oP = StzGeoConicFor(oN, :ConicEqualArea)
	oP.FitFeaturesIn(oN, 30, 70, 690, 580, 10)
	oM = StzGeoMap(oP, oN)
	oM.SetSource("geoBoundaries ADM1 (UN OCHA)")
	return oM

func FixtureMap()
	oF = StzGeoFeaturesFromJson(cFix)
	oP = new stzGeoProjection(:Equirectangular)
	oP.FitToFeatures(oF, 500, 400, 20)
	oM = StzGeoMap(oP, oF)
	oM.SetSource("Invented, for a guard")
	return oM

# the raised message of one call, "" when it did not raise
func ErrOf(oM, cWhat)
	cErr = ""
	oC = new stzCanvas(200, 200)
	try
		switch cWhat
		on "ClassOf"        oM.ClassOf(1)
		on "ColourOf"       oM.ColourOf(1)
		on "DrawOn"         oM.DrawOn(oC)
		on "DrawRegionsOn"  oM.DrawRegionsOn(oC, "#FFFFFF", 0.5)
		on "DrawSheetOn"    oM.DrawSheetOn(oC, "#333333", 0.5)
		on "DrawLegendOn"   oM.DrawLegendOn(oC, oFont, 10, 20, "t")
		on "SetPalette3"    oM.SetPalette([ "#FFFFFF", "#888888", "#000000" ])
		on "SetRampBlues"   oM.SetRamp(:Blues)
		on "SetRampNope"    oM.SetRamp(:NoSuchRamp)
		off
	catch
		cErr = cCatchError
	done
	return cErr

func Has(cText, cNeedle)
	return substr(cText, cNeedle) > 0

# a class edge list that gives Niger's eight regions a spread, Niamey (8) last and densest
func NigerDensity(oM)
	aPop = [ 487620, 593821, 2037713, 3402094, 3328365, 2722482, 3539764, 1026848 ]
	aOut = []
	for i = 1 to oM.Features().Count()
		aOut + (aPop[i] / oM.Features().AreaKm2Of(i))
	next
	return aOut

func RgbOf(cHex)
	return "rgb(" + _GeoHexByte(cHex, 1) + "," + _GeoHexByte(cHex, 3) + "," + _GeoHexByte(cHex, 5) + ")"

func CountOf(cText, cNeedle)
	return len(StzFind(cNeedle, cText))

# ---------------------------------------------------------------------------------------------
func LabelCount(oM, n)
	try
		return len(oM.LabelPointOf(n))
	catch
		return "RAISED: " + cCatchError
	done

func PaperOf(oM, n)
	try
		return oM.IsOnPaper(n)
	catch
		return "RAISED: " + cCatchError
	done

# ---------------------------------------------------------------------------------------------
