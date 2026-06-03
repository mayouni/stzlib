# Narrative
# --------
# Explicit Sets and Nested Patterns
#
# Extracted from stzlistexutertest.ring, block #4.

load "../../stzBase.ring"


pr()

lxu() {
    # Using explicit sets and nested patterns
    AddTrigger(:ValidStatusCode = "[@N{200;404;500}]")  # Only specific status codes
    AddTrigger(:ApiResponse = "[@S, [@N, @S]]")         # Response with nested details
    
    AddCode(:ValidStatusCode, '{
        codeMap = [
            200, "OK",
            404, "Not Found",
            500, "Server Error"
        ]
        
        for i = 1 to len(codeMap) step 2
            if @list = codeMap[i]
                @list = [ @list, codeMap[i+1] ]
                exit
            ok
        next
    }')
    
    AddCode(:ApiResponse, '{
        @list = [
            "API_RESPONSE",
            @list[1],  # Endpoint
            @list[2][1],  # Status code
            @list[2][2]   # Message
        ]
    }')
    
    Process([
        200,
        404,
        [ "/users", [200, "Success"] ],
        [ "/orders", [404, "Order not found"] ]
    ])
    
    ? @@NL( MatchesXT() )
    #--> [
    #   [ 200, [200, "OK"] ],
    #   [ 404, [404, "Not Found"] ],
    #   [ ["/users", [200, "Success"]], ["API_RESPONSE", "/users", 200, "Success"] ],
    #   [ ["/orders", [404, "Order not found"]], ["API_RESPONSE", "/orders", 404, "Order not found"] ]
    # ]
}

proff()
# Executed in 0.03 second(s) in Ring 1.22
