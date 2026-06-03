# Narrative
# --------
# Data warehouse ETL validation
#
# Extracted from stztablextest.ring, block #48.

load "../../stzBase.ring"


pr()

oWarehouse = new stzTable([
	[ :ID, :SOURCE, :LOAD_DATE, :RECORD_COUNT ],
	[ 1, "CRM", "2024-01-15", 1000 ],
	[ 2, "ERP", "2024-01-15", 2500 ],
	[ 3, "WEB", "2024-01-15", 3200 ]
])

# Validate: structure, completeness, and data volume
oTx = new stzTablex("{cols(4) & completeness(source:100) & sumcol(record_count:>5000)}")

? oTx.Match(oWarehouse)
#--> TRUE

pf()
# Executed in 0.15 second(s) in Ring 1.24

#=== AUTOMATIC CAHCE SYSTEM

# ==========================================
# CACHE PERFORMANCE DEMONSTRATION
# ==========================================

# Cache stores match results so identical patterns + tables return instantly
# without re-parsing or re-checking.

# HOW IT WORKS:
# 1. Pattern + Table → Signature (table structure and content)
# 2. Check cache for this signature
# 3. If found → return stored result (FAST)
# 4. If not → compute, store result, return (NORMAL)

# AUTOMATIC FIRING:
# Cache checks happen inside Match() - no user action needed.
#Triggered every time you call oTx.Match(oTable).

# USE CASES:
# ✓ Report generation (same pattern, many tables)
# ✓ Validation loops (same table, checking repeatedly)
# ✓ Test suites (assertions on fixtures)
# ✓ Dashboard refreshes (pattern reuse)


pr()

oTable1 = new stzTable([
	[ :NAME, :AGE, :CITY ],
	[ "Ali", 28, "Tunis" ],
	[ "Sara", 32, "Paris" ],
	[ "Omar", 25, "Cairo" ]
])

oTable2 = new stzTable([
	[ :PRODUCT, :PRICE ],
	[ "Laptop", 1200 ],
	[ "Mouse", 25 ]
])

oTx = new stzTablex("{hascol(name) & hascol(age) & rows(>2)}")

# FIRST MATCH - Cache miss
# Internally: Parse tokens → Check conditions → Store result
t0 = clock()
? oTx.Match(oTable1)  #--> TRUE
# First match (no cache):
? ''+ (clock() - t0) + " ticks"
#--> 20 ticks

# SECOND MATCH - Cache hit!
# Internally: Signature matches → Return stored TRUE (skip all checking)
t0 = clock()
? oTx.Match(oTable1)  #--> TRUE (instant)
# Cached match:
? ''+ (clock() - t0) + " ticks"
#--> 1 ticks (20x faster)

# THIRD MATCH - Cache miss (different table signature)
# Internally: New signature → Compute → Store new result
t0 = clock()
? oTx.Match(oTable2)  #--> FALSE
# Different table:
?'' + (clock() - t0) + " ticks"
#--> 8 ticks

# REAL-WORLD SCENARIO: Validation loop
# Cache makes repeated checks nearly free
? NL + "--- 1000 Validations (same table) ---"

t0 = clock()
for i = 1 to 1000
	oTx.Match(oTable1)  # All hits cached after first
next
? '' + (clock() - t0) + " ticks"
#--> 854 ticks

# CACHE CONTROL (optional)
oTx.ClearCache()        # Reset manually
oTx.SetCacheSize(50)    # Limit entries (LRU eviction)

pf()
# Executed in 0.92 second(s) in Ring 1.24
