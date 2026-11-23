# Narrative
# --------
# Copying a JSON Object
#
# Extracted from stzjsontest.ring, block #30.

load "../../stzBase.ring"


pr()

oJson = new stzJson('{"name": "John", "age": 30 }')
oCopy = oJson.Copy()

# CAPTURED FROM A RUN, NOT AUTHORED. The promise below is a REGRESSION
# BASELINE taken on haro 21317660327e7241, engine stzlib c2b930b71,
# 2026-11-23. The arrow was left empty by whoever wrote this file, so nobody
# has ever judged the value: it records what the code DOES, not what it
# SHOULD do. If it and the code disagree later, read BOTH -- the promise may
# be the defect. (That is how 192 came to be promised for a draw from a list
# not containing it; see listofnumbers/36_anynumberbefore.ring.)
? oCopy.ToString()
#--> {"name":"John","age":30}

pf()
