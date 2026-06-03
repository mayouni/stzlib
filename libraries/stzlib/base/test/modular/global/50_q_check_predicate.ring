# Narrative
# --------
# Q(...).Check(:That = '<predicate code>') passes every char (or
# item, for a list) through the predicate and answers TRUE only
# when every one matches. Here every char in "(,,)" is a
# punctuation char, so the answer is TRUE.
#
# Extracted from stzGlobalTest.ring, the late "Q().Check"
# section. Was missed by the initial extraction sweep because the
# original used a "/*=============" delimiter the splitter didn't
# recognise.

load "../../../stzBase.ring"


? Q("(,,)").Check(:That = 'StzCharQ(@Char).IsPunctuation()')
#--> TRUE
