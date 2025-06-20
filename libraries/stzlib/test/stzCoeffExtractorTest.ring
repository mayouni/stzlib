load "../max/stzmax.ring"
decimals(4)

/*---

pr()

? @substr("softanza solvers are here!", 10, 16)
#--> "solvers"

? @substr("مرحبا بك في عالم البرمجة الرّياضيّة",
13, 24)
#o--> عالم البرمجة

pf()
#--> Executed in almost 0 second(s) in Ring 1.22

/*=== Simple linear expressions

pr()

cExpr = "10*red + 3*green"
o1 = new StzCoefficientExtractor(["red", "green", "blue"])

? o1.Extract(cExpr, "red")
#--> 10

? o1.ExtractCoeff(cExpr, "green")
#--> 3

? o1.ExtractCoefficient(cExpr, "blue")
#--> 0

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Negative coefficients

pr()

cExpr = "5*x - 3*y + 2*z"

o1 = new StzCoefficientExtractor(["x", "y", "z"])

? o1.Extract(cExpr, "x")
#--> 5

? o1.Extract(cExpr, "y")
#--> -3

? o1.Extract(cExpr, "z")
#--> 2

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Variables without explicit coefficients

pr()

cExpr = "x + 2*y - z"

o1 = new StzCoefficientExtractor(["x", "y", "z"])
? o1.Extract(cExpr, "x")
#--> 1

? o1.Extract(cExpr, "y")
#--> 2

? o1.Extract(cExpr, "z")
#--> -1

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Decimal coefficients

pr()

cExpr = "3.5*price + 0.8*quantity"

o1 = new StzCoeffExtractor(["price", "quantity"])
? o1.Extract(cExpr, "price")
#--> 3.5

? o1.Extract(cExpr, "quantity")
#--> 0.8

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Complex expression with min/max functions

pr()

cExpr = "min([ beds_dept1 / 20, 1 ]) * 100 + min([ beds_dept2 / 15, 1 ]) * 100"
o1 = new StzCoefficientExtractor(["beds_dept1", "beds_dept2"])
? o1.Extract(cExpr, "beds_dept1")
#--> 5.0

? o1.extract(cExpr, "beds_dept2")
#--> 6.666667

pf()

/*--- Expression with division

pr()

cExpr = "staff_count / 8 + overtime_hours / 4"

o1 = new StzCoefficientExtractor(["staff_count", "overtime_hours"])
? o1.extractCoefficient(cExpr, "staff_count")
#--> 0.125


? o1.extractCoefficient(cExpr, "overtime_hours")
#--> 0.25

pf()

/*--- Expression with power operations

pr()

# cExpr = "x^2 + 3*y^2 + 2*z" --> should be ringified like this
cExpr = "pow(x, 2) + 3 * pow(y, 2) + 2*z"

o1 = new StzCoefficientExtractor(["x", "y", "z"])
? o1.extractCoefficient(cExpr, "x")
#--> 2.0

? o1.extractCoefficient(cExpr, "y")
#--> 6.0

? o1.extractCoefficient(cExpr, "z")
#--> 2

pf()

/*--- Expression with absolute values

pr()

cExpr = "abs(demand - supply) + 0.5*inventory"
o1 = new StzCoefficientExtractor(["demand", "supply", "inventory"])

? o1.extractCoefficient(cExpr, "demand")
#--> 1.0

? o1.extractCoefficient(cExpr, "supply")
#--> -1.0

? o1.extractCoefficient(cExpr, "inventory")
#--> 0.5

pf()

/*--- Expression with square root

pr()
cExpr = "sqrt(area) + 2*perimeter"
o1 = new StzCoefficientExtractor(["area", "perimeter"])
? o1.extractCoefficient(cExpr, "area")
#--> 0.5

? o1.extractCoefficient(cExpr, "perimeter")
#--> 2

pf()

/*--- Complex multi-term expression

pr()
cExpr = "max([ 0, profit - 1000 ]) + min([ revenue / 100, 50 ]) + cost * 0.1"
o1 = new StzCoefficientExtractor(["profit", "revenue", "cost"])
? o1.extractCoefficient(cExpr, "profit")
#--> 1.0

? o1.extractCoefficient(cExpr, "revenue")
#--> 0.01

? o1.extractCoefficient(cExpr, "cost")
#--> 0.1

pf()

/*--- Expression with parentheses

pr()

# cExpr = "(x + y) * 2 + z" shoud be rewritten like this
cExpr = "2*x + 2*y + z"

o1 = new StzCoefficientExtractor(["x", "y", "z"])

? o1.extractCoefficient(cExpr, "x")
#--> 2.0

? o1.extractCoefficient(cExpr, "y")
#--> 2.0

? o1.extractCoefficient(cExpr, "z")
#--> 1

pf()

/*--- Zero coefficient case


pr()

cExpr = "a + b"
o1 = new StzCoefficientExtractor(["a", "b", "c"])
? o1.extractCoefficient(cExpr, "c")
#--> 0

pf()

/*--- Batch extraction

pr()

cExpr = "2*x + 3*y - z"
o1 = new StzCoefficientExtractor(["x", "y", "z"])
? o1.extractAllCoefficients(cExpr)
#--> [2, 3, -1]

pf()

/*--- Expression validation


pr()

cExpr = "invalid_function(x) + y"
o1 = new StzCoefficientExtractor(["x", "y"])
? o1.validateExpression(cExpr)
#--> FALSE


cExpr = "2*x + 3*y"
? o1.validateExpression(cExpr)
#--> TRUE #TODO #ERROR returned FALSE!

pf()

/*--- Variables as substrings (edge case)

pr()

cExpr = "production + production_cost"

o1 = new StzCoefficientExtractor(["production", "production_cost"])
? o1.extractCoefficient(cExpr, "production")
#--> 1

? o1.extractCoefficient(cExpr, "production_cost")
#--> 1

pf()

/*--- Spaces and formatting

pr()

cExpr = "  5 * x  +  3 * y  "
o1 = new StzCoefficientExtractor(["x", "y"])
? o1.extractCoefficient(cExpr, "x")
#--> 5

? o1.extractCoefficient(cExpr, "y")
#--> 3

pf()

/*---
*/
pr()

cExpr = "0.15*stocks + 0.04*bonds"
o1 = new StzCoefficientExtractor(["x", "y"])
? o1.extractCoefficient(cExpr, "stocks")
#--> 0.15

? o1.extractCoefficient(cExpr, "bonds")
#--> 0.04

o1.SetVariableNames([ "stocks", "bonds" ])
? @@(o1.extractAllCoefficients(cExpr))
#--> [ 0.1500, 0.0400 ]

pf()
