# Narrative
# --------
# Access to Original Data
#
# Extracted from stzdatasettest.ring, block #27.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# Retrieves the raw dataset.

pr()

o1 = new stzDataSet([ 100, 200, 300, 400, 500 ])
o1 {
    ? @@(Data())          #--> [100, 200, 300, 400, 500]
    ? @@(Values())        #--> [100, 200, 300, 400, 500] (alias for Data())
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

#======================================================================#
#  Insights and Recommendations                                        #
#======================================================================#

# Generates interpretative insights and analysis suggestions.
#TODO Add Actions() - Transforms recommendations into actionable code to execute
