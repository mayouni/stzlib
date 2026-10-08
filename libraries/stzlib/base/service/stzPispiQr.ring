# stzPispiQr -- the PI-SPI interoperable QR payload, built and read.
#
# WHAT THIS IS. A QR code on a shop counter or a till screen is a PICTURE of a short string, and the
# string is what the BCEAO published: an EMV merchant-presented payload, scheme `int.bceao.pi`, whose
# one account is the receiver's PI-SPI alias. This file builds and reads THE STRING. The picture --
# the black and white matrix a phone's camera reads -- is a different layer (ISO/IEC 18004: Reed-Solomon
# and masks), it is generic, and it is not here: see SOFTANZA_PAYMENTS_PORT.md section 9c.
#
# READ, NEVER GUESSED. The format was read on 2026-10-05 from the BCEAO's published payload builder
# (the demo page of the PI-SPI portal, and the @pi-spi/qrcode SDK of the same format, MIT) and from the
# PHP port that tests itself against the BCEAO's worked example. No code was copied: the builder below
# was written from the tag table, and its CRC is checked against an independent implementation
# (Python's CRC-16/CCITT-FALSE) by the guard.
#
#   00 02 "01"                                  payload format indicator
#   36 ..  { 00 "int.bceao.pi" , 01 <alias> }   the merchant account: the receiver's alias
#   52 04 "0000"                                merchant category code
#   53 03 "952"                                 XOF, the only currency
#   54 ..  <whole francs, digits only>          optional: absent means the payer types the amount
#   58 02 <country>                             BJ BF CI GW ML NE SN TG
#   59 01 "X" , 60 01 "X"                       merchant name and city, fixed by the format
#   62 ..  { 05 <reference label, at most 25> , 11 <channel> , 12 <purpose, optional> , <custom> }
#   63 04 <CRC-16/CCITT-FALSE of everything before, tag and length of 63 included>
#
# The channel is 000 for a static QR (one code, many payments, the payer types the amount unless it is
# fixed) and 400 for a dynamic QR (made for ONE sale). 731 is the channel of a transfer QR presented by
# the PAYER, which a platform reads and does not make; the BCEAO's own worked example carries 500, a
# value its portal never lists. The reader reports an unlisted channel and does not refuse it.
#
# DIVERGENCES, filed and not settled here (SOFTANZA_PAYMENTS_PORT.md section 11):
#   - the BCEAO's builder emits NO tag 01 (point of initiation, 11 static / 12 dynamic) while the
#     validator's placeholder on the same portal starts 000201 0102 11. The builder follows the SDK;
#     the reader accepts tag 01 when present.
#   - the prose calls the alias alphanumeric and the SDK requires a UUID v4. The builder requires the
#     UUID SHAPE (36 characters, hyphens at 9, 14, 19, 24, hexadecimal elsewhere) and not the version.
#
# WHAT IT REFUSES, so a bad code is never printed: an alias that is not a UUID shape, a country outside
# the union, an amount that is not whole positive francs of at most 13 digits or is not in XOF, a label
# longer than 25 characters, a character outside printable ASCII (the length of a TLV value is a
# count of characters and the BCEAO's builder counts UTF-16 units: ASCII is the one place they agree),
# and a payload whose CRC is wrong.
#
# THE CRC is computed here in Ring over at most a couple of hundred bytes: it is a checksum of a
# payload and not cryptography, and it is not a hot path. If the engine ever grows a crc16 seam this
# is the one place to call it.

$aStzPispiQrCountries = [ "BJ", "BF", "CI", "GW", "ML", "NE", "SN", "TG" ]

# CRC-16/CCITT-FALSE: polynomial 0x1021, initial 0xFFFF, no reflection, no final xor
func StzPispiQrCrc16(pcData)
	_nCrc_ = 65535
	_nLen_ = ring_len(pcData)
	for _i_ = 1 to _nLen_
		_nCrc_ = _nCrc_ ^ (ascii(pcData[_i_]) << 8)
		for _b_ = 1 to 8
			if (_nCrc_ & 32768) != 0
				_nCrc_ = ((_nCrc_ << 1) ^ 4129) & 65535
			else
				_nCrc_ = (_nCrc_ << 1) & 65535
			ok
		next
	next
	_cHex_ = upper(hex(_nCrc_))
	while ring_len(_cHex_) < 4
		_cHex_ = "0" + _cHex_
	end
	return _cHex_

