# Narrative
# --------
# DATABASE BACKUP
#
# Extracted from stzsystemcalldatatest.ring, block #21.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

cTimestamp = "" + clock()
cBackup = "backup_" + cTimestamp + ".db"

Sy = new stzSystemCall(:SqliteBackup)
Sy {
	SetParam(:db, "myapp.db")
	SetParam(:output, cBackup)
	Run()
	
	if Succeeded()
		? "Backup created: " + cBackup
	ok
}

pf()
