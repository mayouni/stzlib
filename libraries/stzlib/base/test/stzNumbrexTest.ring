load "../stzbase.ring"


#=========================================#
#  SOFTANZA NUMBEREX (Nx) - TEST SUITE   #
#=========================================#

#-------------------------------#
#  BASIC TYPE MATCHING          #
#-------------------------------#

/*--- Matching integers only

pr()

? Nx("[@I3]").Match([1, 2, 3])
#--> true

? Nx("[@I3]").Match([1.5, 2, 3])
#--> false (first element is real not integer)

pf()

/*--- Matching reals only

pr()

? Nx("[@R2]").Match([3.14, 2.71])
#--> true

? Nx("[@R2]").Match([3, 2.71])
#--> false (first element is integer)

pf()

/*--- Matching any numbers with @$

pr()

? Nx("[@$5]").Match([1, 2.5, -3, 0, 100])
#--> true (accepts integers and reals)

pf()

#-------------------------------#
#  SIGN-BASED MATCHING          #
#-------------------------------#

/*--- Positive numbers only

pr()

? Nx("[@P+]").Match([1, 5, 10, 99])
#--> true

? Nx("[@P+]").Match([1, -5, 10])
#--> false (contains negative)

pf()

/*--- Negative numbers only

pr()

? Nx("[@N+]").Match([-1, -5, -10])
#--> true

? Nx("[@N+]").Match([-1, 0, -10])
#--> false (zero is not negative)

pf()

/*--- Mixed pattern: positive then negative

pr()

? Nx("[@P2, @N2]").Match([5, 10, -3, -7])
#--> true (2 positive, then 2 negative)

pf()

#-------------------------------#
#  EVEN AND ODD MATCHING        #
#-------------------------------#

/*--- Even numbers only

pr()

? Nx("[@E+]").Match([2, 4, 6, 8])
#--> true

? Nx("[@E+]").Match([2, 4, 5, 8])
#--> false (5 is odd)

pf()

/*--- Odd numbers only

pr()

? Nx("[@O+]").Match([1, 3, 5, 7])
#--> true

pf()

/*--- Alternating even and odd

pr()

? Nx("[@E, @O, @E, @O]").Match([2, 3, 4, 5])
#--> true

pf()

/*--- NOT operator: matching non-even (odd) numbers

pr()

? Nx("[@!E+]").Match([1, 3, 5, 7])
#--> true (all are NOT even, i.e., odd)

? Nx("[@!E+]").Match([1, 2, 5])
#--> false (2 is even)

pf()

#-------------------------------#
#  QUANTIFIERS                  #
#-------------------------------#

/*--- Exact count quantifier

pr()

? Nx("[@I5]").Match([1, 2, 3, 4, 5])
#--> true (exactly 5 integers)

? Nx("[@I5]").Match([1, 2, 3, 4])
#--> false (only 4 integers)

pf()

/*--- Plus (+) quantifier: one or more

pr()

? Nx("[@E+]").Match([2, 4, 6])
#--> true (3 even numbers)

? Nx("[@E+]").Match([2])
#--> true (1 even number)

? Nx("[@E+]").Match([])
#--> false (requires at least 1)

pf()

/*--- Star (*) quantifier: zero or more

pr()

? Nx("[@O*]").Match([1, 3, 5])
#--> true (3 odd numbers)

? Nx("[@O*]").Match([])
#--> true (0 odd numbers allowed)

pf()

/*--- Question (?) quantifier: zero or one

pr()

? Nx("[@P?, @N+]").Match([-5, -10])
#--> true (0 positive, 2 negative)

? Nx("[@P?, @N+]").Match([5, -10, -20])
#--> true (1 positive, 2 negative)

? Nx("[@P?, @N+]").Match([5, 10, -20])
#--> false (2 positive exceeds ?)

pf()

/*--- Section quantifier: min-max

pr()

Nx = Nx("[@I2-4]")
Nx.EnableDebug()
? Nx.Match([1, 2, 3])
#--> true (3 integers, within 2-4)
'
BacktrackMatch: token 1/1, number 1/3
  Token: @I (min: 2, max: 4)
  Trying matches from 2 to 3
  Matched 2 number(s)
  Matched 3 number(s)
'
#~> The debug output is clear and informative. It shows:
#    - Token position and totals
#    - Token type and quantifier section
#    - Match attempts (2 and 3 numbers)
#    - Final result (true)

#--
? ""

Nx.DisableDebug()
? Nx.Match([1])
#--> false (only 1, needs at least 2)

? Nx.Match([1, 2, 3, 4, 5])
#--> false (5 integers exceeds max of 4)

pf()

#-------------------------------#
#  PRIME NUMBER MATCHING        #
#-------------------------------#

/*--- Detecting prime numbers

pr()

? Nx("[@PR+]").Match([2, 3, 5, 7, 11])
#--> true (all are prime)

? Nx("[@PR+]").Match([2, 3, 4, 5])
#--> false (4 is not prime)

pf()

/*--- Pattern: 3 primes followed by any number

pr()

? Nx("[@PR3, @$]").Match([2, 3, 5, 100])
#--> true

pf()

/*--- NOT prime (composite numbers)

pr()

? Nx("[@!PR+]").Match([4, 6, 8, 9, 10])
#--> true (all are composite/not prime)

pf()

#-------------------------------#
#  RANGE CONSTRAINTS            #
#-------------------------------#

/*--- Numbers within a section using (min..max)

pr()

? Nx("[@$(1..10)+]").Match([5, 7, 3, 9])
#--> true (all between 1 and 10)

? Nx("[@$(1..10)+]").Match([5, 15, 3])
#--> false (15 exceeds section)

pf()

/*--- Positive integers in section

pr()

? Nx("[@I(0..100)+]").Match([25, 50, 75])
#--> true

pf()

/*--- Combining type and section constraints

pr()

? Nx("[@E(10..50)3]").Match([12, 24, 36])
#--> true (3 even numbers between 10-50)

? Nx("[@E(10..50)3]").Match([12, 24, 60])
#--> false (60 out of section)

pf()

#-------------------------------#
#  SET CONSTRAINTS              #
#-------------------------------#

/*--- Matching numbers from a specific set

pr()

? Nx("[@${1;3;5;7}+]").Match([1, 5, 3, 7])
#--> true (all in set)

? Nx("[@${1;3;5;7}+]").Match([1, 2, 3])
#--> false (2 not in set)

pf()

/*--- Exact count with set constraint

pr()

? Nx("[@${10;20;30}3]").Match([10, 20, 30])
#--> true

? Nx("[@${10;20;30}3]").Match([10, 20, 20])
#--> true (duplicates allowed)

pf()

/*--- Even numbers from specific set

pr()

? Nx("[@E{2;4;6;8}+]").Match([2, 4, 6])
#--> true (all even AND in set)

? Nx("[@E{2;4;6;8}+]").Match([2, 4, 10])
#--> false (10 not in set)

pf()

#-------------------------------#
#  DIVISIBILITY MATCHING        #
#-------------------------------#

/*--- Numbers divisible by specific value

pr()

? Nx("[@DIV(5)+]").Match([5, 10, 15, 20])
#--> true (all divisible by 5)

? Nx("[@DIV(5)+]").Match([5, 10, 12])
#--> false (12 not divisible by 5)

pf()

/*--- Divisible by 3, exactly 4 numbers

pr()

? Nx("[@DIV(3)4]").Match([3, 6, 9, 12])
#--> true

pf()

/*--- Pattern: 2 multiples of 5, then 2 multiples of 3

pr()

? Nx("[@DIV(5)2, @DIV(3)2]").Match([10, 25, 6, 9])
#--> true

pf()

#-------------------------------#
#  DIGIT COUNT MATCHING         #
#-------------------------------#

/*--- Single-digit numbers only

pr()

? Nx("[@D(1)+]").Match([5, 7, 2, 9])
#--> true (all single digit)

? Nx("[@D(1)+]").Match([5, 12, 2])
#--> false (12 is two digits)

pf()

/*--- Two-digit numbers only

pr()

Nx = Nx("[@D(2)+]")
Nx.EnableDebug()
? Nx.Match([10, 25, 99])
#--> true
'
BacktrackMatch: token 1/1, number 1/3
  Token: @D (min: 1, max: 999999999)
  Trying matches from 1 to 3
  Matched 1 number(s)
  Matched 2 number(s)
  Matched 3 number(s)
'

? ""

Nx.DisableDebug()
? Nx.Match([10, 5, 99])
#--> false (5 is single digit)

pf()

/*--- Pattern: 2 single-digit, then 2 two-digit

pr()

? Nx("[@D(1)2, @D(2)2]").Match([5, 7, 10, 25])
#--> true

pf()

#-------------------------------#
#  COMPLEX PATTERNS             #
#-------------------------------#

/*--- Validation: score pattern (0-100, positive)

pr()

? Nx("[@P(0..100)+]").Match([85, 92, 78, 95])
#--> true (valid test scores)

? Nx("[@P(0..100)+]").Match([85, 105, 78])
#--> false (105 exceeds 100)

pf()

/*--- Financial: amounts with cents pattern

pr()

aTransactions = [10.50, 25.99, 100.00, 5.25]

? Nx("[@P+]").Match(aTransactions)
#--> true (all positive amounts)

pf()

/*--- Sensor data: 5 positive readings, then optional negative

pr()

? Nx("[@P5, @N?]").Match([10, 20, 30, 40, 50])
#--> true (5 positive, 0 negative)

? Nx("[@P5, @N?]").Match([10, 20, 30, 40, 50, -5])
#--> true (5 positive, 1 negative)

pf()

/*--- Time series: alternating increases/decreases

pr()

? Nx("[@P, @N, @P, @N]").Match([5, -2, 8, -3])
#--> true (alternating pattern)

pf()

/*--- Game scores: 3-5 positive integers from specific section

pr()

Nx = Nx("[@I(1..1000)3-5]")
Nx.EnableDebug()
? Nx.Match([100, 250, 500])
#--> true (3 scores)
'
BacktrackMatch: token 1/1, number 1/3
  Token: @I (min: 3, max: 5)
  Trying matches from 3 to 3
  Matched 3 number(s)
'

? ""
Nx.DisableDebug()
? Nx.Match([100, 250, 500, 750, 900])
#--> true (5 scores)

? Nx.Match([100, 250])
#--> false (only 2 scores)

pf()

/*--- Cryptographic: prime numbers of specific digit length

pr()

# Pattern: one prime, then one or more 2-digit numbers


? Nx("[@PR, @D(2)+]").Match([2, 11, 13, 17, 19])
#--> true (2 is prime, then 11,13,17,19 are all 2-digit)

# Requiring all numbers to be 2-digit primes

? Nx("[@D(2), @PR+]").Match([2, 11, 13, 17, 19])
#--> false (2 is only 1 digit, fails first token)

pf()

/*--- Statistical outlier detection: NOT in normal section

pr()

# Detect values outside 10-90 section
Nx = Nx("[@!$(10..90)+]")
Nx.EnableDebug()
? Nx.Match([5, 2, 95, 100])
#--> true (all outside 10-90)

? Nx("[@!$(10..90)+]").Match([5, 50, 95])
#--> false (50 is within section)

pf()

/*--- Lottery numbers: 6 unique primes from 1-50

pr()

# Note: uniqueness requires set constraint
? Nx("[@PR(1..50)6]").Match([7, 11, 13, 19, 23, 29])
#--> true (6 primes in section)

pf()

/*--- Pagination: page sizes (multiples of 10)

pr()

Nx = Nx("[@DIV(10)(10..100)+]")
Nx.EnableDebug()
? Nx.Match([10, 20, 50, 100])
#--> true (all multiples of 10, within section)
'
BacktrackMatch: token 1/1, number 1/4
  Token: @DIV (min: 1, max: 999999999)
  Trying matches from 1 to 4
  Matched 1 number(s)
  Matched 2 number(s)
  Matched 3 number(s)
  Matched 4 number(s)
'

pf()

/*--- RGB color validation: 3 integers 0-255

pr()

? Nx("[@I(0..255)3]").Match([128, 64, 192])
#--> true (valid RGB)

? Nx("[@I(0..255)3]").Match([128, 64])
#--> false (only 2 values)

? Nx("[@I(0..255)3]").Match([128, 64, 300])
#--> false (300 exceeds 255)

pf()

/*--- Temperature readings: optional negative, then positive

pr()

? Nx("[@N*, @P+]").Match([10, 20, 30])
#--> true (0 negative, 3 positive)

? Nx("[@N*, @P+]").Match([-5, -10, 5, 10])
#--> true (2 negative, 2 positive)

pf()

#-------------------------------#
#  NEGATION PATTERNS            #
#-------------------------------#

/*--- NOT even = odd numbers

pr()

? Nx("[@!E+]").Match([1, 3, 5, 7])
#--> true

pf()

/*--- NOT positive = zero or negative

pr()

? Nx("[@!P+]").Match([0, -5, -10])
#--> true

? Nx("[@!P+]").Match([0, 5, -10])
#--> false (5 is positive)

pf()

/*--- NOT in section (outliers)

pr()

? Nx("[@!$(50..100)+]").Match([10, 20, 110, 120])
#--> true (all outside 50-100)

pf()

/*--- NOT divisible by 2 (odd numbers another way)
*/
pr()

