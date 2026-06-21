# Narrative
# --------
# Stringify every nested item of a stzList, then replace across all of them.
#
# StringifyAndReplaceXT first walks the list recursively and turns every
# item -- including the nested sub-list [ 12, "--_--", 10 ] and the bare
# number 9 -- into its string form, then applies a codepoint-safe replace
# of "_" with the multibyte "♥" over each stringified item. The result is
# a flat list of strings where the former sub-list survives as a single
# quoted token '[ 12, "--♥--", 10 ]'. Content() returns that transformed
# list; @@() shows it with the inner double-quoted string auto-promoted to
# single quotes. This is an internal-staff helper used inside Softanza.
#
# Extracted from stzlisttest.ring, block #91.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "--_--", [ 12, "--_--", 10], "--_--", 9 ])
o1.StringifyAndReplaceXT("_", "♥") # Used by internal staff in Softanza
? @@( o1.Content() )
#--> [ "--♥--", '[ 12, "--♥--", 10 ]', "--♥--", "9" ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.05 second(s) in Ring 1.19
# Executed in 0.04 second(s) in Ring 1.19 (32 bits)
# Executed in 0.04 second(s) in Ring 1.18
# Executed in 0.03 second(s) in Ring 1.17
