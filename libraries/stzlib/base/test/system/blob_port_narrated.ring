load "../../stzBase.ring"
load "../_narrated.ring"

# stzBlobPort -- phase 6 of the service-virtualization plane, and the purest
# LOCAL-REAL category in it.
#
# A blob port is "any object with Save(key, bytes) / Fetch(key) / Exists(key) /
# Remove(key)". S3, GCS, Azure Blob, Backblaze -- the same four verbs over a flat
# key namespace, which is why one port covers the whole category.
#
# (S3 spells the first two PutObject/GetObject, and Put/Get would have been the
# obvious names -- but both are Ring STATEMENTS: `put x` prints, `get x` reads
# input. Nothing in the library defines either.)
#
# THIS IS THE CATEGORY WHERE A "SANDBOX" BARELY APPLIES. A blob store's whole
# behaviour is store-these-bytes-give-them-back, and a directory on your disk does
# that genuinely -- there is nothing to fake, the way a payment gateway or a
# frontier model must be faked. So BOTH implementations here are local-real.
#
# WHICH LEAVES ONE REAL PROBLEM, and it is the reason this file exists: AN OBJECT
# KEY IS NOT A FILE PATH. They look alike and they are not, and every claim below
# was MEASURED on this machine before the design was chosen.

$TESTDIR = CurrentDir()
$DIR = $TESTDIR + "/_blobtest"

Scenario("the port is four verbs, and a directory already speaks them")
	if StzDirExists($DIR)  StzDirDeleteAll($DIR) ok
	oB = StzFileBlobStoreQ($DIR)

	Then("a new store is empty", oB.IsEmpty(), TRUE)
	Then("it is LOCAL-REAL, not a fake", oB.IsLocalReal(), TRUE)
	Then("...and a directory survives a restart", oB.IsEphemeral(), FALSE)

	oB.Save("greeting.txt", "hello")
	Then("what went in comes out", oB.Fetch("greeting.txt"), "hello")
	Then("it is there", oB.Exists("greeting.txt"), TRUE)
	Then("...with a size", oB.Size("greeting.txt"), 5)
	Then("and removing it works", oB.Remove("greeting.txt"), TRUE)
	Then("...leaving nothing", oB.Exists("greeting.txt"), FALSE)
EndScenario()

Scenario("A KEY IS NOT A PATH (1): two distinct keys must not become one file")
	oB = StzFileBlobStoreQ($DIR)
	oB.ClearQ()

	# In S3, 'Photo.JPG' and 'photo.jpg' are two different objects. This machine's
	# filesystem is case-INSENSITIVE: writing both as paths leaves ONE file, the
	# second silently overwriting the first. That is data loss with no error --
	# the worst failure mode available.
	oB.Save("Photo.JPG", "the original")
	oB.Save("photo.jpg", "a different picture")

	Then("both objects exist", oB.NumberOfBlobs(), 2)
	Then("the first still holds its own bytes", oB.Fetch("Photo.JPG"), "the original")
	Then("...and the second holds its own", oB.Fetch("photo.jpg"), "a different picture")
	# they survive because the filename is sha256(key), not the key.
EndScenario()

Scenario("A KEY IS NOT A PATH (2): a traversal key must not escape the store")
	oB = StzFileBlobStoreQ($DIR)
	oB.ClearQ()

	# '../secrets.txt' is an ordinary S3 key. Used as a path it writes OUTSIDE the
	# store directory -- verified on this machine, the bytes landed in the parent.
	# Whatever your users can name, they can then write.
	oB.Save("../escaped.txt", "did I get out?")

	Then("it is stored as an ORDINARY object", oB.Exists("../escaped.txt"), TRUE)
	Then("...and reads back correctly", oB.Fetch("../escaped.txt"), "did I get out?")
	Then("NOTHING appeared outside the store", StzFileExists($TESTDIR + "/escaped.txt"), FALSE)
	# not guarded -- UNREPRESENTABLE. The filename is 64 hex characters, so there
	# is no path for a key to express. Same move as the XML parser refusing DOCTYPE.

	Given("the other filesystem-hostile keys, which are all just keys to S3")
	oB.Save("photos/2026/tajine.jpg", "nested")
	Then("a SLASHED key works -- the commonest S3 shape there is",
	     oB.Fetch("photos/2026/tajine.jpg"), "nested")
	# as a path this FAILS outright unless the directories exist; S3 has no
	# directories at all, the slashes are characters a console draws as folders.
	oB.Save("CON", "a windows device name")
	Then("a Windows reserved device name is just a key", oB.Fetch("CON"), "a windows device name")
	oB.Save("trailing. ", "dots and spaces windows strips")
	Then("...so are trailing dots and spaces", oB.Fetch("trailing. "), "dots and spaces windows strips")
	Then("...and they are all DISTINCT objects", oB.NumberOfBlobs(), 4)
