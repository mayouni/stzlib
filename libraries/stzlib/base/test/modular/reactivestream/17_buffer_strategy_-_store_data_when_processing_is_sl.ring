# Narrative
# --------
# Buffer Strategy - Store data when processing is slow
#
# Extracted from stzreactivestreamtest.ring, block #17.

load "../../../stzBase.ring"


# The sample shows proper Overflow with BUFFER_EXPAND strategy
# When the buffer is full, new items are stored temporarily until
# processing capacity becomes available to drain them.

pr()

Rs = new stzReactiveSystem()
Rs {

    # High-frequency data stream with slow processing

    oBufferStream = CreateStream("buffer-example")
    oBufferStream {
        # Set buffer strategy with small buffer for demo
        SetOverflowStrategy(BUFFER_EXPAND, 3)

        # Slow processing Rfunction (simulated)
        OnPassed(func data {
            ? " 📊 Processing: " + data + " (slow processing)"
            # Simulate slow processing
        })
        
        OnOverflow(func(current, max) {
            ? "🚦 Overflow activated: " + current + "/" + max + " buffer full"
        })
        
        # Rapid data reception

        for i = 1 to 7  # Exceeds buffer size of 3
            ? "Receiving item " + i
            Recieve("Data-" + i)
        next
        
        ? "Processing buffer..."
        ProcessAnItemFromBuffer()

    }
    
    RunLoop()
    #--> (#NOTE I added comments to the output for clarity)
 
    # Phase 1: Filling buffer (capacity: 3)
    # -------------------------------------
    # Receiving item 1
    # Receiving item 2
    # Receiving item 3
    # 
    # Phase 2: Buffer full - Overflow stores new items
    # ------------------------------------------------
    # Receiving item 4
    # 🚦 Overflow activated: 3/3 buffer full
    # ⚠️ Overflow: Buffering data (buffer full: 3/3)
    # 
    # Receiving item 5
    # 🚦 Overflow activated: 3/3 buffer full
    # ⚠️ Overflow: Buffering data (buffer full: 3/3)
    # 
    # Receiving item 6
    # 🚦 Overflow activated: 3/3 buffer full
    # ⚠️ Overflow: Buffering data (buffer full: 3/3)
    # 
    # Receiving item 7
    # 🚦 Overflow activated: 3/3 buffer full
    # ⚠️ Overflow: Buffering data (buffer full: 3/3)
    # 
    # Phase 3: Manual buffer processing handles buffered items
    #---------------------------------------------------------
    # Processing buffer...
    # 📊 Processing: Data-1 (slow processing)
    # 📊 Processing: Data-2 (slow processing)
    # 📊 Processing: Data-3 (slow processing)

}

#NOTE

# Processing a buffer means executing Rfunctions on all stored items
# in the buffer. Items were temporarily held due to overflow,
# and processing releases them to Rfunctions for execution.

# In our example above:

# Items 1-3 fill the buffer (capacity: 3)
# Items 4-7 are stored by overflow strategy (buffer extends)
# Processing executes stored items through Rfunctions in order

# It's like a waiting room: people (data) wait when the
# service desk (Rfunction) can't handle the flow, and
# processing is like calling the waiting people forward.

pf()
# Executed in 0.95 second(s) in Ring 1.23
