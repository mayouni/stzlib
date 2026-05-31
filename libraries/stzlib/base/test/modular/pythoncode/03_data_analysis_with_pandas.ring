# Narrative
# --------
# Data Analysis with Pandas
#
# Extracted from stzpythoncodeTest.ring, block #3.

load "../../../stzBase.ring"


pr()

py() {

# Pyhton code
@('
import pandas as pd
import numpy as np

# Create sample data
res = {
    "sales_data": {
            "total_revenue": sum([a*b for a,b in zip([100, 150, 200, 120],
				 [10.5, 8.75, 12.25, 15.00])]),

            "average_price": np.mean([10.5, 8.75, 12.25, 15.00]),
            "best_seller": "C"
    }
}
') # End of Python code

# Back to Ring
Execute()

? @@NL(Result())

} # Closing brace of the py() object

#--> [
#	[
#		"sales_data",
#		[
#			[ "total_revenue", 6612.50 ],
#			[ "average_price", 11.62 ],
#			[ "best_seller", "C" ] ]
#		]
#	]
# ]

pf()
# Executed in 0.77 second(s) in Ring 1.24
