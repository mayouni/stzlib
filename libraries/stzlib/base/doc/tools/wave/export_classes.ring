# export_classes.ring <out.json> <Class> [Class...] -- export the record of some classes only
# (fast: 8-13 s for the four pilot classes). Run from libraries/stzlib/base/test/reflect:
#   ring ../../doc/tools/wave/export_classes.ring ref_pilot.json stzString stzList
load "../../../stzlib.ring"
aArgs = sysargv
if len(aArgs) < 4
	? "usage: ring export_classes.ring <out.json> <Class> [Class...]"
	bye
ok
aClasses = []
for i = 4 to len(aArgs)
	aClasses + aArgs[i]
next
r = StzReferenceExportOnly("../..", aArgs[3], "wave", "wave", aClasses)
? "ms " + r[:total_ms]
