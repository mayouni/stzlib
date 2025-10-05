load "../stzbase.ring"

#-------------------------------------------#
#  Basic Timeline Creation with Boundaries  #
#-------------------------------------------#

/*--- Creating timeline with start and end boundaries

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	? Start()
	#--> 2024-01-01 00:00:00

	? End_()
	#--> 2024-12-31 23:59:59

	? HasBoundaries()
	#--> TRUE

	? Duration()
	#--> 31622399 (seconds)

	? DurationQ().ToHuman()
	#--> 1 year
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Creating timeline without boundaries

pr()

oTimeLine = new stzTimeLine([
	:Start = NULL,
	:End = NULL
])

? oTimeLine.HasBoundaries()
#--> FALSE

? oTimeLine.Duration()
#--> NULL

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Setting boundaries after creation

pr()

oTimeLine = new stzTimeLine([ :Start = NULL, :End = NULL ])

oTimeLine.SetStart("2024-06-01 00:00:00")
oTimeLine.SetEnd("2024-06-30 23:59:59")

? oTimeLine.HasBoundaries()
#--> TRUE

? oTimeLine.Start()
#--> 2024-06-01 00:00:00

pf()

#------------------------#
#  TimePoint Management  #
#------------------------#

/*--- Adding and retrieving points

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {

	AddPoint("NEW_YEAR", "2024-01-01 00:00:00")
	AddPoint("VALENTINE", "2024-02-14 00:00:00")
	AddPoint("SUMMER", "2024-06-21 00:00:00")

	? CountPoints()
	#--> 3

	? @@( PointNames() )
	#--> ["NEW_YEAR", "VALENTINE", "SUMMER"]

	? Point("VALENTINE")
	#--> 2024-02-14 00:00:00

	? HasPoint("SUMMER")
	#--> TRUE

	? HasPoint("WINTER")
	#--> FALSE
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Adding points with Q() chaining

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddPoint("EVENT1", "2024-03-15 10:00:00")
	AddPoint("EVENT2", "2024-03-16 14:30:00")
	AddPoint("EVENT3", "2024-03-17 09:00:00")
}

? oTimeLine.CountPoints()
#--> 3

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Removing points

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddPoints([ 
		[ "EVENT1", "2024-03-15 10:00:00" ],
		[ "EVENT2", "2024-03-16 14:30:00" ],
		[ "EVENT3", "2024-03-17 09:00:00" ]
	])
}

? oTimeLine.CountPoints()
#--> 3

oTimeLine.RemovePoint("EVENT2")

? oTimeLine.CountPoints()
#--> 2

? oTimeLine.HasPoint("EVENT2")
#--> FALSE

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Alternative names for points (Moments)

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine.AddMoment("MILESTONE", "2024-06-15 12:00:00")

? oTimeLine.Moments()
#--> [
# 	[ "MILESTONE", "2024-06-15 12:00:00" ]
# ]

? oTimeLine.CountPoints()
#--> 1

pf()
# Executed in 0.01 second(s) in Ring 1.24

#-----------------------#
#  TimeSpan Management  #
#-----------------------#

/*--- Adding and retrieving spans

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {

	AddSpan("Q1", "2024-01-01 00:00:00", "2024-03-31 23:59:59")
	AddSpan("Q2", "2024-04-01 00:00:00", "2024-06-30 23:59:59")
	AddSpan("Q3", "2024-07-01 00:00:00", "2024-09-30 23:59:59")

	? CountSpans()
	#--> 3

	? SpanNames()
	#--> ["Q1", "Q2", "Q3"]

	? Span("Q2")
	#--> ["2024-04-01 00:00:00", "2024-06-30 23:59:59"]

	? HasSpan("Q3")
	#--> TRUE
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Span boundaries and duration
*/
pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {

	AddSpan("PROJECT", "2024-03-01 00:00:00", "2024-08-31 23:59:59")

	? SpanStart("PROJECT")
	#--> 2024-03-01 00:00:00

	? SpanEnd("PROJECT")
	#--> 2024-08-31 23:59:59

	? SpanDuration("PROJECT")
	#--> 15897599 (seconds)

	? SpanDurationQ("PROJECT").ToHuman()
	#--> 6 months
}

pf()

