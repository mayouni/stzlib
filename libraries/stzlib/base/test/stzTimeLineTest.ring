/*========================================================================
  stzTimeLine - Comprehensive Test Samples
  Testing all features of the timeline management class
=========================================================================*/

load "../stzbase.ring"

/*-------------------------------------------------------------------*/
/* SAMPLE 1: Basic Timeline Creation with Boundaries                */
/*-------------------------------------------------------------------*/

pr()

? BoxRound("SAMPLE 1: Basic Timeline with Boundaries ")

oTimeline = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

? "Start: " + oTimeline.Start()
? "End: " + oTimeline.End_()
? "Has Boundaries: " + oTimeline.HasBoundaries()
? "Duration: " + oTimeline.DurationQ().ToHuman()

/*-------------------------------------------------------------------*/
/* SAMPLE 2: Adding and Managing Points                             */
/*-------------------------------------------------------------------*/

? BoxRound("SAMPLE 2: Points Management ")

oTimeline.AddPoint("New Year", "2024-01-01 00:00:00")
oTimeline.AddPoint("Valentine's Day", "2024-02-14 00:00:00")
oTimeline.AddMoment("Independence Day", "2024-07-04 00:00:00")
oTimeline.AddTimePoint("Halloween", "2024-10-31 00:00:00")
oTimeline.AddPoint("Christmas", "2024-12-25 00:00:00")

? "Points Count: " + oTimeline.CountPoints()
? "Point Names: " + @@(oTimeline.PointNames())
? "Valentine's Day Point: " + oTimeline.Point("Valentine's Day")
? "Has Halloween: " + oTimeline.HasPoint("Halloween")

? oTimeLine.Show()

STOP()
/*-------------------------------------------------------------------*/
/* SAMPLE 3: Adding and Managing Spans                              */
/*-------------------------------------------------------------------*/

? BoxRound("SAMPLE 3: Spans Management ")

oTimeline.AddSpan("Q1", "2024-01-01 00:00:00", "2024-03-31 23:59:59")
oTimeline.AddSpan("Q2", "2024-04-01 00:00:00", "2024-06-30 23:59:59")
oTimeline.AddPeriod("Summer Vacation", "2024-06-15 00:00:00", "2024-08-31 23:59:59")
oTimeline.AddSpan("Q3", "2024-07-01 00:00:00", "2024-09-30 23:59:59")
oTimeline.AddSpan("Q4", "2024-10-01 00:00:00", "2024-12-31 23:59:59")

? "Spans Count: " + oTimeline.CountSpans()
? "Span Names: " + @@(oTimeline.SpanNames())
? "Q2 Span: " + @@(oTimeline.Span("Q2"))
? "Q2 Start: " + oTimeline.SpanStart("Q2")
? "Q2 End: " + oTimeline.SpanEnd("Q2")
? "Q2 Duration: " + oTimeline.SpanDurationQ("Q2").ToHuman()

/*-------------------------------------------------------------------*/
/* SAMPLE 4: Temporal Queries                                       */
/*-------------------------------------------------------------------*/

? BoxRound("SAMPLE 4: Temporal Queries ")

? "What's happening at July 4th: " + @@(oTimeline.WhatsAt("2024-07-04 12:00:00"))
? "What's happening at July 15th: " + @@(oTimeline.HappeningAt("2024-07-15 12:00:00"))

aPointsInSummer = oTimeline.PointsBetween("2024-06-01", "2024-08-31")
? "Points in summer: " + @@(aPointsInSummer)

aSpansInFirstHalf = oTimeline.SpansBetween("2024-01-01", "2024-06-30")
? "Spans in first half: " + @@(aSpansInFirstHalf)

aOverlapping = oTimeline.SpansOverlapping("2024-07-15 00:00:00")
? "Spans overlapping July 15: " + @@(aOverlapping)

