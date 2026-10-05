# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzHBarPlot/terminal.ring > ../../doc/gallery/stzHBarPlot/terminal.txt
# The terminal picture of the same plot as ranked.png.
load "../../stzBase.ring"

oPlot = new stzHBarPlot([ :Niamey = 1300, :Zinder = 450, :Maradi = 400, :Agadez = 140, :Tahoua = 120, :Dosso = 90 ])
oPlot.AddValues()
? oPlot.ToString()
