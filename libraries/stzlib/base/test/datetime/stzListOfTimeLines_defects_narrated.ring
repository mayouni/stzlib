load "../../stzBase.ring"
load "../_narrated.ring"

# stzListOfTimeLines: the methods that edit a lane (AddPointsToLane, AddSpanToLane, AddPeriodToLane,
# AddSpansToLane, AddBlockedSpanToLane, AddBlockedPointToLane, RemovePointFromLane, RenameLabelInLane)
# edited the COPY that Lane() returns and stored nothing, BlockSpanInLane and BlockPointInLane called
# methods the timeline does not have (R14), Copy lost the points, the drawing family raised R19 or R26
# and CrossLaneOverlaps measured every overlap as 0 seconds. Run from this folder:
#   ring stzListOfTimeLines_defects_narrated.ring
# Nothing here draws to a screen: the drawing family returns a text, which is checked, not printed.

cHL = char(226) + char(150) + char(136)    # the solid block that marks a highlighted point or span

Scenario("An add is visible through Lane(name), in the lane named and in no other")
	o = NewSet()
	o.AddPointsToLane("team a", [ [ "Alpha", "2026-07-01" ], [ "Gamma", "2026-08-01" ] ])
	Then("two points reach the stored lane", len(o.Lane("team a").Points()), 2)
	Then("the first keeps its moment, the label in capitals", o.Lane("TEAM A").Points()[1][1] + " " + o.Lane("TEAM A").Points()[1][2], "ALPHA 2026-07-01 00:00:00")
	Then("the other lane is unchanged", len(o.Lane("team b").Points()), 0)

	o.AddSpanToLane("team a", "Build", "2026-04-01", "2026-05-01")
	Then("a span reaches the stored lane", len(o.Lane("team a").Spans()), 1)
	Then("it keeps its label as given and its bounds", o.Lane("team a").Spans()[1][1] + " " + o.Lane("team a").Spans()[1][2] + " " + o.Lane("team a").Spans()[1][3], "Build 2026-04-01 00:00:00 2026-05-01 00:00:00")
	Then("the other lane has no span", len(o.Lane("team b").Spans()), 0)
	Then("the points were not disturbed by the span", len(o.Lane("team a").Points()), 2)

	o.AddPeriodToLane("team b", "Per", "2026-06-01", "2026-06-10")
	Then("AddPeriodToLane stores a span in the lane named", len(o.Lane("team b").Spans()), 1)
	Then("and not in the other", len(o.Lane("team a").Spans()), 1)

	o.AddSpansToLane("team b", [ [ "S1", "2026-07-01", "2026-07-05" ], [ "S2", "2026-07-10", "2026-07-15" ] ])
	Then("AddSpansToLane stores both, after the one already there", len(o.Lane("team b").Spans()), 3)
	Then("in the order given", o.Lane("team b").Spans()[3][1], "S2")
	Then("lane A still has its one span", len(o.Lane("team a").Spans()), 1)

	o.AddSpanToLaneQ("team a", "Fix", "2026-09-01", "2026-09-05").AddSpanToLaneQ("team a", "Fix2", "2026-09-06", "2026-09-09")
	Then("the Q form chains and stores", len(o.Lane("team a").Spans()), 3)
EndScenario()

