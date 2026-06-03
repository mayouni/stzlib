# Narrative
# --------
# #narration MEASURING SPEEDUP AND PERFPRMANCE GAIN
#
# Extracted from stzlistofliststest.ring, block #12.

load "../../stzBase.ring"

# Inspired by a discussion with Mahmoud on the Ring group

pr()

# Suppose you profiled a function you wrote and got 12.08 seconds.
# After refactoring and optimizing the code, you get 3.2 seconds.
# What's the performance gain in percentage?
# And how can you express this in terms of speedup factor?

# Softanza saves your time since it has the exact functions
# to do the required job:

? PerfGain(12.08, 3.20)   # Or PerfGain100 ~> Output in %
#--> 73.51

# Read it: There is a 73.51% performance gain with the second solution.

? SpeedUp(12.08, 3.20) + NL   # Or SpeedUpX() or PerfGainX() ~> Output in factor
#--> 3.78

# Read it: The second solution is 3.78 times more performant.

# These functions can be generally applied to any list of numbers.
# This allows you to calculate multiple speedups and performance
# gains in one shot:

oTimes = new stzListOfNumbers([ 12.08, 3.20, 1.18, 0.08 ])

? oTimes.PerfGains() # Or PerfGains100()
#--> [73.51, 63.13, 93.22]

? oTimes.SpeedUps() # Or PerfGainsX()
#--> [3.77, 2.71, 14.75]

# NOTE: With the more general-purpose names we have for these
# functions, Gain100() and GainX(), we can use them in contexts
# beyond time performance:

oSales = new stzListOfNumbers([ 34500.89, 42180.98, 56100.65 ])

? oSales.Gain100()  # Or simply Gain() instead of PerfGain()
#--> [ 18.21, 24.81 ]

? oSales.GainX()    # Or GainFactor() instead of SpeedUp()
#--> [ 1.22, 1.33 ]

pf()
# Executed in 0.04 second(s).
