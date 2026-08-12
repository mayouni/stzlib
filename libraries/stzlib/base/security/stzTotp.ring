#================================================================#
#  STZTOTP -- RFC 6238 time-based one-time passwords (2FA)         #
#================================================================#

/*--- A real authenticator-app second factor, engine-backed.

TOTP (RFC 6238) is an HMAC over a time counter. The HMAC + RFC 4226 truncation
live in the Zig engine (StzEngineCryptoTotp: a HEX key in, decimal digits out --
so no raw key bytes ever cross the Ring<->engine text boundary, which validates
UTF-8 and would mangle them). This class owns the human-facing parts: a base32
shared secret, the otpauth:// provisioning URI an authenticator app scans, and
verification across a small clock-skew window.

    oTotp = new stzTotp()                          # a fresh 160-bit secret
    cUri  = oTotp.ProvisioningUri("alice", "Softanza")
    #   otpauth://totp/Softanza:alice?secret=...&issuer=Softanza&algorithm=SHA1...
    #   -> render as a QR code; the user scans it into Google Authenticator / Authy
    oTotp.Verify("492039")                         # TRUE within the skew window

The defaults -- SHA1, 6 digits, 30-second period -- are exactly what Google
Authenticator, Authy, 1Password, FreeOTP and every mainstream app expect. SHA256
is available (SetAlgo(2)) for apps that honour the algorithm parameter.

The secret is base32 (RFC 4648, unpadded, upper-case): what a user types into an
app for manual entry. Internally it is decoded to hex for the engine call. Base32
and hex are ASCII, so the conversions are pure Ring -- no byte/codepoint hazard.
*/

func StzTotpQ()
	return new stzTotp()

# wrap an EXISTING base32 secret (e.g. one loaded from the auth store).
func StzTotpFromSecretQ(pcSecretBase32)
	_o_ = new stzTotp()
	_o_.SetSecretQ(pcSecretBase32)
	return _o_


