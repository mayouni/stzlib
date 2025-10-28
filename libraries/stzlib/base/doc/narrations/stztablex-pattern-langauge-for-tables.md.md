# stzTablex: Declarative Pattern Matching for Tables in Softanza


## Introduction

Tables are everywhere in programming—from CSV imports to database results, from spreadsheet data to configuration files. But validating table structure, checking data quality, and filtering table collections often requires verbose conditional logic that obscures intent.

**stzTablex** brings pattern matching to tabular data, offering a declarative language that reads like natural specifications:

```ring
oTx = new stzTablex("{cols(3) & unique(id) & @!nulls(email) & avgcol(salary:>40000)}")

? oTx.Match(oEmployees)
#--> TRUE
```

In one readable expression, you've defined a complete validation rule: exactly three columns, unique IDs, no missing emails, and salaries averaging above 40,000. Let's explore how this pattern language transforms table validation from procedural code into semantic descriptions.

---

## 1. Matching Table Structure

The foundation of any table pattern is its **structural shape**—the number of columns and rows that define its dimensions.

```ring
oTable = new stzTable([
    [ :NAME, :AGE, :JOB ],
    [ "Ali", 28, "Teacher" ],
    [ "Sara", 32, "Engineer" ]
])

oTx = new stzTablex("{cols(3) & rows(2)}")
? oTx.Match(oTable)
#--> TRUE
```

Structure patterns accept exact values or comparison operators:

```ring
oTx = new stzTablex("{cols(>3) & rows(<100)}")

? oTx.Match(oLargeTable)
#--> TRUE if more than 3 columns and fewer than 100 rows
```

This structural foundation ensures your code operates on tables of the expected shape before processing their content.

---

## 2. Verifying Column Existence

Beyond structure, patterns can verify that specific columns exist by name:

```ring
oTable = new stzTable([
    [ :EMPLOYEE, :SALARY, :DEPARTMENT ],
    [ "Ali", 45000, "IT" ],
    [ "Sara", 52000, "HR" ]
])

oTx = new stzTablex("{colname(employee) & colname(salary)}")
? oTx.Match(oTable)
#--> TRUE
```

The `hascol()` token provides an alternative syntax:

```ring
oTx = new stzTablex("{hascol(employee) & hascol(department)}")
? oTx.Match(oTable)
#--> TRUE
```

This column verification is essential when working with dynamic data sources where column presence cannot be guaranteed.

---

## 3. Content Matching with Case Control

The `contains()` token searches for values anywhere in the table:

```ring
oTable1 = new stzTable([
    [ :NAME, :CITY ],
    [ "Ali", "Tunis" ],
    [ "Sara", "Paris" ]
])

oTable2 = new stzTable([
    [ :NAME, :CITY ],
    [ "Omar", "Cairo" ]
])

oTx = new stzTablex("{contains(Tunis)}")
? oTx.Match(oTable1)  #--> TRUE
? oTx.Match(oTable2)  #--> FALSE
```

By default, matching is **case-insensitive**. Use the `@cs:` prefix for exact case matching:

```ring
oTable = new stzTable([
    [ :NAME ],
    [ "ali" ],
    [ "ALI" ]
])

oTx = new stzTablex("{contains(Ali)}")
? oTx.Match(oTable)
#--> TRUE (case-insensitive)

oTx = new stzTablex("{@cs:contains(Ali)}")
? oTx.Match(oTable)
#--> FALSE (neither "ali" nor "ALI" matches exactly)
```

This case control is crucial when working with user-generated data where capitalization varies.

---

## 4. Enforcing Data Uniqueness

Unique constraints are fundamental to data integrity. The `unique()` token verifies column uniqueness:

```ring
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
```

The inverse—detecting duplicates—uses the `duplicates()` token:

```ring
oTable = new stzTable([
    [ :EMAIL ],
    [ "ali@mail.com" ],
    [ "sara@mail.com" ],
    [ "ali@mail.com" ]
])

oTx = new stzTablex("{duplicates(email)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{@!duplicates(email)}")
? oTx.Match(oTable)
#--> FALSE (negated—we DO have duplicates)
```

---

## 5. Type Validation

Type constraints ensure columns contain the expected data types:

```ring
oTable = new stzTable([
    [ :NAME, :AGE, :TAGS ],
    [ "Ali", 28, ["dev", "lead"] ],
    [ "Sara", 32, ["hr", "manager"] ]
])

oTx = new stzTablex("{coltype(age:number) & coltype(name:string) & coltype(tags:list)}")
? oTx.Match(oTable)
#--> TRUE
```

For simpler checks, use the shorthand tokens:

```ring
oTx = new stzTablex("{numeric(age) & alphabetic(name)}")
? oTx.Match(oTable)
#--> TRUE
```

Type validation catches data import errors early, before they propagate through your application logic.

---

## 6. Statistical Constraints

Statistical patterns validate numeric column aggregates:

