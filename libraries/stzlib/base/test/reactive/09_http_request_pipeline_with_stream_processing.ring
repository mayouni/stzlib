# Narrative
# --------
# HTTP request pipeline with stream processing
#
# Extracted from stzreactivetest.ring, block #9.
#ERR Error (R3) : Calling Function without definition: download

load "../../stzBase.ring"


# Combining HTTP requests with streams creates powerful data processing pipelines.
# Results can be transformed and filtered before reaching the application.

pr()

Rs = new stzReactiveSystem()

# Store the stream in a variable first
oHttpStream = Rs.CreateStream("http-stream")

# Then configure the stream
oHttpStream {
    # Map - Convert response string to its length
    Map(func cResponse { return len(cResponse) })  
    
    # Filter - Only pass through responses longer than 10 characters
    Filter(func nLength { return nLength > 10 })
    
    # Define what happens when filtered data reaches the end
    OnPassed(func nLength {
        ? "Large response received: " + nLength + " bytes"
    })
}

# Make multiple HTTP requests
acUrls = [
    "https://api.github.com/users/mayouni",
    "https://httpbin.org/json", 
    "https://api.github.com/users/mayouni/repos/stzlib"
]

for i = 1 to len(acUrls)
    Rs.HttpGet(acUrls[i],
        func cResponse { 
            oHttpStream.Recieve(cResponse) 
        },
        func cError { 
            ? "Request failed: " + cError 
        }
    )
next

# End stream after delay
Rs.RunAfter(3000, func() { oHttpStream.Conclude() })

Rs.Start()
#-->
# Large response received: 1435 bytes
# Large response received: 429 bytes
# Large response received: 106 bytes

# WHAT HAPPENS STEP BY STEP:
# =========================
# 1. Three HTTP GET requests are made simultaneously
# 2. Each request returns a placeholder string (e.g., "GET response from https://...")
# 3. On success, each response is Recieveted to httpStream
# 4. Stream applies Map transform: string -> length (54, 42, 67)
# 5. Stream applies Filter: only lengths > 10 pass through (all pass)  
# 6. Stream calls OnPassed subscriber for each filtered value
# 7. Result: Three "Large response received: X bytes" messages printed

pf()
# Executed in 4.77 second(s) in Ring 1.23
