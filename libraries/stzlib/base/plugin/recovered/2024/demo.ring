# Runnable demo of the RECOVERED July-2024 plugin system, with the
# one seam fix applied (see ../README.md). Run from THIS directory:
#
#     ring demo.ring
#
# impl_fixed.ring = the implementation half of stzPluginSystem.ring
# (verbatim from dfd4b948c) + ONE added line in Xf() and Xff(): after
# injecting @plugin_value/@plugin_param, re-invoke pluginFunc so the
# result is computed from the HOST value, not the file's embedded
# sample. The stubs at the bottom stand in for the two Softanza
# functions the 2024 code used (@@ serializer, ring_find), so this
# demo runs on bare Ring + stdlib — no stzlib load required.

load "stdlib.ring"
load "impl_fixed.ring"

_aPlugins = LoadPlugins()
? "Discovered plugins:"
? _aPlugins

# Deliberately NOT "Hello Ring in Ring!" — the sample-collision rule:
# the 2024 demo used the same string the plugin files embed, which is
# exactly how the dead-injection seam stayed invisible for two years.
o1 = new XString("Softanza 2026")

? "Xf(:reverse):"
? o1.Xf("reverse")
#--> 6202 aznatfoS

? "Xf(:countVowels):"
? o1.Xf("countVowels")
#--> 3

? "XfU(:replace) then Content():"
? o1.XfU([ "replace", [ "Softanza", "Ring" ] ])
? o1.Content()
#--> Ring 2026

? "Ledger (XCalls):"
? o1.XCalls()

# --- minimal stand-ins for the Softanza functions the impl calls ---

func ring_find(aList, item)
	return find(aList, item)

func @@(p)
	if isString(p)
		return '"' + p + '"'
	but isNumber(p)
		return "" + p
	but isList(p)
		cRes = "[ "
		for i = 1 to len(p)
			cRes += @@(p[i])
			if i < len(p) cRes += ", " ok
		next
		return cRes + " ]"
	ok
	return '""'
