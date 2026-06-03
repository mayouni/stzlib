# Narrative
# --------
# Categorical Data Analysis Tests
#
# Extracted from stzdatasettest.ring, block #8.

load "../../stzBase.ring"

# These functions describe the frequency and diversity of categorical data.

pr()

o1 = new stzDataSet([ "Red", "Blue", "Red", "Green", "Blue", "Red", "Yellow" ])
o1 {
    ? Mode()
    #--> "Red" (most frequent value)

    ? @@(FreqTable())
    #--> [[ " Red", 3], [ " Blue", 2], [ " Green", 1], [ " Yellow", 1]]

    ? @@(PercentFreq())
    #--> [[ " Red", 42.8571], ...] (percentage of each category)

    ? @@(RelFreq())
    #--> [[ " Red", 0.4286], ...] (proportion of each category)

    ? @@(UValues())
    #--> [ " Red", "Blue", "Green", "Yellow " ] (unique values)

    ? Diversity()
    #--> 0.5714 (diversity index, 0 to 1)

    ? Entropy()
    #--> 1.8424 (information entropy, measure of uncertainty)
}

pf()
# Executed in 0.0100 second(s) in Ring 1.24
