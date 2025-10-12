load "../stzbase.ring"

#-------------------------------------------#
#  Basic TimeLines Creation with Boundaries #
#-------------------------------------------#

/*--- Creating timelines with lanes, start, and end boundaries

pr()

oTimeLines = new stzTimeLines([
	:Lanes = [ "Team A", "Team B" ],
	:Start = "2024-01-01 00:00:00",
	:End   = "2024-12-31 23:59:59"
])

oTimeLines {
	? GlobalStart()
	#--> 2024-01-01 00:00:00

	? GlobalEnd()
	#--> 2024-12-31 23:59:59

	? Duration()
	#--> 31622399 (seconds)

	? DurationQ().ToHuman()
	#--> 1 year

	? NumberOfLanes()
	#--> 2

	? @@( Lanes() )
	#--> [ "TEAM A", "TEAM B" ]  # Note: labels uppercased if applicable, but lane names may vary
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Creating timelines with date-only inputs
*/
pr()

o1 = new stzTimeLines([
	:Lanes = [ "Dev", "QA" ],
	:From  = "2024-10-10",
	:To    = "2024-10-22 16:40:00"
])

? @@NL( o1.Content() )  # Time added automatically to "2024-10-10"
#--> [
#	[ "start", "2024-10-10 00:00:00" ],
#	[ "end", "2024-10-22 16:40:00" ],
#	[
#		"lanes",
#		[ "DEV", "QA" ]
#	],
#	[
#		"timelines",
#		[
#			[ "lane", "DEV" ],
#			[ "content", [ ... ] ]  # Empty timeline content
#		],
#		[
#			[ "lane", "QA" ],
#			[ "content", [ ... ] ]
#		]
#	]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Setting global boundaries without time

pr()

o1 = new stzTimeLines( @{
	:Lanes = [ "Project1", "Project2" ],
	:Start = "2024-01-01",
	:End   = "2024-03-20"
} )

o1.AddPointToLane("Project1", "EVENT", "2024-03-15")  # Time added automatically
? o1.Lane("Project1").Point("EVENT")
#--> 2024-03-15 00:00:00

o1.AddSpanToLane("Project2", "WEEK", "2024-03-01", "2024-03-07")
? @@( o1.Lane("Project2").Span("WEEK") )
#--> [ "2024-03-01 00:00:00", "2024-03-07 00:00:00" ]

o1.SetGlobalStart("2024-01-01")
? o1.GlobalStart()
#--> 2024-01-01 00:00:00

? @@NL( o1.Content() ) + NL
#--> Similar structure as above with added points/spans in respective lanes

pf()
# Executed in 0.02 second(s) in Ring 1.24

#-------------------------#
#  Lane Management        #
#-------------------------#

