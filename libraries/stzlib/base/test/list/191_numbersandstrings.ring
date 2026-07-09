# Narrative
# --------
# Extracting only the numeric and textual atoms from a mixed list.
#
# The list is built from a range (10:12), two strings, a sublist of
# operator strings, and an undefined variable. NumbersAndStrings()
# keeps just the scalar numbers and strings -- the range expands to
# 10, 11, 12, the two "strN" strings survive, while the nested
# operator sublist and the empty/undefined tail are dropped. The Z
# variant returns the same survivors paired with their 1-based
# position in the filtered result, the Softanza "...Z" zipped-index
# convention used across the list API.
#
# Extracted from stzlisttest.ring, block #191.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Extracting only the numeric and textual atoms from a mixed list.")

	o1 = new stzList( 10:12 + "str1" + "str2" + [ "+", "-" ] + o1 )

	Then("numbersandstrings example 1", @@( o1.NumbersAndStrings() ), @@( [ 10, 11, 12, "str1", "str2" ] ))

	Then("numbersandstrings example 2", @@( o1.NumbersAndStringsZ() ), @@( [ [ 10, 1 ], [ 11, 2 ], [ 12, 3 ], [ "str1", 4 ], [ "str2", 5 ] ] ))
EndScenario()

Summary()
