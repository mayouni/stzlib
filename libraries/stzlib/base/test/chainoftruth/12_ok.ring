# Narrative
# --------
# ok
#
# Extracted from stzchainoftruthtest.ring, block #12.

load "../../stzBase.ring"

pr()

# All these return 1

? _(8).Is('DoubleOf(4)')._
? _("ring").Is('Lowercase()')._
? _("ring").Is(:Lowercase)._

pf()