/*-------------------------------------------------------------------*/
/* SAMPLE 5: Overlap Detection                                      */
/*-------------------------------------------------------------------*/

? BoxRound("SAMPLE 5: Overlap Detection ")

? "Has Overlaps: " + oTimeline.HasOverlaps()

? "Overlapping Spans:"
? @@NL( oTimeline.OverlappingSpans() )

/*-------------------------------------------------------------------*/
/* SAMPLE 6: Gap Analysis                                           */
/*-------------------------------------------------------------------*/

? BoxRound("SAMPLE 6: Gap Analysis ")

oTimeline2 = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeline2.AddSpan("Project Alpha", "2024-01-15 00:00:00", "2024-03-01 23:59:59")
oTimeline2.AddSpan("Project Beta", "2024-04-01 00:00:00", "2024-05-31 23:59:59")
oTimeline2.AddSpan("Project Gamma", "2024-07-01 00:00:00", "2024-09-15 23:59:59")

aGaps = oTimeline2.Gaps()
? "Gaps between spans:"
for aGap in aGaps
	oDur = new stzDuration(aGap[:Duration])
	? "  - Gap after " + aGap[:After] + ", before " + aGap[:Before] + 
	  ": " + oDur.ToHuman()
next

aUncovered = oTimeline2.UncoveredPeriods()
? NL + "Uncovered periods: " + len(aUncovered) + " gaps"
for i = 1 to len(aUncovered)
	oDur = new stzDuration(aUncovered[i][:Duration])
	? "  - From " + aUncovered[i][:Start] + 
	  " to " + aUncovered[i][:End] + 
	  " (" + oDur.ToHuman() + ")"
next

/*-------------------------------------------------------------------*/
/* SAMPLE 7: Distance Calculations                                  */
/*-------------------------------------------------------------------*/

? BoxRound("SAMPLE 7: Distance Calculations ")

oTimeline3 = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeline3.AddPoint("Launch", "2024-03-15 09:00:00")
oTimeline3.AddPoint("Milestone 1", "2024-06-15 17:00:00")
oTimeline3.AddSpan("Development Phase", "2024-01-01 00:00:00", "2024-03-14 23:59:59")
oTimeline3.AddSpan("Testing Phase", "2024-09-01 00:00:00", "2024-11-30 23:59:59")

oDist1 = oTimeline3.DistanceBetweenQ("Launch", "Milestone 1")
? "Distance from Launch to Milestone 1: " + oDist1.ToHuman()

oDist2 = oTimeline3.DistanceBetweenQ("Development Phase", "Testing Phase")
? "Distance from Development to Testing: " + oDist2.ToHuman()

oTime = oTimeline3.TimeBetweenQ("Launch", "Milestone 1")
? "Time between Launch and Milestone 1: " + oTime.ToHuman()

/*-------------------------------------------------------------------*/
/* SAMPLE 8: Sorting Operations                                     */
/*-------------------------------------------------------------------*/

? BoxRound("SAMPLE 8: Sorting Operations ")

oTimeline4 = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeline4.AddPoint("Event C", "2024-07-01 00:00:00")
oTimeline4.AddPoint("Event A", "2024-03-01 00:00:00")
oTimeline4.AddPoint("Event B", "2024-05-01 00:00:00")

aSortedPoints = oTimeline4.SortedPoints()
? "Sorted Points:"
for aPoint in aSortedPoints
	? "  - " + aPoint[1] + " at " + aPoint[2]
next

oTimeline4.AddSpan("Span 3", "2024-09-01 00:00:00", "2024-10-01 00:00:00")
oTimeline4.AddSpan("Span 1", "2024-02-01 00:00:00", "2024-03-01 00:00:00")
oTimeline4.AddSpan("Span 2", "2024-05-01 00:00:00", "2024-06-01 00:00:00")

aSortedSpans = oTimeline4.SortedSpans()
? NL + "Sorted Spans:"
for aSpan in aSortedSpans
	? "  - " + aSpan[1] + " from " + aSpan[2]
