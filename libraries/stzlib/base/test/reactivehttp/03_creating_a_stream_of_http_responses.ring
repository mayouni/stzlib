# Narrative
# --------
# Creating a stream of HTTP responses
#
# Extracted from stzreactivehttptest.ring, block #3.

load "../../stzBase.ring"


pr()

# You can create streams that fetch data from multiple URLs
# Perfect for aggregating data from different sources

# List of URLs to fetch data from
aApiUrls = [
   "https://jsonplaceholder.typicode.com/posts/1",
   "https://jsonplaceholder.typicode.com/posts/2", 
   "https://jsonplaceholder.typicode.com/posts/3"
]

nCurrentIndex = 0
cRequestId = ""

Rs = new stzReactiveSystem()
Rs {
   # Create stream as property of Rs object
   httpStream = CreateStream("http-responses")
   
   # Subscribe to receive each HTTP response
   httpStream.Subscribe(func aData {
       ? " ╰─> Received from stream: Post #" + aData["id"] + " - " + 
         left(aData["title"], 30) + "..."
   })
   
   # Complete handler - called when stream ends
   httpStream.OnComplete(func() {
       ? NL + "✔ All HTTP requests completed!"
       Rs.Stop()
   })
   
   # Start fetching URLs one by one
   ? "Creating HTTP request stream for " + len(aApiUrls) + " URLs..."
   cRequestId = RunEvery(1000, :fFetchNextUrl)  # Every 1 second
   
   Start()
}

pf()

func fFetchNextUrl()

   if nCurrentIndex < len(aApiUrls)
       nCurrentIndex++
       cUrl = aApiUrls[nCurrentIndex]
       
       ? "🔄 Fetching URL #" + nCurrentIndex + ": " + cUrl
       
       # Make the HTTP request
       Rs.HttpGet(cUrl,

           func cResponse {
               # Simulate parsing JSON response
               aMockData = [
                   :id = nCurrentIndex,
                   :title = "Post Title #" + nCurrentIndex,
                   :body = "Post body content...",
                   :response = cResponse
               ]
               
               # Emit to stream
               httpStream.Emit(aMockData)

               # Check if we're done with all URLs
               if nCurrentIndex >= len(aApiUrls)
                   Rs.StopTimer(cRequestId)
                   httpStream.Complete()  # End the stream
               ok
           },

           func cError {
               ? "❌ Request failed: " + cError
               Rs.httpStream.EmitError(cError)
           }
       )
   ok

#--> Creating HTTP request stream for 3 URLs...
#
#🔄 Fetching URL #1: https://jsonplaceholder.typicode.com/posts/1
# ╰─> Received from stream: Post #1 - ...
#🔄 Fetching URL #2: https://jsonplaceholder.typicode.com/posts/2
# ╰─> Received from stream: Post #2 - ...
#🔄 Fetching URL #3: https://jsonplaceholder.typicode.com/posts/3
# ╰─> Received from stream: Post #3 - ...
#
#✔ All HTTP requests completed!

# Executed in 1.30 second(s) in Ring 1.23

#--------------------------------------#
#  EXAMPLE 4: HTTP POLLING WITH TIMER  #
#--------------------------------------#
