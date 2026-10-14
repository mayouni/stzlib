#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZVAULTHTTPRESOLVER        #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#
# A REAL vault resolver (threat-model risk R4, 2026-09-29): it satisfies the
# stzVaultResolver contract -- Resolve(locator), Has(locator) -- by speaking
# the Vault HTTP API, which HashiCorp Vault and OpenBao both serve. So a
# :vault-sourced secret, a sealed store's key, anything that reveals through
# RevealVia, now comes from the secret manager itself.
#
#     oToken = StzSecretQ("vault-token").FromEnvQ("VAULT_TOKEN")
#     oVault = StzVaultHttpResolver("https://vault.internal:8200", oToken, oService)
#     oDb    = StzSecretQ("db").FromVaultQ("secret/data/prod/db#password")
#     ? oDb.RevealVia(oVault, oHuman)
#
# A LOCATOR is  <path>#<field>  -- the path after /v1/, then the field of the
# secret. A path holding /data/ is read as KV version 2 (the value sits under
# data.data); any other path as KV version 1 (under data).
#
# WHAT IT REFUSES, by construction:
#   - an http:// address that is not loopback: the token would cross the
#     network in clear. https:// is verified by the HTTP client (curl), and
#     plain http is allowed only to 127.0.0.1, localhost or [::1] -- a local
#     agent or a dev server;
#   - holding the token: the token is itself a stzSecret, revealed through
#     the actor gate FOR EACH REQUEST and never kept in this object;
#   - saying the token: no error message and no event carries it.
#
# The resolver acts as poActor -- the service identity allowed to read the
# token. The actor who asks for a secret is gated separately, by the secret's
# own RevealVia, before the resolver is ever called.

func StzVaultHttpResolver(pcAddress, poTokenSecret, poActor)
	return new stzVaultHttpResolver(pcAddress, poTokenSecret, poActor)


