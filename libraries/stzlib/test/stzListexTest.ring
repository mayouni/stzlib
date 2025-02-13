load "../max/stzmax.ring"

/*--- Basic list matching

pr()

? Lx("[@N]").Match([42])
#--> TRUE

? Lx("[@S]").Match(["hello"])
#--> TRUE

? Lx("[@L]").Match([[1,2,3]]) + NL
#--> TRUE

? Lx("[@N]").Match([42])
#--> TRUE

? Lx("[@S]").Match(["hello"])
#--> TRUE

? Lx("[@A]").Match([[1,2,3]])
#--> TRUE

proff()
# Executed in 0.14 second(s) in Ring 1.22

/*--- Matching lists with multiple elements

pr()

? Lx("[@N, @S, @L]").Match([42, "hello", [1,2,3]])
#--> TRUE

? Lx("[@N, @N, @N]").Match([1, 2, 3])
#--> TRUE

proff()
# Executed in 0.10 second(s) in Ring 1.22

/*--- Using Quantifiers in the list match

pr()

# Optional element

? Lx("[@N, @S?]").Match([42])
#--> TRUE

# Optional present

? Lx("[@N, @S?]").Match([42, "hello"])
#--> TRUE

# One or more

? Lx("[@N+]").Match([1, 2, 3, 4])
#--> TRUE

# Zero or more empty

? Lx("[@N*]").Match([])
#--> TRUE

# Number quantifier

? Lx("[@N3]").Match([1, 2, 3])
#--> TRUE

# Range quantifier

? Lx("[@N1-3]").Match([1])
#--> TRUE

? Lx("[@N1-3]").Match([1, 2])
#--> TRUE

proff()
# Executed in 0.23 second(s) in Ring 1.22

/*--- Complex types

pr()

# Nested lists

? Lx("[@L]").Macth([ [1, [2, 3], 4] ])
#--> TRUE

# Mixed quotes

? Lx("[@S, @S]").Match([ "double", 'single' ])
#--> TRUE

proff()
# Executed in 0.09 second(s) in Ring 1.22

/*--- Invalid cases (don't matching)

pr()

# Wrong type

? Lx("[@N]").Match(["string"])
#--> FALSE

# Too few elements

? Lx("[@N, @N]").Match([1])
#--> FALSE

# Too many elements

? Lx("[@N]").Match([1, 2])
#--> FALSE

# Invalid range

? Lx("[@N2-4]").Match([1])
#--> FALSE

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*--- Edge cases

pr()

# Empty pattern

? Lx("[]").Match([])
#--> TRUE

# Any type

? Lx("[@A]").Match([42])
#--> TRUE

# Any type string

? Lx("[@A]").Match(["hello"])
#--> TRUE

# Any type list

? Lx("[@A]").Match( [[1,2,3]] )
#--> TRUE

# Deep nesting

? Lx("[@L]").Match( [[[[[1]]]]] )
#--> TRUE

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*===

pr()

Lx = new stzListex('[ @N, @S+, @N ]')
Lx {
	? Match([ 5 , "str", 3 ])
	#--> TRUE

	? Match([ 5 , "str1", "str2", "str3", 3 ])
	#--> TRUE

	? Match([ 5, "", 3 ])
	#--> TRUE

	? Macth([ 5, 2, 3 ])
	#--> FALSE
}

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*---

pr()

Lx = new stzListex('[ @N, @S+, @N ]')
Lx {
	? Match([ 5 , "str", 3 ])
	#--> TRUE

	# Chek the internal tokens structure produced
	# by the parsing process undertaken to transform
	# the list pattern into actionable data ready for match

	? @@NL( Tokens() ) + NL
	#--> [
	# 	[
	# 		[ "type", "number" ],
	# 		[ "pattern", "(?:-?\d+(?:\.\d+)?)" ],
	# 		[ "min", 1 ], [ "max", 1 ]
	# 	],
	# 	[
	# 		[ "type", "string" ],
	# 		[ "pattern", '(?:"[^"]*"|\'[^\']*\')' ],
	# 		[ "min", 1 ], [ "max", 999999999999999 ]
	# 	],
	# 	[
	# 		[ "type", "number" ],
	# 		[ "pattern", "(?:-?\d+(?:\.\d+)?)" ],
	# 		[ "min", 1 ], [ "max", 1 ]
	# 	]
	# ]
}

proff()
# Executed in 0.08 second(s) in Ring

/*--- Range pattern

pr()

Lx = new stzListex('[@N1-3]')
Lx {
	? Match([1])          #--> TRUE	
	? Match([1,2])        #--> TRUE
	? Match([1,2,3])      #--> TRUE
	? Match([1,2,3,4])    #--> FALSE
}

proff()
# Executed in 0.10 second(s) in Ring 1.22

/*--- Basic types

pr()

Lx = new stzListex('[@N, @S, @L]')
Lx {
	? Match([5, "hello", [1,2,3]])  #--> TRUE
	? Match([5, [1,2], "hello"])    #--> FALSE
}

proff()
# Executed in 0.08 second(s) in Ring 1.22

/*--- Quantifiers

pr()

Lx = new stzListex('[@N+, @S]')
Lx {
	? Match([1,2,3, "hello"])       #--> TRUE
	? Match([1, "hello"])           #--> TRUE
	? Match(["hello"])              #--> FALSE
}

proff()
# Executed in 0.10 second(s) in Ring 1.22

#===
*/

