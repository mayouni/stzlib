# Narrative
# --------
# Analytics Dashboard with Multiple Metrics
#
# Extracted from stzreactivestreamtest.ring, block #5.

load "../../stzBase.ring"


# Complex accumulate example calculating multiple statistics
# Shows real-world analytics use case

pr()

Rs = new stzReactiveSystem()
Rs {
    # Website analytics stream

    oAnalyticsStream = CreateStream("web-analytics")
    oAnalyticsStream {

        # Aggregate user session data

        Accumulate(func(stats, session) {
            stats[:totalUsers] += 1
            stats[:totalPageViews] += session[:pageViews]
            stats[:totalSessionTime] += session[:duration]
            
            if session[:converted]
                stats[:conversions] += 1
            ok
            
            return stats

            },
	    [
		:totalUsers = 0,
		:totalPageViews = 0,
		:totalSessionTime = 0,
		:conversions = 0
	    ])

        OnRecieved(func analytics {
            avgPageViews = analytics[:totalPageViews] / analytics[:totalUsers]
            avgSessionTime = analytics[:totalSessionTime] / analytics[:totalUsers]
            conversionRate = (analytics[:conversions] * 100.0) / analytics[:totalUsers]
            
            ? "📊 Website Analytics Summary:"
            ? "   Total Users: " + analytics[:totalUsers]
            ? "   Avg Page Views: " + avgPageViews + " pages/user"
            ? "   Avg Session Time: " + avgSessionTime + " minutes"
            ? "   Conversion Rate: " + conversionRate + "%"
        })

        # User session data
        sessions = [
            [:pageViews = 5, :duration = 12.5, :converted = true],
            [:pageViews = 3, :duration = 8.2, :converted = false],
            [:pageViews = 7, :duration = 18.7, :converted = true], 
            [:pageViews = 2, :duration = 4.1, :converted = false],
            [:pageViews = 9, :duration = 25.3, :converted = true]
        ]

        RecieveMany(sessions)

    }
    
    RunReactiveLoop()
    #-->
    # 📊 Website Analytics Summary:
    #    Total Users: 5
    #    Avg Page Views: 5.2 pages/user
    #    Avg Session Time: 13.76 minutes
    #    Conversion Rate: 60%
}

pf()
