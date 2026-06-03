# Narrative
# --------
# Various Aggregation Functions
#
# Extracted from stzPivotTableTest.ring, block #3.
#ERR Error (R2) : Array Access (Index out of range)

load "../../stzBase.ring"

pr()
    
    # Define a product sales and ratings dataset

    o1 = new stzTable([

        [ :Product,    :Category,    :Region,    :Sales,    :Rating,   :Returns  ],
        # ----------------------------------------------------------------- #
        [ "Laptop A",  "Electronics", "North",    2500,        4.2,        5     ],
        [ "Laptop A",  "Electronics", "South",    3200,        4.0,        7     ],
        [ "Laptop A",  "Electronics", "East",     2800,        4.3,        4     ],
        [ "Laptop A",  "Electronics", "West",     3500,        4.1,        8     ],
        [ "Phone B",   "Electronics", "North",    1800,        4.5,        2     ],
        [ "Phone B",   "Electronics", "South",    2100,        4.6,        1     ],
        [ "Phone B",   "Electronics", "East",     1900,        4.4,        3     ],
        [ "Phone B",   "Electronics", "West",     2300,        4.7,        2     ],
        [ "Chair C",   "Furniture",   "North",     850,        3.8,        3     ],
        [ "Chair C",   "Furniture",   "South",     920,        3.9,        4     ],
        [ "Chair C",   "Furniture",   "East",      780,        3.7,        5     ],
        [ "Chair C",   "Furniture",   "West",      950,        4.0,        2     ],
        [ "Table D",   "Furniture",   "North",    1200,        4.2,        1     ],
        [ "Table D",   "Furniture",   "South",    1350,        4.1,        2     ],
        [ "Table D",   "Furniture",   "East",     1180,        4.0,        2     ],
        [ "Table D",   "Furniture",   "West",     1420,        4.3,        1     ]
    ])

	# Pivoting the table and starting analyisis

    o1.ToStzPivotTable() {

    	# SUM aggregation (default)

		SetRowLabels([:Product])
        SetColumnLabels([:Region])
        SetValues([:Sales])
        SetAggregateFunction("SUM")

        Show()
		#-->
# ╭──────────┬───────────────────────────────────────────┬───────╮
# │          │                  Region                   │       │
# │          │──────────┬──────────┬──────────┬──────────│       │
# │ Product  │  South   │   East   │   West   │  North   │  SUM  │
# ├──────────┼──────────┼──────────┼──────────┼──────────┼───────┤
# │ Laptop A │     3200 │     2800 │     3500 │          │  9500 │
# │ Phone B  │     2100 │     1900 │     2300 │     1800 │  8100 │
# │ Chair C  │      920 │      780 │      950 │      850 │  3500 │
# │ Table D  │     1350 │     1180 │     1420 │     1200 │  5150 │
# ╰──────────┴──────────┴──────────┴──────────┴──────────┴───────╯
#        SUM │     7570 │     6660 │     8170 │     3850 │ 26250  

    	# AVERAGE aggregation

     	SetRowLabels([:Category])
        SetColumnLabels([:Region])
        SetValues([:Rating])
        SetAggregateFunction("AVERAGE")
        Show()
		#-->
# ╭─────────────┬───────────────────────────────────────────┬─────────╮
# │             │                  Region                   │         │
# │             │──────────┬──────────┬──────────┬──────────│         │
# │  Category   │  South   │   East   │   West   │  North   │ AVERAGE │
# ├─────────────┼──────────┼──────────┼──────────┼──────────┼─────────┤
# │ Electronics │     4.30 │     4.35 │     4.40 │     4.50 │    4.39 │
# │ Furniture   │        4 │     3.85 │     4.15 │        4 │       4 │
# ╰─────────────┴──────────┴──────────┴──────────┴──────────┴─────────╯
#       AVERAGE │     4.15 │     4.10 │     4.28 │     4.25 │    4.19  

		# Count of Products by Category and Region + NL
    
		SetRowLabels([:Category])
        SetColumnLabels([:Region])
        SetValues([:Product])
        SetAggregateFunction("COUNT") #todo // check error un COUNT
        Show()
		#-->
# ╭─────────────┬───────────────────────────────────────────┬───────╮
# │             │                  Region                   │       │
# │             │──────────┬──────────┬──────────┬──────────│       │
# │  Category   │  South   │   East   │   West   │  North   │ COUNT │
# ├─────────────┼──────────┼──────────┼──────────┼──────────┼───────┤
# │ Electronics │        2 │        2 │        2 │        1 │     4 │
# │ Furniture   │        2 │        2 │        2 │        2 │     4 │
# ╰─────────────┴──────────┴──────────┴──────────┴──────────┴───────╯
#         COUNT │        2 │        2 │        2 │        2 │     2  


		# Maximum Returns by Product and Region
    
		SetRowLabels([:Product])
		SetColumnLabels([:Region])
		SetValues([:Returns])
		SetAggregateFunction("MAX")
		Show()
		#-->
# ╭──────────┬───────────────────────────────────────────┬─────╮
# │          │                  Region                   │     │
# │          │──────────┬──────────┬──────────┬──────────│     │
# │ Product  │  South   │   East   │   West   │  North   │ MAX │
# ├──────────┼──────────┼──────────┼──────────┼──────────┼─────┤
# │ Laptop A │        7 │        4 │        8 │          │   8 │
# │ Phone B  │        1 │        3 │        2 │        2 │   3 │
# │ Chair C  │        4 │        5 │        2 │        3 │   5 │
# │ Table D  │        2 │        2 │        1 │        1 │   2 │
# ╰──────────┴──────────┴──────────┴──────────┴──────────┴─────╯
#        MAX │        7 │        5 │        8 │        3 │   8  

}

pf()
# Executed in 0.22 second(s) in Ring 1.22
