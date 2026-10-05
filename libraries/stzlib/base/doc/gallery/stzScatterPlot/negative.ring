# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzScatterPlot/negative.ring
# A few labelled points with negative and fractional coordinates: do the axes cross at zero?
load "../../stzBase.ring"

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oPlot = new stzScatterPlot([ :a = [ -3, 4 ], :b = [ -1.5, -2 ], :c = [ 0, 0.5 ], :d = [ 2.5, 3 ], :e = [ 4, -1 ] ])
oPlot.ToPNG("../../doc/gallery/stzScatterPlot/negative.png",
	[ :Font = oFont, :Title = "Points around the origin", :Width = 700, :Height = 460 ])
? "done"
