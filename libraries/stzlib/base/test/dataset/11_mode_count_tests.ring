# Narrative
# --------
# Mode Count Tests
#
# Extracted from stzdatasettest.ring, block #11.

load "../../stzBase.ring"

# Returns the frequency of the most common value(s).

pr()

o1 = new stzDataSet([ 1, 2, 2, 3, 2, 4, 2, 5 ])
o1 {
    ? Mode()		#--> 2
    ? ModeCount()	#--> 4 (frequency of 2)
    ? @@(FrequencyTable())
    #--> [[ " 1", 1], [ " 2", 4], [ " 3", 1], [ " 4", 1], [ " 5", 1]]
}

pf()
# Executed in 0.0060 second(s) in Ring 1.24

#======================================================================#
#  PILLAR 3: DISTRIBUTION - Shape & Spread Analysis                    #
#======================================================================#

# This pillar examines the shape, spread, and patterns of data distributions.
