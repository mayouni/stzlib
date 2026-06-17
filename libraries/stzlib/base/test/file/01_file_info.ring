# Narrative
# --------
# GETTING INFORMATION ABOUT FILES
#
# Intent: "I want to get information about this file."
# Extracted from stzfiletest.ring, block #1. Made portable: a local sandbox
# file replaces the machine-specific "stzFileTest.ring" reference.
#
# stzFileInfo retrieves metadata WITHOUT opening the file. (Use the FileInfoQ
# fluent form to get the queryable object; FileInfo() returns the info as a
# hashlist.)

load "../../stzBase.ring"

pr()

cSbx = CurrentDir() + "/_t01"
if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok
StzMakeDir(cSbx)
write(cSbx + "/notes.txt", "hello softanza")   # 14 bytes

oInfo = FileInfoQ(cSbx + "/notes.txt")

? oInfo.Exists()			#--> 1
? oInfo.IsWritable()		#--> 1
? oInfo.SizeInBytes()		#--> 14
? oInfo.IsExecutable()		#--> 0
? oInfo.LastModified()		#--> a date-time string, e.g. 2026-06-17 21:15:50
							#    (exact value is machine-dependent)

if dirExists(cSbx) RemoveFolderRecursive(cSbx) ok

pf()
# Executed in 0.02 second(s) in Ring 1.23
