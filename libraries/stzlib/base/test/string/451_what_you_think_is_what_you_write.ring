# Narrative
# --------
# #narration "What You Think Is What You Write"
#
# Extracted from stzStringTest.ring, block #451.

load "../../stzBase.ring"


pr()

# In plain english, when you see "12309" you would say
# all "chars are numbers". In Softanza, it's the same:

? Q("12309").CharsQ().NumbrifiedQ().Are(:Numbers)
#--> TRUE

# For "248", yoou say "chars are even positive numbers"
# In Softanza, it's exactly the same:

? Q("248").CharsQ().NumberifiedQ().Are([ :Even, :Positive, :Numbers ])
#--> TRUE

# In this example, "chars are punctuations", right?

? Q([ ",", ":", ";" ]).Are([ :Punctuation, :Chars ])
#--> TRUE

# In Softanza, "What You Think Is What You Write".

pf()
# Executed in 0.19 second(s) in Ring 1.21
