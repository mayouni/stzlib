# Narrative
# --------
# Advanced: Combining Multiple ListEx Features
#
# Extracted from stzlistexutertest.ring, block #5.

load "../../stzBase.ring"


pr()

lxu() {
    # Combining multiple ListEx features
    AddTrigger(:ComplexData = "[@S, [@N{1-100}+], @!N?]")  # String, list of nums 1-100, optional non-number
    
    AddCode(:ComplexData, '{
        # Process the name
        cName = @list[1]
        
        # Calculate statistics on the numbers
        aNumbers = @list[2]
        nSum = 0
        nMin = 999
        nMax = 0
        
        _nNumbers1Len_ = ring_len(aNumbers)
        for _iLoopNumbers1_ = 1 to _nNumbers1Len_
        	num = aNumbers[_iLoopNumbers1_]
            nSum += num
            if num < nMin nMin = num ok
            if num > nMax nMax = num ok
        next
        
        nAvg = nSum / len(aNumbers)
        
        # Check if we have the optional tag
        cTag = ""
        if len(@list) > 2
            cTag = @list[3]
        ok
        
        # Build result
        @list = [
            "ID: " + cName,
            "Stats: [min:" + nMin + ", max:" + nMax + ", avg:" + nAvg + "]"
        ]
        
        if cTag != ""
            @list + ["Tag: " + cTag]
        ok
    }')
    
    Process([
        ["temp_readings", [22, 24, 21, 25], "celsius"],
        ["stock_prices", [55, 62, 58, 63, 67]],
        ["test_scores", [85, 92, 78, 95, 88], "midterm"]
    ])
    
    ? @@NL( MatchesXT() )
    #--> [
    #   [ 
    #       ["temp_readings", [22, 24, 21, 25], "celsius"],
    #       ["ID: temp_readings", "Stats: [min:21, max:25, avg:23]", "Tag: celsius"]
    #   ],
    #   [ 
    #       ["stock_prices", [55, 62, 58, 63, 67]],
    #       ["ID: stock_prices", "Stats: [min:55, max:67, avg:61]"]
    #   ],
    #   [ 
    #       ["test_scores", [85, 92, 78, 95, 88], "midterm"],
    #       ["ID: test_scores", "Stats: [min:78, max:95, avg:87.6]", "Tag: midterm"]
    #   ]
    # ]
}

proff()

pf()
# Executed in 0.05 second(s) in Ring 1.22
