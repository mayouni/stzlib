# Narrative
# --------
# Round-trips a list back to its source-code literal via ToCode().
#
# ToCode() takes a live stzList and renders the Ring/Softanza
# expression that would recreate it: a bracketed, comma-separated
# list of string literals. Notice how it preserves each item's
# exact quoting -- a value that itself contains a double quote
# ("*") is emitted with single-quote delimiters ('"*"'), while the
# plain items keep their double quotes. The result is paste-ready
# source you can drop straight back into code, making ToCode() the
# inverse of constructing a stzList from a literal.
#
# Extracted from stzlisttest.ring, block #165.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"*", '"*"', "*4", "*4*", "*4*3", "*4*34",
	"4", "4*", "4*3", "4*34", "*", "*3",
	"*34", "3", "34", "4"
])

? o1.ToCode()
#--> [ "*", '"*"', "*4", "*4*", "*4*3", "*4*34", "4", "4*", "4*3", "4*34", "*", "*3", "*34", "3", "34", "4" ]

pf()
# Executed in 0.05 second(s)