? Nx("[@!DIV(2)+]").Match([1, 3, 5, 7])
#--> true

pf()

#-------------------------------#
#  REAL-WORLD USE CASES         #
#-------------------------------#

/*--- API response validation: HTTP status codes

pr()

# Success codes (200-299)
? Nx("[@I(200..299)+]").Match([200, 201, 204])
#--> true

# Error codes (400-499 or 500-599)
aErrors = [404, 500, 503]
? Nx("[@I(400..599)+]").Match(aErrors)
#--> true

pf()

/*--- Banking: transaction validation

pr()

# Deposits: positive only
? Nx("[@P+]").Match([100.50, 250.00, 75.25])
#--> true

# Withdrawals: negative only
? Nx("[@N+]").Match([-50.00, -100.00, -25.50])
#--> true

pf()

/*--- Age validation: adults only (18-120)

pr()

? Nx("[@I(18..120)+]").Match([25, 45, 67])
#--> true

? Nx("[@I(18..120)+]").Match([25, 15, 67])
#--> false (15 < 18)

pf()

/*--- Dice rolls: 1-6 only

pr()

? Nx("[@I{1;2;3;4;5;6}+]").Match([3, 5, 1, 6, 2])
#--> true (all valid dice rolls)

? Nx("[@I{1;2;3;4;5;6}+]").Match([3, 7, 1])
#--> false (7 invalid)

pf()

/*--- Rating system: 1-5 stars

pr()

? Nx("[@I{1;2;3;4;5}+]").Match([5, 4, 5, 3, 4])
#--> true (valid ratings)

pf()

/*--- Priority queue: levels 1, 2, or 3 only

pr()

? Nx("[@I{1;2;3}+]").Match([1, 2, 1, 3, 2])
#--> true

pf()

/*--- Fibonacci sequence validator (first 10)

pr()

? Nx("[@${1;1;2;3;5;8;13;21;34;55}+]").Match([1, 1, 2, 3, 5])
#--> true (valid Fibonacci subsequence)

pf()

/*--- Port numbers: well-known (0-1023)

pr()

? Nx("[@I(0..1023)+]").Match([80, 443, 22, 21])
#--> true (common ports)

pf()

/*--- Percentage validation: 0-100

pr()

? Nx("[@$(0..100)+]").Match([75.5, 85, 92.3])
#--> true

? Nx("[@$(0..100)+]").Match([75.5, 105])
#--> false (105 exceeds 100)

pf()

/*--- Cryptographic: checking prime factors

pr()

# Ensure all factors are prime
? Nx("[@PR+]").Match([2, 3, 5, 7])
#--> true (useful for RSA key validation)

pf()

#-------------------------------#
#  ADVANCED COMPOSITIONS        #
#-------------------------------#

/*--- Pattern: even prime (only 2), then odd primes

pr()

? Nx("[@E, @PR1, @O, @PR+]").Match([2, 2, 3, 5, 7])
#--> true (2 is even AND prime, rest odd primes)

pf()

/*--- Three-part pattern: negative, zeros, positive

pr()

? Nx("[@N+, @${0}*, @P+]").Match([-5, -3, 0, 0, 5, 10])
#--> true

? Nx("[@N+, @${0}*, @P+]").Match([-5, -3, 5, 10])
#--> true (zero section optional)

pf()

/*--- Alternating constraints

pr()

? Nx("[@E, @DIV(3), @E, @DIV(3)]").Match([2, 9, 4, 12])
#--> true (2 even, 9 div by 3, 4 even, 12 div by 3)

pf()

/*--- Multiple quantifiers in sequence

pr()

? Nx("[@P1-3, @N2-4, @$*]").Match([5, 10, -2, -5, -8, 100, 200])
#--> true (2 pos, 3 neg, 2 any)

pf()

#-------------------------------#
#  DEBUG AND INTROSPECTION      #
#-------------------------------#

/*--- Viewing parsed tokens

pr()

oNx = Nx("[@E2, @O+, @P(1..10)]")

? @@( oNx.Tokens()) + NL
#--> [ "@E", "@O", "@P" ]

? @@NL( oNx.TokensXT() ) + NL
#-->
'
[
	[
		[ "keyword", "@E" ],
		[ "min", 2 ],
		[ "max", 2 ],
		[ "quantifier", 2 ],
		[ "constraints", [  ] ],
		[ "negated", 0 ],
		[ "type", "even" ]
	],
	[
		[ "keyword", "@O" ],
		[ "min", 1 ],
		[ "max", 999999999 ],
		[ "quantifier", 1 ],
		[ "constraints", [  ] ],
		[ "negated", 0 ],
		[ "type", "odd" ]
	],
	[
		[ "keyword", "@P" ],
		[ "min", 1 ],
		[ "max", 1 ],
		[ "quantifier", 1 ],
		[
			"constraints",
			[
				[
					"section",
					[ 1, 10 ]
				]
			]
		],
		[ "negated", 0 ],
		[ "type", "positive" ]
	]
]
'

? oNx.TokensInfo()
#-->
'
Token #1: @E2
Token #2: @O (1-999999999)
Token #3: @P [constraints: 1]
'

pf()

/*--- Pattern retrieval

pr()

oNx = Nx("[@PR+, @DIV(3)2]")
? oNx.Pattern()
#--> "[@PR+, @DIV(3)2]"

pf()
