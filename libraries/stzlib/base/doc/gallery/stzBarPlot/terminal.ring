# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzBarPlot/terminal.ring > ../../doc/gallery/stzBarPlot/terminal.txt
# The terminal picture of the same plot as basic.png: values written above the bars and the average line.
load "../../stzBase.ring"

oPlot = StzPlotQ(:VBar, [ :Jan = 34, :Feb = 58, :Mar = 47, :Apr = 72, :May = 65, :Jun = 88, :Jul = 61 ])
oPlot.AddAverage()
oPlot.SetHeight(10)
? oPlot.ToString()
