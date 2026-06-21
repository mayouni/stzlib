# Narrative
# --------
# IsByNamedParam: recognise the [ :by, <value> ] named-parameter shape.
#
# Many Softanza methods accept an English-reading named arg such as :By = x,
# which Ring delivers as the pair [ "by", x ]. IsByNamedParam() is the
# predicate those methods use internally to detect that form -- here
# [ "by", [ "2","5","6" ] ] is recognised, so it returns TRUE.
#
# Extracted from stzlisttest.ring, block #63.

load "../../stzBase.ring"

pr()

? Q([ "by", [ "2", "5", "6" ] ]).IsByNamedParam()
#--> TRUE

pf()
#--> Executed in 0.03 second(s)