/*--- Mixed quantifiers and types

pr()

# Multiple quantifiers

? Lx('[ @N+, @S*, @L? ]').Match([ 1, 2, "a", "b" ])
#--> TRUE

# Nested alternating types

? Lx('[ @L ]').Match([ [ 1, "hello", [ 2, "world", [3] ] ] ])
#--> TRUE

# Maximum depth test

? Lx('[ @L ]').Match([ [[[[[[[[["too deep"]]]]]]]]] ])
#--> FALSE

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*--- Edge cases with empty elements

pr()

# Empty strings

? Lx('[ @S+ ]').Match([ "", "", "" ])
#--> TRUE

# Empty lists

? Lx('[ @L+ ]').Match([ [], [], [] ])
#--> TRUE

# Zero in numbers

? Lx("[ @N+ ]").Match([ 0, 0.0, -0 ])
#--> TRUE

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*--- Complex number formats

pr()

# Decimal numbers

? Lx('[@N+]').Match([1.23, -45.67, 0.89, -0.12])
#--> TRUE

# Large numbers

? Lx("[@N]").Match([ 999999999999 ])
#--> TRUE

proff()
# Executed in 0.10 second(s) in Ring 1.22

/*--- String variations

pr()

# Unicode strings
? Lx("[ @S ]").Match(["こんにちは"])
#--> TRUE

# Escaped quotes
? Lx('[ @S ]').Match([ 'He said "hello"' ])
#--> TRUE

# Mixed quote types

? Lx("[ @S ]").Match([ "outer'inner'quotes" ])
#--> TRUE

proff()
# Executed in 0.10 second(s) in Ring 1.22

/*--- Complex combinations

pr()

# Alternating patterns

? Lx('[ @N, @S, @N, @S ]').Match([ 1, "one", 2, "two" ])
#--> TRUE

# Mixed quantifiers

? Lx('[ @N+, @S*, @L1-3 ]').Match([ 1, 2, "a", [1], [2] ])
#--> TRUE

? Lx('[ @N+, @S*, @L0-3 ]').Match([ 1, 2 ])
#--> TRUE

# Nested with quantifiers

? Lx('[ @L+ ]').Match([ [ 1, 2 ], [ "a","b" ], [ [ 1, 2, 3 ] ] ])
#--> TRUE

proff()
# Executed in 0.19 second(s) in Ring 1.22

/*--- Invalid patterns

pr()

# Invalid range order

? Lx('[ @N3-1 ]').Match([1])
#--> ERROR: Invalid range in quantifier: 3-1 

# Invalid quantifier

? Lx('[ @N^ ]').Match([1])
#--> ERROR: Invalid quantifier: ^ 

# Unclosed bracket

? Lx('[@N, @S').Match([ 1, "a" ])
#--> ERROR: Unmatched brackets in pattern

proff()

/*--- Real-world use cases

pr()

# JSON-like structure

? Lx('[ @L ]').Match([[
    "name", "John",
    "age", 30,
    "address", ["city", "NY", "zip", 10001]
]])
#--> TRUE

# CSV-like rows

? Lx('[ @S, @N, @N, @S+ ]').Match([
    "Product", 100, 29.99, "In Stock", "Featured"
])
#--> TRUE

# Matrix-like structure

? Lx('[@L+]').Match([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])
#--> TRUE

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*==== @A in data validation

# @A metachar enables flexible data structures:
# configuration parsing, mixed-type records, optional fields,
# dynamic columns, and nested structures.

/*--- Flexible config entries

pr()

Lx("[@S, @A]") {

	? Match([ "port", 8080 ])
	#--> TRUE

	? Match([ "host", "localhost" ])
	#--> TRUE

	? Match([ "debug", [ true, "verbose" ] ])
	#--> TRUE
}

proff()
# Executed in 0.09 second(s) in Ring 1.22

/*--- Mixed data records

pr()

? Lx("[@S, @A+]").Match([ "user", "john", 25, ["admin", "user"] ])
#--> TRUE

proff()
# Executed in 0.08 second(s) in Ring 1.22

/*--- Optional heterogeneous data

pr()

? Lx("[@N, @A?]").Match([100])
#--> TRUE

? Lx("[@N, @A?]").Match([100, "pending"])
#--> TRUE

? Lx("[@N, @A?]").Match([100, [1,2,3]])
#--> TRUE

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*--- Dynamic columns

pr()

? Lx("[@S, @N, @A*]").Match(["Product", 100])
#--> TRUE

? Lx("[@S, @N, @A*]").Match(["Product", 100, "red", 50, ["S", "M", "L"]])
#--> TRUE

proff()
# Executed in 0.11 second(s) in Ring 1.22

/*--- Nested structures

pr()

? Lx("[@A, @L]").Match([42, [1,2,3]])
#--> TRUE

? Lx("[@A, @L]").Match(["key", ["a","b"]])
#--> TRUE

proff()
# Executed in 0.10 second(s) in Ring 1.22
