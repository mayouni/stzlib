# Narrative
# --------
# #  Unicode Text Support  #
#
# Extracted from stzRegexTest.ring, block #51.

load "../../../stzBase.ring"

#------------------------#

pr()

txt = "مرحبا بكم في عالم البرمجة"

o1 = new stzRegex("مرحبا")

? o1.Match(txt)
#--> TRUE

# Test with word boundary

o2 = new stzRegex("عالم")
? o2.Match(txt)
#--> TRUE

# Test capturing

o3 = new stzRegex("(عالم) (البرمجة)")
if o3.Match(txt) and o3.HasGroups()
    ? @@( o3.Capture() )
ok
#-o-> [ "عالم", "البرمجة" ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

#--------------------------------------#
#  ADVANCED EXAMPLE IN DATA ANALYTICS  #
#--------------------------------------#
