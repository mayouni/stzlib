# Narrative
# --------
# Understanding HttpGet - Simple web request
#
# Extracted from stzreactivehttptest.ring, block #1.

load "../../../stzBase.ring"


# HttpGet fetches data from a URL without blocking your program
# Think of it like sending a letter and getting a response later

pr()

# Making a simple GET request

Rs = new stzReactiveSystem()
Rs {
    ? "Making HTTP GET request to API..."
    
    # HttpGet(url, onSuccess_callback, onError_callback)

    HttpGet(
        'https://jsonplaceholder.typicode.com/posts/1',

        func response {
            ? "✔ SUCCESS! Received response:" + NL
            ? response
            Rs.Stop()  # Stop the engine after success
        },

        func error {
            ? "❌ ERROR: " + error
           Rs.Stop()
        }
    )
    
    Start()  # This starts the event loop and waits for HTTP response
}

#-->
# Making HTTP GET request to API...
# ✔ SUCCESS! Received response:
#
# {
#   "userId": 1,
#   "id": 1,
#   "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
#   "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
# }

pf()
# Executed in 1.07 seconds depending on network