next

/*-------------------------------------------------------------------*/
/* SAMPLE 9: Removing Elements                                      */
/*-------------------------------------------------------------------*/

? BoxRound("SAMPLE 9: Removing Elements ")

oTimeline5 = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeline5.AddPoint("Point 1", "2024-03-01 00:00:00")
oTimeline5.AddPoint("Point 2", "2024-06-01 00:00:00")
oTimeline5.AddPoint("Point 3", "2024-09-01 00:00:00")

? "Points before removal: " + oTimeline5.CountPoints()
oTimeline5.RemovePoint("Point 2")
? "Points after removal: " + oTimeline5.CountPoints()
? "Remaining points: " + @@(oTimeline5.PointNames())

oTimeline5.AddSpan("Span 1", "2024-01-01 00:00:00", "2024-03-31 23:59:59")
oTimeline5.AddSpan("Span 2", "2024-04-01 00:00:00", "2024-06-30 23:59:59")

? NL + "Spans before removal: " + oTimeline5.CountSpans()
oTimeline5.RemoveSpan("Span 1")
? "Spans after removal: " + oTimeline5.CountSpans()
? "Remaining spans: " + @@(oTimeline5.SpanNames())

/*-------------------------------------------------------------------*/
/* SAMPLE 10: Copy and Clone Operations                             */
/*-------------------------------------------------------------------*/

? BoxRound("SAMPLE 10: Copy and Clone ")

oOriginal = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oOriginal.AddPoint("Original Point", "2024-06-01 00:00:00")
oOriginal.AddSpan("Original Span", "2024-01-01 00:00:00", "2024-03-31 23:59:59")

oCopy = oOriginal.Copy()
oClone = oOriginal.Clone()

? "Original Points: " + oOriginal.CountPoints()
? "Copy Points: " + oCopy.CountPoints()
? "Clone Points: " + oClone.CountPoints()

oCopy.AddPoint("Copy Point", "2024-09-01 00:00:00")
? NL + "After adding point to copy:"
? "Original Points: " + oOriginal.CountPoints()
? "Copy Points: " + oCopy.CountPoints()

/*-------------------------------------------------------------------*/
/* SAMPLE 11: Setting and Updating Boundaries                       */
/*-------------------------------------------------------------------*/

? BoxRound("SAMPLE 11: Boundary Management ")

oTimeline6 = new stzTimeLine([
	:Start = NULL,
	:End = NULL
])

? "Has Boundaries: " + oTimeline6.HasBoundaries()

oTimeline6.SetStart("2024-01-01 00:00:00")
oTimeline6.SetEnd("2024-12-31 23:59:59")

? "After setting boundaries:"
? "Has Boundaries: " + oTimeline6.HasBoundaries()
? "Start: " + oTimeline6.StartDate()
? "End: " + oTimeline6.EndDate()
? "Duration: " + oTimeline6.DurationQ().ToHuman()

/*-------------------------------------------------------------------*/
/* SAMPLE 12: Clear and Reset                                       */
/*-------------------------------------------------------------------*/

? BoxRound("SAMPLE 12: Clear Operations ")

oTimeline7 = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeline7.AddPoint("Point 1", "2024-03-01 00:00:00")
oTimeline7.AddPoint("Point 2", "2024-06-01 00:00:00")
oTimeline7.AddSpan("Span 1", "2024-01-01 00:00:00", "2024-03-31 23:59:59")

? "Before clear:"
? "Points: " + oTimeline7.CountPoints()
? "Spans: " + oTimeline7.CountSpans()

oTimeline7.Clear()

? NL + "After clear:"
? "Points: " + oTimeline7.CountPoints()
? "Spans: " + oTimeline7.CountSpans()
? "Has Boundaries: " + oTimeline7.HasBoundaries()

