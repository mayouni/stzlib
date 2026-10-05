# Run from libraries/stzlib/base/test/reflect:  ring ../../doc/gallery/stzHBarPlot/longlabels.ring
# Long labels and a bar of zero, to see whether the label column grows or clips.
load "../../stzBase.ring"

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
oPlot = new stzHBarPlot([ :Customer_support_tickets = 128, :Billing_questions = 64, :Feature_requests = 31, :Bug_reports_closed = 0 ])
oPlot.ToPNG("../../doc/gallery/stzHBarPlot/longlabels.png",
	[ :Font = oFont, :Title = "Tickets by type", :Width = 800, :Height = 360 ])
? "done"
