# Narrative
# --------
# Round-trips a stzList back into the Ring source literal that would recreate it.
#
# ToCode() walks the items and emits a bracketed list expression as a string,
# the inverse of evaluating a list literal. Each element is re-quoted with the
# correct delimiter: ordinary strings get double quotes, while a value that
# itself contains a double quote (here '"B",') is wrapped in single quotes so
# the generated code stays valid. The result is text that, pasted back into a
# program, reconstructs the same list -- handy for codegen, fixtures, and
# debugging dumps.
#
# Extracted from stzlisttest.ring, block #235.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "b", "C", "B", '"B",', "D", "E" ])
? o1.ToCode()
#-->  [ "A", "b", "C", "B", '"B",', "D", "E" ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in ring 1.17
