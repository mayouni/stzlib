# Narrative
# --------
# Simple python code
#
# Extracted from stzpythoncodeTest.ring, block #2.

load "../../stzBase.ring"


pr()

py() {

# Pyhton code
@('
res = {
    "numbers": [1, 2, 3, 4, 5],
    "mean": sum([1, 2, 3, 4, 5]) / 5
}
')
# end of Python code

# Instructing python to run the code
Execute()

# Instructing Ring to return the result from Python
? @@( Result() )
#--> [
#	[ "numbers", [ 1, 2, 3, 4, 5 ] ],
#	[ "mean", 3 ]
# ]

} # closing brace of the py() object

pf()
# Executed in 0.43 second(s) in Ring 1.24
