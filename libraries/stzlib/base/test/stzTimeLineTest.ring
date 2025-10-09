load "../stzbase.ring"

#-------------------------------------------#
#  Basic Timeline Creation with Boundaries  #
#-------------------------------------------#

/*--- Creating timeline with start and end boundaries

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	? Start()
	#--> 2024-01-01 00:00:00

	? End_()
	#--> 2024-12-31 23:59:59

	? Duration()
	#--> 31622399 (seconds)

	? DurationQ().ToHuman()
	#--> 1 year
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Creating timeline onject with a date containing no time

pr()

o1 = new stzTimeLine(:From = "2024-10-10", :To = "2024-10-22 16:40:00")

? @@NL(o1.Content()) # Time is added automatically to "2024-10-10"
#--> [
#	[ "start", "2024-10-10 00:00:00" ],
#	[ "end", "2024-10-22 16:40:00" ],
#	[ "points", [  ] ],
#	[ "spans", [  ] ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*---

pr()

o1 = new stzTimeLine("2024-01-01", "2024-03-20")
o1.AddPoint("EVENT", "2024-03-15") # time added automatically "00:00:00"
? o1.Point("EVENT")
#--> 2024-03-15 00:00:00

o1.AddSpan("WEEK", "2024-03-01", "2024-03-07")  # Both dates normalized
? @@(o1.Span("WEEK"))
#--> [ "2024-03-01 00:00:00", "2024-03-07 00:00:00" ]

o1.SetStart("2024-01-01") # Works without time
? o1.Start()
#--> 2024-01-01 00:00:00

pf()
# Executed in 0.01 second(s) in Ring 1.24

#------------------------#
#  TimePoint Management  #
#------------------------#

/*--- Adding and retrieving points

pr()

oTimeLine = new stzTimeLine("2024-01-01 00:00:00", "2024-12-31 23:59:59")

oTimeLine {

	AddPoint("NEW_YEAR", "2024-01-01 00:00:00")
	AddPoint("VALENTINE", "2024-02-14 00:00:00")
	AddPoint("summer", "2024-06-21 00:00:00") # Note all labels are uppercased internally

	? CountPoints()
	#--> 3

	? @@( PointNames() )
	#--> ["NEW_YEAR", "VALENTINE", "SUMMER"]

	? Point("VALENTINE")
	#--> 2024-02-14 00:00:00

	? HasPoint("sUMMER") # You can enter lable in any case
	#--> TRUE

	? HasPoint("WINTER")
	#--> FALSE
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Adding points with Q() chaining

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

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

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoints([ 
		[ "EVENT1", "2024-03-15 10:00:00" ],
		[ "EVENT1", "2024-05-16 14:30:00" ],
		[ "EVENT1", "2024-08-17 09:00:00" ]
	])
}

oTimeLine.Show()
#-->
'
        EVENT1  EVENT1       EVENT1                 
|──────────●───────●────────────●────────────────○─►
           1       2            3                 

╭────┬─────────────────────┬────────┬────────────────╮
│ No │      Timepoint      │ Label  │  Description   │
├────┼─────────────────────┼────────┼────────────────┤
│    │ 2024-01-01 00:00:00 │        │ Timeline start │
│  1 │ 2024-03-15 10:00:00 │ EVENT1 │ EVENT1 event   │
│  2 │ 2024-05-16 14:30:00 │ EVENT1 │ EVENT1 event   │
│  3 │ 2024-08-17 09:00:00 │ EVENT1 │ EVENT1 event   │
│    │ 2024-12-31 23:59:59 │        │ Timeline end   │
╰────┴─────────────────────┴────────┴────────────────╯
'

? oTimeLine.CountPoints()
#--> 3

oTimeLine.RemovePoint("EVENT1")
oTimeLine.RemovePoint("EVENT1")
oTimeLine.RemovePoint("EVENT1")

? oTimeLine.CountPoints()
#--> 0

? oTimeLine.HasPoint("EVENT2")
#--> FALSE

oTimeLine.Show()
#-->
# |────────────────────────────────────────────────○─►
#
# ╭────┬─────────────────────┬───────┬────────────────╮
# │ No │      Timepoint      │ Label │  Description   │
# ├────┼─────────────────────┼───────┼────────────────┤
# │    │ 2024-01-01 00:00:00 │       │ Timeline start │
# │    │ 2024-12-31 23:59:59 │       │ Timeline end   │
# ╰────┴─────────────────────┴───────┴────────────────╯

pf()
# Executed in 0.09 second(s) in Ring 1.24

/*--- Alternative names for points (Moments)

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

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

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

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

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

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
# Executed in 0.01 second(s) in Ring 1.24

/*--- Removing spans

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {

	AddSpans([
		[ "PHASE1", "2024-01-01 00:00:00", "2024-03-31 23:59:59" ],
		[ "PHASE2", "2024-04-01 00:00:00", "2024-06-30 23:59:59" ],
		[ "PHASE3", "2024-07-01 00:00:00", "2024-09-30 23:59:59" ]
	])

	? CountSpans()
	#--> 3

	RemoveSpan("PHASE2")

	? CountSpans()
	#--> 2

	? SpanNames()
	#--> [ "PHASE1", "PHASE3" ]

}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Alternative names for spans (Periods)

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine.AddPeriod("VACATION", "2024-07-01 00:00:00", "2024-07-15 23:59:59")

? oTimeLine.Periods()
#--> [["VACATION", "2024-07-01 00:00:00", "2024-07-15 23:59:59"]]

? oTimeLine.CountPeriods()
#--> 1

pf()
# Executed in 0.01 second(s) in Ring 1.24

#----------------------#
#  Temporal Queries    #
#----------------------#

/*--- Finding what happens at a specific time

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("MEETING", "2024-03-15 10:00:00")
	AddSpan("PROJECT", "2024-03-01 00:00:00", "2024-05-31 23:59:59")
	AddSpan("CAMPAIGN", "2024-03-10 00:00:00", "2024-03-20 23:59:59")
}

? @@NL( oTimeLine.WhatsAt("2024-03-15 10:00:00") )
#--> [
#	[ "MEETING", "point" ],
#	[ "PROJECT", "span" ],
#	[ "CAMPAIGN", "span" ]
# ]

? @@( oTimeLine.WhatsAt("2024-02-15 12:00:00") )
#--> [ ]

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Finding points between dates

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("JAN_EVENT", "2024-01-15 10:00:00")
	AddPoint("FEB_EVENT", "2024-02-15 10:00:00")
	AddPoint("MAR_EVENT", "2024-03-15 10:00:00")
	AddPoint("APR_EVENT", "2024-04-15 10:00:00")
}

? @@( oTimeLine.PointsBetween("2024-02-01 00:00:00", "2024-03-31 23:59:59") )
#--> ["FEB_EVENT", "MAR_EVENT"]

# More expressive (Moment alternative and named parameter syntax, looks like poetry;)
? oTimeLine.MomentsBetween("2024-02-01 00:00:00", :And = "2024-03-31 23:59:59")
#--> ["FEB_EVENT", "MAR_EVENT"]

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Finding spans between dates

pr()

oTimeLine = new stzTimeLine(
	:From = "2024-01-01 00:00:00",
	:To = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("JAN_SPAN", "2024-01-01 00:00:00", "2024-01-31 23:59:59")
	AddSpan("FEB_SPAN", "2024-02-01 00:00:00", "2024-02-29 23:59:59")
	AddSpan("MAR_SPAN", "2024-03-01 00:00:00", "2024-03-31 23:59:59")
}

? @@( oTimeLine.SpansBetween("2024-01-15 00:00:00", "2024-02-15 23:59:59") )
#--> ["JAN_SPAN", "FEB_SPAN"]

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Finding spans overlapping a point

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {

	AddSpan("PROJECT_A", "2024-02-01 00:00:00", "2024-04-30 23:59:59")
	AddSpan("PROJECT_B", "2024-03-01 00:00:00", "2024-05-31 23:59:59")
	AddSpan("PROJECT_C", "2024-06-01 00:00:00", "2024-08-31 23:59:59")

	? @@( SpansOverlapping("2024-03-15 12:00:00") )
	#--> [ "PROJECT_A", "PROJECT_B" ]

	? @@( SpansContaining("2024-07-15 12:00:00") ) + NL
	#--> [ "PROJECT_C" ]

}

oTimeLine.Show()
#-->
'
         ╞═PROJECT_B═╡                            
     ╞═PROJECT_A═╡   ╞═PROJECT_C══╡                 
│────◉───◉───────◉───◉────────────◉─────────────────○─►
     1   2       3  4-5           6                 

╭────┬─────────────────────┬───────────┬────────────────────╮
│ No │      Timepoint      │   Label   │    Description     │
├────┼─────────────────────┼───────────┼────────────────────┤
│    │ 2024-01-01 00:00:00 │           │ Timeline start     │
│  1 │ 2024-02-01 00:00:00 │ PROJECT_A │ Start of PROJECT_A │
│  2 │ 2024-03-01 00:00:00 │ PROJECT_B │ Start of PROJECT_B │
│  3 │ 2024-04-30 23:59:59 │ PROJECT_A │ End of PROJECT_A   │
│  4 │ 2024-05-31 23:59:59 │ PROJECT_B │ End of PROJECT_B   │
│  5 │ 2024-06-01 00:00:00 │ PROJECT_C │ Start of PROJECT_C │
│  6 │ 2024-08-31 23:59:59 │ PROJECT_C │ End of PROJECT_C   │
│    │ 2024-12-31 23:59:59 │           │ Timeline end       │
╰────┴─────────────────────┴───────────┴────────────────────╯
'

pf()
# Executed in 0.19 second(s) in Ring 1.24

#-----------------------#
#  Overlap Detection    #
#-----------------------#

/*--- Checking for overlapping spans

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("SPAN_A", "2024-02-01 00:00:00", "2024-04-30 23:59:59")
	AddSpan("SPAN_B", "2024-03-01 00:00:00", "2024-05-31 23:59:59")
}

? oTimeLine.HasOverlaps()
#--> TRUE

oTimeLine.ShowShort()
#-->
'
        ╞══SPAN_B═══╡                              
     ╞══SPAN_A═══╡                                  
│────●───●───────●───●─────────────────────────────○─►
     1   2       3   4                              
'

pf()
# Executed in 0.06 second(s) in Ring 1.24

/*--- Getting overlapping span details

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("PROJECT_A", "2024-02-01 00:00:00", "2024-04-30 23:59:59")
	AddSpan("PROJECT_B", "2024-03-15 00:00:00", "2024-05-31 23:59:59")
	AddSpan("PROJECT_C", "2024-06-01 00:00:00", "2024-08-31 23:59:59")
}

? @@( oTimeLine.OverlappingSpans() )
#--> [ ["PROJECT_A", "PROJECT_B", 4060799] ]
# Duration shows overlap in seconds

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Timeline without overlaps

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("Q1", "2024-01-01 00:00:00", "2024-03-31 23:59:59")
	AddSpan("Q2", "2024-04-01 00:00:00", "2024-06-30 23:59:59")
	AddSpan("Q3", "2024-07-01 00:00:00", "2024-09-30 23:59:59")
}

? oTimeLine.HasOverlaps()
#--> FALSE

? @@(oTimeLine.OverlappingSpans())
#--> [ ]

oTimeLine.Show()
#-->
'
             ╞════Q2═════╡                          
╞═════Q1═════╡           ╞═════Q3═════╡             
●────────────●───────────●────────────●────────────○─►
1           2-3         4-5           6             

╭────┬─────────────────────┬───────┬────────────────╮
│ No │      Timepoint      │ Label │  Description   │
├────┼─────────────────────┼───────┼────────────────┤
│    │ 2024-01-01 00:00:00 │       │ Timeline start │
│  1 │ 2024-01-01 00:00:00 │ Q1    │ Start of Q1    │
│  2 │ 2024-03-31 23:59:59 │ Q1    │ End of Q1      │
│  3 │ 2024-04-01 00:00:00 │ Q2    │ Start of Q2    │
│  4 │ 2024-06-30 23:59:59 │ Q2    │ End of Q2      │
│  5 │ 2024-07-01 00:00:00 │ Q3    │ Start of Q3    │
│  6 │ 2024-09-30 23:59:59 │ Q3    │ End of Q3      │
│    │ 2024-12-31 23:59:59 │       │ Timeline end   │
╰────┴─────────────────────┴───────┴────────────────╯
'

# NOTE: As you can see, the start of the timeline — usually marked with "|" — 
# is now displayed as "●" because it coincides with the beginning of the Q1 span.  
#
# Both the start of the timeline and the start of Q1 share the same datetime in the table.  
# However, the start of the timeline has no numeric order, since, like the end of the timeline, 
# it simply acts as a boundary marker rather than a data point.  
#
# The start or end of a timeline may appear as "●" only when a defined point or span 
# (added via `AddPoint()` or `AddSpan()`) starts or ends exactly at those boundaries.  
#
# When the end of the timeline has no explicitly defined event, it is still worth noting — 
# it usually represents an *implicit milestone* of the timeline, illustrated by the symbol "○─►".

pf()
# Executed in 0.15 second(s) in Ring 1.24

#------------------#
#  Gap Analysis    #
#------------------#

/*--- Finding gaps between spans

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("PHASE1", "2024-01-01 00:00:00", "2024-02-15 23:59:59")
	AddSpan("PHASE2", "2024-03-01 00:00:00", "2024-04-15 23:59:59")
	AddSpan("PHASE3", "2024-05-01 00:00:00", "2024-06-30 23:59:59")
}

? @@NL( oTimeLine.Gaps() )
#--> [
#     [:After = "PHASE1", :Before = "PHASE2", :Duration = 1209600],
#     [:After = "PHASE2", :Before = "PHASE3", :Duration = 1296000]
# ]

oTimeLine.ShowShort()
#-->
'
╞PHASE1╡ ╞═════╡ ╞PHASE3═╡                          
●──────●─●─────●─●───────●─────────────────────────○─►
1      2 3     4 5       6                          
'

pf()
# Executed in 0.08 second(s) in Ring 1.24

/*---

pr()

StzDurationQ(18489600) {
	? Days() 	#--> 214
	? ToHuman() 	#--> "214 days"
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Managing uncovered periods in timeline
*/
pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {

	AddSpan("BUSY", "2024-03-01", "2024-05-31")
	AddSpan("BUSY", "2024-04-01", "2024-06-30")
	AddSpan("BUSY", "2024-08-01", "2024-09-20")

	AddMoment('MMM', "2024-08-01")

	ShowUncovered()
}