```ring
oTable = new stzTable([
    [ :PRODUCT, :SALES ],
    [ "A", 10000 ],
    [ "B", 20000 ],
    [ "C", 30000 ]
])

# Sum must equal 60000
oTx = new stzTablex("{sumcol(sales:60000)}")
? oTx.Match(oTable)
#--> TRUE

# Sum must exceed 50000
oTx = new stzTablex("{sumcol(sales:>50000)}")
? oTx.Match(oTable)
#--> TRUE
```

The same constraint syntax applies to averages, minimums, and maximums:

```ring
oTable = new stzTable([
    [ :NAME, :SCORE ],
    [ "Ali", 80 ],
    [ "Sara", 90 ],
    [ "Omar", 70 ]
])

oTx = new stzTablex("{avgcol(score:>75) & mincol(score:>60) & maxcol(score:<100)}")
? oTx.Match(oTable)
#--> TRUE
```

These statistical patterns enable validation of business rules: "average salary must exceed $40,000," "no price below cost," "all grades between 0 and 100."

---

## 7. Data Quality Assessment

Real-world data is messy. Quality patterns detect missing or incomplete data:

```ring
oTable = new stzTable([
    [ :NAME, :EMAIL ],
    [ "Ali", "ali@mail.com" ],
    [ "Sara", "" ]  # Missing email
])

# Detect null/empty values
oTx = new stzTablex("{nulls(email)}")
? oTx.Match(oTable)
#--> TRUE

# Ensure no nulls
oTx = new stzTablex("{@!nulls(email)}")
? oTx.Match(oTable)
#--> FALSE
```

The `completeness()` token quantifies data coverage:

```ring
oTable = new stzTable([
    [ :NAME, :PHONE ],
    [ "Ali", "123456" ],
    [ "Sara", "789012" ],
    [ "Omar", "345678" ],
    [ "Fatma", "" ]  # Missing
])

# Require 75% completeness
oTx = new stzTablex("{completeness(phone:75)}")
? oTx.Match(oTable)
#--> TRUE (3 out of 4 = 75%)

oTx = new stzTablex("{completeness(phone:90)}")
? oTx.Match(oTable)
#--> FALSE
```

These quality checks surface data issues during ETL processes or API validations.

---

## 8. Calculated Column Recognition

Tables often contain derived columns—totals, percentages, computed values. The `calculated()` token identifies them:

```ring
oTable = new stzTable([
    [ :PRICE, :QTY ],
    [ 100, 5 ],
    [ 200, 3 ]
])

oTable.AddCalculatedCol(:TOTAL, '@(:PRICE) * @(:QTY)')

oTx = new stzTablex("{calculated(total)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{calculated(price)}")
? oTx.Match(oTable)
#--> FALSE (price is not calculated)
```

The `aggregated()` token detects any calculated rows or columns:

```ring
oTx = new stzTablex("{aggregated()}")
? oTx.Match(oTable)
#--> TRUE (has calculated column)
```

---

## 9. Logical Composition

Patterns combine through logical operators: `&` (AND), `|` (OR), and `@!` (NOT).

**Conjunction** enforces multiple requirements:

```ring
oTx = new stzTablex("{cols(3) & rows(>10) & unique(id) & @!nulls(email)}")
```

**Alternation** accepts multiple possibilities:

```ring
oTx = new stzTablex("{(cols(3) | cols(4)) & rows(>5)}")
```

**Negation** inverts conditions:

```ring
oTx = new stzTablex("{@!duplicates(email) & @!nulls(phone)}")
```

These operators nest arbitrarily:

```ring
oTx = new stzTablex("{
    (cols(3) | cols(4)) & 
    unique(id) & 
    (@!nulls(email) | completeness(email:90)) &
    (avgcol(salary:>40000) | avgcol(age:>30))
}")
```

This compositional power transforms complex validation rules into readable specifications.

---

## 10. Multi-Table Operations

When working with table collections, stzTablex provides batch operations:

```ring
oTable1 = new stzTable([[ :A, :B, :C ], [ 1, 2, 3 ]])
oTable2 = new stzTable([[ :A, :B ], [ 4, 5 ]])
oTable3 = new stzTable([[ :A, :B, :C ], [ 6, 7, 8 ]])

aTables = [ oTable1, oTable2, oTable3 ]

oTx = new stzTablex("{cols(3)}")

# Count matches
? oTx.CountMatchingTablesIn(aTables)
#--> 2

# Retrieve matches
aMatches = oTx.MatchingTablesIn(aTables)
? len(aMatches)
#--> 2
```

This enables filtering data lake tables, validating batch imports, or finding conformant datasets in heterogeneous collections.

---

## 11. Pattern Composition and Reuse

Patterns are first-class objects that can be combined programmatically:

```ring
oStructure = new stzTablex("{cols(3) & rows(>5)}")
oQuality = new stzTablex("{unique(id) & @!nulls(email)}")

# Combine with AND
oComplete = oStructure.And_(oQuality)
? oComplete.Pattern()
#--> {cols(3) & rows(>5) & unique(id) & @!nulls(email)}

# Combine with OR
oFlexible = oStructure.Or_(oQuality)
? oFlexible.Pattern()
#--> {cols(3) & rows(>5) | unique(id) & @!nulls(email)}

# Negate
oInverse = oQuality.Not_()
? oInverse.Pattern()
#--> {@!unique(id) & @!nulls(email)}
```