# one TLV segment: id, two-digit length, value
func _StzPispiQrTlv(pcId, pcValue)
	_cLen_ = "" + ring_len(pcValue)
	if ring_len(_cLen_) < 2
		_cLen_ = "0" + _cLen_
	ok
	return pcId + _cLen_ + pcValue

# a custom tag is two digits or capitals. The BCEAO's builder also takes lower case and orders the tags
# with a locale-aware comparison, which is not the byte order for mixed case: digits and capitals are the
# one alphabet where the two orders agree, so that is the alphabet offered.
func _StzPispiQrIsTagChar(pcChar)
	return substr("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", pcChar) > 0

# true when every character is printable ASCII
func _StzPispiQrIsPrintableAscii(pcValue)
	_nLen_ = ring_len(pcValue)
	for _i_ = 1 to _nLen_
		_n_ = ascii(pcValue[_i_])
		if _n_ < 32 or _n_ > 126
			return 0
		ok
	next
	return 1

# the shape of a UUID: 36 characters, hyphens at 9, 14, 19 and 24, hexadecimal elsewhere
func _StzPispiQrIsUuidShape(pcAlias)
	if ring_len(pcAlias) != 36
		return 0
	ok
	for _i_ = 1 to 36
		_c_ = lower(pcAlias[_i_])
		if _i_ = 9 or _i_ = 14 or _i_ = 19 or _i_ = 24
			if _c_ != "-"
				return 0
			ok
		else
			if substr("0123456789abcdef", _c_) = 0
				return 0
			ok
		ok
	next
	return 1

# walks one level of TLV: [ [ id, value ], ... ], or the string "malformed: ..." when it does not close
func _StzPispiQrSegments(pcPayload)
	_aOut_ = []
	_nLen_ = ring_len(pcPayload)
	_i_ = 1
	while _i_ <= _nLen_
		if _i_ + 3 > _nLen_
			return "malformed: a segment header is cut short at character " + _i_
		ok
		_cId_ = pcPayload[_i_] + pcPayload[_i_ + 1]
		_cLenText_ = pcPayload[_i_ + 2] + pcPayload[_i_ + 3]
		if not (isdigit(pcPayload[_i_ + 2]) and isdigit(pcPayload[_i_ + 3]))
			return "malformed: the length of segment " + _cId_ + " is not two digits"
		ok
		_nValLen_ = 0 + _cLenText_
		_nFrom_ = _i_ + 4
		if _nFrom_ + _nValLen_ - 1 > _nLen_
			return "malformed: segment " + _cId_ + " claims " + _nValLen_ + " characters and the payload ends first"
		ok
		_cVal_ = ""
		for _j_ = _nFrom_ to _nFrom_ + _nValLen_ - 1
			_cVal_ += pcPayload[_j_]
		next
		_aOut_ + [ _cId_, _cVal_ ]
		_i_ = _nFrom_ + _nValLen_
	end
	return _aOut_

func _StzPispiQrSegmentValue(paSegments, pcId)
	_n_ = len(paSegments)
	for _i_ = 1 to _n_
		if paSegments[_i_][1] = pcId
			return paSegments[_i_][2]
		ok
	next
	return ""

func _StzPispiQrHasSegment(paSegments, pcId)
	_n_ = len(paSegments)
	for _i_ = 1 to _n_
		if paSegments[_i_][1] = pcId
			return 1
		ok
	next
	return 0

