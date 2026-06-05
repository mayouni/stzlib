# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #57.

load "../../stzBase.ring"

pr()

# ? StzCharQ("🌹").Name() #--> ERROR: Can not create char object!
? Unicode("🌹") #--> [ 63, 63 ]
? Q("🌹").CharName() # ?--> QUESTION MARK

pf()
# Executed in 0.06 second(s) in Ring 1.23
