# Narrative
# --------
# Example 2: Nested JSON-like structure
#
# Extracted from stzregexmakertest.ring, block #18.

load "../../../stzBase.ring"


# In this example, we show how Softanza declarative style can help
# you design an interesting recursive regex pattern as complex as:
#
# (?P<object>\{)(?P<pair>"[^"]+"\s*:\s*)+(?P<value>[^{}]+)\}
#
# It matches an object-like structure (similar to a JSON object) with:
#
# - A starting {
# - One or more key-value pairs ("key": value)
# - A value that is not enclosed by {}

pr()

o2 = new stzRecursiveRegexMaker()
o2 {
	EnableNamedRecursion()
	
	AddLevel("object", "\{")
	AddChildLevel("object", "pair", '"[^"]+"\s*:\s*')
	AddChildLevel("pair", "value", '[^{}]+')
	AddLevel("close", "\}")
	
	AddQuantifier("pair", "+")
	
	? Pattern()
	#--> (?P<object>\{)(?P<pair>"[^"]+"\s*:\s*)+(?P<value>[^{}]+)\}
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
