#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZEXPOSURE               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#
# What this process RUNS, as data -- SOFTANZA_ONE_HOUR.md, B1 (rung W0).
#
# An advisory names a component and a version; before it can be matched to
# us, we must be able to name what we run. This class answers from the
# process itself, never from a document a person maintains:
#
#   * the engine domains loaded (the stz_*.dll handles that are not null);
#   * the vendored C libraries, from engine/vendor/DIGESTS -- name, version,
#     file count, the digest of the whole tree, and when the record was
#     written (engine/tools/vendor_digest.py writes it and checks it; a
#     changed tree is refused by exit code, like a model whose SHA256SUMS
#     line disagrees);
#   * the models recorded in models/SHA256SUMS and whether each is present;
#   * the listeners this process opened, recorded by every Listen/Start
#     door through StzNoteListener: class, host, port, and whether the
#     address is loopback;
#   * the model calls the security ledger holds (the doors passed).
#
# AsCycloneDx() exports it as a CycloneDX 1.5 bill of materials, the
# interop form an outside scanner reads, the way the ledger exports OCSF
# and OTel. What is NOT here, said so nobody reads it in: the kernel and
# its options are Harobanda's (harb advisories); a listener opened by
# engine code that bypassed the Ring door is not seen.

# the listeners opened in this process: [ [ class, host, port, loopback ], ... ]
$aStzListeners = []

# THE LISTENER DOOR: every Listen / Start in the library calls this before
# the socket opens, so stzExposure can say what is listening.
func StzNoteListener(pcClass, pcHost, pnPort)
	_cH_ = "" + pcHost
	_bLoop_ = (_cH_ = "127.0.0.1" or _cH_ = "localhost" or _cH_ = "::1")
	# a shut door (stzExposureResponder, W6) refuses here, before the socket opens
	StzDoorCheck("listener", pcClass, pcClass, 1 - _bLoop_)
	$aStzListeners + [ "" + pcClass, _cH_, pnPort, _bLoop_ ]

func StzListeners()
	return $aStzListeners

func StzForgetListeners()
	$aStzListeners = []

# The engine folder of the library's SOURCE tree -- vendor/, tools/ and src/ --
# which is not $cEngineDir when STZ_ENGINE_DIR names a built copy elsewhere.
func StzSourceEngineDir()
	if isglobal("$cStzLibDir") and $cStzLibDir != "" and fexists($cStzLibDir + "/engine/stk_string.ring")
		return $cStzLibDir + "/engine"
	ok
	return $cEngineDir

func StzExposureQ()
	return new stzExposure()


  #===============#
 #  STZEXPOSURE  #
#===============#

