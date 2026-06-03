# Narrative
# --------
# FILE SECURITY
#
# Extracted from stzsystemcalldatatest.ring, block #20.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

==========================================

pr()

# Calculate checksum
Sy = new stzSystemCall(:Sha256sum)
Sy {
	SetParam(:file, "important.zip")
	Run()
	? "Checksum: " + Output()
}

# Encrypt file
new stzSystemCall(:EncryptFile) {
	SetParams([
		[:file, "secret.txt"],
		[:email, "recipient@example.com"]
	])
	Run()
}

pf()
