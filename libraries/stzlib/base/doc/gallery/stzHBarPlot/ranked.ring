# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzHBarPlot/ranked.ring
# Six labelled horizontal bars, longest label first column, with the values written.
load "../../stzBase.ring"

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oPlot = new stzHBarPlot([ :Niamey = 1300, :Zinder = 450, :Maradi = 400, :Agadez = 140, :Tahoua = 120, :Dosso = 90 ])
oPlot.AddValues()
oPlot.ToPNG("../../doc/gallery/stzHBarPlot/ranked.png",
	[ :Font = oFont, :Title = "Population (thousands)", :Width = 800, :Height = 420 ])
? "done"
