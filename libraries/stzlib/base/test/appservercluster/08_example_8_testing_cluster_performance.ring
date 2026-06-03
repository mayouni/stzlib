# Narrative
# --------
# Example 8: Testing Cluster Performance
#
# Extracted from stzappserverclustertest.ring, block #8.

load "../../stzBase.ring"

pr()

    ? "Testing cluster computational performance..."
    
    # Simulate different types of requests
    aTestRequests = [
        # NLP requests
        ["POST", "/api/analyze-document", "Legal contract analysis"],
        ["POST", "/api/translate-text", "Multi-language translation"],
        ["POST", "/api/extract-entities", "Named entity recognition"],
        
        # Math requests  
        ["POST", "/api/optimize-portfolio", "Financial optimization"],
        ["POST", "/api/statistical-analysis", "Data science modeling"], 
        ["POST", "/api/solve-equations", "Numerical computation"],
        
        # Vision requests
        ["POST", "/api/ocr-document", "Document digitization"],
        ["POST", "/api/analyze-image", "Image classification"],
        ["POST", "/api/extract-data", "Form processing"],
        
        # Search requests
        ["GET", "/api/search-database", "Full-text search"],
        ["GET", "/api/find-similar", "Similarity matching"],
        ["GET", "/api/recommend", "Recommendation engine"]
    ]
    
    nStartTime = clock()
    nProcessedRequests = 0
    
    for aRequest in aTestRequests
        # Simulate request processing
        cMethod = aRequest[1]
        cPath = aRequest[2] 
        cDescription = aRequest[3]
        
        ? "Processing: " + cDescription + " → " + 
          This.GetExpectedCluster(cPath)
        nProcessedRequests++
    next
    
    nEndTime = clock()
    nTotalTime = nEndTime - nStartTime
    
    ? ""
    ? "=== Performance Results ==="
    ? "Requests processed: " + nProcessedRequests
    ? "Total time: " + nTotalTime + "ms"
    ? "Average per request: " + (nTotalTime / nProcessedRequests) + "ms" 
    ? "Requests per second: " + (nProcessedRequests * 1000 / nTotalTime)
    ? "=========================="

def GetExpectedCluster(cPath)
    if substr(cPath, "analyze") > 0 or substr(cPath, "translate") > 0 or substr(cPath, "extract") > 0
        return "NLP Cluster"
    ok
    if substr(cPath, "optimize") > 0 or substr(cPath, "statistical") > 0 or substr(cPath, "solve") > 0  
        return "Math Cluster"
    ok
    if substr(cPath, "ocr") > 0 or substr(cPath, "image") > 0 or substr(cPath, "extract-data") > 0
        return "Vision Cluster"  
    ok
    if substr(cPath, "search") > 0 or substr(cPath, "find") > 0 or substr(cPath, "recommend") > 0
        return "Search Cluster"
    ok
    return "General Cluster"

pf()
