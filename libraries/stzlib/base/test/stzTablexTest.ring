load "../stzbase.ring"

#--------------------------#
#  BASIC STRUCTURE TESTS   #
#--------------------------#

/*--- Matching exact column count
*/
pr()

oTable = new stzTable([
	[ :NAME, :AGE, :JOB ],
	[ "Ali", 28, "Teacher" ],
	[ "Sara", 32, "Engineer" ]
])

oTx = new stzTablex("{cols(3)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{cols(4)}")
? oTx.Match(oTable)
#--> FALSE

pf()

/*--- Matching column count with comparisons

pr()

oTable = new stzTable([
	[ :ID, :NAME, :AGE, :SALARY, :DEPT ],
	[ 1, "Ali", 28, 45000, "IT" ],
	[ 2, "Sara", 32, 52000, "HR" ]
])

oTx = new stzTablex("{cols(>3)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{cols(<10)}")
? oTx.Match(oTable)
#--> TRUE

pf()

/*--- Matching exact row count

pr()

oTable = new stzTable([
	[ :NAME, :AGE ],
	[ "Ali", 28 ],
	[ "Sara", 32 ],
	[ "Omar", 45 ]
])

oTx = new stzTablex("{rows(3)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{rows(>2)}")
? oTx.Match(oTable)
#--> TRUE

pf()

/*--- Combining structure constraints

pr()

oTable = new stzTable([
	[ :ID, :NAME, :AGE ],
	[ 1, "Ali", 28 ],
	[ 2, "Sara", 32 ]
])

oTx = new stzTablex("{cols(3) & rows(2)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{cols(>2) & rows(<5)}")
? oTx.Match(oTable)
#--> TRUE

pf()

#--------------------------#
#  CASE SENSITIVITY TESTS  #
#--------------------------#

/*--- Case-insensitive contains (default)

pr()

oTable1 = new stzTable([
	[ :NAME, :AGE, :JOB ],
	[ "Hussein", 24, "Programmer" ],
	[ "ali", 28, "Teacher" ],
	[ "Omar", 44, "Farmer" ]
])

oTable2 = new stzTable([
	[ :NAME, :AGE ],
	[ "Hussein", 24 ],
	[ "Salem", 28 ]
])

oTx = new stzTablex("{contains(Ali)}")
? oTx.Match(oTable1)
#--> TRUE (matches "ali")

? oTx.Match(oTable2)
#--> FALSE

pf()

/*--- Case-sensitive contains

pr()

oTable = new stzTable([
	[ :NAME, :AGE ],
	[ "ali", 28 ],
	[ "ALI", 32 ]
])

# Case-insensitive (matches both)
oTx = new stzTablex("{contains(Ali)}")
? oTx.Match(oTable)
#--> TRUE

# Case-sensitive (no exact "Ali")
oTx = new stzTablex("{@cs:contains(Ali)}")
? oTx.Match(oTable)
#--> FALSE

# Add exact match
oTable = new stzTable([
	[ :NAME, :AGE ],
	[ "Ali", 28 ]
])

? oTx.Match(oTable)
#--> TRUE

pf()

/*--- Case sensitivity in unique check

pr()

oTable1 = new stzTable([
	[ :NAME ],
	[ "Ali" ],
	[ "ali" ],
	[ "ALI" ]
])

# Case-insensitive (all are same)
oTx = new stzTablex("{unique(name)}")
? oTx.Match(oTable1)
#--> FALSE (duplicates when ignoring case)

# Case-sensitive (all different)
oTx = new stzTablex("{@cs:unique(name)}")
? oTx.Match(oTable1)
#--> TRUE (each is unique with case)

pf()

/*--- Case sensitivity in duplicates check

pr()

oTable = new stzTable([
	[ :EMAIL ],
	[ "Ali@mail.com" ],
	[ "ali@mail.com" ]
])

# Case-insensitive (same email)
oTx = new stzTablex("{duplicates(email)}")
? oTx.Match(oTable)
#--> TRUE

# Case-sensitive (different)
oTx = new stzTablex("{@cs:duplicates(email)}")
? oTx.Match(oTable)
#--> FALSE

pf()

/*--- Case sensitivity in sorted check

pr()

oTable1 = new stzTable([
	[ :NAME ],
	[ "Ali" ],
	[ "sara" ],
	[ "Ziad" ]
])

# Case-insensitive sort (a, s, z)
oTx = new stzTablex("{sorted(name)}")
? oTx.Match(oTable1)
#--> TRUE

oTable2 = new stzTable([
	[ :NAME ],
	[ "Ali" ],
	[ "Ziad" ],
	[ "sara" ]
])

# Case-sensitive sort (A < Z < s in ASCII)
oTx = new stzTablex("{@cs:sorted(name)}")
? oTx.Match(oTable2)
#--> TRUE

pf()

/*--- Case sensitivity in grouped check

pr()

oTable = new stzTable([
	[ :DEPT ],
	[ "IT" ],
	[ "it" ],
	[ "HR" ]
])

# Case-insensitive (IT and it are same group)
oTx = new stzTablex("{grouped(dept)}")
oTx.EnableDebug()
? oTx.Match(oTable)
#--> TRUE

# Case-sensitive (IT and it are different)
oTx = new stzTablex("{@cs:grouped(dept)}")
? oTx.Match(oTable)
#--> FALSE

pf()

/*---

pr()

oTable = new stzTable([
	[ :NOM, :SALARY ],
	[ "Mahran", 5000 ],
	[ "Alia", 3500 ]
])

oTx = new stzTablex("{coltype(salary:number)}")
oTx.EnableDebug()
? @@(oTx.Tokens())  # Check what was parsed
? oTx.Match(oTable)

pf()

/*--- Combining case-sensitive patterns

pr()

oTable = new stzTable([
	[ :ID, :NAME, :EMAIL ],
	[ 1, "Ali", "ali@mail.com" ],
	[ 2, "Sara", "sara@mail.com" ],
	[ 3, "Omar", "omar@mail.com" ]
])

# Case-sensitive validation
oTx = new stzTablex("{@cs:unique(name) & @cs:contains(Ali) & @cs:sorted(name)}")
? oTx.Match(oTable)
#--> TRUE

pf()

#--------------------------#
#  COLUMN EXISTENCE TESTS  #
#--------------------------#

/*--- Checking column names

pr()

oTable = new stzTable([
	[ :EMPLOYEE, :SALARY, :DEPARTMENT ],
	[ "Ali", 45000, "IT" ],
	[ "Sara", 52000, "HR" ]
])

oTx = new stzTablex("{colname(employee)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{colname(salary) & colname(department)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{colname(bonus)}")
? oTx.Match(oTable)
#--> FALSE

pf()

/*--- Using hascol (alternative syntax)

pr()

oTable = new stzTable([
	[ :NAME, :AGE, :CITY ],
	[ "Ali", 28, "Tunis" ],
	[ "Sara", 32, "Paris" ]
])

? oTable.HasCol("name") #--> TRUE

oTx = new stzTablex("{hascol(name) & hascol(age)}")
? oTx.Match(oTable)
#--> TRUE

pf()

#--------------------------#
#  DATA CONTENT TESTS      #
#--------------------------#

/*--- Case-insensitive contains (default)

pr()

oTable1 = new stzTable([
	[ :NAME, :AGE, :JOB ],
	[ "Hussein", 24, "Programmer" ],
	[ "ali", 28, "Teacher" ],
	[ "Omar", 44, "Farmer" ]
])

oTable2 = new stzTable([
	[ :NAME, :AGE ],
	[ "Hussein", 24 ],
	[ "Salem", 28 ]
])

oTx = new stzTablex("{contains(Ali)}")
? oTx.Match(oTable1)
#--> TRUE (matches "ali")

? oTx.Match(oTable2)
#--> FALSE

pf()

/*--- Case-sensitive contains

pr()

oTable = new stzTable([
	[ :NAME, :AGE ],
	[ "ali", 28 ],
	[ "ALI", 32 ]
])

# Case-insensitive (matches both)
oTx = new stzTablex("{contains(Ali)}")
? oTx.Match(oTable)
#--> TRUE

# Case-sensitive (no exact "Ali")
oTx = new stzTablex("{@cs:contains(Ali)}")
? oTx.Match(oTable)
#--> FALSE

# Add exact match
oTable = new stzTable([
	[ :NAME, :AGE ],
	[ "Ali", 28 ]
])

? oTx.Match(oTable)
#--> TRUE

pf()

/*--- Combining contains with structure

pr()

oTable = new stzTable([
	[ :NAME, :AGE, :CITY ],
	[ "Ali", 28, "Tunis" ],
	[ "Sara", 32, "Paris" ]
])

oTx = new stzTablex("{cols(>2) & contains(Tunis)}")
? oTx.Match(oTable)
#--> TRUE

pf()

#--------------------------#
#  UNIQUENESS TESTS        #
#--------------------------#

/*--- Checking unique columns

pr()

oTable = new stzTable([
	[ :ID, :NAME, :DEPT ],
	[ 1, "Ali", "IT" ],
	[ 2, "Sara", "IT" ],
	[ 3, "Omar", "HR" ]
])

oTx = new stzTablex("{unique(id)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{unique(dept)}")
? oTx.Match(oTable)
#--> FALSE (IT appears twice)

pf()

/*--- Detecting duplicates

pr()

oTable = new stzTable([
	[ :EMAIL, :NAME ],
	[ "ali@mail.com", "Ali" ],
	[ "sara@mail.com", "Sara" ],
	[ "ali@mail.com", "Ali B" ]
])

oTx = new stzTablex("{duplicates(email)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{@!duplicates(email)}")
? oTx.Match(oTable)
#--> FALSE (negated - we DO have duplicates)

pf()

#--------------------------#
#  COLUMN TYPE TESTS       #
#--------------------------#

/*--- Validating column types

pr()

oTable = new stzTable([
	[ :NAME, :AGE, :SALARY ],
	[ "Ali", 28, 45000 ],
	[ "Sara", 32, 52000 ]
])

oTx = new stzTablex("{coltype(age:number)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{coltype(name:string)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{coltype(name:number)}")
? oTx.Match(oTable)
#--> FALSE

pf()

/*--- Multiple type constraints

pr()

oTable = new stzTable([
	[ :ID, :NAME, :TAGS ],
	[ 1, "Ali", ["dev", "lead"] ],
	[ 2, "Sara", ["hr", "manager"] ]
])

oTx = new stzTablex("{coltype(id:number) & coltype(name:string) & coltype(tags:list)}")
? oTx.Match(oTable)
#--> TRUE

pf()

#--------------------------#
#  NUMERIC COLUMN TESTS    #
#--------------------------#

/*--- Checking if column is numeric

pr()

oTable = new stzTable([
	[ :NAME, :AGE, :SALARY ],
	[ "Ali", 28, 45000 ],
	[ "Sara", 32, 52000 ]
])

oTx = new stzTablex("{numeric(age)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{numeric(name)}")
? oTx.Match(oTable)
#--> FALSE

pf()

/*--- Alphabetic column check

pr()

oTable = new stzTable([
	[ :NAME, :CODE ],
	[ "Ali", "ABC" ],
	[ "Sara", "XYZ" ]
])

oTx = new stzTablex("{alphabetic(name)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{alphabetic(code)}")
? oTx.Match(oTable)
#--> TRUE

pf()

#--------------------------#
#  STATISTICAL TESTS       #
#--------------------------#

/*--- Column sum constraints

pr()

oTable = new stzTable([
	[ :PRODUCT, :SALES ],
	[ "A", 10000 ],
	[ "B", 20000 ],
	[ "C", 30000 ]
])

oTx = new stzTablex("{sumcol(sales:60000)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{sumcol(sales:>50000)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{sumcol(sales:<50000)}")
? oTx.Match(oTable)
#--> FALSE

pf()

/*--- Column average constraints

pr()

oTable = new stzTable([
	[ :NAME, :SCORE ],
	[ "Ali", 80 ],
	[ "Sara", 90 ],
	[ "Omar", 70 ]
])

oTx = new stzTablex("{avgcol(score:80)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{avgcol(score:>75)}")
? oTx.Match(oTable)
#--> TRUE

pf()

/*--- Min and max column values

pr()

oTable = new stzTable([
	[ :PRODUCT, :PRICE ],
	[ "A", 10 ],
	[ "B", 50 ],
	[ "C", 30 ]
])

oTx = new stzTablex("{mincol(price:10)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{maxcol(price:50)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{mincol(price:>0) & maxcol(price:<100)}")
? oTx.Match(oTable)
#--> TRUE

pf()

#--------------------------#
#  DATA QUALITY TESTS      #
#--------------------------#

/*--- Checking for null values

pr()

oTable1 = new stzTable([
	[ :NAME, :EMAIL ],
	[ "Ali", "ali@mail.com" ],
	[ "Sara", "" ]  # Empty email
])

oTable2 = new stzTable([
	[ :NAME, :EMAIL ],
	[ "Ali", "ali@mail.com" ],
	[ "Sara", "sara@mail.com" ]
])

oTx = new stzTablex("{nulls(email)}")
? oTx.Match(oTable1)
#--> TRUE

? oTx.Match(oTable2)
#--> FALSE

pf()

/*--- Completeness percentage

pr()

oTable = new stzTable([
	[ :NAME, :PHONE ],
	[ "Ali", "123456" ],
	[ "Sara", "789012" ],
	[ "Omar", "345678" ],
	[ "Fatma", "" ]  # Missing phone
])

# 75% complete (3 out of 4)
oTx = new stzTablex("{completeness(phone:75)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{completeness(phone:90)}")
? oTx.Match(oTable)
#--> FALSE

pf()

/*--- Ensuring no nulls

pr()

oTable = new stzTable([
	[ :ID, :NAME, :EMAIL ],
	[ 1, "Ali", "ali@mail.com" ],
	[ 2, "Sara", "sara@mail.com" ]
])

oTx = new stzTablex("{@!nulls(email) & @!nulls(name)}")
? oTx.Match(oTable)
#--> TRUE

pf()

#--------------------------#
#  CALCULATED COLUMNS      #
#--------------------------#

/*--- Detecting calculated columns

pr()

oTable = new stzTable([
	[ :PRICE, :QTY ],
	[ 100, 5 ],
	[ 200, 3 ]
])

# Add calculated total column
oTable.AddCalculatedCol(:TOTAL, '@(:PRICE) * @(:QTY)')

oTx = new stzTablex("{calculated(total)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{calculated(price)}")
? oTx.Match(oTable)
#--> FALSE

pf()

/*--- Checking for any calculated data

pr()

oTable = new stzTable([
	[ :A, :B ],
	[ 1, 2 ],
	[ 3, 4 ]
])

oTx = new stzTablex("{aggregated()}")
? oTx.Match(oTable)
#--> FALSE

oTable.AddCalculatedCol(:SUM, '@(:A) + @(:B)')

? oTx.Match(oTable)
#--> TRUE

pf()

#--------------------------#
#  LOGICAL COMBINATIONS    #
#--------------------------#

/*--- AND operator for multiple constraints

pr()

oTable = new stzTable([
	[ :ID, :NAME, :AGE ],
	[ 1, "Ali", 28 ],
	[ 2, "Sara", 32 ],
	[ 3, "Omar", 45 ]
])

oTx = new stzTablex("{cols(3) & rows(3) & unique(id) & numeric(age)}")
? oTx.Match(oTable)
#--> TRUE

pf()

/*--- OR operator for alternatives

pr()

oTable1 = new stzTable([
	[ :A, :B, :C ],
	[ 1, 2, 3 ]
])

oTable2 = new stzTable([
	[ :A, :B, :C, :D ],
	[ 1, 2, 3, 4 ]
])

oTx = new stzTablex("{cols(3) | cols(4)}")
? oTx.Match(oTable1)
#--> TRUE

? oTx.Match(oTable2)
#--> TRUE

pf()

/*--- Negation with @!

pr()

oTable = new stzTable([
	[ :ID, :NAME ],
	[ 1, "Ali" ],
	[ 2, "Sara" ],
	[ 3, "Omar" ]
])

oTx = new stzTablex("{@!duplicates(id) & @!nulls(name)}")
? oTx.Match(oTable)
#--> TRUE

pf()

/*--- Complex nested conditions

pr()

oTable = new stzTable([
	[ :ID, :NAME, :AGE, :SALARY ],
	[ 1, "Ali", 28, 45000 ],
	[ 2, "Sara", 32, 52000 ]
])

oTx = new stzTablex("{(cols(3) | cols(4)) & unique(id) & (avgcol(salary:>40000) | avgcol(age:>30))}")
? oTx.Match(oTable)
#--> TRUE

pf()

#--------------------------#
#  MULTIPLE TABLE MATCHING #
#--------------------------#

/*--- Finding matching tables

pr()

oTable1 = new stzTable([
	[ :NAME, :AGE, :CITY ],
	[ "Ali", 28, "Tunis" ],
	[ "Sara", 32, "Paris" ]
])

oTable2 = new stzTable([
	[ :NAME, :AGE ],
	[ "Omar", 45 ]
])

oTable3 = new stzTable([
	[ :NAME, :AGE, :COUNTRY ],
	[ "Fatma", 29, "Tunisia" ],
	[ "Dorra", 35, "France" ]
])

oTx = new stzTablex("{cols(3) & contains(Tunis)}")

# Only oTable1 matches (3 cols + contains Tunis)
? oTx.CountMatchingTablesIn([oTable1, oTable2, oTable3])
#--> 1

pf()

/*--- Filtering table collections

pr()

aTables = [
	new stzTable([[:A,:B],[1,2]]),
	new stzTable([[:A,:B,:C],[1,2,3]]),
	new stzTable([[:A,:B,:C,:D],[1,2,3,4]])
]

oTx = new stzTablex("{cols(>2)}")
aFiltered = oTx.MatchingTablesIn(aTables)

? len(aFiltered)
#--> 2 (tables with 3 and 4 columns)

pf()

/*--- Case-sensitive matching across tables

pr()

oTable1 = new stzTable([
	[ :NAME, :AGE, :JOB ],
	[ "Ali", 28, "Teacher" ]
])

oTable2 = new stzTable([
	[ :NAME, :AGE, :JOB ],
	[ "ali", 32, "Engineer" ]
])

oTable3 = new stzTable([
	[ :NAME, :AGE, :JOB ],
	[ "ALI", 45, "Doctor" ]
])

# Case-insensitive
oTx = new stzTablex("{contains(Ali)}")
? oTx.CountMatchingTablesIn([oTable1, oTable2, oTable3])
#--> 3

# Case-sensitive
oTx = new stzTablex("{@cs:contains(Ali)}")
? oTx.CountMatchingTablesIn([oTable1, oTable2, oTable3])
#--> 1 (only exact "Ali")

pf()

#--------------------------#
#  PATTERN COMBINATION     #
#--------------------------#

/*--- Combining patterns with And_()

pr()

oTx1 = new stzTablex("{cols(3)}")
oTx2 = new stzTablex("{unique(id)}")
oTx3 = oTx1.And_(oTx2)

? oTx3.Pattern()
#--> {cols(3) & unique(id)}

oTable = new stzTable([
	[ :ID, :NAME, :AGE ],
	[ 1, "Ali", 28 ],
	[ 2, "Sara", 32 ]
])

? oTx3.Match(oTable)
#--> TRUE

pf()

/*--- Combining patterns with Or_()

pr()

oTx1 = new stzTablex("{cols(3)}")
oTx2 = new stzTablex("{cols(4)}")
oTx3 = oTx1.Or_(oTx2)

? oTx3.Pattern()
#--> {cols(3) | cols(4)}

pf()

/*--- Negating a pattern

pr()

oTx1 = new stzTablex("{duplicates(email)}")
oTx2 = oTx1.Not_()

? oTx2.Pattern()
#--> {@!duplicates(email)}

oTable = new stzTable([
	[ :EMAIL ],
	[ "a@m.com" ],
	[ "b@m.com" ]
])

? oTx2.Match(oTable)
#--> TRUE (no duplicates)

pf()

#-------------------------------#
#  DEBUGGING AND INTROSPECTION  #
#-------------------------------#

/*--- Inspecting pattern tokens

pr()

oTx = new stzTablex("{cols(3) & unique(id) & avgcol(salary:>40000)}")

? "Pattern: " + oTx.Pattern()
#--> Pattern: {cols(3) & unique(id) & avgcol(salary:>40000)}

? "Token count: " + len(oTx.Tokens())
#--> Token count: 1

pf()

/*--- Explaining matches

pr()

oTable = new stzTable([
	[ :ID, :NAME, :AGE ],
	[ 1, "Ali", 28 ],
	[ 2, "Sara", 32 ]
])

oTx = new stzTablex("{cols(3) & rows(2)}")
oTx.Match(oTable)

aExplain = oTx.Explain()
? @@(aExplain[1])
#--> ["Pattern","{cols(3) & rows(2)}"]

? @@(aExplain[2])
#--> ["TokenCount",1]

pf()

/*--- Debug mode

pr()

oTx = new stzTablex("{cols(3)}")
oTx.EnableDebug()

oTable = new stzTable([
	[ :A, :B, :C ],
	[ 1, 2, 3 ]
])

? oTx.Match(oTable)
#--> TRUE
# (with debug output showing token parsing)

oTx.DisableDebug()

pf()

#--------------------------#
#  REAL-WORLD SCENARIOS    #
#--------------------------#

/*--- Employee database validation

pr()

oEmployees = new stzTable([
	[ :ID, :NAME, :EMAIL, :SALARY, :DEPT ],
	[ 1, "Ali Hassan", "ali@company.com", 45000, "IT" ],
	[ 2, "Sara Ahmed", "sara@company.com", 52000, "HR" ],
	[ 3, "Omar Ali", "omar@company.com", 48000, "IT" ]
])

# Validate: unique IDs, no null emails, reasonable salaries
oTx = new stzTablex("{unique(id) & @!nulls(email) & avgcol(salary:>40000) & avgcol(salary:<60000)}")

? oTx.Match(oEmployees)
#--> TRUE

pf()

/*--- Sales data quality check

pr()

oSales = new stzTable([
	[ :DATE, :PRODUCT, :AMOUNT, :QTY ],
	[ "2024-01-15", "A", 1000, 10 ],
	[ "2024-01-16", "B", 2000, 20 ],
	[ "2024-01-17", "A", 1500, 15 ]
])

# Check: has all columns, amounts are positive, products exist
oTx = new stzTablex("{cols(4) & @!nulls(product) & mincol(amount:>0) & sumcol(amount:>0)}")

? oTx.Match(oSales)
#--> TRUE

pf()

/*--- Student grades validation

pr()

oGrades = new stzTable([
	[ :STUDENT_ID, :NAME, :MATH, :SCIENCE, :ENGLISH ],
	[ 101, "Ali", 85, 90, 88 ],
	[ 102, "Sara", 92, 87, 95 ],
	[ 103, "Omar", 78, 82, 80 ]
])

# Validate: unique IDs, all grades present, reasonable averages
oTx = new stzTablex("{cols(5) & unique(student_id) & @!nulls(name) & mincol(math:>0) & maxcol(math:<101)}")

? oTx.Match(oGrades)
#--> TRUE

pf()

/*--- Data warehouse ETL validation

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
? "First match (no cache): " + (clock() - t0) + " ticks"

# SECOND MATCH - Cache hit!
# Internally: Signature matches → Return stored TRUE (skip all checking)
t0 = clock()
? oTx.Match(oTable1)  #--> TRUE (instant)
? "Cached match: " + (clock() - t0) + " ticks"
#--> 10-100x faster

# THIRD MATCH - Cache miss (different table signature)
# Internally: New signature → Compute → Store new result
t0 = clock()
? oTx.Match(oTable2)  #--> FALSE
? "Different table: " + (clock() - t0) + " ticks"

# REAL-WORLD SCENARIO: Validation loop
# Cache makes repeated checks nearly free
? "--- 1000 Validations (same table) ---"

t0 = clock()
for i = 1 to 1000
	oTx.Match(oTable1)  # All hits cached after first
next
? "1000 matches: " + (clock() - t0) + " ticks"
#--> ~1000x speedup vs no cache

# CACHE CONTROL (optional)
oTx.ClearCache()        # Reset manually
oTx.SetCacheSize(50)    # Limit entries (LRU eviction)

pf()
