# Narrative
# --------
# pr()
#
# Extracted from stzmisctest.ring, block #3.

load "../../stzBase.ring"

pr()

# Ring's default substr(): returns new string, str unchanged

str = "I love pizza"
? substr(str, "pizza", "couscous")
#--> I love pizza

? str
#--> I love pizza

# Softanza: updates and returns in one step

str = "I love pizza"
str = StzReplace(str, "pizza", "couscous")
? str
#--> I love couscous

pf()
# Executed in almost 0 second(s) in Ring 1.22
