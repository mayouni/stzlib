# Narrative
# --------
# Data Analysis with Pandas
#
# Extracted from stzextercodetest.ring, block #8.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

#WARNING For this sample to work, you must install numpy and pandas mibs on pyhton

oPyCode = new stzExterCode("python")
oPyCode.SetCode('
import numpy as np
import pandas as pd

# Create sample of sales data
res = {
    "total_revenue": sum([a*b for a,b in zip([100, 150, 200, 120], [10.5, 8.75, 12.25, 15.00])]),
    "average_price": np.mean([10.5, 8.75, 12.25, 15.00]),
    "best_seller": "C"
}
')
oPyCode.Execute()
? @@(oPyCode.Result())
#--> [ [ "total_revenue", 6612.50 ], [ "average_price", 11.62 ], [ "best_seller", "C" ] ]

pf()
# Executed in 0.73 second(s) in Ring 1.23
