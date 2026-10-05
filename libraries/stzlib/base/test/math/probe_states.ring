# PROBE M2b -- declared states over Byrne's I.47 and over the sine family:
# apply, export, and the bytes of the exported frames against the picture
# walked by hand.
load "../../stzBase.ring"

oFont = StzMathFigureFont()
oM = StzPythagorasMotionQ(oFont)
? oM.Why()
? "states: " + oM.NumberOfStates()
oM.Apply(1)
x1 = oM.Picture().ValueOf("A.icon.cx")
oM.Apply(2)
x2 = oM.Picture().ValueOf("A.icon.cx")
? "A.cx state 1 -> 2: " + x1 + " -> " + x2 + " (want +60), apply " + oM.ApplyMs() + " ms"
? oM.Why()
for i = 3 to 4
	oM.Apply(i)
	? "state " + i + ": " + oM.Picture().Fact(:expr, [ StzPythagorasGapExpr(), "px^2" ])[:message] + " | " + oM.Picture().Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:message] + " | " + oM.ApplyMs() + " ms"
next

# the export, from a fresh motion
t0 = StzEngineWatchTimestampMs()
oM2 = StzPythagorasMotionQ(oFont)
oS = oM2.ExportTo("folio", "pythagoras")
? "export " + (StzEngineWatchTimestampMs() - t0) + " ms, frames " + oS.NumberOfFrames() + ", clean " + oS.IsClean() + ", narration exists " + fexists("folio/pythagoras.narration")
for i = 1 to oS.NumberOfFrames()
	? "  " + oS.FileOf(i) + " (" + len(read("folio/" + oS.FileOf(i))) + " bytes): " + oS.Caption(i)
next
aJ = oS.Judge()
for i = 1 to len(aJ)  ? "  JUDGE: " + aJ[i][:message]  next
? "motion left where it was: applied = " + oM2.Applied() + ", A.cx = " + oM2.Picture().ValueOf("A.icon.cx") + " (fresh " + x1 + ")"

# the hand pass: a fresh picture, the same acts, by hand
oP = StzPythagorasPictureQ(oFont)
? "fresh build = frame 1 bytes: " + (oP.ToPNG("folio/_h1.png") = read("folio/" + oS.FileOf(1)))
nSame = 0
for i = 2 to 4
	aA = oM2.ActsOf(i)
	for k = 1 to len(aA)
		if aA[k][1] = "dragby"
			oP.DragTo(aA[k][2], oP.ValueOf(aA[k][2] + ".cx") + aA[k][3], oP.ValueOf(aA[k][2] + ".cy") + aA[k][4])
		ok
	next
	cH = oP.ToPNG("folio/_h" + i + ".png")
	cE = read("folio/" + oS.FileOf(i))
	? "state " + i + " by hand = exported bytes: " + (cH = cE) + "  (" + len(cH) + " vs " + len(cE) + ")"
	if cH = cE  nSame++  ok
next
? "frames 1 and 2 differ: " + (read("folio/" + oS.FileOf(1)) != read("folio/" + oS.FileOf(2)))

# the motion's own Apply = the exported frame
oM3 = StzPythagorasMotionQ(oFont)
for i = 1 to 4
	oM3.Apply(i)
	? "Apply(" + i + ") picture = exported bytes: " + (oM3.Picture().ToPNG("folio/_a" + i + ".png") = read("folio/" + oS.FileOf(i)))
next

# the sine family as states
oF = StzMathMotionQ(:Function, [ :f = "{a} * sin(x)", :on = [ -6.3, 6.3 ], :mark = [ :extrema ], :maxmarks = 3, :label = "y = a sin x" ])
oF.Param("a", 1, 3, 1)
for k = 1 to 3
	oF.State("With a = " + k + " the curve reaches {top}.", [ [ :Set, "a", k ] ])
	oF.StateFact("top", :datum, [ "fr", "ymax" ])
next
t0 = StzEngineWatchTimestampMs()
oS2 = oF.ExportTo("folio", "sine")
? "sine export " + (StzEngineWatchTimestampMs() - t0) + " ms, frames " + oS2.NumberOfFrames() + ", clean " + oS2.IsClean() + ", a back to " + oF.Value("a") + ", dirty " + oF.IsDirty()
for i = 1 to 3  ? "  " + oS2.Caption(i)  next
oF2 = StzMathMotionQ(:Function, [ :f = "{a} * sin(x)", :on = [ -6.3, 6.3 ], :mark = [ :extrema ], :maxmarks = 3, :label = "y = a sin x" ])
oF2.Param("a", 1, 3, 1)
for k = 1 to 3
	oF2.Set("a", k)  oF2.Settle()
	? "sine a=" + k + " by hand = exported: " + (oF2.Figure().Diagram().ToPNG("folio/_s" + k + ".png") = read("folio/" + oS2.FileOf(k)))
next

# refusals
aTry = [ "unknown verb", "set on a diagram", "dragto on a function", "hole not in caption", "apply 0", "no free centre" ]
for i = 1 to len(aTry)
	b = FALSE
	try
		oT = StzPythagorasMotionQ(oFont)
		if i = 1  oT.State("x", [ [ :Fly, "A.icon", 1, 2 ] ])
		but i = 2  oT.State("x", [ [ :Set, "a", 1 ] ])
		but i = 3
			oT2 = StzMathMotionQ(:Function, [ :f = "{a} * x", :on = [ 0, 1 ] ])
			oT2.Param("a", 0, 1, 0.5)
			oT2.State("x", [ [ :DragTo, "A.icon", 1, 2 ] ])
		but i = 4  oT.State("no hole here", [])  oT.StateFact("gap", :expr, [ "1" ])
		but i = 5  oT.State("x", [])  oT.Apply(0)
		but i = 6  oT.State("x", [ [ :DragBy, "ABC.sqbc", 1, 2 ] ])
		ok
	catch
		b = TRUE
		? "  refused (" + aTry[i] + "): " + StzLower(cCatchError)
	done
	if NOT b  ? "  NOT REFUSED: " + aTry[i]  ok
next
