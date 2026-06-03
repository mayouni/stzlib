# Narrative
# --------
# Example 2: Financial Services Platform
#
# Extracted from stzappserverclustertest.ring, block #2.

load "../../stzBase.ring"


    # Heavy math processing for risk analysis, modeling, trading algorithms
    oFinanceCluster = new stzCluster() {
        WithMath(5)        # 5 nodes for heavy financial calculations
        WithNLP(3)         # 3 nodes for document analysis, news sentiment
        WithSearch(2)      # 2 nodes for market data retrieval
    }
    
    oFinanceCluster.Start(8080)
    
    # The cluster automatically routes:
    # POST /api/calculate-risk → Math Cluster (instant response)
    # POST /api/analyze-earnings → NLP Cluster (instant response)
    # GET /api/search-market → Search Cluster (instant response)
