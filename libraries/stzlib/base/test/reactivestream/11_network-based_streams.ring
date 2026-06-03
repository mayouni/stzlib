# Narrative
# --------
# Network-Based Streams
#
# Extracted from stzreactivestreamtest.ring, block #11.

load "../../stzBase.ring"


# HTTP requests, WebSocket connections, API polling
# Essential for: Real-time data, API integration, network monitoring

pr()

Rs = new stzReactiveSystem()
Rs {
    # API data processing stream
    oNetworkStream = CreateNetworkStream("api-monitor")
    oNetworkStream {
        # Parse API responses
        Transform( func apiResponse {
            # Simulate JSON parsing
            return [
                :endpoint = apiResponse[:url],
                :status_code = apiResponse[:status],
                :response_time = apiResponse[:time],
                :data_size = apiResponse[:size]
            ]
        })

        # Monitor performance issues
        Filter( func response {
            return response[:status_code] >= 400 or response[:response_time] > 2000
        })

        OnPassed( func issue {

            issueType = ""
            if issue[:status_code] >= 500
                issueType = "🔴 SERVER ERROR"

            but issue[:status_code] >= 400
                issueType = "🟡 CLIENT ERROR"  

            but issue[:response_time] > 2000
                issueType = "🐌 SLOW RESPONSE"
            ok
            
            ? issueType
            ? "• Endpoint: " + issue[:endpoint]
            ? "• Status: " + issue[:status_code]
            ? "• Response Time: " + issue[:response_time] + "ms" + NL
        })
        
        # Simulate API responses
        acResponses = [
            [ :url = "/api/users", :status = 200, :time = 150, :size = 1024 ],
            [ :url = "/api/orders", :status = 404, :time = 89, :size = 256 ],
            [ :url = "/api/products", :status = 500, :time = 3500, :size = 0 ],
            [ :url = "/api/payments", :status = 200, :time = 2500, :size = 512 ]
        ]
        
        RecieveMany(acResponses)

    }
    
    RunLoop()
    #-->
    '
    🟡 CLIENT ERROR
    • Endpoint: /api/orders
    • Status: 404
    • Response Time: 89ms

    🔴 SERVER ERROR
    • Endpoint: /api/products
    • Status: 500
    • Response Time: 3500ms

    🐌 SLOW RESPONSE
    • Endpoint: /api/payments
    • Status: 200
    • Response Time: 2500ms
    '
}

pf()
# Executed in 0.94 second(s) in Ring 1.23
