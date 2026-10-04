load "../stzBase.ring"

# Export the library's reference record (DOCREFORM, base/meta/stzDocExport.ring).
#
#   cd libraries/stzlib/base/doc
#   ring export_reference.ring <commit> <date> [out.json]
#
# <commit> and <date> are written into the header (read them from git:
# `git rev-parse --short HEAD`, `git show -s --format=%cI HEAD`), so the file
# is a pure function of the sources and those two words -- no clock, no model.
# One heavy job: a single process, about a minute. Run it alone.

aArgs = sysargv
cCommit = "unknown"
cDate = "unknown"
cOut = "reference.json"
if len(aArgs) >= 3 cCommit = aArgs[3] ok
if len(aArgs) >= 4 cDate = aArgs[4] ok
if len(aArgs) >= 5 cOut = aArgs[5] ok

r = StzReferenceExport(_StzBaseDir(), cOut, cCommit, cDate)
? "classes " + r[:classes] + ", roots " + r[:roots] + ", names " + r[:names]
? "aliases " + r[:aliases] + ", extension forms " + r[:extension_forms]
? "brief: written " + r[:brief_written] + ", derived " + r[:brief_derived]
? "pass (checks 1-4): " + r[:pass] + ", of them written " + r[:pass_written]
? "with an example: " + r[:with_example]
? "scan " + r[:scan_ms] + " ms, total " + r[:total_ms] + " ms"