/*--- Removing spans

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddSpan("PHASE1", "2024-01-01 00:00:00", "2024-03-31 23:59:59")
	AddSpan("PHASE2", "2024-04-01 00:00:00", "2024-06-30 23:59:59")
	AddSpan("PHASE3", "2024-07-01 00:00:00", "2024-09-30 23:59:59")
}

? oTimeLine.CountSpans()
#--> 3

oTimeLine.RemoveSpan("PHASE2")

? oTimeLine.CountSpans()
#--> 2

? oTimeLine.SpanNames()
#--> ["PHASE1", "PHASE3"]

pf()

/*--- Alternative names for spans (Periods)

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine.AddPeriod("VACATION", "2024-07-01 00:00:00", "2024-07-15 23:59:59")

? oTimeLine.Periods()
#--> [["VACATION", "2024-07-01 00:00:00", "2024-07-15 23:59:59"]]

? oTimeLine.CountPeriods()
#--> 1

pf()

#----------------------#
#  Temporal Queries    #
#----------------------#

/*--- Finding what happens at a specific time

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddPoint("MEETING", "2024-03-15 10:00:00")
	AddSpan("PROJECT", "2024-03-01 00:00:00", "2024-05-31 23:59:59")
	AddSpan("CAMPAIGN", "2024-03-10 00:00:00", "2024-03-20 23:59:59")
}

? oTimeLine.WhatsAt("2024-03-15 10:00:00")
#--> [[:Point, "MEETING"], [:Span, "PROJECT"], [:Span, "CAMPAIGN"]]

? oTimeLine.WhatsAt("2024-02-15 12:00:00")
#--> []

pf()

/*--- Finding points between dates

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddPoint("JAN_EVENT", "2024-01-15 10:00:00")
	AddPoint("FEB_EVENT", "2024-02-15 10:00:00")
	AddPoint("MAR_EVENT", "2024-03-15 10:00:00")
	AddPoint("APR_EVENT", "2024-04-15 10:00:00")
}

? oTimeLine.PointsBetween("2024-02-01 00:00:00", "2024-03-31 23:59:59")
#--> ["FEB_EVENT", "MAR_EVENT"]

# Named parameter syntax
? oTimeLine.PointsBetween("2024-02-01 00:00:00", :And = "2024-03-31 23:59:59")
#--> ["FEB_EVENT", "MAR_EVENT"]

pf()

/*--- Finding spans between dates

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddSpan("JAN_SPAN", "2024-01-01 00:00:00", "2024-01-31 23:59:59")
	AddSpan("FEB_SPAN", "2024-02-01 00:00:00", "2024-02-29 23:59:59")
	AddSpan("MAR_SPAN", "2024-03-01 00:00:00", "2024-03-31 23:59:59")
}

? oTimeLine.SpansBetween("2024-01-15 00:00:00", "2024-02-15 23:59:59")
#--> ["JAN_SPAN", "FEB_SPAN"]

pf()

/*--- Finding spans overlapping a point

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddSpan("PROJECT_A", "2024-02-01 00:00:00", "2024-04-30 23:59:59")
	AddSpan("PROJECT_B", "2024-03-01 00:00:00", "2024-05-31 23:59:59")
	AddSpan("PROJECT_C", "2024-06-01 00:00:00", "2024-08-31 23:59:59")
}

? oTimeLine.SpansOverlapping("2024-03-15 12:00:00")
#--> ["PROJECT_A", "PROJECT_B"]

? oTimeLine.SpansContaining("2024-07-15 12:00:00")
#--> ["PROJECT_C"]

pf()

#-----------------------#
#  Overlap Detection    #
#-----------------------#

/*--- Checking for overlapping spans

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddSpan("SPAN_A", "2024-02-01 00:00:00", "2024-04-30 23:59:59")
	AddSpan("SPAN_B", "2024-03-01 00:00:00", "2024-05-31 23:59:59")
}

? oTimeLine.HasOverlaps()
#--> TRUE

pf()

/*--- Getting overlapping span details

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddSpan("PROJECT_A", "2024-02-01 00:00:00", "2024-04-30 23:59:59")
	AddSpan("PROJECT_B", "2024-03-15 00:00:00", "2024-05-31 23:59:59")
	AddSpan("PROJECT_C", "2024-06-01 00:00:00", "2024-08-31 23:59:59")
}

? oTimeLine.OverlappingSpans()
#--> [["PROJECT_A", "PROJECT_B", 4060799]]
# Duration shows overlap in seconds

pf()

/*--- Timeline without overlaps

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddSpan("Q1", "2024-01-01 00:00:00", "2024-03-31 23:59:59")
	AddSpan("Q2", "2024-04-01 00:00:00", "2024-06-30 23:59:59")
	AddSpan("Q3", "2024-07-01 00:00:00", "2024-09-30 23:59:59")
}

? oTimeLine.HasOverlaps()
#--> FALSE

? oTimeLine.OverlappingSpans()
#--> []

pf()

#------------------#
#  Gap Analysis    #
#------------------#

/*--- Finding gaps between spans

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddSpan("PHASE1", "2024-01-01 00:00:00", "2024-02-15 23:59:59")
	AddSpan("PHASE2", "2024-03-01 00:00:00", "2024-04-15 23:59:59")
	AddSpan("PHASE3", "2024-05-01 00:00:00", "2024-06-30 23:59:59")
}

? oTimeLine.Gaps()
#--> [
#     [:After = "PHASE1", :Before = "PHASE2", :Duration = 1209600],
#     [:After = "PHASE2", :Before = "PHASE3", :Duration = 1296000]
# ]

pf()

/*--- Finding uncovered periods in timeline

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddSpan("BUSY", "2024-03-01 00:00:00", "2024-05-31 23:59:59")
}

? oTimeLine.UncoveredPeriods()
#--> [
#     [:Start = "2024-01-01 00:00:00", :End = "2024-03-01 00:00:00", :Duration = 5097600],
#     [:Start = "2024-05-31 23:59:59", :End = "2024-12-31 23:59:59", :Duration = 18576000]
# ]

pf()

#---------------------------#
#  Distance Calculations    #
#---------------------------#

/*--- Distance between points

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddPoint("START", "2024-01-15 10:00:00")
	AddPoint("END", "2024-03-15 10:00:00")
}

? oTimeLine.Distance("START", "END")
#--> 5184000 (seconds)

? oTimeLine.DistanceQ("START", "END").ToHuman()
#--> 2 months

# Named parameter syntax
? oTimeLine.Distance(:From = "START", :To = "END")
#--> 5184000

pf()

/*--- Distance between span boundaries

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddSpan("PHASE1", "2024-01-01 00:00:00", "2024-02-28 23:59:59")
	AddSpan("PHASE2", "2024-04-01 00:00:00", "2024-05-31 23:59:59")
}

# Distance uses end of first span to start of second
? oTimeLine.Distance("PHASE1", "PHASE2")
#--> 2678401 (seconds)

pf()

/*--- Mixed distance calculations

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddPoint("KICKOFF", "2024-01-15 10:00:00")
	AddSpan("WORK", "2024-02-01 00:00:00", "2024-04-30 23:59:59")
}

? oTimeLine.Distance("KICKOFF", "WORK")
#--> 1425000 (seconds)

? oTimeLine.TimeBetween("KICKOFF", "WORK")
#--> 1425000

pf()

#----------------------#
#  Sorting & Utility   #
#----------------------#

/*--- Sorted points

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddPoint("THIRD", "2024-09-15 10:00:00")
	AddPoint("FIRST", "2024-01-15 10:00:00")
	AddPoint("SECOND", "2024-05-15 10:00:00")
}

? oTimeLine.SortedPoints()
#--> [
#     ["FIRST", "2024-01-15 10:00:00"],
#     ["SECOND", "2024-05-15 10:00:00"],
#     ["THIRD", "2024-09-15 10:00:00"]
# ]

pf()

/*--- Sorted spans

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddSpan("Q3", "2024-07-01 00:00:00", "2024-09-30 23:59:59")
	AddSpan("Q1", "2024-01-01 00:00:00", "2024-03-31 23:59:59")
	AddSpan("Q2", "2024-04-01 00:00:00", "2024-06-30 23:59:59")
}

? oTimeLine.SortedSpans()
#--> [
#     ["Q1", "2024-01-01 00:00:00", "2024-03-31 23:59:59"],
#     ["Q2", "2024-04-01 00:00:00", "2024-06-30 23:59:59"],
#     ["Q3", "2024-07-01 00:00:00", "2024-09-30 23:59:59"]
# ]

pf()

/*--- Timeline summary

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddPoint("KICKOFF", "2024-02-01 10:00:00")
	AddPoint("REVIEW", "2024-06-15 14:00:00")
	AddSpan("DEVELOPMENT", "2024-03-01 00:00:00", "2024-05-31 23:59:59")
}

? oTimeLine.Summary()
#--> [
#     :Start = "2024-01-01 00:00:00",
#     :End = "2024-12-31 23:59:59",
#     :TotalDuration = "1 year",
#     :CountPoints = 2,
#     :CountSpans = 1,
#     :Points = [
#         [:Name = "KICKOFF", :DateTime = "2024-02-01 10:00:00"],
#         [:Name = "REVIEW", :DateTime = "2024-06-15 14:00:00"]
#     ],
#     :Spans = [
#         [:Name = "DEVELOPMENT",
#          :Start = "2024-03-01 00:00:00",
#          :End = "2024-05-31 23:59:59",
#          :Duration = "3 months"]
#     ]
# ]

pf()

/*--- Copying timeline

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddPoint("EVENT", "2024-03-15 10:00:00")
	AddSpan("PERIOD", "2024-04-01 00:00:00", "2024-04-30 23:59:59")
}

oCopy = oTimeLine.Copy()

? oCopy.CountPoints()
#--> 1

? oCopy.CountSpans()
#--> 1

? oCopy.Start()
#--> 2024-01-01 00:00:00

pf()

/*--- Clearing timeline

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddPoint("EVENT1", "2024-03-15 10:00:00")
	AddPoint("EVENT2", "2024-04-15 10:00:00")
	AddSpan("PERIOD", "2024-05-01 00:00:00", "2024-05-31 23:59:59")
}

? oTimeLine.CountPoints()
#--> 2

? oTimeLine.CountSpans()
#--> 1

oTimeLine.Clear()

? oTimeLine.CountPoints()
#--> 0

? oTimeLine.CountSpans()
#--> 0

# Boundaries remain
? oTimeLine.HasBoundaries()
#--> TRUE

pf()

#---------------------------#
#  Displaying the TimeLine  #
#---------------------------#

/*--- Simple display (without configuration)

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddPoint("KICKOFF", "2024-03-01 00:00:00")
	AddSpan("PREP", "2024-05-01 00:00:00", "2024-08-01 00:00:00")
	AddPoint("CLOSING", "2024-11-01 00:00:00")
}

oTimeLine.Show()
#-->
#                                                     
#       KICKOFF    ╞════PREP════╡        CLOSING      
# │────────●───────●────────────●───────────●──────────►
#          1       2            3           4         
# 
# ╭────┬─────────────────────┬─────────┬───────────────╮
# │ No │      Timepoint      │  Label  │  Description  │
# ├────┼─────────────────────┼─────────┼───────────────┤
# │  1 │ 2024-03-01 00:00:00 │ KICKOFF │ KICKOFF event │
# │  2 │ 2024-05-01 00:00:00 │ PREP    │ Start of PREP │
# │  3 │ 2024-08-01 00:00:00 │ PREP    │ End of PREP   │
# │  4 │ 2024-11-01 00:00:00 │ CLOSING │ CLOSING event │
# ╰────┴─────────────────────┴─────────┴───────────────╯

pf()

/*--- Custom width display

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddPoint("Q1", "2024-03-31 23:59:59")
	AddPoint("Q2", "2024-06-30 23:59:59")
	AddPoint("Q3", "2024-09-30 23:59:59")
}

? oTimeLine.ToStringXT([ :Width = 80 ])
# Displays wider timeline

pf()

/*--- Highlighting specific element

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddPoint("EVENT1", "2024-02-15 10:00:00")
	AddPoint("EVENT2", "2024-05-15 10:00:00")
	AddPoint("EVENT3", "2024-08-15 10:00:00")
}

? oTimeLine.VizFindPoint("EVENT2")
# Displays timeline with EVENT2 highlighted

pf()

/*--- Highlighting spans

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddSpan("PHASE1", "2024-01-01 00:00:00", "2024-03-31 23:59:59")
	AddSpan("PHASE2", "2024-04-01 00:00:00", "2024-06-30 23:59:59")
	AddSpan("PHASE3", "2024-07-01 00:00:00", "2024-09-30 23:59:59")
}

? oTimeLine.VizFindSpan("PHASE2")
# Displays timeline with PHASE2 highlighted

pf()

/*--- Complex timeline with overlapping spans

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

oTimeLine {
	AddSpan("PROJECT_A", "2024-02-01 00:00:00", "2024-05-31 23:59:59")
	AddSpan("PROJECT_B", "2024-04-01 00:00:00", "2024-07-31 23:59:59")
	AddSpan("PROJECT_C", "2024-06-01 00:00:00", "2024-09-30 23:59:59")
	AddPoint("MILESTONE1", "2024-03-15 00:00:00")
	AddPoint("MILESTONE2", "2024-08-15 00:00:00")
}

oTimeLine.Show()
# Displays complex timeline with multiple overlapping elements

pf()

/*--- Alternative display methods

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-06-30 23:59:59"
])

oTimeLine {
	AddPoint("START", "2024-01-15 00:00:00")
	AddSpan("WORK", "2024-02-01 00:00:00", "2024-05-31 23:59:59")
	AddPoint("END", "2024-06-15 00:00:00")
}

# All equivalent
oTimeLine.Viz()
oTimeLine.Visualize()
oTimeLine.Display()
oTimeLine.Show()

pf()

#-----------------------------#
#  Error Handling & Validation #
#-----------------------------#

/*--- Point outside boundaries (raises error)

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

try
	oTimeLine.AddPoint("FUTURE", "2025-01-15 10:00:00")
catch
	? "Error: Point outside timeline boundaries"
	#--> Error: Point outside timeline boundaries
done

pf()

/*--- Span outside boundaries (raises error)

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
])

try
	oTimeLine.AddSpan("OVERFLOW", "2024-11-01 00:00:00", "2025-02-28 23:59:59")
catch
	? "Error: Span outside timeline boundaries"
	#--> Error: Span outside timeline boundaries
done

pf()

/*--- Invalid span (start >= end)

pr()

oTimeLine = new stzTimeLine([
	:Start = "2024-01-01 00:00:00",
	:End = "2024-
