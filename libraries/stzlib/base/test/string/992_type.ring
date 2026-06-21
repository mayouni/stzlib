# Narrative
# --------
# StzType(): a Softanza object names its own domain type.
#
# QQ("normal text") wraps a plain string into a stzString object, and StzType()
# reports the lowercase class identity of that object -- here "stzstring".
# StzType() is the runtime reflection hook every Stz* class exposes so a value
# can be routed by the domain it belongs to. (Recorded "stztext" was stale.)
#
# Repositioned from test/list (stzlisttest.ring, block #346): this is a
# stzString test, so it belongs under test/string.

load "../../stzBase.ring"

pr()

? QQ("normal text").StzType()
#--> stzstring

pf()
# Executed in 0.03 second(s)
