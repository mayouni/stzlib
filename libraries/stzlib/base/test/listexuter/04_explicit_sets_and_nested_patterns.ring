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
    
    AddCode(:ValidStatusCode, func v {
        codeMap = [
            200, "OK",
            404, "Not Found",
            500, "Server Error"
        ]
        
        _nCodeMapLen_ = len(codeMap)
        for i = 1 to _nCodeMapLen_ step 2
            if v = codeMap[i]
                v = [ v, codeMap[i+1] ]
                exit
            ok
        next
        return v
    })
    
    AddCode(:ApiResponse, func v {
        v = [
            "API_RESPONSE",
            v[1],  # Endpoint
            v[2][1],  # Status code
            v[2][2]   # Message
        ]
        return v
    })
    
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

pf()
# Executed in 0.03 second(s) in Ring 1.22
