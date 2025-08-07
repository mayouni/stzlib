load "../stzbase.ring"

# =============================================================================
# HTTP CLIENT EXAMPLES - Simple and fluent requests
# =============================================================================

pr()

? "=== HTTP Client Examples ==="

# Simple GET request
client = new stzHttpClient()
response = client.Get_("https://jsonplaceholder.typicode.com/posts/1")

if not client.HasError()
    ? "Status: " + client.ResponseCode()
    ? "Response: " + client.ResponseBody()
else
    ? "Error: " + client.LastError()
ok

# Fluent configuration with method chaining
user_data = new stzHttpClient()
user_data {
    SetUserAgent("MyApp/2.0")
    SetTimeout(15)
    VerifySSL(True)
    FollowRedirects(True)
    SetHeader("Authorization", "Bearer my-token")
    Get_("https://api.github.com/user")
}

if not user_data.HasError()
    ? "GitHub user data retrieved successfully"
    ? "Response time: " + user_data.ResponseTime() + " seconds"
ok

# POST with JSON data
api_client = new stzHttpClient()
api_client {
    SetUserAgent("Softanza-Client/1.0")
    SetTimeout(30)
}

new_post = '{
    "title": "My New Post",
    "body": "This is the content of my post",
    "userId": 1
}'

api_client.PostJson("https://jsonplaceholder.typicode.com/posts", new_post)

if not api_client.HasError()
    ? "Post created! Status: " + api_client.ResponseCode()
    created_post = api_client.ResponseBody()
    ? "Created: " + created_post
ok

# Form data POST
form_client = new stzHttpClient()
form_data = ["name", "John Doe", "email", "john@example.com", "age", "30"]
form_client.PostForm("https://httpbin.org/post", form_data)

? "Form submitted: " + form_client.ResponseCode()

# File download with progress
downloader = new stzHttpClient()
downloader {
    SetTimeout(60)
    SetUserAgent("Softanza-Downloader/1.0")
}

downloader.DownloadFile(
    "https://httpbin.org/json", 
    "./downloads/test.json"
)

if not downloader.HasError()
    ? "File downloaded successfully"
    ? "Download time: " + downloader.ResponseTime() + "s"
ok

# Parallel requests
urls = [
    "https://httpbin.org/delay/1",
    "https://httpbin.org/delay/2", 
    "https://httpbin.org/delay/3"
]

parallel_client = new stzHttpClient()
results = parallel_client.GetMany(urls)
? "Parallel requests completed: " + len(results) + " results"

pf()