//oTimeLine.ShowUncovered()


#-->
#              ╞===BUSY====╡                          
#          ╞===BUSY====╡        ╞=BUSY=╡              
# |////////●───●───────●───●////◉──────●///////////○─►
#          1   2       3   4   5-6     7                     
# 
# ╭────┬─────────────────────┬───────┬────────────────╮
# │ No │      Timepoint      │ Label │  Description   │
# ├────┼─────────────────────┼───────┼────────────────┤
# │    │ 2024-01-01 00:00:00 │       │ Timeline start │
# │  1 │ 2024-03-01 00:00:00 │ BUSY  │ Start of BUSY  │
# │  2 │ 2024-04-01 00:00:00 │ BUSY  │ Start of BUSY  │
# │  3 │ 2024-05-31 23:59:59 │ BUSY  │ End of BUSY    │
# │  4 │ 2024-06-30 23:59:59 │ BUSY  │ End of BUSY    │
# │  5 │ 2024-08-01 00:00:00 │ BUSY  │ Start of BUSY  │
# │  6 │ 2024-08-30 23:59:59 │ BUSY  │ End of BUSY    │
# │    │ 2024-12-31 23:59:59 │       │ Timeline end   │
# ╰────┴─────────────────────┴───────┴────────────────╯

pf()
# Executed in 0.22 second(s) in Ring 1.24

