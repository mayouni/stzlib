# Narrative
# --------
# Example 16: Pattern Information
#
# Extracted from stzregexmakertest.ring, block #31.

load "../../../stzBase.ring"


pr()

# We use rrxm() instead of new stzRecursiveRegexMaker()

#--> "r": recursive, "rxm": regex maker

rrxm() {
    	EnableNamedRecursion()

	AddLevel("object", "\{")
	AddChildLevel("object", "key", '"[^"]+"\s*:\s*')
	AddChildLevel("key", "value", '[^,}]+')
	AddChildLevel("object", "comma", ",\s*")

	AddLevel("close", "\}")
	AddQuantifier("key", "+")
	AddQuantifier("comma", "*")

	? Pattern() + NL
	#--> (?P<object>\{(?P<key>"[^"]+"\s*:\s*(?P<value>[^,}]+))+(?P<comma>,\s*)*)\}

	? @@(LevelNames())
	#--> ["object", "key", "value", "comma", "close"]
	
	? NumberOfLevels()
	#--> 5
	
	? @@(LevelChildren("object"))
	#--> ["key", "comma"]
	
	? HasLevel("key")
	#--> TRUE

}

pf()
# Executed in almost 0 second(s) in Ring 1.22
