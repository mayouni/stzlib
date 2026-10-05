# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzBarPlot/values.ring
# Twelve labelled bars with the value written above each bar, a custom bar colour and a title.
load "../../stzBase.ring"

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oPlot = new stzBarPlot([ :Jan = 12, :Feb = 19, :Mar = 24, :Apr = 31, :May = 38, :Jun = 45,
	:Jul = 52, :Aug = 49, :Sep = 41, :Oct = 33, :Nov = 21, :Dec = 14 ])
oPlot.AddValues()
oPlot.ToPNG("../../doc/gallery/stzBarPlot/values.png",
	[ :Font = oFont, :Title = "Rainfall by month (mm)", :Color = "#e0a030", :Width = 800, :Height = 460 ])
? "done"
