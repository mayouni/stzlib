# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzMBarPlot/quarters.ring
# Three series over four quarters: grouped bars and the legend the pixel tier always draws.
load "../../stzBase.ring"

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oPlot = new stzMBarPlot([
	:Sales  = [ :Q1 = 25, :Q2 = 35, :Q3 = 30, :Q4 = 40 ],
	:Costs  = [ :Q1 = 15, :Q2 = 20, :Q3 = 18, :Q4 = 22 ],
	:Profit = [ :Q1 = 10, :Q2 = 15, :Q3 = 12, :Q4 = 18 ] ])
oPlot.ToPNG("../../doc/gallery/stzMBarPlot/quarters.png",
	[ :Font = oFont, :Title = "Results by quarter", :Width = 800, :Height = 460 ])
? "done"
