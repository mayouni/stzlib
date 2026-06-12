# Narrative
# --------
# Example 3: Code Analysis Pipeline
#
# Extracted from stzregexutertest.ring, block #9.

load "../../stzBase.ring"

# Shows how state helps track code transformations

pr()

rxu = new stzRegexuter()

# Add code analysis triggers
rxu.AddTrigger(["function", "func\s+\w+\s*\([^\)]*\)"])
rxu.AddTrigger(["variable", "var\s+\w+\s*="])
rxu.AddTrigger(["comment", "#.*$"])

# Add analysis computations
rxu.AddCode("function", '{
    @value = "FUNCTION {" + trim(@value) + "}"
}')

rxu.AddCode("variable", '{
    @value = "VAR {" + trim(@value) + "}"
}')

rxu.AddCode("comment", '{
    @value = "COMMENT {" + trim(@value) + "}"
}')

# Process code

codeText = "
func calculate(x, y)
    # Add two numbers
    var result = x + y
    return result
"

rxu.Process(codeText)

# Use state to analyze code structure

See "Code Analysis:" + NL + NL

_aRxuState1_ = rxu.State()
_nRxuState1Len_ = len(_aRxuState1_)
for _iLoopRxuState1_ = 1 to _nRxuState1Len_
	entry = _aRxuState1_[_iLoopRxuState1_]
    ? "Found " + entry[:triggerName] + " at position " + entry[:position] + ":"
    ? "  Original: " + entry[:matchedValue]
    ? "  Processed: " + entry[:computedValue]

    if len(entry[:affects]) > 0
        ? "  Affects: " + @@(entry[:affects])
    ok

next
#-->
# Found function at line 2:
#    Original: func calculate(x, y)
#    Processed: FUNCTION:func calculate(x, y)
# Found variable at line 49:
#    Original: var result =
#    Processed: VAR:var result =

pf()
# Executed in 0.03 second(s) in Ring 1.22
