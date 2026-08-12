/*
	stzSecurityAttestation -- evidence that leaves the process
	(incident I7).

	I1 made the ledger hash-chained and sealable; that made the file
	tamper-EVIDENT. An attestation adds the part a person or an
	auditor needs: WHO exported it, WHEN, over what range, under
	which key, and how to check it -- a custody statement in the
	tool's own words, next to a file that proves itself.

		oAtt = StzSecurityAttestation("nightly-evidence")
		oAtt.Of(oLedger).SealedWith("the-evidence-key")
		oAtt.WriteTo("evidence.stzledger", oHumanActor)
		? oAtt.Statement()
		StzVerifyAttestation("evidence.stzledger", "the-evidence-key")

	GOVERNED, because the ledger is itself sensitive: it names actors,
	subjects, origins and refusals -- a map of what is worth attacking.
	Exporting it requires the SENSING capability, so an inference-only
	actor (an LLM) may analyze the incident in-process and may NOT
	write the evidence out. Refusals and exports are both recorded as
	events, so the ledger carries its own custody history.

	The redaction law holds here as everywhere: what is exported was
	built from events, and an event carries descriptors, never values.
*/

func StzSecurityAttestation(pcName)
	return new stzSecurityAttestation(pcName)

# Verify an attested file: the chain, the seal, and who attested it.
func StzVerifyAttestation(pcPath, pcKey)
	return StzVerifySealedLedger(pcPath, pcKey)

class stzSecurityAttestation from stzObject

	@cName = ""
	@oLedger = ""
	@cKey = ""
	@cPath = ""
	@cAttestor = ""
	@nAt = 0
	@nCount = 0
	@cHead = ""
	@bWritten = 0

	def init(pcName)
		@cName = "" + pcName

	def Name()
		return @cName

	def Of(poLedger)
		@oLedger = poLedger
		return This

	def SealedWith(pcKey)
		@cKey = "" + pcKey
		return This

	  #-- the governed export ------------------------------------------

	# Reading the evidence out is a SENSING act -- an inference-only
	# actor may not perform it.
	def MayAttest(poActor)
		return poActor.Can("sensing")

	def WhyNot(poActor)
		if NOT poActor.Can("sensing")
			return "actor '" + poActor.Name() + "' lacks the sensing capability -- " +
				"the ledger names actors, subjects and refusals, and is not readable out by an inference-only actor"
		ok
		return ""

	# Seal the ledger to a file, attested by this actor. Returns TRUE
	# when written; FALSE (with the refusal recorded) when the actor
	# may not.
	def WriteTo(pcPath, poActor)
		if @oLedger = ""
			stzraise("stzSecurityAttestation '" + @cName + "': nothing to attest -- say Of(oLedger) first.")
		ok
		if NOT This.MayAttest(poActor)
			StzNoteRefusal("evidence.export_refused", "" + poActor.Name(),
				"file:" + pcPath, This.WhyNot(poActor))
			return 0
		ok
		@cPath = "" + pcPath
		@cAttestor = "" + poActor.Name()
		@nAt = StzEngineTimeWallMs()
		@nCount = @oLedger.Size()
		@cHead = @oLedger.Digest()
		@oLedger.SealAttestedTo(@cPath, @cKey, @cAttestor)
		# the export is itself part of the story
		StzNoteGrant("evidence.exported", @cAttestor, "file:" + @cPath)
		@bWritten = 1
		return 1

	def WasWritten()
		return @bWritten

	def Path()
		return @cPath

	def Attestor()
		return @cAttestor

	def AttestedAt()
		return @nAt

	def HeadDigest()
		return @cHead

	def EntryCount()
		return @nCount

	  #-- the custody statement ----------------------------------------

	# What a person (or an auditor) reads beside the file.
	def Statement()
		if NOT @bWritten
			return "Attestation " + @cName + ": nothing written yet."
		ok
		_aL_ = This.Explain()
		_c_ = ""
		_n_ = ring_len(_aL_)
		for _i_ = 1 to _n_
			_c_ += (_aL_[_i_] + Char(10))
		next
		return _c_

	def Explain()
		_aL_ = []
		if NOT @bWritten
			_aL_ + ("Attestation " + @cName + " -- nothing written yet.")
			return _aL_
		ok
		_aL_ + ("Attestation " + @cName)
		_aL_ + ("  file      : " + @cPath)
		_aL_ + ("  attestor  : " + @cAttestor)
		_aL_ + ("  at        : " + @nAt + " (epoch ms, wall)")
		_aL_ + ("  entries   : " + @nCount)
		_aL_ + ("  chain head: " + @cHead)
		_cSealed_ = "keyed HMAC-SHA256 over (head digest | count)"
		if @cKey = ""
			_cSealed_ = "UNKEYED -- the chain is verifiable, the seal is not"
		ok
		_aL_ + ("  seal      : " + _cSealed_)
		_aL_ + "  verify    : StzVerifyAttestation(path, key) -- recomputes"
		_aL_ + "              sha256(prev|record) down the file and names the"
		_aL_ + "              first broken link, then checks the seal."
		_aL_ + "  note      : entries are DESCRIPTORS -- no secret value is"
		_aL_ + "              present in this evidence by construction."
		return _aL_

	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next