/*--- Adding and removing lanes

pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Team A" ],
	:Start = "2024-01-01 00:00:00",
	:End   = "2024-12-31 23:59:59"
} )

oTimeLines {
	AddLane("Team B")
	AddLane("Resources")

	? NumberOfLanes()
	#--> 3

	? @@( Lanes() )
	#--> [ "TEAM A", "TEAM B", "RESOURCES" ]

	? HasLane("team b")  # Case-insensitive if implemented
	#--> TRUE

	RemoveLane("Resources")
	? NumberOfLanes()
	#--> 2

	? HasLane("Resources")
	#--> FALSE
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#--------------------------------#
#  Adding Points/Spans to Lanes  #
#--------------------------------#

/*--- Adding points to specific lanes

pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Team A", "Team B" ],
	:Start = "2024-01-01 00:00:00",
	:End   = "2024-12-31 23:59:59"
} )

oTimeLines {
	AddPointToLane("Team A", "NEW_YEAR", "2024-01-01 00:00:00")
	AddPointToLane("Team B", "VALENTINE", "2024-02-14 00:00:00")
	AddPointToLane("Team A", "SUMMER", "2024-06-21 00:00:00")

	? Lane("Team A").CountPoints()
	#--> 2

	? @@( Lane("Team A").PointNames() )
	#--> [ "NEW_YEAR", "SUMMER" ]

	? Lane("Team B").Point("VALENTINE")
	#--> 2024-02-14 00:00:00

	? Lane("Team A").HasPoint("summer")
	#--> TRUE
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Adding multiple points and spans to lanes

pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Dev", "QA" ],
	:Start = "2024-01-01 00:00:00",
	:End   = "2024-12-31 23:59:59"
} )

oTimeLines {
	AddPointsToLane("Dev", [
		[ "CODE_REVIEW", "2024-03-15 10:00:00" ],
		[ "CODE_REVIEW", "2024-05-16 14:30:00" ]
	])

	AddSpansToLane("QA", [
		[ "TEST_PHASE", "2024-04-01", "2024-06-30" ]
	])

	? Lane("Dev").CountPoints()
	#--> 2

	? Lane("QA").CountSpans()
	#--> 1
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Renaming labels in specific lanes

pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Team A", "Team B" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddPointsToLane("Team A", [
		[ "HR-EVAL", "2024-03-15 10:00:00" ],
		[ "KICKOFF", "2024-05-16 14:30:00" ]
	])

	AddSpansToLane("Team B", [
		[ "PREP", "2024-03-15", "2024-05-15" ],
		[ "HR-EVAL", "2024-11-01", "2024-11-25" ]
	])

	RenameLabelInLane("Team A", "HR-EVAL", "PERF-REVIEW")
	RenameLabelInLane("Team B", "PREP", "PREPARATION")

	? @@NL( Content() )  # Show updated labels in respective lanes
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

#-------------------------#
#  Querying Across Lanes  #
#-------------------------#

/*--- Querying what's at a specific time across lanes

pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Team A", "Team B" ],
	:Start = "2024-01-01 00:00:00",
	:End   = "2024-12-31 23:59:59"
} )

oTimeLines {
	AddPointToLane("Team A", "EVENT1", "2024-03-15 10:00:00")
	AddSpanToLane("Team B", "PHASE1", "2024-03-10", "2024-03-20")

	? @@NL( WhatsAt("2024-03-15 10:00:00") )
	#--> [
	#	[ "lane", "TEAM A" ],
	#	[ "events", [ [ "EVENT1", "point" ] ] ],
	#	[ "lane", "TEAM B" ],
	#	[ "events", [ [ "PHASE1", "span" ] ] ]
	# ]
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Detecting cross-lane overlaps

pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Dev", "QA" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddSpanToLane("Dev", "CODING", "2024-04-01", "2024-05-15")
	AddSpanToLane("QA", "TESTING", "2024-05-10", "2024-06-01")

	? @@( CrossLaneOverlaps() )
	#--> [ [ [ "DEV", "QA" ], "CODING", "TESTING", 432000 ] ]  # 5 days in seconds
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

#-------------------------------------#
#  Blocking Regions in Specific Lanes #
#-------------------------------------#

/*--- Adding blocked spans to lanes

pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Resources", "Team" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddBlockedSpanToLane("Resources", "DOWNTIME", "2024-06-15 09:00:00", "2024-06-15 17:00:00")
	// AddPointToLane("Team", "EVENT", "2024-06-15 12:00:00")  # OK, since block is in different lane

	AddPointToLane("Resources", "TASK", "2024-06-15 12:00:00")
	#--> ERROR: Point 'TASK' falls within a blocked span in lane 'Resources'
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Checking blocks in lanes

pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Server" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddBlockedSpanToLane("Server", "BLACKOUT", "2024-08-01 00:00:00", "2024-08-08 23:59:59")

	if IsBlockedInLane("Server", "2024-08-05 14:30:00")
		? "Cannot add event during blackout in Server lane"
	ok
	#--> Cannot add event during blackout in Server lane
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

#-------------------------#
#  Visualization          #
#-------------------------#

/*--- Basic show with multiple lanes

pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Team A", "Team B" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddSpanToLane("Team A", "PROJECT", "2024-03-01", "2024-05-31")
	AddPointToLane("Team B", "HR-EVAL", "2024-03-15")

	? Show()
	#--> Multi-lane ASCII visualization with lanes labeled on left
}

pf()
# Executed in 0.05 second(s) in Ring 1.24

/*--- Show uncovered across lanes

pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Dev", "QA" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddSpanToLane("Dev", "BUSY", "2024-03-01", "2024-05-31")
	AddSpanToLane("QA", "BUSY", "2024-08-01", "2024-09-20")

	? ShowUncovered()
	#--> Visualization with '/' for uncovered in each lane
}

pf()
# Executed in 0.05 second(s) in Ring 1.24

/*--- Highlighting across lanes

pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Team A", "Team B" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddPointToLane("Team A", "HR-EVAL", "2024-03-15")
	AddSpanToLane("Team B", "HR-EVAL", "2024-08-01", "2024-08-31")

	VizFind("HR-EVAL")
	#--> Shows highlighted '█' in both lanes for "HR-EVAL"
}

pf()
# Executed in 0.05 second(s) in Ring 1.24

#-------------------------#
#  Conversion and Misc    #
#-------------------------#

/*--- Converting to single TimeLine

pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Dev", "QA" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddPointToLane("Dev", "EVENT", "2024-03-15")
	AddSpanToLane("QA", "TEST", "2024-04-01", "2024-04-30")

	oMerged = ToTimeLine()
	? oMerged.Point("DEV-EVENT")
	#--> 2024-03-15 00:00:00

	? @@( oMerged.Span("QA-TEST") )
	#--> [ "2024-04-01 00:00:00", "2024-04-30 00:00:00" ]
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*--- Clearing all lanes

pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Team A" ],
	:Start = "2024-01-01",
	:End   = "2024-12-31"
} )

oTimeLines {
	AddPointToLane("Team A", "EVENT", "2024-03-15")

	Clear()
	? Lane("Team A").CountPoints()
	#--> 0
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Complex example with multiple lanes, blocks, and visualization

pr()

oTimeLines = new stzTimeLines( @{
	:Lanes = [ "Dev", "QA", "Resources" ],
	:Start = "2024-01-01 00:00:00",
	:End   = "2024-12-31 23:59:59"
} )

oTimeLines {

	# Spans in lanes
	AddSpanToLane("Dev", "CODING", "2024-01-01", "2024-06-30")
	AddSpanToLane("QA", "TESTING", "2024-03-01", "2024-09-30")
	AddSpanToLane("Resources", "AVAILABLE", "2024-05-01", "2024-12-31")

	# Blocked spans
	AddBlockedSpanToLane("Resources", "DOWNTIME", "2024-07-01", "2024-07-15")

	# Points
	AddPointToLane("Dev", "KICKOFF", "2024-01-05 09:00:00")
	AddPointToLane("QA", "MEETING", "2024-05-10 11:00:00")

	? Show()
	#--> Multi-lane visualization with spans, points, and blocks

	? @@NL( UncoveredPeriodsPerLane() )
	#--> List of uncovered periods for each lane
}

pf()
# Executed in 0.35 second(s) in Ring 1.24