# reads a payload: [ :valid, :errors, :notes, :data ]. It never raises on a bad payload: it says what is wrong.
func StzPispiQrParse(pcPayload)
	_aErr_ = []
	_aNotes_ = []
	_aData_ = []
	_cPayload_ = "" + pcPayload
	if _cPayload_ = "" or not _StzPispiQrIsPrintableAscii(_cPayload_)
		return [ [ "valid", 0 ], [ "errors", [ "the payload is empty or holds a character outside printable ASCII" ] ], [ "notes", [] ], [ "data", [] ] ]
	ok
	_aTop_ = _StzPispiQrSegments(_cPayload_)
	if isString(_aTop_)
		return [ [ "valid", 0 ], [ "errors", [ _aTop_ ] ], [ "notes", [] ], [ "data", [] ] ]
	ok
	if _StzPispiQrSegmentValue(_aTop_, "00") != "01"
		_aErr_ + "tag 00 (payload format indicator) is missing or is not 01"
	ok

	# the CRC covers everything up to and including "6304"
	_cCrc_ = _StzPispiQrSegmentValue(_aTop_, "63")
	if _cCrc_ = ""
		_aErr_ + "tag 63 (CRC) is missing"
	else
		_nAt_ = ring_len(_cPayload_) - 4
		_cBody_ = ""
		for _i_ = 1 to _nAt_
			_cBody_ += _cPayload_[_i_]
		next
		if ring_len(_cCrc_) != 4 or upper(_cCrc_) != StzPispiQrCrc16(_cBody_)
			_aErr_ + "the CRC does not match the payload"
		ok
	ok

	# the account
	_cAlias_ = ""
	_cAcct_ = _StzPispiQrSegmentValue(_aTop_, "36")
	if _cAcct_ = ""
		_aErr_ + "tag 36 (merchant account) is missing"
	else
		_aIn_ = _StzPispiQrSegments(_cAcct_)
		if isString(_aIn_)
			_aErr_ + ("tag 36: " + _aIn_)
		else
			if _StzPispiQrSegmentValue(_aIn_, "00") != "int.bceao.pi"
				_aErr_ + "tag 36 does not name the scheme int.bceao.pi"
			ok
			_cAlias_ = _StzPispiQrSegmentValue(_aIn_, "01")
			if not _StzPispiQrIsUuidShape(_cAlias_)
				_aErr_ + "the alias (36-01) is not 36 characters in the shape of a UUID"
			ok
		ok
	ok

	if _StzPispiQrSegmentValue(_aTop_, "53") != "952"
		_aErr_ + "tag 53 (currency) is missing or is not 952 (XOF)"
	ok
	_cCountry_ = _StzPispiQrSegmentValue(_aTop_, "58")
	_bUnion_ = 0
	for _i_ = 1 to len($aStzPispiQrCountries)
		if $aStzPispiQrCountries[_i_] = _cCountry_
			_bUnion_ = 1
		ok
	next
	if not _bUnion_
		_aErr_ + "tag 58 (country) is missing or is not a member of the union"
	ok
	_cAmount_ = _StzPispiQrSegmentValue(_aTop_, "54")
	if _cAmount_ != ""
		_bDigits_ = 1
		for _i_ = 1 to ring_len(_cAmount_)
			if not isdigit(_cAmount_[_i_])
				_bDigits_ = 0
			ok
		next
		if not _bDigits_ or ring_len(_cAmount_) > 13
			_aErr_ + "tag 54 (amount) is not whole francs of at most 13 digits"
		ok
	ok

	# the point of initiation is not in the BCEAO's builder and is in its validator's placeholder: accept it
	if _StzPispiQrHasSegment(_aTop_, "01")
		_aNotes_ + "tag 01 (point of initiation) is present; the BCEAO's own builder does not emit it"
	ok

	# the additional data
	_cLabel_ = ""
	_cChannel_ = ""
	_cPurpose_ = ""
	_cAdd_ = _StzPispiQrSegmentValue(_aTop_, "62")
	if _cAdd_ = ""
		_aErr_ + "tag 62 (additional data) is missing"
	else
		_aAd_ = _StzPispiQrSegments(_cAdd_)
		if isString(_aAd_)
			_aErr_ + ("tag 62: " + _aAd_)
		else
			_cLabel_ = _StzPispiQrSegmentValue(_aAd_, "05")
			_cChannel_ = _StzPispiQrSegmentValue(_aAd_, "11")
			_cPurpose_ = _StzPispiQrSegmentValue(_aAd_, "12")
			if _cLabel_ = ""
				_aErr_ + "tag 62-05 (reference label) is missing"
			ok
			if ring_len(_cLabel_) > 25
				_aErr_ + "tag 62-05 (reference label) is longer than 25 characters"
			ok
			if _cChannel_ = ""
				_aErr_ + "tag 62-11 (merchant channel) is missing"
			but _cChannel_ != "000" and _cChannel_ != "400"
				if _cChannel_ = "731"
					_aNotes_ + "channel 731: a transfer QR presented by the payer, which a platform reads and does not make"
				else
					_aNotes_ + ("channel " + _cChannel_ + " is not one the BCEAO's portal lists (000, 400, 731)")
				ok
			ok
		ok
	ok

	_cType_ = "OTHER"
	if _cChannel_ = "000"
		_cType_ = "STATIC"
	but _cChannel_ = "400"
		_cType_ = "DYNAMIC"
	ok
	_aData_ = [ [ "alias", _cAlias_ ], [ "countryCode", _cCountry_ ], [ "qrType", _cType_ ], [ "amount", _cAmount_ ],
	            [ "referenceLabel", _cLabel_ ], [ "merchantChannel", _cChannel_ ], [ "purpose", _cPurpose_ ] ]
	_bValid_ = 0
	if len(_aErr_) = 0
		_bValid_ = 1
	ok
	return [ [ "valid", _bValid_ ], [ "errors", _aErr_ ], [ "notes", _aNotes_ ], [ "data", _aData_ ] ]