Scenario("A refused add changes nothing, and an unknown lane raises")
	o = NewSet()
	cMsg = ""
	try
		o.AddSpanToLane("nobody", "Build", "2026-04-01", "2026-05-01")
	catch
		cMsg = cCatchError
	done
	Then("an unknown lane raises with the name in the message", StzFindFirst("nobody", cMsg) > 0, 1)
	Then("and no lane gained a span", len(o.Lane("team a").Spans()) + len(o.Lane("team b").Spans()), 0)
	cMsg = ""
	try
		o.AddPointsToLane("nobody", [ [ "Alpha", "2026-07-01" ] ])
	catch
		cMsg = cCatchError
	done
	Then("AddPointsToLane on an unknown lane raises too", StzFindFirst("nobody", cMsg) > 0, 1)
	cMsg = ""
	try
		o.AddSpansToLane("nobody", [ [ "A", "2026-07-01", "2026-07-02" ] ])
	catch
		cMsg = cCatchError
	done
	Then("AddSpansToLane on an unknown lane raises too", StzFindFirst("nobody", cMsg) > 0, 1)
	cMsg = ""
	try
		o.AddSpanToLane("team a", "Late", "2027-01-01", "2027-02-01")
	catch
		cMsg = cCatchError
	done
	Then("a span outside the shared bounds raises", StzFindFirst("outside", cMsg) > 0, 1)
	Then("and is not stored", len(o.Lane("team a").Spans()), 0)
	cMsg = ""
	try
		o.AddSpanToLane("team a", "Backwards", "2026-05-01", "2026-04-01")
	catch
		cMsg = cCatchError
	done
	Then("an end before the start raises", StzFindFirst("invalid dates", cMsg) > 0, 1)
	o.AddSpansToLane("team a", [ [ "One", "2026-03-01", "2026-03-02" ] ])
	cMsg = ""
	try
		o.AddSpansToLane("team a", [ [ "Two", "2026-03-05", "2026-03-06" ], [ "Bad", "2027-03-05", "2027-03-06" ] ])
	catch
		cMsg = cCatchError
	done
	Then("a list whose second span is refused raises", StzFindFirst("outside", cMsg) > 0, 1)
	Then("and keeps the span before it, as the timeline does", len(o.Lane("team a").Spans()), 2)
EndScenario()

Scenario("Blocking a stretch or a moment of a lane is kept, and only in that lane")
	o = NewSet()
	o.AddBlockedSpanToLane("team a", "Holiday", "2026-08-01", "2026-08-10")
	Then("a moment inside the blocked stretch is blocked", o.IsBlockedInLane("team a", "2026-08-05"), 1)
	Then("a moment outside it is not", o.IsBlockedInLane("team a", "2026-08-20"), 0)
	Then("the same moment in the other lane is not blocked", o.IsBlockedInLane("team b", "2026-08-05"), 0)
	o.AddBlockedPointToLane("team a", "2026-09-01")
	Then("a blocked moment is blocked", o.IsBlockedInLane("team a", "2026-09-01"), 1)
	Then("the moment after it is not", o.IsBlockedInLane("team a", "2026-09-02"), 0)
	Then("the other lane is not blocked there either", o.IsBlockedInLane("team b", "2026-09-01"), 0)
	Then("the blocked stretch is stored in capitals", o.Lane("team a").BlockedSpans()[1][1], "HOLIDAY")

	cMsg = ""
	try
		o.AddPointToLane("team a", "Clash", "2026-08-05")
	catch
		cMsg = cCatchError
	done
	Then("a point over the blocked stretch is now refused", StzFindFirst("blocked", cMsg) > 0, 1)
	o.AddPointToLane("team b", "Fine", "2026-08-05")
	Then("while the other lane takes it", len(o.Lane("team b").Points()), 1)
	cMsg = ""
	try
		o.AddSpanToLane("team a", "Clash", "2026-08-08", "2026-08-12")
	catch
		cMsg = cCatchError
	done
	Then("a span over the blocked stretch is refused", StzFindFirst("blocked", cMsg) > 0, 1)
	cMsg = ""
	try
		o.AddBlockedPointToLane("nobody", "2026-08-05")
	catch
		cMsg = cCatchError
	done
	Then("blocking in an unknown lane raises", StzFindFirst("nobody", cMsg) > 0, 1)
	cMsg = ""
	try
		o.AddBlockedSpanToLane("team b", "Out", "2027-01-01", "2027-01-05")
	catch
		cMsg = cCatchError
	done
	Then("blocking a stretch outside the bounds raises", StzFindFirst("outside", cMsg) > 0, 1)
	Then("and blocks nothing", len(o.Lane("team b").BlockedSpans()), 0)
EndScenario()