#---------------------------#
#  Distance Calculations    #
#---------------------------#

/*--- Distance between points

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("START", "2024-01-15 10:00:00")
	AddPoint("END", "2024-03-15 10:00:00")
}

? oTimeLine.Distance("START", "END")
#--> 5184000 (seconds)

? oTimeLine.DistanceQ("START", "END").ToHuman()
#--> 60 days

# Named parameter syntax
? oTimeLine.Distance(:From = "START", :To = "END")
#--> 5184000

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Distance between span boundaries

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("PHASE1", "2024-01-01 00:00:00", "2024-02-28 23:59:59")
	AddSpan("PHASE2", "2024-04-01 00:00:00", "2024-05-31 23:59:59")
}

# Distance uses end of first span to start of second
? oTimeLine.Distance("PHASE1", "PHASE2")
#--> 2678401 (seconds)

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Mixed distance calculations

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("KICKOFF", "2024-01-15 10:00:00")
	AddSpan("WORK", "2024-02-01 00:00:00", "2024-04-30 23:59:59")
}

? oTimeLine.Distance("KICKOFF", "WORK") # Or TimeBetween
#--> 1432800 (seconds)

? oTimeLine.TimeBetween("KICKOFF", "WORK")
#--> 1432800

pf()
# Executed in 0.01 second(s) in Ring 1.24

#----------------------#
#  Sorting & Utility   #
#----------------------#

/*--- Sorted points

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("THIRD", "2024-09-15 10:00:00")
	AddPoint("FIRST", "2024-01-15 10:00:00")
	AddPoint("SECOND", "2024-05-15 10:00:00")
}

? @@NL( oTimeLine.SortedPoints() )
#--> [
#     ["FIRST", "2024-01-15 10:00:00"],
#     ["SECOND", "2024-05-15 10:00:00"],
#     ["THIRD", "2024-09-15 10:00:00"]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Sorted spans

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("Q3", "2024-07-01 00:00:00", "2024-09-30 23:59:59")
	AddSpan("Q1", "2024-01-01 00:00:00", "2024-03-31 23:59:59")
	AddSpan("Q2", "2024-04-01 00:00:00", "2024-06-30 23:59:59")
}

? @@NL( oTimeLine.SortedSpans() )
#--> [
#     ["Q1", "2024-01-01 00:00:00", "2024-03-31 23:59:59"],
#     ["Q2", "2024-04-01 00:00:00", "2024-06-30 23:59:59"],
#     ["Q3", "2024-07-01 00:00:00", "2024-09-30 23:59:59"]
# ]

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*--- Timeline summary

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("KICKOFF", "2024-02-01 10:00:00")
	AddPoint("REVIEW", "2024-06-15 14:00:00")
	AddSpan("DEVELOPMENT", "2024-03-01 00:00:00", "2024-05-31 23:59:59")
}

? @@NL( oTimeLine.Summary() )
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
# Executed in 0.02 second(s) in Ring 1.24

/*--- Copying timeline

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

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

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

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

pf()
# Executed in 0.01 second(s) in Ring 1.24

#---------------------------#
#  Displaying the TimeLine  #
#---------------------------#

/*--- Simple display (without configuration)

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("KICKOFF", "2024-03-01 00:00:00")
	AddSpan("PREP", "2024-05-01 00:00:00", "2024-08-01 00:00:00")
	AddPoint("CLOSING", "2024-11-01 00:00:00")
}

# Displaying the timeline along with the info tbale

oTimeLine.Show()
#-->
#                                                    
#       KICKOFF    ╞════PREP════╡        CLOSING      
# |────────●───────●────────────●───────────●──────○─►
#          1       2            3           4         
# 
# ╭────┬─────────────────────┬─────────┬────────────────╮
# │ No │      Timepoint      │  Label  │  Description   │
# ├────┼─────────────────────┼─────────┼────────────────┤
# │    │ 2024-01-01 00:00:00 │         │ Timeline start │
# │  1 │ 2024-03-01 00:00:00 │ KICKOFF │ KICKOFF event  │
# │  2 │ 2024-05-01 00:00:00 │ PREP    │ Start of PREP  │
# │  3 │ 2024-08-01 00:00:00 │ PREP    │ End of PREP    │
# │  4 │ 2024-11-01 00:00:00 │ CLOSING │ CLOSING event  │
# │    │ 2024-12-31 23:59:59 │         │ Timeline end   │
# ╰────┴─────────────────────┴─────────┴────────────────╯
 
# If you want to see the timeline without the table

oTimeLine.ShowShort() # Same as ShowXT([ :ShowTable = FALSE ])
#-->
#                                                     
#       KICKOFF    ╞════PREP════╡        CLOSING      
# │────────●───────●────────────●───────────●────────○─►
#          1       2            3           4         

# You can display a statistical legend instead of the norma table

oTimeLine.ShowXT([ :TableType = :Statistical ]) # VS :TableType = :Normal
#-->
#                                                     
#       KICKOFF    ╞════PREP════╡        CLOSING      
# │────────●───────●────────────●───────────●────────○─►
#          1       2            3           4         
# 
# ╭────────────────────┬────────────────╮
# │       Metric       │     Value      │
# ├────────────────────┼────────────────┤
# │ Total Points       │              2 │
# │ Total Spans        │              1 │
# │ Timeline Duration  │ 1 year         │
# │ Coverage           │ 25%            │
# │ Longest Span       │ PREP (92 days) │
# │ Gaps Between Spans │              0 │
# │ Overlapping Spans  │              0 │
# ╰────────────────────┴────────────────╯

# You can get the stats as date:
? @@NL( oTimeLine.Stats() )
#--> [
#	[ "metric", "value" ],

#	[ "Total Points", 2 ],
#	[ "Total Spans", 1 ],
#	[ "Timeline Duration", "1 year" ],
#	[ "Coverage", "25%" ],
#	[ "Longest Span", "PREP (92 days)" ],
#	[ "Gaps Between Spans", 0 ],
#	[ "Overlapping Spans", 0 ]
# ]

#TODO: May it's better Stats() returns the values in number formats not in natural text...

pf()
# Executed in 0.12 second(s) in Ring 1.24

/*--- Custom width display

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddPoint("Q1", "2024-03-31 23:59:59")
	AddPoint("Q2", "2024-06-30 23:59:59")
	AddPoint("Q3", "2024-09-30 23:59:59")
}

? oTimeLine.ToStringXT([ :Width = 30 ])
#-->
#       Q1     Q2     Q3        
# │──────●──────●──────●────────○─►
#        1      2      3   
#
# ╭────┬─────────────────────┬───────┬─────────────╮
# │ No │      Timepoint      │ Label │ Description │
# ├────┼─────────────────────┼───────┼─────────────┤
# │  1 │ 2024-03-31 23:59:59 │ Q1    │ Q1 event    │
# │  2 │ 2024-06-30 23:59:59 │ Q2    │ Q2 event    │
# │  3 │ 2024-09-30 23:59:59 │ Q3    │ Q3 event    │
# ╰────┴─────────────────────┴───────┴─────────────╯

pf()
# Executed in 0.07 second(s) in Ring 1.24

/*--- Finding and Highlighting specific element

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {

	AddMoments([
		[ "EVENT_1", "2024-02-15 10:00:00" ],
		[ "EVENT_2", "2024-05-15 10:00:00" ],
		[ "EVENT_1", "2024-08-15 10:00:00" ]
	])

	# Finding the occurrences of a given moment by lablel
	# and returning the occurences datetimes

	? @@(FindMoment("EVENT_1"))
	#--> [ "2024-02-15 10:00:00", "2024-08-15 10:00:00" ]

	# The same as above along with the positions on the timeline

	? @@(FindMomentXT("EVENT_1")) + NL
	#--> [ [ "1", "2024-02-15 10:00:00" ], [ "3", "2024-08-15 10:00:00" ] ]

	# Higligting the moments visually on the timeline
	? VizFindMoment("EVENT_1")
}
#-->
'
    EVENT_1     EVENT_2      EVENT_1                
│──────█───────────●────────────█───────────────────○─►
       1           2            3                   

╭────┬─────────────────────┬─────────┬────────────────╮
│ No │      Timepoint      │  Label  │  Description   │
├────┼─────────────────────┼─────────┼────────────────┤
│    │ 2024-01-01 00:00:00 │         │ Timeline start │
│  1 │ 2024-02-15 10:00:00 │ EVENT_1 │ EVENT_1 event  │
│  2 │ 2024-05-15 10:00:00 │ EVENT_2 │ EVENT_2 event  │
│  3 │ 2024-08-15 10:00:00 │ EVENT_1 │ EVENT_1 event  │
│    │ 2024-12-31 23:59:59 │         │ Timeline end   │
╰────┴─────────────────────┴─────────┴────────────────╯
'

pf()
# Executed in 0.09 second(s) in Ring 1.24

/*--- Highlighting spans

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("PHASE1", "2024-01-01 00:00:00", "2024-03-31 23:59:59")
	AddSpan("PHASE2", "2024-04-01 00:00:00", "2024-06-30 23:59:59")
	AddSpan("PHASE3", "2024-07-01 00:00:00", "2024-09-30 23:59:59")
}

? oTimeLine.VizFindSpan("PHASE2")
#-->
'                                              
             ╞══PHASE2═══╡                          
╞═══PHASE1═══╡           ╞═══PHASE3═══╡             
●────────────●███████████●────────────●──────────○─►
1           2-3         4-5           6             

╭────┬─────────────────────┬────────┬─────────────────╮
│ No │      Timepoint      │ Label  │   Description   │
├────┼─────────────────────┼────────┼─────────────────┤
│    │ 2024-01-01 00:00:00 │        │ Timeline start  │
│  1 │ 2024-01-01 00:00:00 │ PHASE1 │ Start of PHASE1 │
│  2 │ 2024-03-31 23:59:59 │ PHASE1 │ End of PHASE1   │
│  3 │ 2024-04-01 00:00:00 │ PHASE2 │ Start of PHASE2 │
│  4 │ 2024-06-30 23:59:59 │ PHASE2 │ End of PHASE2   │
│  5 │ 2024-07-01 00:00:00 │ PHASE3 │ Start of PHASE3 │
│  6 │ 2024-09-30 23:59:59 │ PHASE3 │ End of PHASE3   │
│    │ 2024-12-31 23:59:59 │        │ Timeline end    │
╰────┴─────────────────────┴────────┴─────────────────╯
'

pf()
# Executed in 0.16 second(s) in Ring 1.24

/*--- #NOTE Period is an alias of Span

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {

	AddPeriods([
		[ "SUCCESS", "2024-01-01 00:00:00", "2024-03-31 23:59:59" ],
		[ "FAILURE", "2024-04-01 00:00:00", "2024-06-30 23:59:59" ],
		[ "SUCCESS", "2024-07-01 00:00:00", "2024-09-30 23:59:59" ]
	])

	# Finding the occurrences of a given Period by lablel
	# and returning the occurences datetimes

	? @@(FindPeriod("SUCCESS"))
	#--> [
	# 	[ "2024-01-01 00:00:00", "2024-03-31 23:59:59" ],
	# 	[ "2024-07-01 00:00:00", "2024-09-30 23:59:59" ]
	# ]

	# The same as above along with the positions on the timeline

	? @@(FindPeriodXT("SUCCESS")) + NL
	#--> [
	# 	[ "1", [ "2024-01-01 00:00:00", "2024-03-31 23:59:59" ] ],
	# 	[ "3", [ "2024-07-01 00:00:00", "2024-09-30 23:59:59" ] ]
	# ]

	# Higligting the Periods visually on the timeline
	? VizFindPeriod("SUCCESS")
}
#-->
'
             ╞══FAILURE══╡                          
╞══SUCCESS═══╡           ╞══SUCCESS═══╡             
●████████████●───────────●████████████●──────────○─►
1           2-3         4-5           6             

╭────┬─────────────────────┬─────────┬──────────────────╮
│ No │      Timepoint      │  Label  │   Description    │
├────┼─────────────────────┼─────────┼──────────────────┤
│    │ 2024-01-01 00:00:00 │         │ Timeline start   │
│  1 │ 2024-01-01 00:00:00 │ SUCCESS │ Start of SUCCESS │
│  2 │ 2024-03-31 23:59:59 │ SUCCESS │ End of SUCCESS   │
│  3 │ 2024-04-01 00:00:00 │ FAILURE │ Start of FAILURE │
│  4 │ 2024-06-30 23:59:59 │ FAILURE │ End of FAILURE   │
│  5 │ 2024-07-01 00:00:00 │ SUCCESS │ Start of SUCCESS │
│  6 │ 2024-09-30 23:59:59 │ SUCCESS │ End of SUCCESS   │
│    │ 2024-12-31 23:59:59 │         │ Timeline end     │
╰────┴─────────────────────┴─────────┴──────────────────╯
'

pf()
# Executed in 0.16 second(s) in Ring 1.24

/*--- Complex timeline with overlapping spans

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {
	AddSpan("PROJECT_A", "2024-02-01 00:00:00", "2024-05-31 23:59:59")
	AddSpan("PROJECT_B", "2024-04-01 00:00:00", "2024-07-31 23:59:59")
	AddSpan("PROJECT_C", "2024-06-01 00:00:00", "2024-09-30 23:59:59")

	AddPoint("MILESTONE1", "2024-03-15 00:00:00")
	AddPoint("MILESTONE2", "2024-08-15 00:00:00")
}

oTimeLine.Show()
#-->
'
                     ╞═══PROJECT_C════╡             
             ╞═══PROJECT_B════╡                     
     ╞MILESTONE1_A═══╡     MILESTONE2               
|────●─────●─●───────●────────●─●─────●──────────○─►
     1     2 3      4-5       6 7     8             

╭────┬─────────────────────┬────────────┬────────────────────╮
│ No │      Timepoint      │   Label    │    Description     │
├────┼─────────────────────┼────────────┼────────────────────┤
│    │ 2024-01-01 00:00:00 │            │ Timeline start     │
│  1 │ 2024-02-01 00:00:00 │ PROJECT_A  │ Start of PROJECT_A │
│  2 │ 2024-03-15 00:00:00 │ MILESTONE1 │ MILESTONE1 event   │
│  3 │ 2024-04-01 00:00:00 │ PROJECT_B  │ Start of PROJECT_B │
│  4 │ 2024-05-31 23:59:59 │ PROJECT_A  │ End of PROJECT_A   │
│  5 │ 2024-06-01 00:00:00 │ PROJECT_C  │ Start of PROJECT_C │
│  6 │ 2024-07-31 23:59:59 │ PROJECT_B  │ End of PROJECT_B   │
│  7 │ 2024-08-15 00:00:00 │ MILESTONE2 │ MILESTONE2 event   │
│  8 │ 2024-09-30 23:59:59 │ PROJECT_C  │ End of PROJECT_C   │
│    │ 2024-12-31 23:59:59 │            │ Timeline end       │
╰────┴─────────────────────┴────────────┴────────────────────╯
'

pf()
# Executed in 0.11 second(s) in Ring 1.24

#------------------------------#
#  Error Handling & Validation #
#------------------------------#

#---

pr()

o1 = new stzTimeLine("2024-10-10 12:10:10", "18:59:59")
#--> ERROR: Invalid input in pEnd! Time specified without a date.

pf()

/*---

pr()

oTimeLine = new stzTimeLine(
	:Start = "",
	:End = ""
)
#--> ERROR: Can't create the stzTimeLine object! pStart must not be empty!

pf()

/*--- Point outside boundaries (raises error)

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine.AddPoint("FUTURE", "2025-01-15 10:00:00")
#--> ERROR: Point 'FUTURE' is outside timeline boundaries 

pf()

/*--- Span outside boundaries (raises error)

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine.AddSpan("OVERFLOW", "2024-11-01 00:00:00", "2025-02-28 23:59:59")
#--> ERROR: Span 'OVERFLOW' is outside timeline boundaries 

pf()

/*--- Invalid span (start >= end)

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine.AddSpan("INVALID", "2024-03-15 10:00:00", "2024-03-15 10:00:00")
#--> ERROR: Span 'INVALID' has invalid dates. Start time (2024-03-15 10:00:00)
# must be before end time (2024-03-15 10:00:00)

pf()

/*---

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

# Should auto-adjust height for overlapping spans
oTimeLine.AddSpan("SPAN1", "2024-01-01", "2024-06-30")
oTimeLine.AddSpan("SPAN2", "2024-03-01", "2024-09-30")
oTimeLine.AddSpan("SPAN3", "2024-05-01", "2024-12-31")

? oTimeLine.Show()  # Should display all spans without overlap issues
#-->
'                                                    
                 ╞═════════════SPAN3══════════════╡ 
         ╞═══════════SPAN2════════════╡             
╞═════════SPAN1══════════╡                          
●────────●───────●───────●────────────●───────────●○─►
1        2       3       4            5           6 

╭────┬─────────────────────┬───────┬────────────────╮
│ No │      Timepoint      │ Label │  Description   │
├────┼─────────────────────┼───────┼────────────────┤
│    │ 2024-01-01 00:00:00 │       │ Timeline start │
│  1 │ 2024-01-01 00:00:00 │ SPAN1 │ Start of SPAN1 │
│  2 │ 2024-03-01 00:00:00 │ SPAN2 │ Start of SPAN2 │
│  3 │ 2024-05-01 00:00:00 │ SPAN3 │ Start of SPAN3 │
│  4 │ 2024-06-30 00:00:00 │ SPAN1 │ End of SPAN1   │
│  5 │ 2024-09-30 00:00:00 │ SPAN2 │ End of SPAN2   │
│  6 │ 2024-12-31 00:00:00 │ SPAN3 │ End of SPAN3   │
│    │ 2024-12-31 23:59:59 │       │ Timeline end   │
╰────┴─────────────────────┴───────┴────────────────╯
'

pf()
# Executed in 0.10 second(s) in Ring 1.24

/*---

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-32 23:59:59"
)
#--> ERROR: Invalid datetime format (2024-12-32 23:59:59)!

pf()

/*---

pr()

o1 = new stzTimeLine(
	:Start = "2024-03-01 00:00:00",
	:End   = "2024-03-30 00:00:00"
)

//o1.AddPoint("ONE", "10:12:25")
#--> ERROR MESSAGE: Invalid input! Time specified without a date.
 
# When only a date is provide, Softanza extends it with a " 00:00:00" time
o1.AddPoint("ONE", "2024-03-12")
? @@(o1.Points())
#--> [ [ "ONE", "2024-03-12 00:00:00" ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*---

pr()

o1 = new stzTimeLine(
	:Start = "2024-03-01 00:00:00",
	:End   = "2024-03-30 00:00:00"
)

o1 {

	AddMoment("One", "2024-03-15 10:00:00")
	AddMoment("Two", "2024-03-15 10:00:00")
	AddMoment("Three", "2024-03-15 10:00:00")

	AddSpan("Phase1", "2024-03-15 00:00:00", "2024-03-18 10:00:00")

	? @@NL(WhatsAt("2024-03-15 10:00:00")) + NL
	#--> [
	# [
	# 	[ "One", "point" ],
	# 	[ "Two", "point" ],
	# 	[ "Three", "point" ],
	# 	[ "Phase1", "span" ]
	# ]

	? @@NL(WhatsAt("2024-03-15")) + NL         # Date only: all events on that date
	#--> [
	# 	[ "One", "point" ],
	# 	[ "Two", "point" ],
	# 	[ "Three", "point" ],
	# 	[ "Phase1", "span" ]
	# ]

	? @@NL(WhatsAt("10:00:00") )            # Time only: all events at that time
	#--> [
	# 	[ "One", "point" ],
	# 	[ "Two", "point" ],
	# 	[ "Three", "point" ],
	# 	[ "Phase1", "span" ]
	# ]

	? @@NL(PointNamesXT()) + NL           # [["EVENT1", 3], ["EVENT2", 1]]
	#--> [
	# 	[ "One", 1 ],
	# 	[ "Two", 1 ],
	# 	[ "Three", 1 ]
	# ]

	? @@(WhatsBetween("2024-03-12", "2024-03-18"))
	#--> [ "One", "Two", "Three" ]

}

pf()
# Executed in 0.05 second(s) in Ring 1.24

/*---

pr()

o1 = new stzTimeLine(
	:Start = "2024-03-01 00:00:00",
	:End   = "2024-03-30 00:00:00"
)

o1 {

	AddMoment('', "2024-03-15 10:00:00")
	AddMoment('', "2024-03-15 10:00:00")
	AddMoment('', "2024-03-15 10:00:00")

	AddSpan('', "2024-03-15 00:00:00", "2024-03-18 10:00:00")

	Show()
}
#-->
'              
                         ╞═════╡                    
|────────────────────────◉─────●─────────────────○─►
                        1-2    5                    
                        3-4                         

╭────┬─────────────────────┬────────┬─────────────────╮
│ No │      Timepoint      │ Label  │   Description   │
├────┼─────────────────────┼────────┼─────────────────┤
│    │ 2024-03-01 00:00:00 │        │ Timeline start  │
│  1 │ 2024-03-15 00:00:00 │ Phase1 │ Start of Phase1 │
│  2 │ 2024-03-15 10:00:00 │ One    │ One event       │
│  3 │ 2024-03-15 10:00:00 │ Two    │ Two event       │
│  4 │ 2024-03-15 10:00:00 │ Three  │ Three event     │
│  5 │ 2024-03-18 10:00:00 │ Phase1 │ End of Phase1   │
│    │ 2024-03-30 00:00:00 │        │ Timeline end    │
╰────┴─────────────────────┴────────┴─────────────────╯
'

pf()
# Executed in 0.08 second(s) in Ring 1.24

#------------------------------------#
#  Blocking regions of the timeline  #
#------------------------------------#

/*--- Simple blocked maintenance period

pr()

oTimeline = new stzTimeLine("2024-01-01", "2024-12-31")
oTimeline.AddBlockedSpan("MAINTENANCE", "2024-06-15 09:00:00", "2024-06-15 17:00:00")
oTimeline.AddPoint("EVENT1", "2024-06-15 08:00:00")  # OK
oTimeline.AddPoint("EVENT2", "2024-06-15 12:00:00")  # Error: blocked
#--> Point 'EVENT2' falls within a blocked span 

pf()

/*--- Multiple blocked periods

pr()

oTimeline = new stzTimeLine("2024-01-01", "2024-12-31")

oTimeline.AddBlockedSpan("Q2_FREEZE", "2024-04-01", "2024-06-30")
oTimeline.AddBlockedSpan("HOLIDAY", "2024-12-20", "2024-12-31")

oTimeline.AddSpan("PROJECT", "2024-05-01", "2024-05-15")
#--> ERROR: Span 'PROJECT' overlaps with a blocked span 

oTimeline.AddSpan("PLANNING", "2024-07-01", "2024-07-15") # OK

pf()


/*--- Checking blocks before operations

pr()

oTimeline = new stzTimeLine("2024-01-01", "2024-12-31")
oTimeline.AddBlockedSpan("BLACKOUT", "2024-08-01 00:00:00", "2024-08-08 23:59:59")

if oTimeline.IsBlocked("2024-08-05 14:30:00")
	? "Cannot add event during blackout"
ok
#--> Cannot add event during blackout

if oTimeline.IsRangeBlocked("2024-08-07", "2024-08-10")
	? "Span partially blocked"
ok
#--> Span partially blocked

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Block specific maintenance points

pr()

oTimeline = new stzTimeLine("2024-01-01", "2024-01-31")
oTimeline.AddBlockedPoint("2024-01-15 12:00:00")
oTimeline.AddBlockedPoint("2024-01-20 09:00:00")

oTimeline.AddPoint("MEETING", "2024-01-15 12:00:00")
#--> ERROR: Point 'MEETING' falls within a blocked span or blocked point 

oTimeline.AddPoint("LAUNCH", "2024-01-15 14:00:00")   # OK

pf()

/*--- Mixed blocked spans and points

pr()

oTimeline = new stzTimeLine("2024-06-01", "2024-06-30")
oTimeline.AddBlockedSpan("FREEZE", "2024-06-15", "2024-06-20")
oTimeline.AddBlockedPoint("2024-06-10 10:00:00")

//oTimeline.AddPoint("EVENT1", "2024-06-10 10:00:00")
#--> ERROR: Point 'EVENT1' falls within a blocked span or blocked point 

oTimeline.AddPoint("EVENT2", "2024-06-17 14:00:00")
#--> oint 'EVENT2' falls within a blocked span or blocked point 

oTimeline.AddPoint("EVENT3", "2024-06-05 09:00:00")  # OK

pf()

/*--- Visualize blocks
*/
pr()