func StzPispiQrQ()
	return new stzPispiQr

# Builds the PI-SPI interoperable QR payload, the short text a camera reads, and refuses to build one that would print wrong.
#
# The library builds the QR STRING and does not draw the picture, and no QR it made has been scanned
# by any wallet or bank app: the black and white matrix a phone's camera reads is a second step this
# library does not do, so hand the string to a QR-drawing component of your front end. The string
# follows the BCEAO's published merchant-presented format: the receiver's PI-SPI alias, the currency
# XOF, an optional whole-franc amount, a country of the union, a reference label of at most 25
# characters and a checksum. A static code serves many payments and a dynamic code one sale. The
# builder refuses a bad alias, country, label or amount when the payload is asked for, and
# StzPispiQrParse reads a string back without raising and says what is wrong. It is a builder, not a
# payment: the payer's banking application makes an ordinary payment to the alias. The checksum
# matches an independent implementation, which proves the string is well formed and nothing about a
# scan.
#
#   receiver   o1 = StzPispiQrQ()
#   example    o1.WithAlias("9b1b3499-3e50-435b-b757-ac7a83d8aa96").InCountry("NE").AsDynamic()
#              o1.WithReference("APP-2026-000002").WithAmount(StzAmountQ("18500", "XOF"))
#              cQr = o1.Payload()
#              ? StzPispiQrParse(cQr)[:valid]
#              #--> 1
#              ? StzPispiQrParse(cQr)[:data][:amount]
#              #--> 18500
#              ? StzPispiQrParse("0002010102126304BEEF")[:valid]
#              #--> 0
#   see        stzAmount, stzPiSpiSandbox, stzPaymentsPort
class stzPispiQr

	@cAlias = ""
	@cCountry = ""
	@cChannel = ""
	@cLabel = ""
	@cAmount = ""
	@cPurpose = ""
	@aCustom = []

	# Sets the PI-SPI alias of the receiver, the one account the code pays.
	#
	#   pcAlias    the receiver's PI-SPI alias, a UUID of 36 characters such as the twin's
	#              BusinessAlias()
	#   returns    the builder itself, so calls chain
	#   note       the UUID shape is checked, not the version
	#   warning    an alias that is not in the shape of a UUID is not refused here but when Payload
	#              is asked for
	#   see        InCountry, Payload
	#@ aka  -- who is paid ---------------------------------------------------
	def WithAlias(pcAlias)
		@cAlias = "" + pcAlias
		return This

	# Sets the country of the receiver, in capitals whatever case is given.
	#
	#   pcCountry   the country code, one of BJ BF CI GW ML NE SN TG
	#   returns     the builder itself, so calls chain
	#   warning     a country outside the union is not refused here but when Payload is asked for
	#   see         WithAlias, Payload
	#@ aka  the country of the receiver, one of BJ BF CI GW ML NE SN TG
	def InCountry(pcCountry)
		@cCountry = upper("" + pcCountry)
		return This

	# Makes the code a static one, printed once and read for many payments, with channel 000.
	#
	#   returns    the builder itself, so calls chain
	#   note       in a static code the payer types the amount unless WithAmount fixes it; the last
	#              of AsStatic and AsDynamic called wins
	#   see        AsDynamic, WithAmount
	#@ aka  -- what kind of code ---------------------------------------------
	def AsStatic()
		@cChannel = "000"
		return This

	# Makes the code a dynamic one, made for one sale, with channel 400.
	#
	#   returns    the builder itself, so calls chain
	#   note       the last of AsStatic and AsDynamic called wins
	#   see        AsStatic, WithAmount
	#@ aka  a code made for ONE sale: channel 400
	def AsDynamic()
		@cChannel = "400"
		return This

	# Sets the label the payer's application shows and the receiver reconciles the payment on.
	#
	#   pcLabel    the reference label, 1 to 25 printable ASCII characters
	#   returns    the builder itself, so calls chain
	#   note       the payment received carries it as its motif
	#   warning    a label that is empty, over 25 characters or outside printable ASCII is not
	#              refused here but when Payload is asked for
	#   see        WithAlias, Payload
	#@ aka  -- what it asks -----------------------------------------------------
	def WithReference(pcLabel)
		@cLabel = "" + pcLabel
		return This

	# Fixes the amount the payer is asked for, which must be whole francs in XOF.
	#
	#   poAmount   the stzAmount to ask for, in XOF, above zero and of at most 13 digits
	#   returns    the builder itself, so calls chain
	#   warning    raises an error at once for an amount in another currency or an amount that is
	#              not above zero; without it the payer types the amount
	#   see        AsDynamic, Payload
	#@ aka  a fixed amount, as an amount that carries its currency: XOF, whole francs, at most 13 digits
	def WithAmount(poAmount)
		if poAmount.Currency() != "XOF"
			StzRaise("stzPispiQr: the interoperable QR is in XOF only, this amount is in " + poAmount.Currency())
		ok
		_n_ = poAmount.MinorUnits()
		if _n_ <= 0
			StzRaise("stzPispiQr: a QR amount is a positive number of francs")
		ok
		@cAmount = "" + _n_
		return This

	# Sets the optional purpose text carried in the additional data of the code.
	#
	#   pcPurpose   the purpose, in printable ASCII
	#   returns     the builder itself, so calls chain
	#   warning     a purpose outside printable ASCII is not refused here but when Payload is asked
	#               for
	#   see         WithReference, WithCustom
	def WithPurpose(pcPurpose)
		@cPurpose = "" + pcPurpose
		return This

	# Adds an additional-data tag of the receiver's own to the code.
	#
	#   pcTag      the tag, exactly two characters, digits or capital letters
	#   pcValue    the tag's value, as text
	#   returns    the builder itself, so calls chain
	#   note       the receiver's tags are written after the standard ones, in the order of their
	#              names
	#   warning    a tag that is not two characters of digits or capital letters is not refused here
	#              but when Payload is asked for
	#   see        WithPurpose, Payload
	#@ aka  an additional-data tag of the receiver's own: two characters, digits or capital letters
	def WithCustom(pcTag, pcValue)
		@aCustom + [ "" + pcTag, "" + pcValue ]
		return This

	# Returns the QR string, whose last four characters are its checksum, after refusing any value that would print a bad code.
	#
	#   returns    a text: the payload string, not a picture
	#   note       the library builds this string and does not draw the picture, and no code it made
	#              has been scanned by any wallet or bank app: StzPispiQrParse reads it back and
	#              checks the checksum, which proves the string is well formed and not that a phone
	#              accepts it
	#   warning    raises an error naming the cause when AsStatic or AsDynamic was not called, or
	#              the alias is not a UUID shape, or the country is outside the union, or the label
	#              is missing, over 25 characters or not printable ASCII, or a custom tag is
	#              malformed, or the amount has more than 13 digits
	#   see        StzPispiQrParse, WithReference
	#@ aka  -- the string ---------------------------------------------------------
	def Payload()
		if @cChannel = ""
			StzRaise("stzPispiQr: say AsStatic() or AsDynamic() before asking for the payload")
		ok
		if not _StzPispiQrIsUuidShape(@cAlias)
			StzRaise("stzPispiQr: the alias must be 36 characters in the shape of a UUID, got '" + @cAlias + "'")
		ok
		_bUnion_ = 0
		for _i_ = 1 to len($aStzPispiQrCountries)
			if $aStzPispiQrCountries[_i_] = @cCountry
				_bUnion_ = 1
			ok
		next
		if not _bUnion_
			StzRaise("stzPispiQr: the country must be one of BJ BF CI GW ML NE SN TG, got '" + @cCountry + "'")
		ok
		if @cLabel = ""
			StzRaise("stzPispiQr: a reference label is required: it is what the payer sees and the receiver reconciles on")
		ok
		if ring_len(@cLabel) > 25
			StzRaise("stzPispiQr: the reference label is at most 25 characters, got " + ring_len(@cLabel))
		ok
		if not _StzPispiQrIsPrintableAscii(@cLabel) or not _StzPispiQrIsPrintableAscii(@cPurpose)
			StzRaise("stzPispiQr: a label and a purpose are printable ASCII: the length of a TLV value counts characters")
		ok
		if ring_len(@cAmount) > 13
			StzRaise("stzPispiQr: an amount is at most 13 digits")
		ok

		_cAcct_ = _StzPispiQrTlv("00", "int.bceao.pi") + _StzPispiQrTlv("01", @cAlias)
		_cBody_ = _StzPispiQrTlv("00", "01") + _StzPispiQrTlv("36", _cAcct_) + _StzPispiQrTlv("52", "0000") + _StzPispiQrTlv("53", "952")
		if @cAmount != ""
			_cBody_ += _StzPispiQrTlv("54", @cAmount)
		ok
		_cBody_ += _StzPispiQrTlv("58", @cCountry) + _StzPispiQrTlv("59", "X") + _StzPispiQrTlv("60", "X")

		_cAdd_ = _StzPispiQrTlv("05", @cLabel) + _StzPispiQrTlv("11", @cChannel)
		if @cPurpose != ""
			_cAdd_ += _StzPispiQrTlv("12", @cPurpose)
		ok
		# the receiver's own tags, in the order of their names
		_aTags_ = []
		for _i_ = 1 to len(@aCustom)
			_cTag_ = @aCustom[_i_][1]
			if ring_len(_cTag_) != 2 or not (_StzPispiQrIsTagChar(_cTag_[1]) and _StzPispiQrIsTagChar(_cTag_[2]))
				StzRaise("stzPispiQr: an additional-data tag is exactly two characters, digits or capital letters, got '" + _cTag_ + "'")
			ok
			_aTags_ + [ _cTag_, @aCustom[_i_][2] ]
		next
		_aSorted_ = sort(_aTags_, 1)
		for _i_ = 1 to len(_aSorted_)
			_cAdd_ += _StzPispiQrTlv(_aSorted_[_i_][1], _aSorted_[_i_][2])
		next
		_cBody_ += _StzPispiQrTlv("62", _cAdd_)

		_cBody_ += "6304"
		return _cBody_ + StzPispiQrCrc16(_cBody_)
