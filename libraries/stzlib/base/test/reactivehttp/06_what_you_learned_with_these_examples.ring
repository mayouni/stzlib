# Narrative
# --------
# What you learned with these examples:
#
# Extracted from stzreactivehttptest.ring, block #6.

load "../../stzBase.ring"


1. **HttpGet**: Non-blocking GET requests
   - HttpGet(url, onSuccess, onError)
   - Perfect for fetching data from APIs

2. **HttpPost**: Sending data to servers
   - HttpPost(url, data, onSuccess, onError)  
   - Perfect for submitting forms, creating resources

3. **HTTP Streams**: Transform HTTP responses into reactive streams
   - Combine multiple requests into unified data flow
   - Apply transformations and filters to responses

4. **HTTP + Timers**: Polling patterns
   - RunEvery() + HttpGet() for regular data updates
   - Common pattern for real-time dashboards

5. **Parallel HTTP Requests**: Fetch multiple sources simultaneously
   - Send requests at same time, not sequentially
   - Much faster than waiting for each request

6. **Error Handling**: Always prepare for failures
   - Network issues, server errors, timeouts
   - Graceful degradation when services are unavailable

7. **Data Aggregation**: Combining results from multiple sources
   - Track completion status across multiple async operations
   - Process and summarize results when all complete

Common HTTP streaming applications:
- Real-time dashboards pulling from multiple APIs
- Social media feed oAggregators  
- Stock price monitoring systems
- Weather data collectors
- News feed processors
- IoT sensor data aggregation

Best Practices:
- Always handle both success and error cases
- Use timeouts to prevent hanging requests
- Consider rate limiting when polling frequently
- Cache responses when appropriate
- Process data as it arrives (don't wait for all requests)

