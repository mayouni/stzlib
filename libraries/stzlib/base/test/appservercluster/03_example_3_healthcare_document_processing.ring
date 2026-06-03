# Narrative
# --------
# Example 3: Healthcare Document Processing
#
# Extracted from stzappserverclustertest.ring, block #3.
#ERR Error (R3) : Calling Function without definition: init

load "../../stzBase.ring"

pr()

    oHealthCluster = new stzCluster() {
        WithVision(4)      # OCR for medical records, X-rays, prescriptions
        WithNLP(3)         # Medical text analysis, ICD coding
        WithSearch(2)      # Patient record search, drug interactions
    }
    
    oHealthCluster.Start(8080)
    
    # Smart routing automatically handles:
    # POST /api/process-xray → Vision Cluster (OCR + analysis)
    # POST /api/analyze-symptoms → NLP Cluster (medical text processing)
    # GET /api/search-interactions → Search Cluster (drug database)

pf()