class stzTotp from stzObject

	@cSecret = ""      # the shared secret, base32 (RFC 4648, unpadded, upper-case)
	@nDigits = 6       # code length (6 is the app default; 1..9 allowed)
	@nPeriod = 30      # seconds per step
	@nAlgo   = 1       # 1 = SHA1 (app default), 2 = SHA256
	@nSkew   = 1       # accept a code from +/- this many steps (clock drift)

	# a brand-new random secret (160-bit -- one SHA1 block, RFC-recommended size).
	def init()
		This.GenerateQ()

	  #-- configuration (plain + Q twins) ---------------------------------

	# replace the secret with a fresh random one.
	def Generate()
		This.GenerateQ()

	def GenerateQ()
		@cSecret = This._HexToBase32(StzEngineCryptoRandomHex(20))
		return This

	def SetSecret(pcBase32)
		This.SetSecretQ(pcBase32)

	def SetSecretQ(pcBase32)
		@cSecret = This._NormalizeSecret(pcBase32)
		return This

	def SetDigits(pnDigits)
		This.SetDigitsQ(pnDigits)

	def SetDigitsQ(pnDigits)
		if pnDigits < 1 or pnDigits > 9
			StzRaise("stzTotp: digits must be 1..9.")
		ok
		@nDigits = pnDigits
		return This

	def SetPeriod(pnSeconds)
		This.SetPeriodQ(pnSeconds)

	def SetPeriodQ(pnSeconds)
		if pnSeconds < 1
			StzRaise("stzTotp: period must be >= 1 second.")
		ok
		@nPeriod = pnSeconds
		return This

	def SetSkew(pnSteps)
		This.SetSkewQ(pnSteps)

	def SetSkewQ(pnSteps)
		if pnSteps < 0
			StzRaise("stzTotp: skew must be >= 0.")
		ok
		@nSkew = pnSteps
		return This

	# 1 = SHA1 (default, universal app support), 2 = SHA256.
	def SetAlgo(pnAlgo)
		This.SetAlgoQ(pnAlgo)

	def SetAlgoQ(pnAlgo)
		if pnAlgo != 1 and pnAlgo != 2
			StzRaise("stzTotp: algo must be 1 (SHA1) or 2 (SHA256).")
		ok
		@nAlgo = pnAlgo
		return This

	  #-- read-out (data methods) -----------------------------------------

	def Secret()
		return @cSecret

	def Digits()
		return @nDigits

	def Period()
		return @nPeriod

	def Skew()
		return @nSkew

	def Algo()
		return @nAlgo

	def AlgorithmName()
		if @nAlgo = 2
			return "SHA256"
		ok
		return "SHA1"

	# the otpauth:// URI an authenticator app consumes (usually via a QR code).
	# LABEL is issuer:account; the issuer is repeated as a query parameter, per
	# the Key-Uri spec, so apps that read either place show the right name.
	def ProvisioningUri(pcAccount, pcIssuer)
		_label_ = This._UriEnc("" + pcIssuer) + ":" + This._UriEnc("" + pcAccount)
		return "otpauth://totp/" + _label_ +
		       "?secret=" + @cSecret +
		       "&issuer=" + This._UriEnc("" + pcIssuer) +
		       "&algorithm=" + This.AlgorithmName() +
		       "&digits=" + @nDigits +
		       "&period=" + @nPeriod

	  #-- codes -----------------------------------------------------------

	# the code valid at an explicit wall-clock instant (epoch seconds).
	def CodeAt(pnUnixSecs)
		_counter_ = floor(pnUnixSecs / @nPeriod)
		return StzEngineCryptoTotp(This._Base32ToHex(@cSecret), _counter_, @nDigits, @nAlgo)

	# the code valid right now.
	def Code()
		return This.CodeAt(This._NowSecs())

	# verify a submitted code against now, tolerating +/- @nSkew steps of drift.
	def Verify(pcCode)
		return This.VerifyAt(pcCode, This._NowSecs())

	# deterministic verify against an explicit instant (for tests + the auth layer).
	def VerifyAt(pcCode, pnUnixSecs)
		_sub_ = ring_trim("" + pcCode)
		if _sub_ = ""
			return 0
		ok
		_counter_ = floor(pnUnixSecs / @nPeriod)
		_hex_ = This._Base32ToHex(@cSecret)
		_s_ = -@nSkew
		while _s_ <= @nSkew
			_c_ = StzEngineCryptoTotp(_hex_, _counter_ + _s_, @nDigits, @nAlgo)
			if StzEngineCryptoConstEqual(_sub_, _c_) = 1   # constant-time compare
				return 1
			ok
			_s_++
		end
		return 0

	def Show()
		? "stzTotp(" + This.AlgorithmName() + ", " + @nDigits + " digits, " +
		  @nPeriod + "s) secret=" + @cSecret

	  #==== internals =====================================================

	# wall-clock now in epoch SECONDS (StzEngineTimeNowMs is epoch milliseconds;
	# StzEngineTimeNow() is unusable -- returns 1).
	def _NowSecs()
		return floor(StzEngineTimeNowMs() / 1000)

	# accept a user-typed secret: strip spaces, upper-case (base32 is ASCII).
	def _NormalizeSecret(pcBase32)
		_s_ = ring_trim("" + pcBase32)
		_out_ = ""
		_n_ = len(_s_)
		for _i_ = 1 to _n_
			_a_ = ascii(_s_[_i_])
			if _a_ = 32 or _a_ = 45      # skip spaces and dashes
				loop
			ok
			if _a_ >= 97 and _a_ <= 122  # lower -> upper
				_a_ = _a_ - 32
			ok
			_out_ += char(_a_)
		next
		return _out_

	  #-- base32 <-> hex (RFC 4648; pure ASCII, so pure Ring) --------------

	# hex string -> base32 (unpadded, upper-case).
	def _HexToBase32(pcHex)
		_out_ = ""
		_buf_ = 0
		_bits_ = 0
		_n_ = len(pcHex)
		_i_ = 1
		while _i_ + 1 <= _n_
			_byte_ = This._HexVal(pcHex[_i_]) * 16 + This._HexVal(pcHex[_i_ + 1])
			_buf_ = (_buf_ << 8) | _byte_
			_bits_ += 8
			while _bits_ >= 5
				_bits_ -= 5
				_out_ += This._B32Char((_buf_ >> _bits_) & 31)
			end
			_buf_ = _buf_ & ((1 << _bits_) - 1)   # keep only the pending bits
			_i_ += 2
		end
		if _bits_ > 0
			_out_ += This._B32Char((_buf_ << (5 - _bits_)) & 31)
		ok
		return _out_

	# base32 -> hex string (lower-case).
	def _Base32ToHex(pcB32)
		_buf_ = 0
		_bits_ = 0
		_out_ = ""
		_n_ = len(pcB32)
		for _i_ = 1 to _n_
			_v_ = This._B32Val(pcB32[_i_])
			if _v_ < 0
				loop                       # skip padding / stray characters
			ok
			_buf_ = (_buf_ << 5) | _v_
			_bits_ += 5
			while _bits_ >= 8
				_bits_ -= 8
				_out_ += This._ByteToHex((_buf_ >> _bits_) & 255)
			end
			_buf_ = _buf_ & ((1 << _bits_) - 1)
		next
		return _out_

	# 0..31 -> a base32 alphabet character (A-Z, then 2-7).
	def _B32Char(pnIdx)
		if pnIdx < 26
			return char(65 + pnIdx)        # A-Z
		ok
		return char(50 + (pnIdx - 26))     # 2-7

	# a base32 character -> 0..31 (case-insensitive), or -1 if not in the alphabet.
	def _B32Val(pcChar)
		_a_ = ascii(pcChar)
		if _a_ >= 65 and _a_ <= 90   return _a_ - 65 ok        # A-Z
		if _a_ >= 97 and _a_ <= 122  return _a_ - 97 ok        # a-z
		if _a_ >= 50 and _a_ <= 55   return _a_ - 50 + 26 ok   # 2-7
		return -1

	# a hex character -> 0..15 (0 for anything invalid).
	def _HexVal(pcChar)
		_a_ = ascii(pcChar)
		if _a_ >= 48 and _a_ <= 57    return _a_ - 48 ok       # 0-9
		if _a_ >= 97 and _a_ <= 102   return _a_ - 97 + 10 ok  # a-f
		if _a_ >= 65 and _a_ <= 70    return _a_ - 65 + 10 ok  # A-F
		return 0

	# a byte 0..255 -> two lower-case hex characters.
	def _ByteToHex(pnByte)
		_h_ = "0123456789abcdef"
		return _h_[((pnByte >> 4) & 15) + 1] + _h_[(pnByte & 15) + 1]

	# minimal percent-encoding for otpauth labels/params (unreserved set passes).
	def _UriEnc(pcS)
		_out_ = ""
		_n_ = len(pcS)
		for _i_ = 1 to _n_
			_c_ = pcS[_i_]
			_a_ = ascii(_c_)
			if (_a_ >= 48 and _a_ <= 57) or (_a_ >= 65 and _a_ <= 90) or
			   (_a_ >= 97 and _a_ <= 122) or _c_ = "-" or _c_ = "." or _c_ = "_" or _c_ = "~"
				_out_ += _c_
			else
				_h_ = "0123456789ABCDEF"
				_out_ += "%" + _h_[((_a_ >> 4) & 15) + 1] + _h_[(_a_ & 15) + 1]
			ok
		next
		return _out_
