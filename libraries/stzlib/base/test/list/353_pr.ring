# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #353.

load "../../stzBase.ring"


? Q([ 1, 2, 3 ]).Are(:Numbers)
#--> TRUE

? Q([ -2, -4, -8 ]).Are([ :Even, :Negative, :Numbers ])
#--> TRUE

? Q([ 2, 4, 8 ]).Are([ :Even, :Numbers ])
#--> TRUE

? Q([ 2, 4, 8 ]).Are([ :Even, :Positive, :Numbers ])
#--> TRUE

? Q([ "(",";", ")" ]).Are([ :Punctuation, :Chars ])
#--> TRUE

pf()
# Executed in 0.28 second(s).
