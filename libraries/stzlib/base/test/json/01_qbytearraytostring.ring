# Narrative
# --------
# (retired) Original test depended on Ring's QByteArray Qt binding.
# Softanza is now engine-only and does NOT ship that binding. The
# byte-buffer surface is now spelled via stzBytes (engine-backed):
#
#   o = new stzBytes("XYZ")
#   ? o.ToString()
#
#SKIP retired -- Qt QByteArray binding replaced by stzBytes

load "../../stzBase.ring"

? "(retired Qt QByteArray test; see header for stzBytes equivalent)"