Scenario("BlockSpanInLane and BlockPointInLane block what a label already names")
	o = NewSet()
	o.AddSpanToLane("team a", "Build", "2026-04-01", "2026-05-01")
	o.AddPointToLane("team a", "Kick", "2026-02-01")
	o.AddSpanToLane("team b", "Build", "2026-04-01", "2026-05-01")
	Then("before, the span stretch is not blocked", o.IsBlockedInLane("team a", "2026-04-10"), 0)
	o.BlockSpanInLane("team a", "build")
	Then("a span named in another case is blocked", o.IsBlockedInLane("team a", "2026-04-10"), 1)
	Then("its edges are blocked too", o.IsBlockedInLane("team a", "2026-05-01"), 1)
	Then("a moment after it is not", o.IsBlockedInLane("team a", "2026-05-02"), 0)
	Then("the span itself stays in the lane", len(o.Lane("team a").Spans()), 1)
	Then("the other lane's span of the same label is not blocked", o.IsBlockedInLane("team b", "2026-04-10"), 0)
	Then("one blocked stretch was recorded, in capitals", o.Lane("team a").BlockedSpans()[1][1], "BUILD")

	Then("before, the point's moment is not blocked", o.IsBlockedInLane("team a", "2026-02-01"), 0)
	o.BlockPointInLane("team a", "kick")
	Then("a point named in another case has its moment blocked", o.IsBlockedInLane("team a", "2026-02-01"), 1)
	Then("the moment next to it is not", o.IsBlockedInLane("team a", "2026-02-02"), 0)
	Then("the point itself stays", len(o.Lane("team a").Points()), 1)
	Then("the other lane is not blocked there", o.IsBlockedInLane("team b", "2026-02-01"), 0)

	cMsg = ""
	try
		o.BlockSpanInLane("team a", "NoSuchSpan")
	catch
		cMsg = cCatchError
	done
	Then("a label no span carries raises", StzFindFirst("NoSuchSpan", cMsg) > 0, 1)
	Then("and blocks nothing more", len(o.Lane("team a").BlockedSpans()), 1)
	cMsg = ""
	try
		o.BlockPointInLane("team a", "NoSuchPoint")
	catch
		cMsg = cCatchError
	done
	Then("a label no point carries raises", StzFindFirst("NoSuchPoint", cMsg) > 0, 1)
	Then("and blocks nothing more", len(o.Lane("team a").BlockedPoints()), 1)
	cMsg = ""
	try
		o.BlockSpanInLane("nobody", "Build")
	catch
		cMsg = cCatchError
	done
	Then("an unknown lane raises", StzFindFirst("nobody", cMsg) > 0, 1)
	cMsg = ""
	try
		o.BlockPointInLane("team a", "Build")
	catch
		cMsg = cCatchError
	done
	Then("a span label is not a point label", StzFindFirst("No point found", cMsg) > 0, 1)
EndScenario()

Scenario("Removing and renaming a point act on the stored lane only")
	o = NewSet()
	o.AddPointToLane("team a", "Kickoff", "2026-02-01")
	o.AddPointToLane("team a", "Review", "2026-03-01")
	o.AddPointToLane("team b", "Kickoff", "2026-02-01")
	o.RemovePointFromLane("team a", "kickoff")
	Then("the point is gone from the lane", len(o.Lane("team a").Points()), 1)
	Then("the other point of that lane stays", o.Lane("team a").Points()[1][1], "REVIEW")
	Then("the same label in the other lane stays", len(o.Lane("team b").Points()), 1)

	o.RemovePointFromLane("team a", "Missing")
	Then("a label that is not there changes nothing", len(o.Lane("team a").Points()), 1)
	o.RemovePointFromLane("team b", "Missing")
	Then("in the other lane too", len(o.Lane("team b").Points()), 1)
	cMsg = ""
	try
		o.RemovePointFromLane("nobody", "Review")
	catch
		cMsg = cCatchError
	done
	Then("an unknown lane raises", StzFindFirst("nobody", cMsg) > 0, 1)

	o.RenameLabelInLane("team a", "review", "Retro")
	Then("the label is renamed, in capitals", o.Lane("team a").Points()[1][1], "RETRO")
	Then("its moment is kept", o.Lane("team a").Points()[1][2], "2026-03-01 00:00:00")
	Then("the other lane's label is not renamed", o.Lane("team b").Points()[1][1], "KICKOFF")
	o.RenameLabelInLane("team b", "Review", "Retro")
	Then("renaming a label the lane does not have changes nothing", o.Lane("team b").Points()[1][1], "KICKOFF")
	cMsg = ""
	try
		o.RenameLabelInLane("nobody", "Review", "Retro")
	catch
		cMsg = cCatchError
	done
	Then("an unknown lane raises", StzFindFirst("nobody", cMsg) > 0, 1)

	o.AddSpanToLane("team b", "SPRINT", "2026-04-01", "2026-04-10")
	o.RenameLabelInLane("team b", "SPRINT", "Cycle")
	Then("a span whose label is in capitals is renamed too", o.Lane("team b").Spans()[1][1], "CYCLE")
