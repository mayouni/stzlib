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

# Exports a security ledger to a sealed file under an actor's name and states who exported what, when and how to verify it.
#
# The ledger's hash chain makes the file tamper-evident; the attestation adds the custody statement
# an auditor needs: the attestor, the time, the number of entries, the head of the chain and the key
# kind. Exporting is governed by the sensing capability, so an inference-only actor may analyse an
# incident in the process and may not write the evidence out. Both a refusal and an export are
# recorded as events, so the ledger carries its own custody history. A keyed seal needs the same key
# to verify with StzVerifyAttestation. Use invented keys in examples; real ones belong in a secret
# store.
#
#   receiver   o1 = StzSecurityAttestation("nightly-evidence")
#   example    ? o1.WasWritten()
#              #--> 0
#              ? o1.MayAttest(HumanActor("alice"))
#              #--> 1
#              ? o1.MayAttest(LLMActor("bot"))
#              #--> 0
#              ? o1.Statement()
#              #--> Attestation nightly-evidence: nothing written yet.
#   see        stzSecurityLedger, StzVerifyAttestation, stzSecurityPosture
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

	# Builds a custody statement for exported evidence, with a name and nothing attested yet.
	#
	#   pcName     the attestation's name, quoted in its statement
	#   returns    nothing; the object is built
	#   see        Of, WriteTo
	def init(pcName)
		@cName = "" + pcName

	# Returns the name the attestation was built with.
	#
	#   returns    a text
	#   see        init
	def Name()
		return @cName

	# Chooses the security ledger whose events will be exported.
	#
	#   poLedger   a stzSecurityLedger, such as the process ledger
	#   returns    the attestation itself, so calls chain
	#   note       the ledger is read when WriteTo runs
	#   see        SealedWith, WriteTo
	def Of(poLedger)
		@oLedger = poLedger
		return This

	# Sets the key that seals the exported file with a keyed HMAC-SHA256 over the chain head and the count.
	#
	#   pcKey      the sealing key, held as given
	#   returns    the attestation itself, so calls chain
	#   note       the same key is needed to verify the file
	#   warning    without a key, or with an empty one, the export is sealed with no key: the chain
	#              still detects a changed entry, but anyone can recompute the seal, and Statement
	#              says so
	#   see        WriteTo, StzVerifyAttestation
	def SealedWith(pcKey)
		@cKey = "" + pcKey
		return This

	# TRUE if the actor holds the sensing capability that reading the evidence out requires.
	#
	#   poActor    the actor asking
	#   returns    TRUE or FALSE
	#   note       an inference-only actor, such as an LLM actor, is refused
	#   see        WhyNot, WriteTo
	#@ aka  -- the governed export ------------------------------------------
	def MayAttest(poActor)
		return poActor.Can("sensing")

	# Returns the reason an actor may not export the evidence, an empty text when it may.
	#
	#   poActor    the actor asking
	#   returns    a text
	#   note       the reason names the actor
	#   see        MayAttest
	def WhyNot(poActor)
		if NOT poActor.Can("sensing")
			return "actor '" + poActor.Name() + "' lacks the sensing capability -- " +
				"the ledger names actors, subjects and refusals, and is not readable out by an inference-only actor"
		ok
		return ""

	# Seals the ledger to a file under this actor's name and records the export as an event; a refused actor writes nothing.
	#
	#   pcPath     the file to write
	#   poActor    the actor exporting, which needs the sensing capability
	#   returns    TRUE when the file was written, FALSE when the actor is refused
	#   note       the ledger names actors, subjects and refusals, so the file is sensitive: store
	#              it with care
	#   warning    raises an error telling to say Of first when no ledger was chosen; a refusal is
	#              noted as evidence.export_refused, a success as evidence.exported
	#   see        MayAttest, Statement
	#@ aka  Seal the ledger to a file, attested by this actor. Returns TRUE when written; FALSE (with the refusal recorded) when the actor may not.
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

	# TRUE if a successful export has been made.
	#
	#   returns    TRUE or FALSE
	#   see        WriteTo
	def WasWritten()
		return @bWritten

	# Returns the file the last export was written to.
	#
	#   returns    a text; empty before an export
	#   see        WriteTo
	def Path()
		return @cPath

	# Returns the name of the actor who made the last export.
	#
	#   returns    a text; empty before an export
	#   see        WriteTo
	def Attestor()
		return @cAttestor

	# Returns when the last export was made.
	#
	#   returns    a number, epoch milliseconds on the wall clock; 0 before an export
	#   see        WriteTo
	def AttestedAt()
		return @nAt

	# Returns the digest of the last event exported, the head of the hash chain.
	#
	#   returns    a text of 64 hexadecimal characters; empty before an export
	#   see        EntryCount
	def HeadDigest()
		return @cHead

	# Returns how many events the exported file holds.
	#
	#   returns    a number; 0 before an export
	#   see        HeadDigest
	def EntryCount()
		return @nCount

	# Returns the custody statement a person reads beside the file, as one text with a line per fact.
	#
	#   returns    a multi-line text, or a sentence saying nothing is written yet
	#   see        Explain, Show
	#@ aka  -- the custody statement ----------------------------------------
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

	# Returns the custody statement as a list of lines: file, attestor, time, entries, chain head, seal and how to verify.
	#
	#   returns    a list of text
	#   note       it states that entries are descriptors with no secret value, which holds only for
	#              the values a caller put in an event: a path with a query string, or an actor
	#              name, is recorded as received
	#   see        Statement, Show
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

	# Prints the custody statement, one line per fact.
	#
	#   returns    nothing; it prints
	#   see        Explain
	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next
