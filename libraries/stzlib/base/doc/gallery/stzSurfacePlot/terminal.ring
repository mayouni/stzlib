# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzSurfacePlot/terminal.ring > ../../doc/gallery/stzSurfacePlot/terminal.txt
# The terminal picture of the same plot as budget.png, with the shares written in the cells.
load "../../stzBase.ring"

oPlot = new stzSurfacePlot([ :Engineering = 45, :Sales = 25, :Support = 15, :Admin = 10, :Legal = 5 ])
oPlot.SetSize(60, 16)
oPlot.AddPercent()
? oPlot.ToString()
