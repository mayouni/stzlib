# Narrative
# --------
# HANDLING CSS (style manipulation)
#
# Extracted from stzHtmlTest.ring, block #6.

load "../../../stzBase.ring"


pr()

cSampleCss = `
body { background: white; }
h1 { color: blue; font-size: 24px; }
`

oCss = new stzCSS(cSampleCss)

? oCss.Selectors()           #--> [ "body", "h1" ]
? oCss.PropertyOf("h1", "color")  #--> "blue"

aRules = oCss.Rules()
? len(aRules)                #--> 2
? aRules[1][1]               #--> "body"
? aRules[1][2][1]            #--> [ "background", "white" ]

# TODO: Implement and test ApplyToHtml if possible

pf()
# Executed in almost 0 second(s) in Ring 1.22
