#================================================================#
#  STZBLOBPORT -- the object-store port (local-real: a directory)    #
#================================================================#

/*--- Phase 6: the purest LOCAL-REAL category, and one security trap.

A blob port is **"any object with `Save(key, bytes)` / `Fetch(key)` / `Exists(key)` /
`Remove(key)`"**. S3, GCS, Azure Blob, Backblaze -- all the same four verbs over a
flat key namespace, which is why one port covers the category.

(S3 spells the first two `PutObject`/`GetObject`, and `Put`/`Get` would have been
the obvious names -- but both are Ring STATEMENTS (`put x` prints, `get x` reads
input), so neither can be a method. Nothing in the library defines either. Same
accommodation `stzHttpPort` makes with `GetFrom`/`PostTo`, and `stzAppServer` with
`Get_`.)

This is the category where a "sandbox" barely applies. A blob store's whole
behaviour is *store these bytes, give them back*, and a directory on your disk does
that genuinely -- there is no fidelity to fake, the way a payment gateway or a
frontier model has to be faked. So both implementations here are **local-real**:
`stzFileBlobStore` (a directory, persistent) and `stzMemoryBlobStore` (RAM,
ephemeral -- and caught in production by the invariant sqlite's `":memory:"`
already earned, with no new rule needed).

THE TRAP, and the reason this file is more than a wrapper around `write()`:
**an object key is NOT a file path.** They look alike and they are not, and the
difference was *measured* on this machine before the code was written:

  * `photo.jpg` and `Photo.JPG` are TWO objects in S3. On this filesystem, writing
    both leaves ONE file -- the second silently overwrote the first. A naive
    key-to-path store LOSES DATA, quietly, which is the worst failure available.
  * a key of `../secrets.txt` is an ordinary S3 key. As a path it **escapes the
    bucket directory** -- verified: the bytes landed in the parent folder. That is
    a path-traversal write, driven by whatever your users can name.
  * `photos/2026/a.jpg` is the single commonest S3 key shape there is. As a path it
    FAILS outright unless the directories already exist (S3 has no directories --
    the slashes are just characters that a console draws as folders).
  * and then the Windows tail: reserved device names (`CON`, `NUL`, `COM1`),
    trailing dots and spaces that get stripped, `:` meaning an alternate data
    stream.

Guarding those one by one is a losing game. So the key never becomes a path at
all: **the filename is `sha256(key)`**, and the real key lives beside it in a
`.key` sidecar so listing still works. Traversal becomes *unrepresentable* rather
than blocked, distinct keys stay distinct on any filesystem, slashes are just
characters again, and the hex name is ASCII by construction. Same move as the XML
parser refusing DOCTYPE outright: close the hole by making it unsayable.

    oBlobs = StzFileBlobStoreQ("D:/data/uploads")
    oBlobs.Save("photos/2026/tajine.jpg", cBytes)
    oBlobs.Fetch("photos/2026/tajine.jpg")
    oBlobs.KeysWithPrefix("photos/2026/")

BYTES ARE BYTES: verified across all 256 byte values that Ring strings, Ring
lists, and the engine's file helpers each round-trip binary intact -- so an image
or a zip goes in and comes out identical, with no base64 detour.

THE HONEST LIMIT: a directory gives you storage, not a CDN. **No presigned URLs,
no public HTTP endpoint, no replication, no storage classes, no cross-region, no
versioning, no lifecycle rules.** If your application hands a browser a URL to
upload to or download from, *that* part is not virtualized here and still needs
the real service. What you get fee-free is every path that reads and writes bytes
by key -- which is most application code. The S3/GCS adapter binds the same four
methods and is infra-gated (account + key + network).
*/

# shared across copies -- see the Ring note in stzServiceRegistry.
# the FILE store needs none of this: its state is on DISK, so a copy sees it
# already, exactly as the sqlite data source does.
# [ [ id, [ [key, bytes], ... ] ], ... ]
$aStzMemoryBlobStores = []
$nStzMemoryBlobStoreSeq = 0

