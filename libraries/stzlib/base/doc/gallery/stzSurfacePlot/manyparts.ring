# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzSurfacePlot/manyparts.ring
# Twelve parts, from one large to several tiny, to see small cells and their labels.
load "../../stzBase.ring"

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oPlot = new stzSurfacePlot([ :Rent = 38, :Salaries = 120, :Marketing = 22, :Travel = 9, :Software = 17, :Legal = 4,
	:Insurance = 6, :Training = 5, :Meals = 3, :Office = 7, :Misc = 2, :Taxes = 31 ])
oPlot.ToPNG("../../doc/gallery/stzSurfacePlot/manyparts.png",
	[ :Font = oFont, :Title = "Spending by line", :Width = 800, :Height = 480 ])
? "done"