This compositional approach encourages pattern libraries—reusable validation rules across your application.

---

## 12. Advanced Table-Specific Patterns

Beyond basics, stzTablex recognizes table-specific properties:

**Grouping detection:**
```ring
# Detect grouped data (consecutive duplicates)
oTx = new stzTablex("{grouped(department)}")
```

**Filtering indicators:**
```ring
# Detect gaps in sequential data
oTx = new stzTablex("{filtered(id)}")
```

**Transposition hints:**
```ring
# More columns than rows
oTx = new stzTablex("{transposed()}")
```

**Pattern matching:**
```ring
# Email format validation
oTx = new stzTablex("{colpattern(email:@EMAIL)}")
```

These specialized patterns expose table semantics that traditional validation misses.

---

## 13. Debugging and Introspection

For transparency, stzTablex provides introspection tools:

```ring
oTx = new stzTablex("{cols(3) & unique(id) & avgcol(salary:>40000)}")

? oTx.Pattern()
#--> {cols(3) & unique(id) & avgcol(salary:>40000)}

? len(oTx.Tokens())
#--> 1 (conjunction token containing conditions)

oTx.EnableDebug()
oTx.Match(oTable)  # Shows parsing details
```

The `Explain()` method provides structured analysis:

```ring
oTx.Match(oTable)
aExplain = oTx.Explain()

? @@(aExplain[1])
#--> ["Pattern", "{cols(3) & unique(id)}"]

? @@(aExplain[2])
#--> ["TokenCount", 1]
```

---

## 14. Real-World Validation Scenarios

**Employee database integrity:**
```ring
oTx = new stzTablex("{
    unique(id) & 
    @!nulls(email) & 
    coltype(salary:number) &
    avgcol(salary:>40000) & 
    avgcol(salary:<60000)
}")

? oTx.Match(oEmployees)
#--> Ensures: unique IDs, valid emails, numeric salaries in reasonable range
```

**Sales data quality:**
```ring
oTx = new stzTablex("{
    cols(4) & 
    @!nulls(product) & 
    mincol(amount:>0) & 
    completeness(customer:95)
}")

? oTx.Match(oSales)
#--> Validates: structure, products exist, positive amounts, 95%+ customer coverage
```

**ETL pipeline validation:**
```ring
oTx = new stzTablex("{
    hascol(load_date) & 
    hascol(source) & 
    completeness(source:100) & 
    sumcol(record_count:>5000)
}")

? oTx.Match(oWarehouse)
#--> Checks: required columns present, complete metadata, sufficient data volume
```

---

## 15. Comparative Advantages

Where other frameworks require procedural validation code, stzTablex provides declarative specifications:

| Feature | **stzTablex** | Pandas | SQL CHECK | Manual Code |
|---------|---------------|--------|-----------|-------------|
| **Declarative syntax** | ✅ `{cols(3) & unique(id)}` | ❌ Procedural | ⚠️ Limited | ❌ Verbose |
| **Multi-table filtering** | ✅ Native | ⚠️ Manual loops | ❌ N/A | ⚠️ Complex |
| **Case sensitivity control** | ✅ `@cs:` prefix | ⚠️ Parameters | ❌ | ⚠️ String ops |
| **Statistical constraints** | ✅ `avgcol(salary:>40000)` | ⚠️ Separate checks | ✅ Aggregates | ❌ Manual calc |
| **Quality metrics** | ✅ `completeness()`, `nulls()` | ⚠️ `isnull()` | ⚠️ Manual | ⚠️ Loops |
| **Pattern composition** | ✅ `And_()`, `Or_()`, `Not_()` | ❌ | ❌ | ⚠️ Nested ifs |
| **Type validation** | ✅ `coltype(age:number)` | ✅ `dtype` | ⚠️ Limited | ⚠️ Manual |
| **Calculated column detection** | ✅ `calculated()`, `aggregated()` | ❌ | ❌ | ❌ |
| **Readable validation rules** | ✅ Self-documenting | ⚠️ Code comments | ⚠️ SQL | ❌ Verbose |

---

## Conclusion

stzTablex transforms table validation from imperative verification into declarative specification. Where traditional approaches scatter validation logic across conditional statements, stzTablex consolidates it into readable patterns that double as documentation.

By expressing requirements as:

```ring
{unique(id) & @!nulls(email) & completeness(phone:90) & avgcol(salary:>40000)}
```

instead of nested loops and conditionals, your code becomes self-explanatory. Table validation becomes pattern recognition—semantic, composable, and maintainable.

Together with `stzTable` for manipulation and `stzPivotTable` for analysis, `stzTablex` completes Softanza's vision of tabular data as a first-class programming abstraction—where structure, semantics, and validation are expressed in the language of the domain rather than the mechanics of implementation.
