
load "../stzbase.ring"

/*----------------------------------------#
#  Test 1: Basic calendar creation        #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    ? Start()
    #--> 2024-10-01
    
    ? End_()
    #--> 2024-10-31
    
    ? Year()
    #--> 2024
    
    ? MonthName()
    #--> October
    
    ? TotalDays()
    #--> 31
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 2: Working days configuration     #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    
    ? IsWorkingDay("2024-10-03")
    #--> 1
    
    ? IsWorkingDay("2024-10-05")
    #--> 0
    
    ? FirstWorkingDay()
    #--> 2024-10-01
    
    ? len(WorkingDays())
    #--> 23
}

pf()
# Executed in 0.07 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 3: Holiday management             #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    AddHoliday("2024-10-05", "Independence Day")
    AddHoliday("2024-10-15", "National Day")
    
    ? IsHoliday("2024-10-05")
    #--> 1
    
    ? HolidayName("2024-10-05")
    #--> Independence Day
    
    ? len(Holidays())
    #--> 2
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 4: Business hours and breaks      #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    
    ? @@NL(BusinessHours())
	#-->
	'
	[
		[ "from", "09:00:00" ],
		[ "to", "17:00:00" ]
	]
	'

    ? @@NL(Breaks())
	#-->
	'
	[
		[ "12:00:00", "13:00:00", "Lunch" ]
	]
	'
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 5: Capacity calculations          #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Independence Day")
    
    ? AvailableHoursN()
    #--> 161

    ? AvailableDaysN()
    #--> 23

    ? AvailableHoursOnN("2024-10-10")
    #--> 7

    ? AvailableHoursBetweenN("2024-10-01", "2024-10-15")
    #--> 7

}

pf()
# Executed in 0.20 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 6: Task fitting                   #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    
    ? CanFit("2024-10-10", "5")
    #--> TRUE

    ? CanFit("2024-10-10", "10")
    #--> FALSE

    ? @@NL( FirstAvailableSlot("4") )
    #--> [ "2024-10-01 09:00:00", "2024-10-01 04:00:00" ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*-----------------------------------------#
#  Test 7: Date information                #
#------------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Independence Day")
    
    ? @@NL(DateInfo("2024-10-03"))
    #-->
	'
	[
		[ "date", "2024-10-03" ],
		[ "isWorkingDay", 1 ],
		[ "isHoliday", 0 ],
		[ "availableHours", 7 ]
	]
	'

    ? @@NL(RangeInfo("2024-10-01", "2024-10-15"))
    #-->
	'
	[
		[ "startDate", "2024-10-01" ],
		[ "endDate", "2024-10-15" ],
		[ "totalDays", 15 ],
		[ "workingDays", 11 ],
		[ "weekendDays", 4 ],
		[ "holidays", 0 ],
		[ "availableHours", 77 ],
		[ "overlappingEvents", [  ] ]
	]
	'

}

pf()
# Executed in 0.05 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 8: Display options                #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Independence Day")
    
    Show()
}
#-->
'
                October 2024
╭─────────────────────────────────────────╮
│ Mon   Tue   Wed   Thu   Fri   Sat   Sun │
├─────────────────────────────────────────┤
│        1     2     3     4    [5]   ░░  │
│  7     8     9     10    11   ░░    ░░  │
│  14    15    16    17    18   ░░    ░░  │
│  21    22    23    24    25   ░░    ░░  │
│  28    29    30    31                   │
╰─────────────────────────────────────────╯

Legend:
  [D] = Holiday
  ░ = Weekend

╭───────────────────────┬──────────────────────────╮
│        Metric         │          Value           │
├───────────────────────┼──────────────────────────┤
│ Total Days            │                       31 │
│ Working Days          │                       23 │
│ Weekend Days          │                        7 │
│ Holidays              │                        1 │
│ Total Available Hours │                      161 │
│ Average Hours Per Day │                        7 │
│ First Working Day     │ 2024-10-01               │
│ Last Working Day      │ 2024-10-31               │
│ Business Hours        │ 09:00:00 - 17:00:00      │
│ Holidays Listed       │ Independence Day         │
│ Breaks                │ Lunch: 12:00:00-13:00:00 │
╰───────────────────────┴──────────────────────────╯
'

pf()
# Executed in 0.34 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 9: Heat map visualization         #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Independence Day")
    
    ShowHeatMap()
}
#-->
'
October 2024 - Capacity Heat Map

Week 1:  ▓▓▓▓▓ (5/5 days available)
Week 2:  ▓▓▓▓▓ (5/5 days available)
Week 3:  ▓▓▓▓▓ (5/5 days available)
Week 4:  ▓▓▓▓▓ (5/5 days available)
Week 5:  ▓▓▓░░ (3/5 days available)

Legend:
  ▓ = Available working day
  ░ = Weekend or holiday

'

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 10: Detailed table                #
/*----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Independence Day")
    
    ShowTable()

    # You can get the table content using:
    # ? @@NL( DetailedTable() )

    # And you can cast it to a stzTable object:
    # DetailedTableQ().Show()
}
#-->
'
October 2024 - Detailed View

╭────────────┬───────────┬───────────────────┬───────────────────┬───────────╮
│    Date    │    Day    │     Business      │      Breaks       │ Available │
├────────────┼───────────┼───────────────────┼───────────────────┼───────────┤
│ 2024-10-01 │ Tuesday   │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-02 │ Wednesday │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-03 │ Thursday  │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-04 │ Friday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-05 │ Saturday  │ HOLIDAY           │                   │ 0h        │
│ 2024-10-06 │ Sunday    │ WEEKEND           │                   │ 0h        │
│ 2024-10-07 │ Monday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-08 │ Tuesday   │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-09 │ Wednesday │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-10 │ Thursday  │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-11 │ Friday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-12 │ Saturday  │ WEEKEND           │                   │ 0h        │
│ 2024-10-13 │ Sunday    │ WEEKEND           │                   │ 0h        │
│ 2024-10-14 │ Monday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-15 │ Tuesday   │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-16 │ Wednesday │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-17 │ Thursday  │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-18 │ Friday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-19 │ Saturday  │ WEEKEND           │                   │ 0h        │
│ 2024-10-20 │ Sunday    │ WEEKEND           │                   │ 0h        │
│ 2024-10-21 │ Monday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-22 │ Tuesday   │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-23 │ Wednesday │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-24 │ Thursday  │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-25 │ Friday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-26 │ Saturday  │ WEEKEND           │                   │ 0h        │
│ 2024-10-27 │ Sunday    │ WEEKEND           │                   │ 0h        │
│ 2024-10-28 │ Monday    │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-29 │ Tuesday   │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-30 │ Wednesday │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
│ 2024-10-31 │ Thursday  │ 09:00:00-17:00:00 │ 12:00:00-13:00:00 │ 7h        │
╰────────────┴───────────┴───────────────────┴───────────────────┴───────────╯

Summary:
  Total Days: 31
  Working Days: 23
  Available Hours: 161
'
pf()
# Executed in 0.50 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 11: Navigation                    #
#-----------------------------------------#

/*--- Navigation to next and previous month

pr()

oCal = new stzCalendar([2024, 10])
oCal {
	? Current()
	#--> October 2024

	? NextMonth() # Does not move the calendar, just returns the month
	#--> November

	? Current() # Calendar is still in october!
	#--> October 2024

	GotoNextMonth() # Now it will move to next month

	? Current() + NL
	#--> November 2024

	# Let's do the same gymanastics with previous month

	? PreviousMonth()
	#--> October

	? Current()
	#--> November 2024

	GoToPreviousMonth()

	? Current() + NL
	#--> October 2024

}
# Executed in 0.01 second(s) in Ring 1.24

/*--- Navigating to Next and previous year

pr()

oCal = new stzCalendar([2024, 10])
oCal {
	? Current()
	#--> October 2024

	? NextYear() # Does not move the calendar, just returns the Year
	#--> 2025

	? Current() # Calendar is still in october!
	#--> October 2024

	GotoNextYear() # Now it will move to next Year

	? Current() + NL
	#--> November 2025

	# Let's do the same gymanastics with previous Year

	? PreviousYear()
	#--> 2024

	? Current()
	#--> November 2025

	GoToPreviousYear()

	? Current() + NL
	#--> October 2024

}


pf()
# Executed in almost 0 second(s) in Ring 1.24

/*--- Navigation next/previous day

...

/*--- Navigating to a given date #TODO

pr()

oCal = new stzCalendar([2024, 10])
oCal {
	? Current()
	#--> October 2024

	GoTo("01/12/2026") #TODO fix

	? Current()
}

pf()

/*--- Getting current info #TODO

pr()

oCal = new stzCalendar([2024, 10])
oCal {
	? Current()
	#--> October 2024	# Add the current day

	? @@(CurrentXT())
	#--> [ :year = ..., :month = ..., :day = ... ]

	? CurrentYear()

	? CurrentMonth() # for name and CurrentMonthN() for number

	? CurrentDay()

}

#NOTE: All dispaly of calendar should show the current day with a distinguuisded char

/*----------------------------------------#
#  Test 12: Copy and comparison           #
#-----------------------------------------#

pr()

oCal1 = new stzCalendar([2024, 10])
oCal1.SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])

oCal2 = oCal1.Copy()
oCal2.GotoNextMonth()

? "Original: " + oCal1.Current() #--> October 2024
? "Copy: " + oCal2.Current()	 #--> October 2024

? @@NL(oCal1.CompareWith(oCal2))
#-->
'
[
	[
		"Metric",
		"This Calendar",
		"Other Calendar",
		"Difference"
	],
	[
		"Total Days",
		31,
		30,
		1
	],
	[
		"Working Days",
		23,
		21,
		2
	],
	[
		"Available Hours",
		184,
		168,
		16
	],
	[
		"Holidays",
		0,
		0,
		0
	],
	[
		"Total Weeks",
		5,
		5,
		0
	]
]
'

pf()
# Executed in 0.28 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 13: Data export                   #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Independence Day")
    SetBusinessHours("09:00:00", "17:00:00")
}

? @@NL(oCal.ToHash())
#-->
'
[
	[ "startdate", "2024-10-01" ],
	[ "enddate", "2024-10-31" ],
	[ "year", 2024 ],
	[ "month", 10 ],
	[ "quarter", "" ],
	[ "totaldays", 31 ],
	[ "workingdays", 23 ],
	[ "availablehours", 184 ],
	[
		"workingdayslist",
		[
			1,
			2,
			3,
			4,
			5
		]
	],
	[
		"holidays",
		[
			[ "2024-10-05", "Independence Day" ]
		]
	],
	[ "breaks", [  ] ],
	[ "businessstart", "09:00:00" ],
	[ "businessend", "17:00:00" ]
]
'

pf()
# Executed in 0.16 second(s) in Ring 1.24

/*-----------------------------------------#
#  Test 14: Custom constraints             #
#------------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    
    AddConstraint("MaintWindow", [:Every, :Wednesday, :From, "14:00", :To, "16:00"])
    
    ? "Hours on Wednesday 2024-10-09: " + ApplyConstraints("2024-10-09")
    ? @@NL(Constraints())
}
#-->
'
Hours on Wednesday 2024-10-09: 5
[
	[
		"MaintWindow",
		[
			"every",
			"wednesday",
			"from",
			"14:00",
			"to",
			"16:00"
		]
	]
]
'

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*-----------------------------------------#
#  Test 15: Stats                          #
#------------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Independence Day")
    
    ? @@NL(Stats())
}
#-->
'
[
	[ "metric", "value" ],
	[ "Total Days", 31 ],
	[ "Working Days", 23 ],
	[ "Weekend Days", 7 ],
	[ "Holidays", 1 ],
	[ "Total Available Hours", 161 ],
	[ "Average Hours Per Day", 7 ],
	[ "First Working Day", "2024-10-01" ],
	[ "Last Working Day", "2024-10-31" ]
]
'

pf()
# Executed in 0.22 second(s) in Ring 1.24

/*----------------------------#
#  Multi-calendar Comparsion  #
#-----------------------------#

pr()

oCal1 = new stzCalendar([ 2024, 2 ])
oCal2 = new stzCalendar([ 2029, 2 ])

? oCal1.CompareToQR(oCal2, :stzTable).Show()
#-->
'
╭─────────────────┬───────────────┬───────────────┬────────────╮
│     Metric      │ February 2024 │ February 2029 │ Difference │
├─────────────────┼───────────────┼───────────────┼────────────┤
│ Total Days      │            29 │            28 │          1 │
│ Working Days    │            21 │            20 │          1 │
│ Available Hours │           168 │           160 │          8 │
│ Holidays        │             0 │             0 │          0 │
│ Total Weeks     │             5 │             4 │          1 │
╰─────────────────┴───────────────┴───────────────┴────────────╯
'

pf()
# Executed in 0.31 second(s) in Ring 1.24

/*-----------------------#
#  TimeLine Integration  #
#------------------------#

pr()

oCal = new stzCalendar([ 2024, 10 ])

oTimeline = new stzTimeLine("2024-10-01", "2024-10-31")
oTimeline.AddPoint("STANDUP", "2024-10-10 09:00:00")
oTimeline.AddSpan("PROJECT", "2024-10-15", "2024-10-20")

oCal.MarkTimeline(oTimeline)
oCal.Show()  # Events appear as ● and ▬
#-->
'
                October 2024
╭─────────────────────────────────────────╮
│ Mon   Tue   Wed   Thu   Fri   Sat   Sun │
├─────────────────────────────────────────┤
│        1     2     3     4    ░░    ░░  │
│  7     8     9    ●10    11   ░░    ░░  │
│  14   ▬15   ▬16   ▬17   ▬18   ▬░░   ▬░░ │
│  21    22    23    24    25   ░░    ░░  │
│  28    29    30    31                   │
╰─────────────────────────────────────────╯

Legend:
  ░ = Weekend
  ● = Timeline-event
  ▬ = Timeline-span

╭───────────────────────┬─────────────────────╮
│        Metric         │        Value        │
├───────────────────────┼─────────────────────┤
│ Total Days            │                  31 │
│ Working Days          │                  23 │
│ Weekend Days          │                   8 │
│ Holidays              │                   0 │
│ Total Available Hours │                 184 │
│ Average Hours Per Day │                   8 │
│ First Working Day     │ 2024-10-01          │
│ Last Working Day      │ 2024-10-31          │
│ Business Hours        │ 09:00:00 - 17:00:00 │
╰───────────────────────┴─────────────────────╯
'

? oCal.ConflictsWith(oTimeline)
#--> TRUE (events hit holidays/weekends)

? @@NL(oCal.TimelineEvents())    # Count events, analyze
#-->
'
[
	[
		"points",
		[
			[ "STANDUP", "2024-10-10 09:00:00" ]
		]
	],
	[
		"spans",
		[
			[
				"PROJECT",
				"2024-10-15 00:00:00",
				"2024-10-20 00:00:00"
			]
		]
	]
]
'

pf()
# Executed in 0.61 second(s) in Ring 1.24

/*---------------------------------------#
#  Real world example : sprint planning  #
#----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])
oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Independence Day")
}

aTasks = [
    ["Design", 40],
    ["Development", 80],
    ["Testing", 32]
]

nRequired = 0
for aTask in aTasks
    nRequired += aTask[2]
next

nAvailable = oCal.AvailableHoursN()

if nRequired <= nAvailable
    ? "✓ Sprint fits: " + nRequired + "h needed, " + nAvailable + "h available"
else
    ? "✗ Capacity exceeded by " + (nRequired - nAvailable) + " hours"
ok

#--> ✓ Sprint fits: 152h needed, 161h available

pf()
# Executed in 0.09 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 16: Quarter initialization        #
#-----------------------------------------#

pr()

# Test Q1
oCal_Q1 = new stzCalendar("2024-Q1")

oCal_Q1 {
    ? Start()
    #--> 2024-01-01
    
    ? End_()
    #--> 2024-03-31
    
    ? QuarterNumber()
    #--> 1
    
    ? TotalDays()
    #--> 91
}

? nl

# Test Q2
oCal_Q2 = new stzCalendar("2024-Q2")

oCal_Q2 {
    ? Start()
    #--> 2024-04-01
    
    ? End_()
    #--> 2024-06-30
    
    ? TotalDays()
    #--> 91
}

? nl

# Test Q3
oCal_Q3 = new stzCalendar("2024-Q3")

oCal_Q3 {
    ? Start()
    #--> 2024-07-01
    
    ? End_()
    #--> 2024-09-30
}

? nl

# Test Q4
oCal_Q4 = new stzCalendar("2024-Q4")

oCal_Q4 {
    ? Start()
    #--> 2024-10-01
    
    ? End_()
    #--> 2024-12-31
}

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 17: Year-month string init        #
#-----------------------------------------#

pr()

oCal = new stzCalendar("2024-10")

oCal {
    ? "Start: " + Start()
    #--> Start: 2024-10-01
    
    ? "End: " + End_()
    #--> End: 2024-10-31
    
    ? "Month Name: " + MonthName()
    #--> Month Name: October
    
    ? "Month Number: " + MonthNumber()
    #--> Month Number: 10
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 18: Single date initialization    #
#-----------------------------------------#

pr()

oCal = new stzCalendar("2024-10-15")

oCal {
    ? "Start: " + Start()
    #--> Start: 2024-10-15
    
    ? "End: " + End_()
    #--> End: 2024-10-15
    
    ? "Total Days: " + TotalDays()
    #--> Total Days: 1
    
    ? "Contains Days: " + ContainsDays()
    #--> Contains Days: 1
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 19: Year-only initialization      #
#-----------------------------------------#

pr()

oCal = new stzCalendar(2024)

oCal {
    ? "Start: " + Start()
    #--> Start: 2024-01-01
    
    ? "End: " + End_()
    #--> End: 2024-12-31
    
    ? "Year: " + Year()
    #--> Year: 2024
    
    ? "Total Days: " + TotalDays()
    #--> Total Days: 366 (leap year)
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 20: List initialization variants  #
#-----------------------------------------#

pr()

# Test [year, month] format
oCal1 = new stzCalendar([2024, 10])

oCal1 {
    ? "Format [year, month] - Start: " + Start()
    #--> Format [year, month] - Start: 2024-10-01
}

? nl

# Test [year, "Q3"] format
oCal2 = new stzCalendar([2024, "Q3"])

oCal2 {
    ? "Format [year, Q] - Start: " + Start()
    #--> Format [year, Q] - Start: 2024-07-01
    
    ? "Format [year, Q] - End: " + End_()
    #--> Format [year, Q] - End: 2024-09-30
}

? nl

# Test named parameters
oCal3 = new stzCalendar([ :Start = "2024-10-01", :End = "2024-10-31" ])

oCal3 {
    ? "Named params - Start: " + Start()
    #--> Named params - Start: 2024-10-01
    
    ? "Named params - End: " + End_()
    #--> Named params - End: 2024-10-31
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 21: Content method               #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddHoliday("2024-10-05", "Holiday")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    
    ? @@NL(Content())
    #-->
    '
    [
        [ "start", "2024-10-01" ],
        [ "end", "2024-10-31" ],
        [ "year", 2024 ],
        [ "month", 10 ],
        [ "quarter", "" ],
        [ "totaldays", 31 ],
        [ "workingdays", 23 ],
        [ "holidays", [ [ "2024-10-05", "Holiday" ] ] ],
        [ "businesshours", [ [ "from", "09:00:00" ], [ "to", "17:00:00" ] ] ],
        [ "breaks", [ [ "12:00:00", "13:00:00", "Lunch" ] ] ]
    ]
    '
}

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 22: FirstDayOfWeek/LastDayOfWeek #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    
    ? "First Day of Week: " + FirstDayOfWeek()
    #--> First Day of Week: 2024-09-30 (Monday of week containing 2024-10-01)
    
    ? "Last Day of Week: " + LastDayOfWeek()
    #--> Last Day of Week: 2024-10-06 (Sunday)
}

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 23: Working days list             #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    
    aWorkingDays = WorkingDays()
    
    ? "Number of working days: " + len(aWorkingDays)
    #--> Number of working days: 23
    
    ? "First working day: " + aWorkingDays[1]
    #--> First working day: 2024-10-01
    
    ? "Last working day: " + aWorkingDays[len(aWorkingDays)]
    #--> Last working day: 2024-10-31
}

pf()
# Executed in 0.10 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 24: Weekends list                 #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    
    aWeekends = Weekends()
    
    ? "Number of weekend days: " + WeekendsN()
    #--> Number of weekend days: 8
    
    ? "First weekend day: " + aWeekends[1]
    #--> First weekend day: 2024-10-05
    
    ? "Contains Weekends: " + ContainsWeekends()
    #--> Contains Weekends: TRUE
    
    ? "Has Weekends: " + HasWeekends()
    #--> Has Weekends: TRUE
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 25: Available days list           #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Holiday")
    
    aAvailableDays = AvailableDays()
    
    ? "Available Days Count: " + len(aAvailableDays)
    #--> Available Days Count: 22
    
    ? "Contains Available Days: " + ContainsAvailableDays()
    #--> Contains Available Days: 1
    
    ? "Has Available Days: " + HasAvailableDays()
    #--> Has Available Days: 1
    
    ? @@NL(aAvailableDays)
    # Shows list of all available working days excluding holidays
}
#-->
'
[
	"2024-10-01", #TODO// See why this format is different
	"02/10/2024",
	"03/10/2024",
	"04/10/2024",
	"07/10/2024",
	"08/10/2024",
	"09/10/2024",
	"10/10/2024",
	"11/10/2024",
	"14/10/2024",
	"15/10/2024",
	"16/10/2024",
	"17/10/2024",
	"18/10/2024",
	"21/10/2024",
	"22/10/2024",
	"23/10/2024",
	"24/10/2024",
	"25/10/2024",
	"28/10/2024",
	"29/10/2024",
	"30/10/2024",
	"31/10/2024"
]
'

pf()
# Executed in 0.28 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 26: Consecutive working days      #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Holiday")
    
    aConsecutive = ConsecutiveWorkingDaysAvailable("2024-10-01")
    
    ? "Consecutive working days from Oct 1: " + len(aConsecutive)
    #--> Consecutive working days from Oct 1: 4
    
    ? "Alternative form: " + ConsecutiveAvailableWorkingDaysN("2024-10-01")
    #--> Alternative form: 4
    
    ? "Starting from Oct 7: " + ConsecutiveWorkingDaysAvailableN("2024-10-07")
    #--> Starting from Oct 7: 5
}

pf()
# Executed in 0.06 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 27: FreeDays                      #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Holiday")
    
    # Getting the list of working days that aren't holidays"

    aFreeDays = FreeDays()

    ? "Free Days Count: " + len(aFreeDays) # Or use FreeDaysN()
    #--> Free Days Count: 23
    
    ? "First Free Day: " + aFreeDays[1]
    #--> First Free Day: 2024-10-01
}

pf()
# Executed in 0.09 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 28: TotalWeeks and ContainsWeeks  #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    ? "Total Weeks: " + TotalWeeks()
    #--> Total Weeks: 5
    
    ? "Contains Weeks: " + ContainsWeeks()
    #--> Contains Weeks: TRUE
    
    ? "Has Weeks: " + HasWeeks()
    #--> Has Weeks: TRUE
    
    ? "Week Count aliases: " + WeeksN()
    #--> Week Count aliases: 5
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 29: AvailableWeeks and Minutes    #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    
    ? "Available Weeks: " + AvailableWeeksN()
    #--> Available Weeks: 5 (ceil(23 / 5))
    
    ? "Contains Available Weeks: " + ContainsAvailableWeeks()
    #--> Contains Available Weeks: TRUE
    
    ? "Available Minutes: " + AvailableMinutesN()
    #--> Available Minutes: 9660
    
    ? "Alternative form: " + AvailableMinutes()
    #--> Alternative form: 9660
}

pf()
# Executed in 0.31 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 30: IsToday method                #
#-----------------------------------------#

pr()

# Create calendar for current month
oCal = new stzCalendar([2024, 10])

oCal {
    ? "Is Today (October 2024): " + IsToday()
    #--> FALSE (Result depends on current date)
}


# Create a single-day calendar for today

oTodayCal = new stzCalendar(Today())
	? "Single day calendar is today: " + oTodayCal.IsToday()
	#--> TRUE
}

pf()
# Executed in 0.03 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 31: ToJSON and ToCSV export       #
#-----------------------------------------#
*/
pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Holiday")
    SetBusinessHours("09:00:00", "17:00:00")
    
    # Test JSON export
    cJSON = ToJSON()
    ? RoundBox("JSON Export (first 100 chars)")
    ? @substr(cJSON, 1, 100)
    
    ? nl
    
    # Test CSV export
    cCSV = ToCSV()
    ? RoundBox("CSV Export (first 200 chars)")
    ? @substr(cCSV, 1, 200)
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 32: Display variants              #
#-----------------------------------------#
*/
pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Holiday")
    
    ? "===== Short Display ====="
    ShowShort()
    
    ? nl + "===== Default Display ====="
    Show()
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 33: DateInfo variations           #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Holiday")
    
    # Test working day
    ? "Working Day Info:"
    ? @@NL(DateInfo("2024-10-03"))
    
    ? nl + "Holiday Info:"
    ? @@NL(DateInfo("2024-10-05"))
    
    ? nl + "Weekend Info:"
    ? @@NL(DateInfo("2024-10-06"))
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 34: Year navigation methods       #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    ? "Current: " + Current()
    #--> Current: October 2024
    
    ? "Previous Year: " + PreviousYear()
    #--> Previous Year: 2023
    
    ? "Current still: " + Current()
    #--> Current still: October 2024
    
    GoToPreviousYear()
    
    ? "After GoToPreviousYear: " + Current()
    #--> After GoToPreviousYear: October 2023
    
    ? nl + "Next Year: " + NextYear()
    #--> Next Year: 2024
    
    GoToNextYear()
    
    ? "After GoToNextYear: " + Current()
    #--> After GoToNextYear: October 2024
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 35: Month navigation methods      #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    ? "Current: " + Current()
    #--> Current: October 2024
    
    ? "Next Month: " + NextMonth()
    #--> Next Month: November
    
    ? "Current still: " + Current()
    #--> Current still: October 2024
    
    GotoNextMonth()
    
    ? "After GotoNextMonth: " + Current()
    #--> After GotoNextMonth: November 2024
    
    ? nl + "Previous Month: " + PreviousMonth()
    #--> Previous Month: October
    
    GoToPreviousMonth()
    
    ? "After GoToPreviousMonth: " + Current()
    #--> After GoToPreviousMonth: October 2024
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 36: Alias methods verification    #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Holiday")
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    
    # Test various alias forms
    ? "TotalDays: " + TotalDays()
    ? "DaysN: " + DaysN()
    ? "NumberOfDays: " + NumberOfDays()
    ? "HowManyDays: " + HowManyDays()
    ? "CountDays: " + CountDays()
    
    ? nl + "AvailableDaysN: " + AvailableDaysN()
    ? "HowManyAvailableDays: " + HowManyAvailableDays()
    ? "CountAvailableDays: " + CountAvailableDays()
    
    ? nl + "HolidaysN: " + HolidaysN()
    ? "NumberOfHolidays: " + NumberOfHolidays()
    ? "CountHolidays: " + CountHolidays()
    
    ? nl + "AvailableHoursN: " + AvailableHoursN()
    ? "HowManyAvailableHoursB: " + HowManyAvailableHoursB()
    ? "CountAvailableHours: " + CountAvailableHours()
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 37: Legend method                 #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    AddHoliday("2024-10-05", "Holiday")
    
    aLegend = Legend()
    
    ? "Legend entries:"
    ? @@NL(aLegend)
    
    oLegendQ = LegendQ()
    ? nl + "LegendQ returns stzList: " + ring_classname(oLegendQ)
    #--> LegendQ returns stzList: stzlist
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 38: SetVizWidth and SetVizHeight  #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    ? "Default Viz Width: " + VizWidth()
    #--> Default Viz Width: 50
    
    ? "Default Viz Height: " + VizHeight()
    #--> Default Viz Height: 10
    
    SetVizWidth(80)
    SetVizHeight(20)
    
    ? "After SetVizWidth(80): " + VizWidth()
    #--> After SetVizWidth(80): 80
    
    ? "After SetVizHeight(20): " + VizHeight()
    #--> After SetVizHeight(20): 20
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 39: Stats method                  #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Holiday")
    
    ? "===== Statistics ====="
    ? @@NL(Stats())
}

pf()
# Executed in almost 0 second(s) in Ring 1.24

/*----------------------------------------#
#  Test 40: DetailedTable methods         #
#-----------------------------------------#

pr()

oCal = new stzCalendar([2024, 10])

oCal {
    SetWorkingDays(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
    SetBusinessHours("09:00:00", "17:00:00")
    AddBreak("12:00:00", "13:00:00", "Lunch")
    AddHoliday("2024-10-05", "Holiday")
    
    aDetailTable = DetailedTable()
    
    ? "Detailed Table Row Count: " + len(aDetailTable)
    #--> Detailed Table Row Count: 32 (header + 31 days)
    
    ? "First row: " + @@(aDetailTable[1])
    ? "Second row: " + @@(aDetailTable[2])
    
    ? nl + "===== Using DetailedTableQ ====="
    DetailedTableQ().Show()
}

pf()
# Executed in almost 0 second(s) in Ring 1.24
