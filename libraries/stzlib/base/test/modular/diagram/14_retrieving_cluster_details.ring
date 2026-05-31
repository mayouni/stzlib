# Narrative
# --------
# Retrieving cluster details
#
# Extracted from stzdiagramtest.ring, block #14.

load "../../../stzBase.ring"


pr()

oDiag = new stzDiagram("ClusterInfo")
oDiag.AddNodeXTT("a", "A", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("b", "B", [ :type = "process", :color = "primary" ])

oDiag.AddClusterXTT("domain1", "My Domain", ["a", "b"], "lightblue")

aClusters = oDiag.Clusters()
aCluster = aClusters[1]

? aCluster["label"] #--> My Domain
? len(aCluster["nodes"]) #--> 2

pf()
# Executed in 0.03 second(s) in Ring 1.25

#--------------#
#  SET THEMES  #
#--------------#