# S3 caps a key at 1024 UTF-8 bytes. Enforced here so the local store refuses what
# the live one would refuse -- a sandbox that accepts MORE than the real service
# lets you build something that breaks at deploy (the same reason the payments
# sandbox refuses a float).
$nStzBlobKeyMaxBytes = 1024

func StzFileBlobStoreQ(pcDir)
	return new stzFileBlobStore(pcDir)

func StzMemoryBlobStoreQ()
	return new stzMemoryBlobStore()

# The one rule that makes a key safe to put on a filesystem: don't. Hash it.
func StzBlobKeyToName(pcKey)
	return StzEngineCryptoSha256("" + pcKey)


  #=========================================================#
 #  FILE BLOB STORE -- a directory, and genuinely durable     #
#=========================================================#

# Stores binary objects by key in a folder on disk, the four verbs of an S3 bucket over a flat key namespace.
#
# Save, Fetch, Exists and Remove are the whole port; listing is by prefix. A key is never a file
# name: each object is a file named by the SHA-256 of its key, with the real key kept in a .key file
# beside it, so keys that differ only by case stay distinct, a key such as ../x cannot leave the
# folder, and slashes are ordinary characters. Keys are limited to 1024 bytes, as in S3. It is a
# real store, not a fake, and it survives a restart. It has no presigned URLs, no versioning and no
# replication.
#
#   receiver   o1 = new stzFileBlobStore("demo_blobs")
#   example    o1.Save("photos/2026/a.jpg", "abcde")
#              o1.Save("Photo.JPG", "XY")
#              ? o1.NumberOfBlobs()
#              #--> 2
#              ? o1.Fetch("photos/2026/a.jpg")
#              #--> abcde
#              ? o1.Exists("photo.jpg")
#              #--> 0
#              ? @@( o1.KeysWithPrefix("photos/") )
#              #--> [ "photos/2026/a.jpg" ]
#              o1.Clear()
#   see        stzMemoryBlobStore, stzServiceRegistry
class stzFileBlobStore from stzObject

	@cDir = ""

	# Builds a store over a directory, creating the directory (and its parents) when it does not exist yet.
	#
	#   pcDir      the folder that holds the objects, as text
	#   returns    nothing; the object is built
	#   note       the directory is kept as given, trimmed of blanks
	#   warning    an empty path raises the error "a directory path is required"; so does a folder
	#              that cannot be created
	#   see        Directory, Save
	def init(pcDir)
		_d_ = ring_trim("" + pcDir)
		if _d_ = ""
			StzRaise("stzFileBlobStore: a directory path is required.")
		ok
		if NOT StzDirExists(_d_)
			StzDirCreatePath(_d_)
		ok
		if NOT StzDirExists(_d_)
			StzRaise("stzFileBlobStore: could not create the store directory '" + _d_ + "'.")
		ok
		@cDir = _d_

	# TRUE if the store is a genuine local equivalent of a real object store rather than a fake.
	#
	#   returns    TRUE or FALSE; always TRUE for this class
	#   note       the service registry asks this of every port
	#   see        IsEphemeral
	#@ aka  a genuine local equivalent, not a fake -- see stzServiceRegistry's postures
	def IsLocalReal()
		return 1

	# TRUE if the stored objects vanish when the process ends.
	#
	#   returns    TRUE or FALSE; always FALSE for this class, since the objects are files
	#   see        IsLocalReal, stzMemoryBlobStore
	#@ aka  a directory survives a restart
	def IsEphemeral()
		return 0

	# Returns the folder that holds the objects of this store.
	#
	#   returns    a text, the path given to the constructor
	#   see        init, Keys
	def Directory()
		return @cDir

	# Stores bytes under an object key, replacing the object when the key already exists, as an S3 PUT does.
	#
	#   pcKey      the object key, any text up to 1024 bytes, such as "photos/2026/a.jpg"
	#   pcBytes    the content to store, as text, binary included
	#   returns    1 (TRUE), always
	#   note       SaveQ is the same call and returns the store; the key is never used as a file
	#              name: the file is named by the SHA-256 of the key, so "photo.jpg" and "Photo.JPG"
	#              stay two objects and "../x" cannot leave the folder; the real key is kept in a
	#              .key file beside the .blob file
	#   warning    an empty key and a key over 1024 bytes raise an error
	#   see        Fetch, Exists, Remove, SaveFile
	#@ aka  -- the PORT contract ------------------------------------------------
	def Save(pcKey, pcBytes)
		_k_ = This._CheckedKey(pcKey)
		_h_ = StzBlobKeyToName(_k_)
		StzFileWrite(@cDir + "/" + _h_ + ".blob", "" + pcBytes)
		StzFileWrite(@cDir + "/" + _h_ + ".key", _k_)
		return 1

	def SaveQ(pcKey, pcBytes)
		This.Save(pcKey, pcBytes)
		return This

	# Returns the bytes stored under a key.
	#
	#   pcKey      the object key to read
	#   returns    a text; the empty text when the key is absent, which Exists tells apart from a
	#              stored empty object
	#   note       an object stored empty and a missing one both give the empty text
	#   warning    an empty key raises an error
	#   see        Exists, Size, FetchToFile
	#@ aka  -> the bytes, or "" when absent. Ask Exists() to tell an empty object from a missing one -- a zero-byte object is a legitimate thing to store.
	def Fetch(pcKey)
		_p_ = This._BlobPath(pcKey)
		if NOT StzFileExists(_p_)
			return ""
		ok
		return StzFileRead(_p_)

	# TRUE if an object is stored under the key.
	#
	#   pcKey      the object key to look for
	#   returns    TRUE or FALSE
	#   note       keys are compared exactly, case included
	#   warning    an empty key raises an error
	#   see        Fetch, Size
	def Exists(pcKey)
		return StzFileExists( This._BlobPath(pcKey) )

	# Deletes the object stored under a key; deleting an absent key also succeeds, as an S3 DELETE does.
	#
	#   pcKey      the object key to delete
	#   returns    1 (TRUE), always
	#   note       RemoveQ returns the store so calls chain
	#   warning    an empty key raises an error
	#   see        Clear, Exists
	#@ aka  S3's DELETE is idempotent: removing what is not there SUCCEEDS. Kept, because a test that asserts otherwise would be asserting a fiction.
	def Remove(pcKey)
		_h_ = StzBlobKeyToName( This._CheckedKey(pcKey) )
		if StzFileExists(@cDir + "/" + _h_ + ".blob")
			StzFileDelete(@cDir + "/" + _h_ + ".blob")
		ok
		if StzFileExists(@cDir + "/" + _h_ + ".key")
			StzFileDelete(@cDir + "/" + _h_ + ".key")
		ok
		return 1

	def RemoveQ(pcKey)
		This.Remove(pcKey)
		return This

	# Returns the number of bytes stored under a key.
	#
	#   pcKey      the object key to measure
	#   returns    a number; 0 when the key is absent
	#   note       an absent object and an empty one both give 0
	#   warning    an empty key raises an error
	#   see        Fetch, TotalBytes
	#@ aka  -- listing, the S3 idiom -------------------------------------------
	def Size(pcKey)
		_p_ = This._BlobPath(pcKey)
		if NOT StzFileExists(_p_)
			return 0
		ok
		return StzFileSize(_p_)

	# Returns the real keys of every stored object, read back from the .key files.
	#
	#   returns    a list of text, in the order the folder lists its files (not sorted, not the
	#              order saved)
	#   note       a real store pages a long listing; this one returns everything in one call
	#   see        KeysWithPrefix, NumberOfBlobs
	#@ aka  The real keys, read back from the sidecars. A local store lists everything; a real one PAGINATES (a continuation token per 1000 objects), so code that must scale should page rather than assume one call sees all.
	def Keys()
		_out_ = []
		_a_ = StzListFiles(@cDir)
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if StzEndsWith(_a_[_i_], ".key")
				_out_ + StzFileRead(@cDir + "/" + _a_[_i_])
			ok
		next
		return _out_

	# Returns the keys that begin with a prefix, the way an S3 listing by prefix does.
	#
	#   pcPrefix   the beginning the keys must have, compared with case
	#   returns    a list of text; [ ] when none matches
	#   note       order is the folder's, as for Keys
	#   see        Keys
	def KeysWithPrefix(pcPrefix)
		_p_ = "" + pcPrefix
		_out_ = []
		_a_ = This.Keys()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if StzStartsWith(_a_[_i_], _p_)
				_out_ + _a_[_i_]
			ok
		next
		return _out_

	# Returns how many objects the store holds.
	#
	#   returns    a number
	#   see        Keys, IsEmpty
	def NumberOfBlobs()
		return len( This.Keys() )

	# TRUE if the store holds no object.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfBlobs
	def IsEmpty()
		return This.NumberOfBlobs() = 0

	# Returns the sum of the sizes of all stored objects, in bytes.
	#
	#   returns    a number
	#   see        Size, NumberOfBlobs
	def TotalBytes()
		_t_ = 0
		_a_ = This.Keys()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_t_ += This.Size(_a_[_i_])
		next
		return _t_

	# Stores the content of an existing file under a key.
	#
	#   pcKey      the object key to store under
	#   pcPath     the file to read
	#   returns    1 (TRUE)
	#   note       the whole file passes through memory, in spite of the name
	#   warning    a path that does not exist raises an error naming it
	#   see        Save, FetchToFile
	#@ aka  -- large payloads, without passing through RAM ----------------------
	def SaveFile(pcKey, pcPath)
		if NOT StzFileExists(pcPath)
			StzRaise("stzFileBlobStore.SaveFile: no such file '" + pcPath + "'.")
		ok
		return This.Save(pcKey, StzFileRead(pcPath))

	# Writes the bytes of an object to a file.
	#
	#   pcKey      the object key to read
	#   pcPath     the file to write, replaced if it exists
	#   returns    1 (TRUE) when written; 0 when the key is absent, and then no file is written
	#   warning    an empty key raises an error
	#   see        Fetch, SaveFile
	def FetchToFile(pcKey, pcPath)
		if NOT This.Exists(pcKey)
			return 0
		ok
		StzFileWrite(pcPath, This.Fetch(pcKey))
		return 1

	# Deletes every object of the store, one by one, and leaves the folder itself.
	#
	#   returns    nothing; use ClearQ to chain
	#   note       files that are not part of the store (no matching .key file) are left alone
	#   see        Remove, IsEmpty
	def Clear()
		This.ClearQ()

	def ClearQ()
		_a_ = This.Keys()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			This.Remove(_a_[_i_])
		next
		return This

	# Prints a one-line summary: the folder, how many objects and how many bytes.
	#
	#   returns    nothing; it prints
	#   see        NumberOfBlobs, TotalBytes
	def Show()
		? "stzFileBlobStore(" + @cDir + "): " + This.NumberOfBlobs() +
		  " object(s), " + This.TotalBytes() + " byte(s)"

	  #-- internals -------------------------------------------------------

	def _BlobPath(pcKey)
		return @cDir + "/" + StzBlobKeyToName( This._CheckedKey(pcKey) ) + ".blob"

	# An empty key is not an object name, and an over-long one would be accepted
	# here and rejected at deploy.
	def _CheckedKey(pcKey)
		_k_ = "" + pcKey
		if _k_ = ""
			StzRaise("stzBlobStore: an object key may not be empty.")
		ok
		if len(_k_) > $nStzBlobKeyMaxBytes
			StzRaise("stzBlobStore: an object key may not exceed " +
			         $nStzBlobKeyMaxBytes + " bytes (this one is " + len(_k_) + ").")
		ok
		return _k_


  #=========================================================#
 #  MEMORY BLOB STORE -- real, and gone at the next restart   #
