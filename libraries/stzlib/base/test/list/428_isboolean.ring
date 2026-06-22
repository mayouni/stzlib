# Narrative
# --------
# Asking whether a value is a boolean, two equivalent ways.
#
# Softanza recognizes TRUE/FALSE (Ring's 1/0) as a distinct boolean
# kind. The free function IsBoolean(value) answers the question
# directly, while Q(value).IsBoolean() wraps the value in an object
# and asks the same thing through the fluent method form. Both report
# TRUE here -- FALSE is still a boolean, and so is TRUE -- showing the
# global helper and the object method are interchangeable.
#
# Extracted from stzlisttest.ring, block #428.

load "../../stzBase.ring"

pr()

? IsBoolean(FALSE)
#--> TRUE

? Q(TRUE).IsBoolean()
#--> TRUE

pf()
# Executed in almost 0 second(s).
