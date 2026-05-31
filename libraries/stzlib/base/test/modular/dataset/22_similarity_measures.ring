# Narrative
# --------
# Similarity Measures
#
# Extracted from stzdatasettest.ring, block #22.

load "../../../stzBase.ring"

# Quantifies how similar two datasets are.

pr()

o1 = new stzDataSet([ 1, 2, 3, 4, 5 ])
? o1.SimilarityScore(o1) #--> 1 (identical datasets)

pf()
# Executed in 0.0010 second(s) in Ring 1.24
# Executed in 0.0020 second(s) in Ring 1.22