#=========================================================#
#
# Local-real like the file store, but EPHEMERAL: it holds the bytes in RAM, so it
# is a real store right up to the process exit that empties it. That is precisely
# the case `ephemeral-in-production` was added for when sqlite's ":memory:" forced
# it, and the registry asks the OBJECT (`IsEphemeral()`) rather than knowing about
# databases -- so this store is caught by that existing rule with no new code.
#
# Unlike the file store it holds Ring-side state, so it needs the handle table:
# `=` and list-insertion both COPY in Ring, and the file store escapes that only
# because its state lives on disk.

# Stores binary objects by key in memory, with the same four verbs as the file store; it is gone when the process ends.
#
# It is a real store for the length of the process, and the service registry reports it as ephemeral
# so that a production check can refuse it. Keys follow the same rules as the file store: exact
# comparison, 1024 bytes at most, never empty. Each instance keeps its own objects.
#
#   receiver   o1 = new stzMemoryBlobStore()
#   example    o1.Save("a/1", "abc")
#              o1.Save("a/2", "de")
#              o1.Save("b/1", "f")
#              ? o1.TotalBytes()
#              #--> 6
#              ? @@( o1.KeysWithPrefix("a/") )
#              #--> [ "a/1", "a/2" ]
#              ? o1.IsEphemeral()
#              #--> 1
#   see        stzFileBlobStore, stzServiceRegistry
class stzMemoryBlobStore from stzObject

	@nId = 0

	# Builds an empty store that holds its objects in memory, numbered so that each store keeps its own.
	#
	#   returns    nothing; the object is built
	#   note       two stores never see each other's objects
	#   see        Save, stzFileBlobStore
	def init()
		$nStzMemoryBlobStoreSeq = $nStzMemoryBlobStoreSeq + 1
		@nId = $nStzMemoryBlobStoreSeq
		$aStzMemoryBlobStores + [ @nId, [] ]

	# TRUE if the store is a genuine local equivalent of a real object store rather than a fake.
	#
	#   returns    TRUE or FALSE; always TRUE for this class
	#   see        IsEphemeral
	def IsLocalReal()
		return 1

	# TRUE if the stored objects vanish when the process ends.
	#
	#   returns    TRUE or FALSE; always TRUE for this class, which is why a production check flags
	#              it
	#   see        IsLocalReal, stzFileBlobStore
	def IsEphemeral()
		return 1

	# Stores bytes under an object key, replacing the object when the key already exists.
	#
	#   pcKey      the object key, any text up to 1024 bytes
	#   pcBytes    the content to store, as text
	#   returns    1 (TRUE), always
	#   note       SaveQ is the same call and returns the store; keys are compared exactly:
	#              "photo.jpg" and "Photo.JPG" are two objects
	#   warning    an empty key and a key over 1024 bytes raise an error
	#   see        Fetch, Exists, Remove
	#@ aka  -- the PORT contract, same four verbs -------------------------------
	def Save(pcKey, pcBytes)
		_k_ = This._CheckedKey(pcKey)
		_i_ = This._Slot()
		_j_ = This._Index(_k_)
		if _j_ > 0
			$aStzMemoryBlobStores[_i_][2][_j_] = [ _k_, "" + pcBytes ]
		else
			$aStzMemoryBlobStores[_i_][2] + [ _k_, "" + pcBytes ]
		ok
		return 1

	def SaveQ(pcKey, pcBytes)
		This.Save(pcKey, pcBytes)
		return This

	# Returns the bytes stored under a key.
	#
	#   pcKey      the object key to read
	#   returns    a text; the empty text when the key is absent, which Exists tells apart from a
	#              stored empty object
	#   warning    an empty key raises an error
	#   see        Exists, Size
	def Fetch(pcKey)
		_j_ = This._Index( This._CheckedKey(pcKey) )
		if _j_ = 0
			return ""
		ok
		return $aStzMemoryBlobStores[This._Slot()][2][_j_][2]

	# TRUE if an object is stored under the key.
	#
	#   pcKey      the object key to look for
	#   returns    TRUE or FALSE
	#   warning    an empty key raises an error
	#   see        Fetch, Size
	def Exists(pcKey)
		return This._Index( This._CheckedKey(pcKey) ) > 0

	# Deletes the object stored under a key; deleting an absent key also succeeds, as an S3 DELETE does.
	#
	#   pcKey      the object key to delete
	#   returns    1 (TRUE), always
	#   warning    an empty key raises an error
	#   see        Clear, Exists
	def Remove(pcKey)
		_j_ = This._Index( This._CheckedKey(pcKey) )
		if _j_ > 0
			_i_ = This._Slot()
			ring_del($aStzMemoryBlobStores[_i_][2], _j_)
		ok
		return 1

	def RemoveQ(pcKey)
		This.Remove(pcKey)
		return This

	# Returns the number of bytes stored under a key.
	#
	#   pcKey      the object key to measure
	#   returns    a number; 0 when the key is absent
	#   warning    an empty key raises an error
	#   see        Fetch, TotalBytes
	def Size(pcKey)
		return len( This.Fetch(pcKey) )

	# Returns the keys of the stored objects.
	#
	#   returns    a list of text, in the order saved
	#   see        KeysWithPrefix, NumberOfBlobs
	def Keys()
		_out_ = []
		_a_ = $aStzMemoryBlobStores[This._Slot()][2]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_out_ + _a_[_i_][1]
		next
		return _out_

	# Returns the keys that begin with a prefix, the way an S3 listing by prefix does.
	#
	#   pcPrefix   the beginning the keys must have, compared with case
	#   returns    a list of text, in the order saved; [ ] when none matches
	#   see        Keys
	def KeysWithPrefix(pcPrefix)
		_p_ = "" + pcPrefix
		_out_ = []
		_a_ = This.Keys()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if StzStartsWith(_a_[_i_], _p_)
				_out_ + _a_[_i_]
			ok
		next
		return _out_

	# Returns how many objects the store holds.
	#
	#   returns    a number
	#   see        Keys, IsEmpty
	def NumberOfBlobs()
		return len($aStzMemoryBlobStores[This._Slot()][2])

	# TRUE if the store holds no object.
	#
	#   returns    TRUE or FALSE
	#   see        NumberOfBlobs
	def IsEmpty()
		return This.NumberOfBlobs() = 0

	# Returns the sum of the sizes of all stored objects, in bytes.
	#
	#   returns    a number
	#   see        Size, NumberOfBlobs
	def TotalBytes()
		_t_ = 0
		_a_ = $aStzMemoryBlobStores[This._Slot()][2]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_t_ += len(_a_[_i_][2])
		next
		return _t_

	# Deletes every object of this store, leaving other stores alone.
	#
	#   returns    nothing; use ClearQ to chain
	#   see        Remove, IsEmpty
	def Clear()
		This.ClearQ()

	def ClearQ()
		$aStzMemoryBlobStores[This._Slot()][2] = []
		return This

	# Prints a one-line summary: how many objects and how many bytes, marked EPHEMERAL.
	#
	#   returns    nothing; it prints
	#   see        NumberOfBlobs, TotalBytes
	def Show()
		? "stzMemoryBlobStore: " + This.NumberOfBlobs() + " object(s), " +
		  This.TotalBytes() + " byte(s) -- EPHEMERAL"

	  #-- internals -------------------------------------------------------

	def _Index(pcKey)
		_a_ = $aStzMemoryBlobStores[This._Slot()][2]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if _a_[_i_][1] = pcKey
				return _i_
			ok
		next
		return 0

	def _CheckedKey(pcKey)
		_k_ = "" + pcKey
		if _k_ = ""
			StzRaise("stzBlobStore: an object key may not be empty.")
		ok
		if len(_k_) > $nStzBlobKeyMaxBytes
			StzRaise("stzBlobStore: an object key may not exceed " +
			         $nStzBlobKeyMaxBytes + " bytes (this one is " + len(_k_) + ").")
		ok
		return _k_

	def _Slot()
		_n_ = len($aStzMemoryBlobStores)
		for _i_ = 1 to _n_
			if $aStzMemoryBlobStores[_i_][1] = @nId
				return _i_
			ok
		next
		$aStzMemoryBlobStores + [ @nId, [] ]
		return len($aStzMemoryBlobStores)
