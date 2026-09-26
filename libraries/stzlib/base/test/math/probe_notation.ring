# PROBE, and the instrument of the notation reader: every label of
# StzMathNotationLabels() is turned into runs and measured; the output is
# the expectation base/test/math/expect/notation.txt, GENERATED FROM THESE
# BYTES and compared by the gate. Run from this directory:
#
#     ring probe_notation.ring > expect/notation.txt
load "../../stzBase.ring"
load "math_scenes.ring"
? StzMathNotationProbeText(StzMathFigureFont())
