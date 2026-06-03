# Narrative
# --------
# GIT WORKFLOW
#
# Extracted from stzsystemcalldatatest.ring, block #15.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

# Check status
Sy = new stzSystemCall(:GitStatus)
? Sy.Run()

# Commit changes
new stzSystemCall(:GitCommit) {
	SetParam(:message, "Added new feature")
	Run()
	? Output()
}

# Push to remote
new stzSystemCall(:GitPush) {
	SetParam(:branch, "main")
	Run()
}

pf()
