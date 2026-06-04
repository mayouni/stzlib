# Narrative
# --------
# GETTING RESULT WITHOUT DISPLAY
#
# Extracted from stznaturaltest.ring, block #7.

load "../../stzBase.ring"

pr()

Nt = Naturally("
    Create a stzString with 'test.data'
    Create a text with 'test.data'
    Replace '.' with '_'
    Uppercase it
")

? Nt.Result()
#--> TEST_DATA

? Nt.Code() + NL
#-->
# oStr = StzStringQ("test.data")
# oStr.Replace(".", "_")
# oStr.Uppercase()
# @result = oStr.Content()

pf()
# Executed in 0.01 second(s) in Ring 1.24
