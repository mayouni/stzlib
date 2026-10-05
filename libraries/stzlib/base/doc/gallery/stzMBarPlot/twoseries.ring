# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzMBarPlot/twoseries.ring
# Two series over six months, no values written (:ShowValues = 0).
load "../../stzBase.ring"

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oPlot = new stzMBarPlot([
	:Visits = [ :Jan = 820, :Feb = 910, :Mar = 1240, :Apr = 1100, :May = 1500, :Jun = 1380 ],
	:Orders = [ :Jan = 61, :Feb = 70, :Mar = 118, :Apr = 96, :May = 143, :Jun = 120 ] ])
oPlot.ToPNG("../../doc/gallery/stzMBarPlot/twoseries.png",
	[ :Font = oFont, :Title = "Visits and orders", :ShowValues = 0, :Width = 800, :Height = 460 ])
? "done"