EndScenario()

Scenario("The reads that needed spans now see them")
	o = new stzListOfTimeLines([ :Lanes = [ "Team A", "Team B", "Empty" ], :Start = "2026-01-01", :End = "2026-12-31" ])
	Then("before any span, no lane overlaps itself", o.HasOverlapsInLane("team a"), 0)
	Then("and no lanes overlap each other", len(o.CrossLaneOverlaps()), 0)
	o.AddSpanToLane("team a", "Build", "2026-04-01", "2026-05-01")
	o.AddSpanToLane("team b", "Test", "2026-04-15", "2026-05-15")
	Then("one span does not overlap itself", o.HasOverlapsInLane("team a"), 0)
	aCross = o.CrossLaneOverlaps()
	Then("two spans of two lanes that overlap give one row", len(aCross), 1)
	Then("it names the two lanes", aCross[1][1][1] + "/" + aCross[1][1][2], "TEAM A/TEAM B")
	Then("and the two labels", aCross[1][2] + "/" + aCross[1][3], "Build/Test")
	Then("and the overlap, 2026-04-15 to 2026-05-01, is 16 days in seconds", aCross[1][4], 1382400)
	o.AddSpanToLane("team a", "Fix", "2026-04-20", "2026-04-25")
	Then("a second span inside the first makes the lane overlap itself", o.HasOverlapsInLane("team a"), 1)
	Then("the other lane still does not", o.HasOverlapsInLane("team b"), 0)

	aUnc = o.UncoveredPeriodsPerLane()
	Then("one answer per lane", len(aUnc), 3)
	Then("a lane with no span answers an empty list (the timeline's own answer, see the doc warning)", len(aUnc[3][2][2]), 0)
	Then("lane A leaves two stretches open around its spans", len(aUnc[1][2][2]), 2)
	Then("the first ends where the span starts", aUnc[1][2][2][1][2][2], "2026-04-01 00:00:00")

	o.AddPointToLane("team a", "Kick", "2026-04-20")
	aAt = o.WhatsAt("2026-04-20")
	Then("two lanes have something at that moment", len(aAt), 2)
	Then("lane A has the point and its two spans", len(aAt[1][2][2]), 3)
	Then("lane B has its span", aAt[2][2][2][1][1] + " " + aAt[2][2][2][1][2], "Test span")

	oMerged = o.ToTimeLine("")
	Then("the merged timeline carries every span with its lane in front", len(oMerged.Spans()), 3)
	Then("the first of them", oMerged.Spans()[1][1], "TEAM A-Build")
	Then("and the point", oMerged.Points()[1][1], "TEAM A-KICK")
EndScenario()