EndScenario()

Scenario("bytes are bytes -- an image or a zip, not just text")
	oB = StzFileBlobStoreQ($DIR)
	oB.ClearQ()

	cEvery = ""
	for i = 0 to 255
		cEvery += char(i)
	next
	oB.Save("payload.bin", cEvery)

	Then("all 256 byte values round-trip identically", oB.Fetch("payload.bin") = cEvery, TRUE)
	Then("...with the length intact", oB.Size("payload.bin"), 256)
	# verified separately that Ring strings, Ring lists and the engine's file
	# helpers each carry binary intact -- so no base64 detour is needed, which
	# matters because the engine's TEXT boundary does validate UTF-8.

	When("a file on disk is stored and fetched back to disk")
	cIn = $TESTDIR + "/_blobtest_in.dat"
	cOut = $TESTDIR + "/_blobtest_out.dat"
	StzFileWrite(cIn, cEvery)
	oB.SaveFile("from-disk", cIn)
	Then("the fetch-to-file succeeds", oB.FetchToFile("from-disk", cOut), TRUE)
	Then("...byte-identical", StzFileRead(cOut) = cEvery, TRUE)
	StzFileDelete(cIn)
	StzFileDelete(cOut)
	Then("fetching a missing key to a file reports FALSE rather than writing junk",
	     oB.FetchToFile("no-such-key", cOut), FALSE)
EndScenario()

Scenario("listing, the S3 idiom -- and the semantics a test must not contradict")
	oB = StzFileBlobStoreQ($DIR)
	oB.ClearQ()
	oB.Save("photos/a.jpg", "1")
	oB.Save("photos/b.jpg", "22")
	oB.Save("docs/c.pdf", "333")

	Then("everything is listed", len(oB.Keys()), 3)
	Then("a PREFIX narrows it, which is how S3 fakes folders", len(oB.KeysWithPrefix("photos/")), 2)
	Then("...and a prefix matching nothing gives nothing", len(oB.KeysWithPrefix("videos/")), 0)
	Then("total bytes are countable", oB.TotalBytes(), 6)
	# a local store lists everything; a real one PAGINATES (a continuation token
	# per 1000 objects), so code that must scale should page rather than assume
	# one call sees all.

	Given("the semantics of the real service, kept rather than improved on")
	oB.Save("photos/a.jpg", "overwritten")
	Then("Save overwrites SILENTLY, as S3 does", oB.Fetch("photos/a.jpg"), "overwritten")
	Then("...without adding an object", len(oB.Keys()), 3)
	Then("removing a key that never existed SUCCEEDS -- S3's DELETE is idempotent",
	     oB.Remove("never-existed"), TRUE)
	# a test asserting that a missing delete FAILS would be asserting a fiction.

	When("a ZERO-BYTE object is stored -- a legitimate thing to do")
	oB.Save("marker", "")
	Then("it exists", oB.Exists("marker"), TRUE)
	Then("...though its bytes are empty", oB.Fetch("marker"), "")
	Then("while a MISSING key is also empty -- so ask Exists, never Fetch",
	     oB.Exists("no-such-thing"), FALSE)
EndScenario()

