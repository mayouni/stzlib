# stzGeoMap: a choropleth of Niger's population density (RGPH 2012) with names, an inset,
# a ramp legend, a scale bar and a north arrow.
# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzGeoMap/niger_density.ring
load "../../stzBase.ring"
decimals(2)
oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oBold = new stzFont("C:/Windows/Fonts/segoeuib.ttf")
oN = StzGeoFeaturesFromJson(read("../graphics/niger_adm1.geojson"))

aPop = [ [ "Agadez", 487620 ], [ "Diffa", 593821 ], [ "Dosso", 2037713 ], [ "Maradi", 3402094 ],
         [ "Niamey", 1026848 ], [ "Tahoua", 3328365 ], [ "Tillaberi", 2722482 ], [ "Zinder", 3539764 ] ]
aDens = []
for i = 1 to oN.Count()
	nP = 0
	for k = 1 to len(aPop)
		if StzLower(aPop[k][1]) = StzLower(oN.NameOf(i))  nP = aPop[k][2]  ok
	next
	aDens + (nP / oN.AreaKm2Of(i))
next

oC = new stzCanvas(1000, 640)
oC.SetBackground("#FBF7F0")
oC.SetFontQ(oBold, 26).AddTextQ("Niger, people per km2 by region (2012)", 30, 40).Fill("#1A1206")
oC.Flush()
oP = StzGeoConicFor(oN, :ConicEqualArea)
oP.FitFeaturesIn(oN, 30, 70, 690, 580, 10)
oM = StzGeoMap(oP, oN)
oM.SetPaper(20, 60, 700, 590)
oM.SetSource("geoBoundaries ADM1 (UN OCHA); population RGPH 2012")
oM.SetValues(aDens)
oM.SetClasses([ 0, 2, 10, 50, 100 ])
oM.SetOpenTop(1)
oM.SetRamp(:YlOrRd)
oM.AddInsetXT([ 1.9, 13.3, 2.4, 13.75 ], [ 740, 400, 960, 560 ], "Niamey")
oM.DrawSheetOn(oC, "#5A3A1E", 0.9)
oM.SetLabelMode(:Names)
oM.DrawLabelsOn(oC, oFont, 15, "#222222")
oM.DrawInsetsOn(oC, oFont, 14, "#222222")
oM.DrawRampLegendOn(oC, oFont, 14, 730, 120, 240, 22, "#4A3A22")
oC.SetFontQ(oFont, 14).AddTextQ("people per km2", 730, 100).Fill("#4A3A22")
oC.Flush()
oM.DrawScaleBarOn(oC, oFont, 13, 40, 575, 120, 16, "#4A3A22")
oM.DrawNorthArrowOn(oC, oFont, 14, 650, 120, 40, 8, 16, "#4A3A22")
oM.DrawCaptionOn(oC, oFont, 30, 625)
? @@( oM.LabelReport() )
? @@( oM.Findings() )
chdir("../../doc/gallery/stzGeoMap")
oC.ToPNG("niger_density.png")
? "-> niger_density.png"
