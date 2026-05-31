# Narrative
# --------
# #  Code Analysis  #
#
# Extracted from stzRegexTest.ring, block #44.

load "../../../stzBase.ring"

#-----------------#

pr()

codeText = "
function CalculateTotal(price, quantity) {
    // Calculate total with tax
    const tax = 0.2;  // 20% tax rate
    return price * quantity * (1 + tax);
}
"

o1 = new stzRegex("")

# Find function declarations

o1.SetPattern("function\s+(?<name>\w+)\s*\((?<params>[^)]*)\)")

if o1.Match(codeText) and o1.HasNames()
    ? @@NL(o1.CaptureXT()) + NL
ok
#--> [
#	[ "name", "CalculateTotal" ],
#	[ "params", "price, quantity" ]
# ]

# Find comments

o1.SetPattern("//[^\n]*")
? o1.MatchLinesIn(codeText)
#--> TRUE

# Find variable declarations

o1.SetPattern("(?:const|let|var)\s+(?<name>\w+)\s*=\s*(?<value>[^;]+);")

if o1.Match(codeText) and o1.HasNames()
    ? @@NL(o1.CaptureXT())
ok
#--> [
#	[ "name", "tax" ],
#	[ "value", "0.2" ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