/*-------------------------------------------------------------------*/
/* SAMPLE 13: Complete Timeline Summary (New Format)                */
/*-------------------------------------------------------------------*/

? BoxRound("SAMPLE 13: Complete Summary ")

oFinal = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oFinal.AddPoint("Project Kickoff", "2024-01-15 09:00:00")
oFinal.AddPoint("Beta Release", "2024-06-01 00:00:00")
oFinal.AddPoint("Final Launch", "2024-10-15 00:00:00")

oFinal.AddSpan("Planning Phase", "2024-01-01 00:00:00", "2024-02-28 23:59:59")
oFinal.AddSpan("Development Phase", "2024-03-01 00:00:00", "2024-05-31 23:59:59")
oFinal.AddSpan("Testing Phase", "2024-06-01 00:00:00", "2024-09-30 23:59:59")
oFinal.AddSpan("Launch Phase", "2024-10-01 00:00:00", "2024-12-15 23:59:59")

? "Timeline Summary (Structured Data):"
? @@NL(oFinal.Summary())

/*-------------------------------------------------------------------*/
/* SAMPLE 14: Alternative Method Names                              */
/*-------------------------------------------------------------------*/

? BoxRound("SAMPLE 14: Alternative Method Names ")

oAlt = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oAlt.AddMoment("Moment 1", "2024-03-01 00:00:00")
? "Moments: " + @@(oAlt.Moments())
? "Time Points: " + @@(oAlt.TimePoints())

oAlt.AddPeriod("Period 1", "2024-01-01 00:00:00", "2024-03-31 23:59:59")
? "Periods: " + @@(oAlt.Periods())
? "Period Names: " + @@(oAlt.PeriodNames())

? "Number of Points: " + oAlt.NumberOfPoints()
? "Number of Spans: " + oAlt.NumberOfSpans()
? "Periods Count: " + oAlt.CountPeriods()

/*-------------------------------------------------------------------*/
/* SAMPLE 15: Complex Real-World Scenario                           */
/*-------------------------------------------------------------------*/

? BoxRound("SAMPLE 15: Software Project Timeline ")

oProject = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

# Major milestones
oProject.AddPoint("Requirements Signed Off", "2024-01-20 17:00:00")
oProject.AddPoint("Design Approved", "2024-02-28 17:00:00")
oProject.AddPoint("Development Complete", "2024-07-15 17:00:00")
oProject.AddPoint("QA Approved", "2024-09-30 17:00:00")
oProject.AddPoint("Production Release", "2024-10-31 09:00:00")

# Project phases
oProject.AddSpan("Requirements", "2024-01-01 00:00:00", "2024-01-20 23:59:59")
oProject.AddSpan("Design", "2024-01-21 00:00:00", "2024-02-28 23:59:59")
oProject.AddSpan("Development", "2024-03-01 00:00:00", "2024-07-15 23:59:59")
oProject.AddSpan("QA Testing", "2024-07-16 00:00:00", "2024-09-30 23:59:59")
oProject.AddSpan("Deployment", "2024-10-01 00:00:00", "2024-10-31 23:59:59")

# Find what's happening mid-year
? "Activity on July 1st: " + @@(oProject.HappeningAt("2024-07-01 12:00:00"))

# Check time from design to deployment
oDist = oProject.DistanceBetweenQ("Design", "Deployment")
? "Time from Design to Deployment: " + oDist.ToHuman()

# Get all milestones in second half
aMilestones = oProject.PointsBetween("2024-07-01", "2024-12-31")
? "Milestones in H2: " + @@(aMilestones)

# Check for gaps
aGaps = oProject.Gaps()
? "Gaps in schedule: " + len(aGaps) + " found"
if len(aGaps) > 0
	for aGap in aGaps
		oDur = new stzDuration(aGap[:Duration])
		? "  - Gap after " + aGap[:After] + ", before " + aGap[:Before] + 
		  ": " + oDur.ToHuman()
	next
ok


pf()
