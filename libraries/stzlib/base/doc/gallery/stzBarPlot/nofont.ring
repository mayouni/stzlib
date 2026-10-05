# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzBarPlot/nofont.ring
# The same kind of plot with no :Font option: bars and axes are drawn, text is not.
load "../../stzBase.ring"

oPlot = new stzBarPlot([ 5, 9, 3, 12, 7 ])
oPlot.ToPNG("../../doc/gallery/stzBarPlot/nofont.png", [ :Width = 600, :Height = 360 ])
? "done"
