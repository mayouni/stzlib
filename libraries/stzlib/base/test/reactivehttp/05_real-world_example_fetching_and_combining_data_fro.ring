# Narrative
# --------
# Real-world example: Fetching and combining data from multiple APIs
#
# Extracted from stzreactivehttptest.ring, block #5.
#ERR Error (R3) : Calling Function without definition: download

load "../../stzBase.ring"


# This shows how to coordinate multiple HTTP requests and combine results
# Common pattern for dashboards, data analysis, or API mashups

pr()

# Global variables for callback access
oCurrentAggregator = NULL

oAggregator = new DataAggregator()
oAggregator.StartAggregation()

pf()

# Global callback functions
func OnHttpSuccess(cResponse)
    # Use oCurrentoAggregator to process the data
    # Note: We need to track which request this is for - simplified version
    oCurrentAggregator.ProcessSourceData("API", cResponse, 1)

func OnHttpError(cError)
    ? "❌ HTTP Error: " + cError
    oCurrentoAggregator.ProcessSourceData("API", NULL, 1)

# Aggaregator class
class DataAggregator
    oReactive = NULL
    aAggregatedData = []
    nCompletedRequests = 0
    nTotalRequests = 0
    
    def Init()
       oReactive = new stzReactive()
       aAggregatedData = []
       nCompletedRequests = 0
       nTotalRequests = 3  # Set the expected number of requests
       oCurrentAggregator = self  # Set global reference
        
    def StartAggregation()
        aApiSources = [
            ["users", "https://jsonplaceholder.typicode.com/users"],
            ["posts", "https://jsonplaceholder.typicode.com/posts"],  
            ["comments", "https://jsonplaceholder.typicode.com/comments"]
        ]
        
        ? "🔄 Starting API data aggregation..."
        ? "Fetching data from " + nTotalRequests + " different sources..." + NL
        
        # Fetch from all sources simultaneously (parallel requests)
        for i = 1 to ring_len(aApiSources)
            aSource = aApiSources[i]
            cName = aSource[1]
            cUrl = aSource[2]
            
            FetchFromSource(cName, cUrl, i)
        next
        
        oReactive.Start()
        
    def FetchFromSource(cSourceName, cSourceUrl, nSourceIndex)
        ? "─> Fetching " + cSourceName + " from " + cSourceUrl + "..."
        
        oReactive.HttpGet(cSourceUrl, :OnHttpSuccess, :OnHttpError)
        
    def ProcessSourceData(cSourceName, aResponseData, sourceIndex)
        # Simulate data processing
        if aResponseData != NULL
            nDataSize = ring_len(aResponseData)
            # Extract key metrics (simplified)
            nItemCount = floor(nDataSize / 100)  # Rough estimate of items
            
            aResult = [
                :source = cSourceName,
                :status = "success",
                :itemCount = nItemCount,
                :dataSize = nDataSize,
                :fetchTime = clock()
            ]
            
            ? "✔ " + cSourceName + " loaded: ~" + nItemCount + " items (" + nDataSize + " bytes)" + NL
        else
            aResult = [
                :source = cSourceName, 
                :status = "failed",
                :itemCount = 0,
                :dataSize = 0,
                :fetchTime = clock()
            ]
            ? "(!)  " +cSourceName + " failed to load"
        ok


        aAggregatedData + aResult
        nCompletedRequests++
        
        # Check if all requests completed
        if nCompletedRequests >= nTotalRequests
            CompleteAggregation()
        ok
        
    def CompleteAggregation()
        ? "🎉 Data aggregation completed!"
        ? "═══════════════════════════════"
        
        nTotalItems = 0
        nTotalBytes = 0
        nSuccessCount = 0
        
        for aData in aAggregatedData
            ? "📊 " + aData[:source] + ": " + aData[:status] + 
              " (" + aData[:itemCount] + " items, " + aData[:dataSize] + " bytes)"
              
            nTotalItems += aData[:itemCount]
            nTotalBytes += aData[:dataSize]
            
            if aData[:status] = "success"
                nSuccessCount++
            ok
        next
        
        ? NL + "📈 SUMMARY:"
        ? "   Sources processed: " + ring_len(aAggregatedData) + "/" + ntotalRequests  
        ? "   Success rate: " + (nSuccessCount * 100 / nTotalRequests) + "%"
        ? "   Total items: ~" + nTotalItems
        ? "   Total data: " + nTotalBytes + " bytes"
        
        oReactive.Stop()

#-->
# 🔄 Starting API data aggregation...
# Fetching data from 3 different sources...

# ─> Fetching Users from https://jsonplaceholder.typicode.com/users...
# ✔ API loaded: ~56 items (5645 bytes)

# ─> Fetching Posts from https://jsonplaceholder.typicode.com/posts...
# ✔ API loaded: ~275 items (27520 bytes)

# ─> Fetching Comments from https://jsonplaceholder.typicode.com/comments...
# ✔ API loaded: ~1577 items (157745 bytes)

# 🎉 Data aggregation completed!
# ═══════════════════════════════
# 📊 API: success (56 items, 5645 bytes)
# 📊 API: success (275 items, 27520 bytes)
# 📊 API: success (1577 items, 157745 bytes)

# 📈 SUMMARY:
#    Sources processed: 3/3
#    Success rate: 100%
#    Total items: ~1908
#    Total data: 190910 bytes

# Executed in 1.95 second(s) in Ring 1.23

#------------------------#
#  KEY CONCEPTS SUMMARY  #
#------------------------#
