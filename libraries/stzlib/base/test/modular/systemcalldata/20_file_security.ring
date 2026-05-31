# Narrative
# --------
# FILE SECURITY
#
# Extracted from stzsystemcalldatatest.ring, block #20.

load "../../../stzBase.ring"

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
