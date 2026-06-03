# Narrative
# --------
# Scientific notation
#
# Extracted from stzextercodetest.ring, block #35.

load "../../stzBase.ring"


pr()

njs = new stzExterCode("nodejs")
njs.SetCode('

// Create an object with scientific notation numbers
const res = {
    avogadro: 6.02214076e23,
    planck: 6.62607015e-34,
    speedOfLight: 2.99792458e8,
    values: [1e10, 2e-5, 3.5e6]
};

') # End of NodeJS code

njs.Execute()
? @@( njs.Result() )
#-->
#   [ "avogadro", "6.02214076e+23" ],
#	[ "planck", "6.62607015e-34" ],
#	[ "speedOfLight", 299792458 ],
#	[ "values", [ 10000000000, 0.00, 3500000 ] ]
# ]

pf()
# Executed in 0.34 second(s) in Ring 1.23
