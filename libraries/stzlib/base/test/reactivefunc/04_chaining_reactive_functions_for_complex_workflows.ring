# Narrative
# --------
# Chaining reactive functions for complex workflows
#
# Extracted from stzreactivefunctest.ring, block #4.

load "../../stzBase.ring"


# Real applications often need to chain operations:
# fetch data → process it → save results → notify user
# Reactive functions make this elegant with proper sequencing

pr()

oRs = new stzReactiveSystem()
oRs {

    # Step 1: Fetch user data
    fetchUser = func userId {
        # Simulate API call delay
        sleep(0.1)
        if userId = 1
            return '{"name":"John","age":30,"role":"admin"}'
        else
            return '{"name":"Jane","age":25,"role":"user"}'
        ok
    }
    
    # Step 2: Process user data
    processUser = func jsonData {
        # Parse JSON-like string (simplified)
        if substr(jsonData, "admin")
            return "ADMIN_USER_PROCESSED"
        else
            return "REGULAR_USER_PROCESSED"
        ok
    }
    
    # Step 3: Save to log
    saveLog = func processedData {
        logEntry = "LOG: " + processedData + " at " + timeList()[4] + ":" + timeList()[5]
        return logEntry
    }

    # Make all functions reactive
    RFetch = Reactivate(fetchUser)
    RProcess = Reactivate(processUser)
    RSave = Reactivate(saveLog)

    # Chain them together - each step waits for the previous one
    ? "Starting user processing workflow..."
    
    RFetch.CallAsync([1], func userData {
        ? "Step 1 complete - User data fetched"
        
        # When fetch completes, start processing
        RProcess.CallAsync([userData], func processedData {
            ? "Step 2 complete - Data processed: " + processedData
            
            # When processing completes, save log
            RSave.CallAsync([processedData], func logResult {
                ? "Step 3 complete - " + logResult
                ? "Workflow finished successfully!"
            }, func error {
                ? "Save error: " + error
            })
            
        }, func error {
            ? "Process error: " + error
        })
        
    }, func error {
        ? "Fetch error: " + error
    })

    Start()
    #-->
    # Starting user processing workflow...
    # Step 1 complete - User data fetched
    # Step 2 complete - Data processed: ADMIN_USER_PROCESSED
    # Step 3 complete - LOG: ADMIN_USER_PROCESSED at 14:23
    # Workflow finished successfully!
}

pf()
# Executed in 1.04 second(s) in Ring 1.23

#-----------------------------------#
#  EXAMPLE 5: BATCH PROCESSING      #
#-----------------------------------#
