# Narrative
# --------
# Testing basic initialization with simple list data
#
# Extracted from stzdatawranglertest.ring, block #1.

load "../../stzBase.ring"


pr()

# Simple list with mixed data quality issues with # Duplicates, whitespace, missing values
aSimpleData = [ "John", "  Mary  ", '', "BOB", "NULL", "alice", "John" ]

o1 = new stzDataWrangler(aSimpleData, [])

# Check initial data profile
o1.ShowReport()
#-->
'
╭───────────────────────╮
│ DATA WRANGLING REPORT │
╰───────────────────────╯
• Structure: list
• Dimensions: 7 rows × 0 columns
• Issues Found: 0
• Transformations: 1

🔄 TRANSFORMATIONS APPLIED:
╰─> Data loaded: {Structure: list}
'

pf()
# Executed in 0.02 second(s) in Ring 1.22
