# Narrative
# --------
# Example 1: Basic Cluster Setup (3 lines to create enterprise-grade clustering)
#
# Extracted from stzappserverclustertest.ring, block #1.

load "../../../stzBase.ring"

    oCluster = new stzCluster()
    oCluster.WithNLP(3).WithMath(2).WithVision(2).WithSearch(1)
    oCluster.Start(8080)
