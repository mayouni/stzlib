load "../stzlib.ring"

/*---
*/
pron()

# Example 1: Code formatting - Finding proper indentation position

cCode = '
if n = 5 {
	while x < 10 {
		DoSomething()
	DoSomethingElse() # Bad indentation here
}'

oCode = new stzString(cCode)
oCode.Trim()

nOpenBrace = oCode.FindNth(2, "{")
#--> 38

//? oCode[nOpenBrace]
#--> "{"

nCloseBrace = oCode.FindNext("}", :StartingAt = nOpenBrace)
#--> 110

//? oCode[nCloseBrace]
#--> "}"

oSection = oCode.SectionQ(nOpenBrace+1, nCloseBrace-1)
//? oSection.NumberOf(NL) - 1
#--> 2

# We should then have 4 TABs but we have only 3

//? oSection.NumberOf(TAB)
#--> 3

oLines = oSection.SplitQ(NL)
? oLines.FindWXT(' Q(@item).IsAString() ')

//? oSection.SplitQ(NL).FindWXT(' Q(@item).StartsWith(TAB) and Q(@NextItem) != TAB ')

proff()
# Executed in 0.01 second(s).

/*---

# Example 2: XML/HTML tag analysis
xml = "<product><name>Phone</name><price>599</price></product>"
o2 = new stzString(xml)
# Find distance to closing tag for proper tag matching
? o2.DistanceTo("</name>", :StartingAt = 1)  # Distance to first closing tag

/*---

# Example 3: Source code analysis - Finding function boundaries
code = "func1() {
    doSomething()
    if (x) {
        return y
    }
}

func2() {"
o3 = new stzString(code)
# Find where current function block ends
? o3.DistanceTo("}", :StartingAt = 1)  # Distance to function end

/*---

# Example 4: Template processing - Finding placeholder positions
template = "Dear {{name}}, your order #{{orderID}} will arrive on {{date}}."
o4 = new stzString(template)
# Find distances between placeholders for template processing
? o4.DistanceTo("{{", :StartingAt = 1)       # Distance to first placeholder
? o4.DistanceToXT("{{", :StartingAt = 1)     # Include placeholder in measurement

/*---

# Example 5: Query parsing - Finding clause boundaries
query = "SELECT * FROM users WHERE age > 18 AND city = 'NY'"
o5 = new stzString(query)
# Find distance to WHERE clause for query analysis
? o5.DistanceTo("WHERE", :StartingAt = 1)    # Distance to WHERE clause
? o5.DistanceToXT("AND", :StartingAt = 1)    # Include AND in measurement

/*---

# Example 6: Markdown processing - Finding section markers
markdown = "# Header\nSome text\n## Subheader\nMore text"
o6 = new stzString(markdown)
# Find distances between headers for section analysis
? o6.DistanceTo("##", :StartingAt = 1)       # Distance to subheader
? o6.DistanceToXT("##", :StartingAt = 1)     # Include header marker in calculation

/*---

# Example 7: String interpolation detection
code = 'print("Value is ${var1} and ${var2}")'
o7 = new stzString(code)
# Find interpolation points
? o7.DistanceTo("${", :StartingAt = 1)       # Distance to first variable
? o7.DistanceToXT("${", :StartingAt = 1)     # Include interpolation marker

/*---
*/
pron()

# Example 8: Comment block analysis

code = "/* Multi-line
   comment */
   code here
   /* Another
   comment */"

o8 = new stzString(code)
# Find distances between comment blocks
? o8.DistanceTo("/*", :StartingAt = 1)       # Distance to next comment block
? o8.DistanceToXT("*/", :StartingAt = 1)     # Include comment marker end

proff()
