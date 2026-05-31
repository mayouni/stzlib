# Narrative
# --------
# #  MATCHING HTML CONTENT  #
#
# Extracted from stzRegexTest.ring, block #50.

load "../../../stzBase.ring"

#-------------------------#

pr()

# Simple HTML content with multiple lines

htmlText = '
<html>
    <head>
        <title>Hello World</title>
    </head>
    <body>
        <h1>Welcome</h1>
        <p>First paragraph</p>
        <p>Second paragraph</p>
    </body>
</html>
'

# Match all paragraph lines

o1 = new stzRegex("<p>.*</p>")

# Testing MatchLinesIn() to find all paragraph lines

? o1.MatchLinesIn(htmlText)
#--> TRUE


//? o1.Capture()
#--> ERROR: No capture groups found in pattern. Use groups like (xyz) to capture values.
#NOTE: To protect your code use if HasGroups()

# Match just the first h1 line

o2 = new stzRegex("<h1>.*</h1>")
? o2.MatchLine(htmlText)
#--> TRUE

# Match title line with content capture

o3 = new stzRegex("<title>(.*)</title>")
? o3.MatchLine(htmlText)
#--> TRUE

# Captured title content

if o3.HasGroups()
    ? @@( o3.Capture() )
ok
#--> [ "Hello World" ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
