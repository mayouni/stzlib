# Narrative
# --------
#
# Extracted from stzPivotTableTest.ring, block #4.
#ERR Error (R2) : Array Access (Index out of range)

load "../../stzBase.ring"

pr()

    # Simple financial data
    o1 = new stzTable([
        [ :Year,  :Quarter,  :Department,   :Revenue,    :Expenses,   :Profit  ],
        # ---------------------------------------------------------------------- #
        [ 2023,    "Q1",      "Sales",       120000,       85000,      35000   ],
        [ 2023,    "Q1",      "Marketing",    45000,       40000,       5000   ],
        [ 2023,    "Q1",      "Operations",   65000,       50000,      15000   ],
        [ 2023,    "Q2",      "Sales",       135000,       90000,      45000   ],
        [ 2023,    "Q2",      "Marketing",    50000,       42000,       8000   ],
        [ 2023,    "Q2",      "Operations",   70000,       52000,      18000   ],
        [ 2023,    "Q3",      "Sales",       142000,       92000,      50000   ],
        [ 2023,    "Q3",      "Marketing",    55000,       44000,      11000   ],
        [ 2023,    "Q3",      "Operations",   75000,       55000,      20000   ],
        [ 2023,    "Q4",      "Sales",       150000,       95000,      55000   ],
        [ 2023,    "Q4",      "Marketing",    60000,       46000,      14000   ],
        [ 2023,    "Q4",      "Operations",   80000,       58000,      22000   ],
        [ 2024,    "Q1",      "Sales",       130000,       88000,      42000   ],
        [ 2024,    "Q1",      "Marketing",    48000,       41000,       7000   ],
        [ 2024,    "Q1",      "Operations",   68000,       51000,      17000   ],
        [ 2024,    "Q2",      "Sales",       145000,       94000,      51000   ],
        [ 2024,    "Q2",      "Marketing",    53000,       43000,      10000   ],
        [ 2024,    "Q2",      "Operations",   73000,       54000,      19000   ]
    ])
    
    # Basic pivot with default display
    o1.ToStzPivotTable() {

		SetRowLabels([:Year, :Quarter])
        SetColumnLabels([:Department])
        SetValues([:Profit])
        SetAggregateFunction("SUM")
    

		Show()
 		#-->
# ╭────────────────┬───────────────────────────────────┬────────╮
# │                │            Department             │        │
# │                │───────────┬────────────┬──────────│        │
# │ Year │ Quarter │ Marketing │ Operations │  Sales   │  SUM   │
# ├──────┬─────────┼───────────┼────────────┼──────────┼────────┤
# │ 2023 │ Q2      │      8000 │      18000 │    45000 │  71000 │
# │      │ Q3      │     11000 │      20000 │    50000 │  81000 │
# │      │ Q4      │     14000 │      22000 │    55000 │  91000 │
# │      │         │           │            │          │        │
# │ 2024 │ Q1      │      7000 │      17000 │    42000 │  66000 │
# │      │ Q2      │     10000 │      19000 │    51000 │  80000 │
# ╰──────┴─────────┴───────────┴────────────┴──────────┴────────╯
#             SUM │     55000 │     111000 │   243000 │ 409000  


		? Value("2024", "Marketing")
		#--> 7000
		
		? Value(["2024", "Q2"], "Marketing")
		#--> 10000
		
		? Value([ "2023", "Q3" ], "Sales")
		#--> 50000

	}

pf()
# Executed in 0.09 second(s) in Ring 1.22