Scenario("Copy is independent of the original and keeps everything")
	o = NewSet()
	o.AddPointToLane("team a", "Kick", "2026-02-01")
	o.AddSpanToLane("team a", "Build", "2026-04-01", "2026-05-01")
	o.AddPointToLane("team b", "Demo", "2026-06-01")
	o.AddBlockedSpanToLane("team b", "Holiday", "2026-08-01", "2026-08-10")
	o.AddBlockedPointToLane("team a", "2026-09-01")
	oCopy = o.Copy()
	Then("the copy has the same lanes", oCopy.Lanes()[1] + " " + oCopy.Lanes()[2], "TEAM A TEAM B")
	Then("and the same bounds", oCopy.GlobalStart() + " " + oCopy.GlobalEnd(), "2026-01-01 00:00:00 2026-12-31 00:00:00")
	Then("the points of lane A are kept", oCopy.Lane("team a").Points()[1][1] + " " + oCopy.Lane("team a").Points()[1][2], "KICK 2026-02-01 00:00:00")
	Then("the spans of lane A are kept", oCopy.Lane("team a").Spans()[1][1], "Build")
	Then("the points of lane B are kept", oCopy.Lane("team b").Points()[1][1], "DEMO")
	Then("a blocked stretch is kept", oCopy.IsBlockedInLane("team b", "2026-08-05"), 1)
	Then("a blocked moment is kept", oCopy.IsBlockedInLane("team a", "2026-09-01"), 1)
	Then("the copy blocks nothing the original does not", oCopy.IsBlockedInLane("team a", "2026-08-05"), 0)
	Then("Content of the copy reads as Content of the original", @@(oCopy.Content()), @@(o.Content()))

	oCopy.AddPointToLane("team a", "OnlyCopy", "2026-03-01")
	oCopy.AddSpanToLane("team b", "OnlyCopySpan", "2026-10-01", "2026-10-05")
	oCopy.RemovePointFromLane("team b", "Demo")
	oCopy.AddLane("Extra")
	oCopy.AddBlockedPointToLane("team a", "2026-11-01")
	Then("a point added to the copy is not in the original", len(o.Lane("team a").Points()), 1)
	Then("a span added to the copy is not in the original", len(o.Lane("team b").Spans()), 0)
	Then("a point removed from the copy is still in the original", len(o.Lane("team b").Points()), 1)
	Then("a lane added to the copy is not in the original", o.NumberOfLanes(), 2)
	Then("a moment blocked in the copy is not blocked in the original", o.IsBlockedInLane("team a", "2026-11-01"), 0)
	o.AddPointToLane("team a", "OnlyOrig", "2026-03-15")
	o.RenameLabelInLane("team a", "Kick", "Start")
	Then("a point added to the original is not in the copy", len(oCopy.Lane("team a").Points()), 2)
	Then("a label renamed in the original is not renamed in the copy", oCopy.Lane("team a").Points()[1][1], "KICK")
	Then("the copy kept the point it was given", oCopy.Lane("team a").Points()[2][1], "ONLYCOPY")

	oEmpty = NewSet().Copy()
	Then("a copy of an empty set has its two lanes", oEmpty.NumberOfLanes(), 2)
	Then("and no point in them", len(oEmpty.Lane("team a").Points()) + len(oEmpty.Lane("team b").Points()), 0)
EndScenario()

Scenario("Lane names of any script work through the new edits")
	o = new stzListOfTimeLines([ :Lanes = [ "צוות", "فريق", "😀" ], :Start = "2026-01-01 08:00:00", :End = "2026-01-01 18:00:00" ])
	o.AddSpanToLane("فريق", "اجتماع", "2026-01-01 09:00:00", "2026-01-01 10:00:00")
	o.AddPointsToLane("😀", [ [ "ping", "2026-01-01 12:00:00" ] ])
	Then("the Arabic lane holds its span", len(o.Lane("فريق").Spans()), 1)
	Then("the emoji lane holds its point", len(o.Lane("😀").Points()), 1)
	Then("the Hebrew lane holds nothing", len(o.Lane("צוות").Spans()) + len(o.Lane("צוות").Points()), 0)
	oCopy = o.Copy()
	Then("the copy keeps them", len(oCopy.Lane("فريق").Spans()) + len(oCopy.Lane("😀").Points()), 2)
	Then("the drawing names the Arabic lane", StzFindFirst("== " + StzUpper("فريق") + " ==", o.Show()) > 0, 1)
EndScenario()