oTimeline = new stzTimeLine("2024-01-01", "2024-01-31")
oTimeline.AddBlockedSpan("MAINTENANCE", "2024-01-10", "2024-01-12")
oTimeline.AddBlockedPoints(["2024-01-20 08:00:00", "2024-01-25 15:00:00"])
oTimeline.AddPoint("TASK1", "2024-01-05 10:00:00")
oTimeline.AddPoint("TASK2", "2024-01-15 10:00:00")
oTimeline.Show()  # Shows 'x' for blocked regions and points
#-->
'
|───────●──────XXXXX─────●───────X────────X──────○─►
        1                2               

╭────┬─────────────────────┬───────┬────────────────╮
│ No │      Timepoint      │ Label │  Description   │
├────┼─────────────────────┼───────┼────────────────┤
│    │ 2024-01-01 00:00:00 │       │ Timeline start │
│  1 │ 2024-01-05 10:00:00 │ TASK1 │ TASK1 event    │
│  2 │ 2024-01-15 10:00:00 │ TASK2 │ TASK2 event    │
│    │ 2024-01-31 00:00:00 │       │ Timeline end   │
╰────┴─────────────────────┴───────┴────────────────╯
'

pf()
# Executed in 0.09 second(s) in Ring 1.24

/*--- Complex timeline with blocked regions and points

pr()

oTimeLine = new stzTimeLine(
	:Start = "2024-01-01 00:00:00",
	:End = "2024-12-31 23:59:59"
)

oTimeLine {

	# Regular spans

	AddSpan("SPAN1", "2024-01-01", "2024-06-30")
	AddSpan("SPAN2", "2024-03-01", "2024-09-30")
	AddSpan("SPAN3", "2024-05-01", "2024-12-31")

	# Blocked spans (maintenance windows, freezes)

	AddBlockedSpan("FREEZE1", "2024-01-20", "2024-02-28")
	AddBlockedSpan("FREEZE2", "2024-07-01", "2024-07-15")
	AddBlockedSpan("MAINTENANCE", "2024-11-15", "2024-11-20")

	# Blocked individual points

	AddBlockedPoint("2024-03-15 10:30:00")
	AddBlockedPoint("2024-06-15 14:00:00")
	AddBlockedPoint("2024-10-05 09:00:00")

	# Regular points

	AddPoint("KICKOFF", "2024-01-05 09:00:00")
	//oTimeLine.AddPoint("REVIEW1", "2024-03-15 10:30:00")  # Will error - blocked point
	AddPoint("MEETING", "2024-05-10 11:00:00")
	//oTimeLine.AddPoint("DEMO", "2024-06-15 14:00:00")     # Will error - blocked point
	AddPoint("SYNC", "2024-08-20 15:00:00")
	AddPoint("FINAL", "2024-11-10 10:00:00")

	Show()
}
#-->
'
                ╞=============SPAN3==============╡ 
         ╞===========SPAN2============╡             
╞=========SPAN1SPAN3=====╡                      SPAN
●●─XXXXXX●─X─────●●────X─●XX────●─────●X───●XX────●○─►
12       3       45      6      7     8    9     10 

╭────┬─────────────────────┬─────────┬────────────────╮
│ No │      Timepoint      │  Label  │  Description   │
├────┼─────────────────────┼─────────┼────────────────┤
│    │ 2024-01-01 00:00:00 │         │ Timeline start │
│  1 │ 2024-01-01 00:00:00 │ SPAN1   │ Start of SPAN1 │
│  2 │ 2024-01-05 09:00:00 │ KICKOFF │ KICKOFF event  │
│  3 │ 2024-03-01 00:00:00 │ SPAN2   │ Start of SPAN2 │
│  4 │ 2024-05-01 00:00:00 │ SPAN3   │ Start of SPAN3 │
│  5 │ 2024-05-10 11:00:00 │ MEETING │ MEETING event  │
│  6 │ 2024-06-30 00:00:00 │ SPAN1   │ End of SPAN1   │
│  7 │ 2024-08-20 15:00:00 │ SYNC    │ SYNC event     │
│  8 │ 2024-09-30 00:00:00 │ SPAN2   │ End of SPAN2   │
│  9 │ 2024-11-10 10:00:00 │ FINAL   │ FINAL event    │
│ 10 │ 2024-12-31 00:00:00 │ SPAN3   │ End of SPAN3   │
│    │ 2024-12-31 23:59:59 │         │ Timeline end   │
╰────┴─────────────────────┴─────────┴────────────────╯
'

pf()
# Executed in 0.35 second(s) in Ring 1.24