Scenario("the local store refuses what the LIVE one would refuse")
	oB = StzFileBlobStoreQ($DIR)

	bEmpty = FALSE
	try
		oB.Save("", "x")
	catch
		bEmpty = TRUE
	done
	Then("an empty key is refused", bEmpty, TRUE)

	bLong = FALSE
	try
		oB.Save(StzRepeatStr("k", 1025), "x")
	catch
		bLong = TRUE
	done
	Then("a key over S3's 1024-byte limit is refused", bLong, TRUE)
	Then("...while 1024 exactly is accepted", oB.Save(StzRepeatStr("k", 1024), "x"), TRUE)
	# a sandbox that accepts MORE than the real service lets you build something
	# that breaks at deploy -- the same reason the payments sandbox refuses a float.
EndScenario()

Scenario("durability: this is real storage, not a test fixture")
	oB = StzFileBlobStoreQ($DIR)
	oB.ClearQ()
	oB.Save("kept.txt", "still here")

	When("a COMPLETELY NEW store object is opened on the same directory")
	oB2 = StzFileBlobStoreQ($DIR)
	Then("it sees the object", oB2.Exists("kept.txt"), TRUE)
	Then("...and its bytes", oB2.Fetch("kept.txt"), "still here")
	Then("...and can list it", len(oB2.Keys()), 1)
	# which is what makes shipping this a legitimate choice rather than a fake
	# awaiting replacement: the bytes are on a real disk in a real filesystem.
EndScenario()

Scenario("the memory store: equally real, and gone at the next restart")
	oM = StzMemoryBlobStoreQ()
	oM.Save("a/one", "1")
	oM.Save("a/two", "2")
	oM.Save("b/three", "3")

	Then("it speaks the same four verbs", oM.Fetch("a/one"), "1")
	Then("...including prefix listing", len(oM.KeysWithPrefix("a/")), 2)
	Then("...and carries binary", oM.Save("bin", char(0) + char(255)), TRUE)
	Then("it is LOCAL-REAL like the file store", oM.IsLocalReal(), TRUE)
	Then("but EPHEMERAL, which the file store is not", oM.IsEphemeral(), TRUE)

	oM.Remove("a/one")
	Then("removal works", oM.Exists("a/one"), FALSE)
	Then("...leaving the rest", oM.NumberOfBlobs(), 3)
EndScenario()

Scenario("through the registry -- and an invariant that generalised for free")
	oB = StzFileBlobStoreQ($DIR)
	oM = StzMemoryBlobStoreQ()
	oReg = new stzServiceRegistry("app")
	oReg.Bind(:uploads, oB)
	oReg.Bind(:scratch, oM)

	Then("the file store is detected as local", oReg.PostureOf(:uploads), :local)
	Then("...and so is the memory store", oReg.PostureOf(:scratch), :local)

	When("the application stores through the service the registry hands back")
	oReg.Service(:uploads).Save("via-registry", "x")
	Then("the ORIGINAL store has it", oB.Exists("via-registry"), TRUE)
	# The file store needs NO handle table to survive Ring's copy-on-assignment:
	# its state is on DISK, so a copy simply sees it -- exactly like the sqlite
	# data source. The MEMORY store does need one, and has one.
	oReg.Service(:scratch).Save("via-registry", "y")
	Then("...and so does the memory store, via its handle table", oM.Exists("via-registry"), TRUE)

	When("the phase becomes production")
	oReg.SetPhaseQ(:production)
	aF = oReg.Findings()
	Then("exactly ONE thing is refused", len(aF), 1)
	Then("...the EPHEMERAL store, not the durable one", aF[1][:where], "app/scratch")
	Then("...by the rule sqlite's ':memory:' earned in phase 2",
	     aF[1][:invariant], "ephemeral-in-production")
	# no new rule was written for blobs. The registry asks the OBJECT
	# (IsEphemeral()) rather than knowing about databases, so a category added
	# four phases later is covered by construction.

	# and the honest limit: a directory gives you storage, not a CDN. No presigned
	# URLs, no public endpoint, no replication, no versioning, no lifecycle rules.
	# If the application hands a browser a URL to upload to, THAT part is not
	# virtualized here. The S3/GCS adapter binds the same four methods and is
	# infra-gated (account + key + network).
EndScenario()

if StzDirExists($DIR)  StzDirDeleteAll($DIR) ok

Summary()