Scenario("The drawing family returns a text, one block per lane, and prints nothing")
	o = NewSet()
	o.AddPointToLane("team a", "Kick", "2026-04-20")
	o.AddSpanToLane("team a", "Build", "2026-04-01", "2026-05-01")
	o.AddSpanToLane("team b", "Test", "2026-04-15", "2026-05-15")
	cShow = o.Show()
	Then("Show is a text", isString(cShow), 1)
	Then("it names lane A", StzFindFirst("== TEAM A ==", cShow) > 0, 1)
	Then("and lane B", StzFindFirst("== TEAM B ==", cShow) > 0, 1)
	Then("lane A comes before lane B", StzFindFirst("== TEAM A ==", cShow) < StzFindFirst("== TEAM B ==", cShow), 1)
	Then("it lists the point's label in the table of dates", StzFindFirst("KICK", cShow) > 0, 1)
	Then("and the span's", StzFindFirst("Test", cShow) > 0, 1)
	Then("no highlight mark is drawn", StzFindFirst(cHL, cShow), 0)
	Then("Show is the same on a second call", o.Show(), cShow)

	cShort = o.ShowShort()
	Then("ShowShort names both lanes", StzFindFirst("== TEAM A ==", cShort) > 0 and StzFindFirst("== TEAM B ==", cShort) > 0, 1)
	Then("it is shorter than Show", len(cShort) < len(cShow), 1)
	Then("it has no table of dates", StzFindFirst("Timepoint", cShort), 0)
	Then("while Show has one", StzFindFirst("Timepoint", cShow) > 0, 1)

	cUnc = o.ShowUncovered()
	Then("ShowUncovered names both lanes", StzFindFirst("== TEAM A ==", cUnc) > 0 and StzFindFirst("== TEAM B ==", cUnc) > 0, 1)
	Then("it marks the uncovered periods with slashes", StzFindFirst("////", cUnc) > 0, 1)
	Then("Show has none", StzFindFirst("////", cShow), 0)
	Then("a lane with no span is answered by the sentence that it is fully covered", StzFindFirst("fully covered", NewSet().ShowUncovered()) > 0, 1)

	cViz = o.VizFind("kick")
	Then("VizFind marks the point of that label", StzFindFirst(cHL, cViz) > 0, 1)
	Then("it still names both lanes", StzFindFirst("== TEAM B ==", cViz) > 0, 1)
	Then("a label nobody carries draws as Show does", o.VizFind("nothing"), cShow)
	cVizSpan = o.VizFind("build")
	Then("a span label marks the span's ends", StzFindFirst(cHL, cVizSpan) > 0, 1)
	Then("and the highlight does not stay: Show is unchanged after VizFind", o.Show(), cShow)
	Then("VizFindQ answers the set", o.VizFindQ("kick").NumberOfLanes(), 2)

	cXT = o.ShowXT([ [ :Width, 40 ] ])
	Then("ShowXT with a width names both lanes", StzFindFirst("== TEAM B ==", cXT) > 0, 1)
	Then("a narrower drawing than Show", len(cXT) < len(cShow), 1)
	cXTHL = o.ShowXT([ [ :Highlight, "KICK" ] ])
	Then("ShowXT with :Highlight marks the point", StzFindFirst(cHL, cXTHL) > 0, 1)
	Then("and leaves the stored lanes alone: Show is unchanged", o.Show(), cShow)
	Then("ShowXT without the table", StzFindFirst("Timepoint", o.ShowXT([ [ :ShowTable, 0 ] ])), 0)

	oNone = new stzListOfTimeLines([ :Lanes = [], :Start = "2026-01-01", :End = "2026-12-31" ])
	Then("a set without lanes draws the empty text", oNone.Show() + oNone.ShowShort() + oNone.ShowUncovered() + oNone.VizFind("x") + oNone.ShowXT([]), "")

	cFile = "stzListOfTimeLines_defects_show.tmp.txt"
	write(cFile, cShow + char(10) + cShort + char(10) + cUnc + char(10) + cViz)
	Then("the drawings can be written to a file", fexists(cFile), 1)
	remove(cFile)
	Then("and the file is removed again", fexists(cFile), 0)
EndScenario()

Summary()

func NewSet
	return new stzListOfTimeLines([ :Lanes = [ "Team A", "Team B" ], :Start = "2026-01-01", :End = "2026-12-31" ])
