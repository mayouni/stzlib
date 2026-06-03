# Narrative
# --------
# Chat Message Processing
#
# Extracted from stzreactivestreamtest.ring, block #7.

load "../../stzBase.ring"


# Realistic example: Processing chat messages with filtering and
# formatting demonstrates practical stream usage

pr()

Rs = new stzReactiveSystem()
Rs {
    
    # Chat message processing pipeline

    oChatStream = CreateStream("chat-messages")
    oChatStream {

        # Filter out spam and inappropriate content

        Filter(func message {
            spamWords = [ "spam", "advertisement", "buy now" ]
            text = lower(message)
            
            nLenSpam = len(spamWords)
            for i = 1 to nLenSpam
                if substr(text, spamWords[i])
                    return false  # Block spam
                ok
            next
            
            return len(message) > 0 and len(message) <= 280  # Valid length
        })
        
        # Format messages

        Transform(func message {
            timestamp = "12:34"  # In real app, use actual timestamp
            return "[" + timestamp + "] " + message
        })
        
        OnPassed(func formattedMessage {
            ? "💬 " + formattedMessage
        })
        
        # Simulate chat messages

        messages = [
            "Hello everyone!",
            "How's everyone doing?", 
            "Check out this spam advertisement",  # Will be filtered
            "",  # Empty message - filtered
            "Great discussion today!",
            "See you later!"
        ]
        
        RecieveMany(messages)

    }
    
    RunLoop()
    #-->
    # 💬 [12:34] Hello everyone!
    # 💬 [12:34] How's everyone doing?
    # 💬 [12:34] Great discussion today!
    # 💬 [12:34] See you later!
}

pf()
# Executed in 0.94 second(s) in Ring 1.23
