# Narrative
# --------
# RAISING ERROR WHEN OBJECT TYPE IS NOT SUPPORTED
#
# Extracted from stznaturaltest.ring, block #6.

load "../../stzBase.ring"

pr()

Nt = Naturally("
    Create a stxString with 'test.data'
    Replace '.' with '_'
    Uppercase it
")
#--> ERROR: Unsupported object type while processing "CREATE_OBJECT"!

pf()
