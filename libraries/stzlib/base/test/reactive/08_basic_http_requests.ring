# Narrative
# --------
# Basic HTTP requests
#
# Extracted from stzreactivetest.ring, block #8.

load "../../stzBase.ring"


# Reactive HTTP requests prevent blocking during network operations.
# They provide clean error handling and response processing.
# Support for all HTTP methods with customizable headers and data.

pr()

Rs = new stzReactiveSystem()
Rs {

    # Simple GET request
    HttpGet("https://api.github.com/users/mayouni", 
        func cResponse {
            ? "GET Response received: " + len(cResponse) + " characters"
        },
        func cError {
            ? "GET Error: " + cError
        }
    )

    # POST request with data
    cPostData = '{"name": "test", "value": 123}'
    HttpPost("https://httpbin.org/post",
	cPostData,
        func cResponse {
            ? "POST Response: Success"
        },
        func cError {
            ? "POST Error: " + cError
        }
    )

    Start()
}
#-->
# GET Response received: 54 characters
# POST Response: Success

pf()
# Executed in almost 1.69 second(s) in Ring 1.23
