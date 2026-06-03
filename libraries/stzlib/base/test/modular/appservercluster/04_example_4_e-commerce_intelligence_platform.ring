# Narrative
# --------
# Example 4: E-commerce Intelligence Platform
#
# Extracted from stzappserverclustertest.ring, block #4.

load "../../../stzBase.ring"


    oEcomCluster = new stzCluster() {
        WithVision(3)      # Product image analysis, visual search
        WithNLP(4)         # Review analysis, product descriptions
        WithMath(2)        # Price optimization, demand forecasting
        WithSearch(3)      # Product search, recommendations
    }
    
    oEcomCluster.Start(8080)
    
    # Handles complex e-commerce workflows:
    # POST /api/analyze-product-image → Vision Cluster
    # POST /api/sentiment-reviews → NLP Cluster  
    # POST /api/optimize-pricing → Math Cluster
    # GET /api/search-products → Search Cluster
