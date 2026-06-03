# Narrative
# --------
# pr()
#
# Extracted from stzextinpythonTest.ring, block #5.

load "../../stzBase.ring"

pr()

# In python, we get the integer part of the division using the // operator

'345 // 100'
#--> 3

# In Ring, we can simulate this Python syntax by saying:

? Q(345)['// 100']
#--> 3

pf()
# Executed in almost 0 second(s) in Ring 1.23
# Executed in 0.01 second(s) in Ring 1.21
