# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #432.
#
# NOTE (audit, 2026-07-02): DEFERRED. SoftanzaLogo() renders Unicode
# box-drawing art; the current impl returns a plain "Softanza" placeholder
# and the glyph strings need the char()-raw-bytes rebuild (the source
# mojibake issue -- same family as the Box/BoxRound cluster, blocks
# #99-#101). Visual rendering, not assertable on the Windows console.

load "../../stzBase.ring"

pr()

? SoftanzaLogo()

pf()
# Executed in almost 0 second(s) in Ring 1.21
