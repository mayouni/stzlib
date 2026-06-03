# Narrative
# --------
# Latest Strategy - Keep most recent data
#
# Extracted from stzreactivestreamtest.ring, block #19.

load "../../stzBase.ring"


# The sample shows BUFFER_EVICT_OLDEST behavior
# Buffer maintains fixed size by discarding oldest data when new arrives
# Ensures most current information is preserved for time-sensitive applications

pr()

Rs = new stzReactiveSystem()
Rs {
    # Stock price stream - only latest price matters
    oLatestStream = CreateNetworkStream("latest-price")
    oLatestStream {
        SetOverflowStrategy(BUFFER_EVICT_OLDEST, 2)

        Transform(func price {
            return "AAPL: $" + price
        })

        OnPassed(func stockPrice {
            ? "💰 " + stockPrice
        })

        OnOverflow(func(current, max) {
            ? "📈 High trading volume - keeping latest prices only"
        })

        ? "Simulating rapid stock price updates..."
        
        # Rapid price updates
        prices = [150.25, 150.30, 150.15, 150.45, 150.60, 150.55]
        for i = 1 to len(prices)
            ? "Price update: $" + prices[i]
            Recieve(prices[i])
        next
        
        ProcessAnItemFromBuffer()

    }
 
    RunLoop()
    #--> (#NOTE I added some comments to clarify the output)
    # 
    # Simulating rapid stock price updates...
    # 
    # Phase 1: Buffer fills with initial price updates (capacity: 2)
    # --------------------------------------------------------------
    # Price update: $150.25
    # Price update: $150.30
    # 
    # Phase 2: Latest strategy - keeps newest prices, discards oldest
    # ---------------------------------------------------------------
    # Price update: $150.15
    # 📈 High trading volume - keeping latest prices only
    # ⚠️ Overflow: Keeping latest, dropped oldest
    # 
    # Price update: $150.45
    # 📈 High trading volume - keeping latest prices only
    # ⚠️ Overflow: Keeping latest, dropped oldest
    # 
    # Price update: $150.60
    # 📈 High trading volume - keeping latest prices only
    # ⚠️ Overflow: Keeping latest, dropped oldest
    # 
    # Price update: $150.55
    # 📈 High trading volume - keeping latest prices only
    # ⚠️ Overflow: Keeping latest, dropped oldest
    # 
    # Phase 3: Final buffer contains most recent prices
    # -------------------------------------------------
    # 💰 AAPL: $150.60
    # 💰 AAPL: $150.55
}

pf()
# Executed in 0.93 second(s) in Ring 1.23
