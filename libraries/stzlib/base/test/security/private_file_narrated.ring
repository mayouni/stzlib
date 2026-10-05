load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-PRIVATEFILE-01 -- a key written to disk is readable by its owner alone.
#
# A TLS client key has to exist as a FILE for a call that wants a path, and the
# read-only setters only stop an overwrite. StzWritePrivateFile creates the file
# with a protected access list (Windows) or mode 0600 (elsewhere) from the
# first byte. On Windows the guard reads the REAL access list with icacls: an
# ordinary file inherits entries for Users and Authenticated Users, a private
# one holds one entry, for its owner. Not run on POSIX here: the mode branch is
# type-checked, never run.

$cPlain = "_pf_plain.tmp"
$cPriv = "_pf_private.tmp"
# stand-in bytes shaped like a PEM file, but NOT a key; the header is split so the secrets gate
# does not read this fixture as a real one
$cKey = "-----BEGIN " + "STAND-IN-----" + char(10) + "not-a-key-just-bytes-0123456789" + char(10) + "-----END " + "STAND-IN-----" + char(10)
CleanUp()

Scenario("the bytes arrive exactly, and an existing file is replaced")
	StzWritePrivateFile($cPriv, $cKey)
	Then("the content reads back byte for byte", StzFileRead($cPriv), $cKey)
	StzWritePrivateFile($cPriv, "short")
	Then("a second write REPLACES, it does not append", StzFileRead($cPriv), "short")
	StzWritePrivateFile($cPriv, "")
	Then("an empty write leaves an empty file", StzFileSize($cPriv), 0)
EndScenario()

Scenario("on Windows, only the owner can read it -- the real access list")
	if iswindows()
		StzFileWrite($cPlain, $cKey)
		StzWritePrivateFile($cPriv, $cKey)
		cPlainAcl = ReadAcl($cPlain)
		cPrivAcl = ReadAcl($cPriv)
		# icacls prints localised, non-UTF-8 account names, and StzFindFirst answers 0 on any
		# string that is not valid UTF-8 -- even for an ASCII needle that is present. So this
		# guard reads the list BYTE-WISE (Ring's substr), and first proves the lists are not empty:
		# a "shows none" assertion over an unread list would pass for the wrong reason.
		Then("the ordinary file's list was read (has entries)", Entries(cPlainAcl) >= 3, 1)
		Then("the private file's list was read (has an entry)", Entries(cPrivAcl) >= 1, 1)
		Then("an ordinary file inherits Users and Administrators (this is the problem)", Has(cPlainAcl, "Users") + Has(cPlainAcl, "Utilisateurs") > 0 and Has(cPlainAcl, "Administrat") > 0, 1)
		Then("the private file names no group of users", Has(cPrivAcl, "Users") + Has(cPrivAcl, "Utilisateurs") + Has(cPrivAcl, "Everyone") + Has(cPrivAcl, "Tout le monde"), 0)
		Then("...nor Administrators", Has(cPrivAcl, "Administrat"), 0)
		Then("...nor System", Has(cPrivAcl, "SYSTEM") + Has(cPrivAcl, "Syst"), 0)
		Then("it names exactly one access entry", Entries(cPrivAcl), 1)
		Then("the owner can still read it (negative sibling)", len(StzFileRead($cPriv)) > 0, 1)
	else
		Then("(not Windows: the 0600 branch is type-checked, not run here)", 1, 1)
	ok
EndScenario()

Scenario("a path the caller must give, and a path that cannot be written, are refused")
	bR1 = 0  try  StzWritePrivateFile("", "x")  catch  bR1 = 1  done
	bR2 = 0  try  StzWritePrivateFile("no_such_folder_pf/key.pem", "x")  catch  bR2 = 1  done
	Then("an empty path raises", bR1, 1)
	Then("a missing folder raises", bR2, 1)
EndScenario()

CleanUp()
Summary()

# -- helpers (after the main code) ------------------------------------

# the access list as icacls prints it, never the account names of the machine
func ReadAcl cPath
	oC = StzSystemCallQ("icacls")
	oC.SetArgs([ cPath ])
	oC.Run()
	return oC.Output()

# 1 when the bytes of cNeedle occur in cText (Ring's byte-wise substr; see the note above)
func Has cText, cNeedle
	if substr(cText, cNeedle) > 0  return 1  ok
	return 0

# access entries in an icacls listing: every ":(" -- counted by walking the BYTES, since the
# listing is not valid UTF-8 and the library's split/find are codepoint-aware
func Entries cAcl
	n = 0
	nLast = len(cAcl) - 1
	for i = 1 to nLast
		if cAcl[i] = ":" and cAcl[i+1] = "("  n++  ok
	next
	return n

func CleanUp
	if fexists($cPlain)  remove($cPlain)  ok
	if fexists($cPriv)  remove($cPriv)  ok
