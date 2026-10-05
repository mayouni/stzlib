# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzBarPlot/basic.ring
# (the engine DLL is found relative to that folder; the picture is written beside this script)
load "../../stzBase.ring"

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oPlot = StzPlotQ(:VBar, [ :Jan = 34, :Feb = 58, :Mar = 47, :Apr = 72, :May = 65, :Jun = 88, :Jul = 61 ])
oPlot.AddAverage()
oPlot.ToPNG("../../doc/gallery/stzBarPlot/basic.png",
	[ :Font = oFont, :Title = "Monthly throughput", :Width = 700, :Height = 420 ])
? "done"
