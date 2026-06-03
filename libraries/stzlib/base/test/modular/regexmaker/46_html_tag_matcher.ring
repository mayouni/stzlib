# Narrative
# --------
# HTML Tag Matcher
#
# Extracted from stzregexmakertest.ring, block #46.

load "../../../stzBase.ring"


pr()

# Instead of cretaing a stzRegexMaker object, storing it in an o1
# variable, then use it, we can use the small function rxm()

#~> "rx" for Regex and "m" for Maker

rxm() {

	AddCapturingGroup("tag", "<([a-z]+)>")
	AddCapturingGroup("content", ".*?")
	AddBackReference(1)  # Match closing tag

	? Pattern()
	#--> (?P<tag><([a-z]+)>)(?P<content>.*?)\\1
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
