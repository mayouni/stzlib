# Narrative
# --------
# FROM FILE
#
# Extracted from stznaturaltest.ring, block #34.

load "../../../stzBase.ring"


pr()

# Save natural code to file
cCode = "
    Create string with 'from file'
    Uppercase it
    Show it
"
write("test.natural", cCode)
write("test.stzn", cCode)

# Execute from file
Naturally(read("test.natural"))
Naturally(read("test.stzn"))
#--> FROM FILE

pf()
# Executed in 0.01 second(s) in Ring 1.24