# Reports what this process runs: engine domains, vendored libraries with their digests, models, listeners and the doors passed.
#
# Everything is read from the process and its recorded digests, not typed by a person. An
# advisory feed matches against this; a bill of materials is exported from it. The vendored
# record is engine/vendor/DIGESTS, written and checked by engine/tools/vendor_digest.py.
#
#   receiver   o1 = new stzExposure()
#   example    ? o1.NumberOfVendored()
#              #--> 21
#              ? o1.NumberOfDomains() > 0
#              #--> 1
#              ? left(o1.AsCycloneDx(), 14)
#              #--> {"bomFormat":"
#   see        stzSecurityLedger, StzNoteListener
class stzExposure from stzObject

	@aDomains  = []    # [ name, ... ] the loaded engine domains
	@aVendored = []    # [ [ name, version, files, digest ], ... ]
	@cRecorded = ""    # when DIGESTS was written
	@aModels   = []    # [ [ file, digest, present ], ... ]

	# Builds the exposure by reading the process: loaded domains, the vendored record, the models record.
	#
	#   returns    nothing; the object is built
	#   see        Refresh
	def init()
		This.Refresh()

	# Reads the process again: domains loaded since, a rewritten DIGESTS, models added.
	#
	#   returns    the object itself, so calls chain
	def Refresh()
		This._ReadDomains()
		This._ReadVendored()
		This._ReadModels()
		return This

	  #-- engine domains ---------------------------------------------------

	# Returns the names of the engine domains loaded in this process, from their non-null DLL handles.
	#
	#   returns    a list of texts such as crypto, seclog, neural
	#   note       a domain whose DLL was not found loads nothing and is not listed
	def Domains()
		return @aDomains

	def NumberOfDomains()
		return len(@aDomains)

	# Returns the domains this process did NOT load: left out by its manifest, or refused by the deny list.
	#
	#   returns    a list of names; empty when every domain loaded
	#   see        StzDomainWanted (ruling 3, W7b)
	def SkippedDomains()
		_a_ = []
		_aS_ = StzDomainsSkipped()
		_n_ = len(_aS_)
		for _i_ = 1 to _n_  _a_ + _aS_[_i_]  next
		return _a_

	def HasDomain(pcName)
		return This._Has(StzLower("" + pcName), @aDomains)

	  #-- vendored libraries -----------------------------------------------

	# Returns the vendored C libraries as rows [ name, version, files, digest ], from engine/vendor/DIGESTS.
	#
	#   returns    a list of rows; empty when the record is absent
	#   note       the digest is one SHA-256 over the whole tree; vendor_digest.py --check refuses a tree that differs
	#   see        VendoredRecordedAt, VendoredDigestOf
	def Vendored()
		return @aVendored

	def NumberOfVendored()
		return len(@aVendored)

	# Returns the time the vendored record was written, as the record says it.
	#
	#   returns    a text such as 2026-11-05T13:56:32Z; empty when the record is absent
	def VendoredRecordedAt()
		return @cRecorded

	def VendoredDigestOf(pcName)
		_n_ = len(@aVendored)
		for _i_ = 1 to _n_
			if @aVendored[_i_][1] = pcName  return @aVendored[_i_][4]  ok
		next
		return ""

	def VendoredVersionOf(pcName)
		_n_ = len(@aVendored)
		for _i_ = 1 to _n_
			if @aVendored[_i_][1] = pcName  return @aVendored[_i_][2]  ok
		next
		return ""

	  #-- models -------------------------------------------------------------

	# Returns the models the record names, as rows [ file, digest, present ].
	#
	#   returns    a list of rows from models/SHA256SUMS; present is 1 when the file exists
	#   note       a model absent from the record loads with status -3 and is refused
	def Models()
		return @aModels

	def NumberOfModels()
		return len(@aModels)

	  #-- listeners ----------------------------------------------------------

	# Returns the listeners this process opened, as rows [ class, host, port, loopback ].
	#
	#   returns    a list of rows recorded by StzNoteListener
	#   see        NumberOfOpenListeners, ExposedListeners
	def Listeners()
		return $aStzListeners

	def NumberOfListeners()
		return len($aStzListeners)

	# Returns the listeners bound to an address other than loopback -- the ones another machine can reach.
	#
	#   returns    a list of rows
	def ExposedListeners()
		_a_ = []
		_n_ = len($aStzListeners)
		for _i_ = 1 to _n_
			if $aStzListeners[_i_][4] = 0  _a_ + $aStzListeners[_i_]  ok
		next
		return _a_

	def NumberOfExposedListeners()
		return len(This.ExposedListeners())

	  #-- doors --------------------------------------------------------------

	# Returns how many model calls the security ledger holds -- the doors passed in this process.
	#
	#   returns    a number; 0 when no ledger is open
	def ModelCallsRecorded()
		if NOT StzSecurityLedgerIsOpen()  return 0  ok
		return len(StzSecurityLedgerQ().OfKind("model.call"))

	  #-- the whole picture --------------------------------------------------

	# Returns the exposure as one record of counts, for a report or an assertion.
	#
	#   returns    a hash list with domains, vendored, models, listeners, exposed, modelCalls, recordedAt
	def Summary()
		return [
			:domains = len(@aDomains),
			:vendored = len(@aVendored),
			:models = len(@aModels),
			:listeners = len($aStzListeners),
			:exposed = This.NumberOfExposedListeners(),
			:modelCalls = This.ModelCallsRecorded(),
			:recordedAt = @cRecorded
		]

	# Returns the exposure as a CycloneDX 1.5 bill of materials in JSON, the form an outside scanner ingests.
	#
	#   returns    a JSON text; each vendored library is a component of type library with its version and
	#              tree digest, each model a component of type data with its digest, each engine domain a
	#              component of type library with the engine's version; listeners are services
	#   note       the tree digest is not a file digest, so its algorithm is named SHA-256 and its
	#              component carries the property stz:digest-of = tree
	def AsCycloneDx()
		_c_ = '{"bomFormat":"CycloneDX","specVersion":"1.5","version":1,"metadata":{"component":{"type":"library","name":"stzlib","version":"' + "0.9" + '"}},"components":['
		_aC_ = []
		_n_ = len(@aVendored)
		for _i_ = 1 to _n_
			_r_ = @aVendored[_i_]
			_aC_ + ('{"type":"library","name":"' + This._Esc(_r_[1]) + '","version":"' + This._Esc(_r_[2]) +
				'","hashes":[{"alg":"SHA-256","content":"' + _r_[4] + '"}],"properties":[{"name":"stz:digest-of","value":"tree"},{"name":"stz:files","value":"' + _r_[3] + '"}]}')
		next
		_n_ = len(@aModels)
		for _i_ = 1 to _n_
			_r_ = @aModels[_i_]
			_aC_ + ('{"type":"data","name":"' + This._Esc(_r_[1]) + '","hashes":[{"alg":"SHA-256","content":"' + _r_[2] +
				'"}],"properties":[{"name":"stz:present","value":"' + _r_[3] + '"}]}')
		next
		_n_ = len(@aDomains)
		for _i_ = 1 to _n_
			_aC_ + ('{"type":"library","name":"stz_' + @aDomains[_i_] + '","group":"softanza-engine"}')
		next
		_c_ += This._Join(_aC_) + '],"services":['
		_aS_ = []
		_n_ = len($aStzListeners)
		for _i_ = 1 to _n_
			_r_ = $aStzListeners[_i_]
			_aS_ + ('{"name":"' + This._Esc(_r_[1]) + '","endpoints":["' + This._Esc(_r_[2]) + ':' + _r_[3] +
				'"],"properties":[{"name":"stz:loopback","value":"' + _r_[4] + '"}]}')
		next
		_c_ += This._Join(_aS_) + ']}'
		return _c_

	def Show()
		_s_ = This.Summary()
		? "exposure: " + _s_[:domains] + " engine domains, " + _s_[:vendored] + " vendored libraries (recorded " +
			_s_[:recordedAt] + "), " + _s_[:models] + " models, " + _s_[:listeners] + " listeners (" +
			_s_[:exposed] + " beyond loopback), " + _s_[:modelCalls] + " model calls recorded"

	  #-- internals ------------------------------------------------------------

	# the loaded domains: every $pStz<Name>Handle global that is not null
	def _ReadDomains()
		@aDomains = []
		_aG_ = globals()
		_n_ = len(_aG_)
		for _i_ = 1 to _n_
			_g_ = StzLower(_aG_[_i_])
			if left(_g_, 4) = "$pst" and right(_g_, 6) = "handle" and StzIsPlainIdentifier(right(_aG_[_i_], len(_aG_[_i_]) - 1))
				_v_ = eval("return " + _aG_[_i_])
				if NOT (isString(_v_) and _v_ = "")
					if isPointer(_v_) or isNumber(_v_)
						_g_ = _aG_[_i_]                       # $pStzCryptoHandle -> crypto
						_cN_ = StzLower(left(right(_g_, len(_g_) - 5), len(_g_) - 11))
						# the core's own libraries ($pStkStringHandle) are named stk_<name>:
						# read as "string" they were counted twice (W7b, 2026-11-05)
						if StzLower(left(_g_, 5)) = "$pstk"  _cN_ = "stk_" + _cN_  ok
						@aDomains + _cN_
					ok
				ok
			ok
		next

	def _ReadVendored()
		@aVendored = []
		@cRecorded = ""
		# the record belongs to the SOURCE tree: an engine copy built elsewhere
		# (STZ_ENGINE_DIR) carries the libraries, not the record (W7b, 2026-11-05)
		_p_ = StzSourceEngineDir() + "/vendor/DIGESTS"
		if NOT fexists(_p_)  return  ok
		_aL_ = StzSplit(read(_p_), char(10))
		_n_ = len(_aL_)
		for _i_ = 1 to _n_
			_l_ = ring_trim(_aL_[_i_])
			if _l_ = ""  loop  ok
			if left(_l_, 1) = "#"
				if left(_l_, 11) = "# recorded:"  @cRecorded = ring_trim(substr(_l_, 12))  ok
				loop
			ok
			_aF_ = StzSplit(_l_, "|")
			if len(_aF_) < 4  loop  ok
			@aVendored + [ ring_trim(_aF_[1]), ring_trim(_aF_[2]), number(ring_trim(_aF_[3])), ring_trim(_aF_[4]) ]
		next

	def _ReadModels()
		@aModels = []
		# STZ_MODELS_DIR names the models folder outright: under a Ring++ engine copy
		# the folder derived from the engine path does not exist
		_d_ = sysget("STZ_MODELS_DIR")
		if _d_ = ""  _d_ = StzModelsDir()  ok
		_p_ = _d_ + "/SHA256SUMS"
		if _d_ = "" or NOT fexists(_p_)  return  ok
		_aL_ = StzSplit(read(_p_), char(10))
		_n_ = len(_aL_)
		for _i_ = 1 to _n_
			_l_ = ring_trim(_aL_[_i_])
			if _l_ = "" or left(_l_, 1) = "#"  loop  ok
			_k_ = StzFindFirst(" ", _l_)
			if _k_ = 0  loop  ok
			_cD_ = left(_l_, _k_ - 1)
			_cF_ = ring_trim(substr(_l_, _k_ + 1))
			@aModels + [ _cF_, _cD_, fexists(_d_ + "/" + _cF_) ]
		next

	def _Has(pcItem, paList)
		_n_ = len(paList)
		for _i_ = 1 to _n_
			if paList[_i_] = pcItem  return 1  ok
		next
		return 0

	def _Join(paParts)
		_c_ = ""
		_n_ = len(paParts)
		for _i_ = 1 to _n_
			if _i_ > 1  _c_ += ","  ok
			_c_ += paParts[_i_]
		next
		return _c_

	def _Esc(pcStr)
		_c_ = StzReplace("" + pcStr, char(92), char(92) + char(92))
		return StzReplace(_c_, char(34), char(92) + char(34))
