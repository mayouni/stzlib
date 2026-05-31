# Narrative
# --------
# Understanding HttpPost - Sending data to server
#
# Extracted from stzreactivehttptest.ring, block #2.

load "../../../stzBase.ring"


# HttpPost sends data to a server and receives a response
# Like filling out a form and submitting it online

pr()

# Creating and sending data via POST request

cPostData = '{
    "title": "My New Post",
    "body": "This is the content of my post", 
    "userId": 1
}'

Rs = new stzReactiveSystem()
Rs {
    ? "Sending HTTP POST request with data..." + NL

    ? "Data being sent: " + cPostData + NL
    
    # HttpPost(url, data, onSuccess_callback, onError_callback)
    HttpPost("https://jsonplaceholder.typicode.com/posts", 
        cPostData,
        func cResponse {
            ? "✔ POST SUCCESS! Server response:"
            ? "Created resource: " + cResponse
            Rs.Stop()
        },
        func cError {
            ? "❌ POST ERROR: " + cError
            Rs.Stop()
        }
    )
    
    Start()
}
#-->
# Sending HTTP POST request with data...
# Data being sent: {
#    "title": "My New Post",
#    "body": "This is the content of my post", 
#    "userId": 1
# }

# ✔ POST SUCCESS! Server response:
# Created resource: {
#  "{\n    \"title\": \"My New Post\",\n    \"body\": \"This is the content of my post\", \n    \"userId\": 1\n}": "",
#  "id": 101
# }

pf()
# Executed in 0.60 second(s) in Ring 1.23
