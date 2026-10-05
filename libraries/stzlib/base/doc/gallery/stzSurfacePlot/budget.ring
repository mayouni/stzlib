# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzSurfacePlot/budget.ring
# stzSurfacePlot is a composition plot (a treemap): the area of each cell is its value, not a function surface.
load "../../stzBase.ring"

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oPlot = new stzSurfacePlot([ :Engineering = 45, :Sales = 25, :Support = 15, :Admin = 10, :Legal = 5 ])
oPlot.ToPNG("../../doc/gallery/stzSurfacePlot/budget.png",
	[ :Font = oFont, :Title = "Budget by department", :Width = 800, :Height = 480 ])
? "done"
