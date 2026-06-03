# Narrative
# --------
# Example 12: Multiple Quantified Children
#
# Extracted from stzregexmakertest.ring, block #27.

load "../../../stzBase.ring"


pr()

o8 = new stzRecursiveRegexMaker()
o8 {

	EnableNamedRecursion()

	AddLevel("object", "\{")
	AddChildLevel("object", "key", '"[^"]+"\s*:\s*')
	AddChildLevel("key", "value", '[^,}]+')
    	AddChildLevel("object", "comma", ",\s*")
	AddLevel("close", "\}")

	AddQuantifier("key", "+")
	AddQuantifier("comma", "*")

	? Pattern()
	#--> (?P<object>\{(?P<key>"[^"]+"\s*:\s*(?P<value>[^,}]+))+(?P<comma>,\s*)*)\}
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
