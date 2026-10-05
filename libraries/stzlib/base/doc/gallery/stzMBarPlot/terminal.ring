# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzMBarPlot/terminal.ring > ../../doc/gallery/stzMBarPlot/terminal.txt
# The terminal picture of the same plot as quarters.png.
load "../../stzBase.ring"

oPlot = new stzMBarPlot([
	:Sales  = [ :Q1 = 25, :Q2 = 35, :Q3 = 30, :Q4 = 40 ],
	:Costs  = [ :Q1 = 15, :Q2 = 20, :Q3 = 18, :Q4 = 22 ],
	:Profit = [ :Q1 = 10, :Q2 = 15, :Q3 = 12, :Q4 = 18 ] ])
? oPlot.ToString()