# Resolves vault-sourced secrets from a real HashiCorp Vault or OpenBao server over its HTTP API, without keeping the token.
#
# It satisfies the stzVaultResolver contract, Resolve and Has, so a secret revealed through
# RevealVia, or the key of a sealed store, comes from the secret manager itself. A locator is
# path#field; a path holding /data/ is read as KV version 2, any other as KV version 1. It refuses
# by construction an http address that is not loopback, since the token would cross the network in
# clear, holds the token only as a stzSecret revealed through the actor gate for each request, and
# puts it in no message or event. The actor who asks for a secret is gated separately, by the
# secret's own RevealVia, before the resolver is called. The documentation here was run only against
# a loopback port that never answers, never against a real vault.
#
#   receiver   o1 = new stzVaultHttpResolver("https://vault.internal:8200/", StzSecretQ("vault-
#              token"), HumanActor("svc"))
#   example    ? o1.Address()
#              #--> https://vault.internal:8200
#              ? o1.LastStatus()
#              #--> 0
#              o2 = new stzVaultHttpResolver("http://localhost:8200", StzSecretQ("vault-token"), HumanActor("svc"))
#              ? o2.Address()
#              #--> http://localhost:8200
#   see        stzVaultResolver, stzSecret, stzSecretStore
class stzVaultHttpResolver from stzObject

	@cAddress = ""
	@oToken = ""
	@oActor = ""
	@nTimeoutMs = 5000
	@nLastStatus = 0

	# Builds a resolver for a HashiCorp Vault or OpenBao server, refusing an address over which the token would travel in clear.
	#
	#   pcAddress       the server address, https:// or http:// to 127.0.0.1, localhost or [::1]
	#                   only, with trailing slashes removed
	#   poTokenSecret   a stzSecret holding the token
	#   poActor         the service identity allowed to reveal the token
	#   returns         nothing; the object is built
	#   note            the token is never kept in this object: it is revealed for each request
	#                   through the actor gate
	#   warning         raises an error for any other http address, including lookalikes such as
	#                   http://127.0.0.1.evil.example and http://127.0.0.1@evil.example, and one for
	#                   a token that is not an object
	#   see             Resolve, Has
	def init(pcAddress, poTokenSecret, poActor)
		_c_ = ring_trim("" + pcAddress)
		while StzRight(_c_, 1) = "/"
			_c_ = StzLeft(_c_, len(_c_) - 1)
		end
		if NOT This._AddressIsSafe(_c_)
			stzraise("stzVaultHttpResolver: refused '" + _c_ + "' -- use https://, or plain http:// " +
				"only to a loopback address; a vault token must not cross the network in clear.")
		ok
		if NOT isObject(poTokenSecret)
			stzraise("stzVaultHttpResolver: the token must be a stzSecret (e.g. FromEnvQ(" + char(34) + "VAULT_TOKEN" + char(34) + ")).")
		ok
		@cAddress = _c_
		@oToken = poTokenSecret
		@oActor = poActor

	# Returns the server address in use, trimmed of trailing slashes.
	#
	#   returns    a text
	#   see        init
	def Address()
		return @cAddress

	# Sets how long a request may take before it counts as unanswered.
	#
	#   pnMs       the timeout in milliseconds
	#   returns    the resolver itself, so calls chain
	#   see        LastStatus
	def SetTimeout(pnMs)
		@nTimeoutMs = pnMs
		return This

	# Returns the HTTP status of the last request, for diagnosis.
	#
	#   returns    a number; 0 before any request, and -1 when the server could not be reached or
	#              did not answer in time
	#   see        Resolve, Has
	#@ aka  the HTTP status of the last request (0 = no answer) -- for diagnostics
	def LastStatus()
		return @nLastStatus

	# Reads the field a locator names from the vault, as the vault contract requires, and raises when the value cannot be had.
	#
	#   pcLocator   path#field, the path after /v1/ and then the field
	#   returns     a text, the field's value
	#   note        the token goes in the X-Vault-Token header of one request and appears in no
	#               message or event; not run against a real vault when documented, only against a
	#               loopback port that never answers
	#   warning     raises an error for a locator without a path or a field, for a refusal (403,
	#               noted to the security ledger), for a missing secret (404) and for a missing
	#               field; with no answer it raises Vault answered -1, because the did not answer
	#               message is written for status 0; the locator is appended to the URL as given, so
	#               never build one from untrusted input, and it is quoted in errors without
	#               escaping
	#   see         Has, Address
	#@ aka  -- the contract ------------------------------------------------------
	def Resolve(pcLocator)
		_aL_ = This._Split(pcLocator)
		_aDoc_ = This._Read(_aL_[1])
		_aData_ = This._DataOf(_aL_[1], _aDoc_)
		if NOT HasKey(_aData_, _aL_[2])
			stzraise("Vault: the secret at '" + _aL_[1] + "' has no field '" + _aL_[2] + "'.")
		ok
		return "" + _aData_[_aL_[2]]

	# TRUE if the vault holds the path and the field; a missing secret answers FALSE, while a refusal or an unreachable vault raises.
	#
	#   pcLocator   path#field, as for Resolve
	#   returns     TRUE or FALSE
	#   note        a 404 is the only answer that gives FALSE
	#   warning     raises as Resolve does for a malformed locator, a refusal or no answer, since
	#               cannot tell is not absent
	#   see         Resolve
	#@ aka  1 when the vault holds the path AND the field, 0 otherwise (a refusal or an unreachable vault raises: "cannot tell" is not "absent").
	def Has(pcLocator)
		_aL_ = This._Split(pcLocator)
		_aDoc_ = This._Get(_aL_[1])
		if @nLastStatus = 404
			return 0
		ok
		This._RaiseOnStatus(_aL_[1])
		return HasKey(This._DataOf(_aL_[1], _aDoc_), _aL_[2])

	  #-- internals ---------------------------------------------------------

	def _AddressIsSafe(pcAddr)
		_c_ = StzLower(pcAddr)
		if StzLeft(_c_, 8) = "https://"
			return 1
		ok
		_acLoop_ = [ "http://127.0.0.1", "http://localhost", "http://[::1]" ]
		for _i_ = 1 to 3
			_p_ = _acLoop_[_i_]
			if _c_ = _p_ or StzLeft(_c_, len(_p_) + 1) = _p_ + ":" or StzLeft(_c_, len(_p_) + 1) = _p_ + "/"
				return 1
			ok
		next
		return 0

	# "secret/data/prod/db#password" -> [ "secret/data/prod/db", "password" ]
	def _Split(pcLocator)
		_c_ = "" + pcLocator
		_n_ = StzFindFirst("#", _c_)
		if _n_ = 0 or _n_ = len(_c_)
			stzraise("Vault: a locator is <path>#<field> -- got '" + _c_ + "'.")
		ok
		_cPath_ = StzLeft(_c_, _n_ - 1)
		while StzLeft(_cPath_, 1) = "/"
			_cPath_ = StzMidToEnd(_cPath_, 2)
		end
		return [ _cPath_, StzMidToEnd(_c_, _n_ + 1) ]

	def _Read(pcPath)
		_aDoc_ = This._Get(pcPath)
		This._RaiseOnStatus(pcPath)
		return _aDoc_

	# One GET with the token in X-Vault-Token. The token lives in this call's
	# locals only, for the length of the request.
	def _Get(pcPath)
		_oC_ = new stzHttpClient()
		_oC_.SetRequestTimeout(@nTimeoutMs)
		_oC_.SetHeader("X-Vault-Token", @oToken.Reveal(@oActor))
		_oC_.Get_(@cAddress + "/v1/" + pcPath)
		@nLastStatus = _oC_.ResponseCode()
		_cBody_ = "" + _oC_.ResponseBody()
		_oC_.SetHeader("X-Vault-Token", "")
		if @nLastStatus != 200
			return []
		ok
		return StzJsonToList(_cBody_)

	def _RaiseOnStatus(pcPath)
		if @nLastStatus = 200
			return
		ok
		if @nLastStatus = 403
			StzNoteRefusal("secret.reveal.refused", "" + @oActor.Name(), "vault:" + pcPath,
				"the vault refused the token (403)")
			stzraise("Vault refused access to '" + pcPath + "' (403) -- the token may not read it.")
		but @nLastStatus = 404
			stzraise("Vault: no secret at '" + pcPath + "' (404).")
		but @nLastStatus = 0
			stzraise("Vault did not answer at " + @cAddress + ".")
		ok
		stzraise("Vault answered " + @nLastStatus + " for '" + pcPath + "'.")

	# KV v2 nests the fields under data.data; KV v1 under data.
	def _DataOf(pcPath, paDoc)
		if NOT (isList(paDoc) and HasKey(paDoc, "data"))
			stzraise("Vault: the answer for '" + pcPath + "' is not a secret document.")
		ok
		_aD_ = paDoc["data"]
		if StzFindFirst("/data/", "/" + pcPath) > 0
			if NOT (isList(_aD_) and HasKey(_aD_, "data"))
				stzraise("Vault: '" + pcPath + "' is not a KV version 2 secret.")
			ok
			return _aD_["data"]
		ok
		return _aD_
