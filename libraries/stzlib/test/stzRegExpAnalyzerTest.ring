load "../max/stzmax.ring"

o1 = new stzRegExpAnalyzer()
o1.init("(a+)*b{1,1000}[a-zA-Z]*")
aResult = o1getAnalysis()

? "Analysis Results:"
? "=============="
? "Complexity Score: " + aResult[:metrics][:complexityScore]

? nl + "Warnings:"
for cWarning in aResult[:warnings]
    ? "- " + cWarning
next

? nl + "Suggestions:"
for cSuggestion in aResult[:suggestions]
    ? "- " + cSuggestion
next
