#=====================================================================#
#  STZOUTPUTSCHEMA -- DECLARED STRUCTURE, VALIDATED WHOLES            #
#  the rung above scalar type checking (C9's working practice)        #
#=====================================================================#
/*
	stzLLMFunction could already say "this call returns a number, a
	boolean, or one of these three words". It could not say "this call
	returns a PERSON: a name, an age between 0 and 130, a mood drawn
	from a closed list, and any number of tags" -- and its own FLOOR
	NOTE said so in as many words.

	An stzOutputSchema is that missing sentence, declared once:

		oS = StzOutputSchemaQ([
			[ :field = "name", :type = :string ],
			[ :field = "age",  :type = :number, :must = [ [ ">=", 0 ], [ "<=", 130 ] ] ],
			[ :field = "mood", :type = :oneof,  :choices = [ "positive", "negative" ] ],
			[ :field = "tags", :type = :list,   :of = :string, :optional = 1 ]
		])

		aV = oS.ParseOutput(cWhateverTheModelSaid)
		if aV[:ok] = 1
			aPerson = aV[:value]          # the DECLARED shape, nothing else
		else
			? oS.CiteFindings(aV[:findings])
		ok

	STRUCTURE KILLS MALFORMEDNESS, NOT FALSEHOOD.
	Read that twice before trusting anything this file returns. A
	schema-valid lie validates: "age: 900000" is refused because 900000
	is outside the declared band, but "age: 41" for a person who is 62
	passes every rule here and is simply false. This class promises
	INTEGRITY -- that the answer has the shape it was asked for, whole,
	or that there is no answer at all. Truth is a different obligation
	and needs reversibility, audit and judgement, none of which live
	here.

	THREE HABITS BORROWED RATHER THAN REINVENTED:

	  - The OPERATOR VOCABULARY is stzGraphRule's, normalized by the
	    same _StzGraphRuleNormalizeOp(): equals, not-equals, contains,
	    greaterthan, lessthan, greaterequal, lessequal. A typo raises at
	    DECLARATION time rather than never matching at run time.

	  - The FINDING SHAPE is the family's unified one,
	    [ :rule, :subject, :where, :severity, :message ], so a schema
	    verdict can be handed straight to stzRuleReport.Ingest() and
	    stand in the same CI gate as the code, agent and security rules.
	    :subject is always "structured-output"; :where is the field
	    PATH ("author.name", "tags[2]").

	  - The COURT MANNER is the family's: deterministic, refusing, and
	    every refusal names the rule that produced it.

	FOUR DECISIONS A READER SHOULD NOT HAVE TO INFER:

	  1. PARTIAL CREDIT IS FORBIDDEN. One missing required field refuses
	     the whole structure. There is no "mostly valid" return.

	  2. A REPRESENTABLE SCALAR IS COERCED; NOTHING IS GUESSED. The
	     string "36" satisfies a :number field and comes back as the
	     number 36. The string "old" does not, and is refused. A closed
	     enumeration is CLOSED: unlike the scalar ReturnsOneOf() path,
	     which accepts a unique containment, a :oneof field must match a
	     choice exactly (after trim and case folding).

	  3. A REQUIRED FIELD THAT IS PRESENT BUT EMPTY IS MISSING. The
	     model did not answer it. Optional fields may be empty.

	  4. THE VALIDATED VALUE IS THE DECLARED SHAPE -- declared fields,
	     in DECLARED order, whatever order the model wrote them in.
	     Fields the schema never declared are reported (as warnings, so
	     they do not refuse) and DROPPED. RefuseUnknownFields() promotes
	     them to errors, which is what "a closed language" means when
	     you want it strictly.

	COMPARISON OPERATORS ON A :list CONSTRAIN ITS ELEMENT COUNT
	(":must = [ [ '>=', 1 ] ]" on a list reads "at least one element"),
	and `contains` on a list is MEMBERSHIP. Both are stated in every
	refusal message so no reader has to remember which it was.

	NOT IN SCOPE HERE, DELIBERATELY: grammar-constrained decoding. This
	file validates text the model has already produced. Making a
	violating token unemittable (type -> GBNF, at the sampler) is the
	engine rung under this surface; it is filed as an ask to the engine
	plane rather than stubbed here, so nothing in this file pretends to
	do it. The ask is
	prompts/42-stzlib-engine-schema-constrained-decoding.md in the
	coordination repository.
*/

#---------------------------------------------------------------------#
#  THE DECLARATION VOCABULARY                                          #
#---------------------------------------------------------------------#

# The field types. An unknown one raises, exactly as an unknown
# graph-rule operator does -- a typed declaration that silently never
# matches is the failure this whole file exists to prevent.
func StzOutputFieldTypes()
	return [ "string", "number", "boolean", "oneof", "list", "structure" ]

func _StzOutputNormalizeType(pcType)
	_t_ = StzLower(ring_trim("" + pcType))
	if _t_ = "string" or _t_ = "text" or _t_ = "str"
		return "string"
	but _t_ = "number" or _t_ = "num" or _t_ = "int" or _t_ = "integer" or _t_ = "float" or _t_ = "decimal"
		return "number"
	but _t_ = "boolean" or _t_ = "bool" or _t_ = "flag"
		return "boolean"
	but _t_ = "oneof" or _t_ = "enum" or _t_ = "choice"
		return "oneof"
	but _t_ = "list" or _t_ = "array" or _t_ = "listof"
		return "list"
	but _t_ = "structure" or _t_ = "struct" or _t_ = "object" or _t_ = "record"
		return "structure"
	ok
	stzraise("stzOutputSchema: unknown field type '" + pcType +
		"' (use string|number|boolean|oneof|list|structure).")

# The keys a field declaration may carry. Anything else raises at
# declaration time: ":requird = 0" quietly leaving a field required is
# precisely the class of typo a court must not tolerate in its own law.
func _StzOutputFieldKeys()
	return [ "field", "name", "type", "required", "optional",
		 "choices", "oneof", "of", "fields", "must", "note", "description" ]

# Which operators mean anything on which type. Declaring a constraint
# that cannot apply is a declaration defect, not a runtime miss.
func _StzOutputOpsFor(pcType)
	if pcType = "number"
		return [ "equals", "not-equals", "greaterthan", "lessthan", "greaterequal", "lessequal" ]
	but pcType = "string"
		return [ "equals", "not-equals", "contains" ]
	but pcType = "boolean"
		return [ "equals", "not-equals" ]
	but pcType = "oneof"
		return [ "equals", "not-equals" ]
	but pcType = "list"
		return [ "equals", "not-equals", "contains", "greaterthan", "lessthan", "greaterequal", "lessequal" ]
	ok
	return []

# The engine's field-type codes. Kept beside the type vocabulary above so
# the two cannot drift: a new type added there without a code here compiles
# to the WRONG grammar rather than to none, which is the failure a schema
# compiler must never have.
func _StzOutputTypeCode(pcType)
	_t_ = StzLower(ring_trim("" + pcType))
	if _t_ = "string"
		return 0
	but _t_ = "number"
		return 1
	but _t_ = "boolean"
		return 2
	but _t_ = "oneof"
		return 3
	but _t_ = "list"
		return 4
	but _t_ = "structure"
		return 5
	ok
	return 0

func _StzOutputAt(pcPath)
	if ring_trim("" + pcPath) = ""
		return ""
	ok
	return " at '" + pcPath + "'"

func _StzOutputJoin(pacWords, pcSep)
	_c_ = ""
	_n_ = len(pacWords)
	for _i_ = 1 to _n_
		if _i_ > 1
			_c_ += pcSep
		ok
		_c_ += "" + pacWords[_i_]
	next
	return _c_

func _StzOutputHasWord(pacWords, pcWord)
	_n_ = len(pacWords)
	for _i_ = 1 to _n_
		if ("" + pacWords[_i_]) = ("" + pcWord)
			return 1
		ok
	next
	return 0

#---------------------------------------------------------------------#
#  COMPILING A DECLARATION (the court reads its own law first)         #
#---------------------------------------------------------------------#

# paFields -> the compiled field list, or a raise. Recursive: a
# :structure field compiles its own :fields the same way, so a
# declaration error deep inside reads "author.name" like every other
# path in this file.
func _StzOutputCompileFields(paFields, pcPath)
	if NOT isList(paFields)
		stzraise("stzOutputSchema" + _StzOutputAt(pcPath) +
			": the declaration must be a LIST of field declarations.")
	ok
	if len(paFields) = 0
		stzraise("stzOutputSchema" + _StzOutputAt(pcPath) +
			": a structure with no fields declares nothing -- name at least one field.")
	ok

	_aOut_ = []
	_acSeen_ = []
	_nFlds_ = len(paFields)

	for _iFld_ = 1 to _nFlds_
		_aRaw_ = paFields[_iFld_]
		if NOT isList(_aRaw_)
			stzraise("stzOutputSchema" + _StzOutputAt(pcPath) + ": field #" + _iFld_ +
				" is not a field declaration (expected a list).")
		ok

		_aF_ = []
		if len(_aRaw_) > 0 and isList(_aRaw_[1])
			_aF_ = _StzOutputCompileHashForm(_aRaw_, pcPath, _iFld_)
		else
			_aF_ = _StzOutputCompilePositionalForm(_aRaw_, pcPath, _iFld_)
		ok

		_cSeenKey_ = StzLower(_aF_[:name])
		if _StzOutputHasWord(_acSeen_, _cSeenKey_)
			stzraise("stzOutputSchema" + _StzOutputAt(pcPath) + ": field '" + _aF_[:name] +
				"' is declared twice (Ring folds keys, so two spellings of one name are one field).")
		ok
		_acSeen_ + _cSeenKey_
		_aOut_ + _aF_
	next

	return _aOut_

# [ :field = "age", :type = :number, ... ] -- the canonical form.
func _StzOutputCompileHashForm(paRaw, pcPath, pnIndex)
	_cName_ = ""
	_cType_ = ""
	_bRequired_ = 1
	_acChoices_ = []
	_cOf_ = ""
	_aSub_ = []
	_aMustRaw_ = []
	_cNote_ = ""

	_acAllowed_ = _StzOutputFieldKeys()
	_nPairs_ = len(paRaw)

	for _iPair_ = 1 to _nPairs_
		_aPair_ = paRaw[_iPair_]
		if NOT (isList(_aPair_) and len(_aPair_) = 2)
			stzraise("stzOutputSchema" + _StzOutputAt(pcPath) + ": field #" + pnIndex +
				" mixes the named form with something else -- use [ :field = .., :type = .. ].")
		ok
		_cK_ = StzLower(ring_trim("" + _aPair_[1]))
		_vV_ = _aPair_[2]

		if _StzOutputHasWord(_acAllowed_, _cK_) = 0
			stzraise("stzOutputSchema" + _StzOutputAt(pcPath) + ": unknown key ':" + _aPair_[1] +
				"' in field #" + pnIndex + " (use :" + _StzOutputJoin(_acAllowed_, ", :") + ").")
		ok

		if _cK_ = "field" or _cK_ = "name"
			_cName_ = ring_trim("" + _vV_)
		but _cK_ = "type"
			_cType_ = _StzOutputNormalizeType(_vV_)
		but _cK_ = "required"
			_bRequired_ = _StzOutputTruth(_vV_)
		but _cK_ = "optional"
			_bRequired_ = 1 - _StzOutputTruth(_vV_)
		but _cK_ = "choices" or _cK_ = "oneof"
			_acChoices_ = _StzOutputCompileChoices(_vV_, pcPath, _cName_)
			if _cType_ = ""
				_cType_ = "oneof"
			ok
		but _cK_ = "of"
			_cOf_ = _StzOutputNormalizeType(_vV_)
		but _cK_ = "fields"
			_aSub_ = _vV_
		but _cK_ = "must"
			_aMustRaw_ = _vV_
		but _cK_ = "note" or _cK_ = "description"
			_cNote_ = "" + _vV_
		ok
	next

	return _StzOutputSealField(_cName_, _cType_, _bRequired_, _acChoices_,
		_cOf_, _aSub_, _aMustRaw_, _cNote_, pcPath, pnIndex)

# [ "age", :number ] / [ "age", :number, "optional" ] /
# [ "mood", :oneof, [ "up", "down" ] ] / [ "tags", :list, :string ] /
# [ "author", :structure, [ ...fields... ] ]  -- the compact form, for
# declarations short enough to read on one line.
func _StzOutputCompilePositionalForm(paRaw, pcPath, pnIndex)
	_nParts_ = len(paRaw)
	if _nParts_ < 2 or _nParts_ > 4
		stzraise("stzOutputSchema" + _StzOutputAt(pcPath) + ": field #" + pnIndex +
			" -- the compact form is [ name, type ] with an optional third " +
			"(choices, element type, sub-fields, or 'optional') and an optional fourth ('optional').")
	ok

	_cName_ = ring_trim("" + paRaw[1])
	_cType_ = _StzOutputNormalizeType(paRaw[2])
	_bRequired_ = 1
	_acChoices_ = []
	_cOf_ = ""
	_aSub_ = []

	for _iPart_ = 3 to _nParts_
		_v_ = paRaw[_iPart_]
		if isList(_v_)
			if _cType_ = "oneof"
				_acChoices_ = _StzOutputCompileChoices(_v_, pcPath, _cName_)
			but _cType_ = "structure" or _cType_ = "list"
				_aSub_ = _v_
			else
				stzraise("stzOutputSchema" + _StzOutputAt(pcPath) + ": field '" + _cName_ +
					"' is a " + _cType_ + " -- a list in the compact form only means " +
					"choices (oneof), or sub-fields (structure, or list of structures).")
			ok
		else
			_cFlag_ = StzLower(ring_trim("" + _v_))
			if _cFlag_ = "optional"
				_bRequired_ = 0
			but _cFlag_ = "required"
				_bRequired_ = 1
			but _cType_ = "list"
				_cOf_ = _StzOutputNormalizeType(_v_)
			else
				stzraise("stzOutputSchema" + _StzOutputAt(pcPath) + ": field '" + _cName_ +
					"' -- '" + _v_ + "' is not a flag ('optional' / 'required') and this " +
					"field is not a list, so it cannot be an element type.")
			ok
		ok
	next

	if _cType_ = "list" and len(_aSub_) > 0 and _cOf_ = ""
		_cOf_ = "structure"
	ok

	return _StzOutputSealField(_cName_, _cType_, _bRequired_, _acChoices_,
		_cOf_, _aSub_, [], "", pcPath, pnIndex)

func _StzOutputCompileChoices(pvChoices, pcPath, pcName)
	if NOT isList(pvChoices) or len(pvChoices) = 0
		stzraise("stzOutputSchema" + _StzOutputAt(pcPath) + ": field '" + pcName +
			"' declares :choices, which must be a non-empty list of words.")
	ok
	_acOut_ = []
	_nCh_ = len(pvChoices)
	for _iCh_ = 1 to _nCh_
		if isList(pvChoices[_iCh_])
			stzraise("stzOutputSchema" + _StzOutputAt(pcPath) + ": field '" + pcName +
				"' -- a choice must be a word, not a list.")
		ok
		_cCh_ = StzLower(ring_trim("" + pvChoices[_iCh_]))
		if _cCh_ = ""
			stzraise("stzOutputSchema" + _StzOutputAt(pcPath) + ": field '" + pcName +
				"' -- a choice cannot be empty.")
		ok
		if _StzOutputHasWord(_acOut_, _cCh_)
			stzraise("stzOutputSchema" + _StzOutputAt(pcPath) + ": field '" + pcName +
				"' lists the choice '" + _cCh_ + "' twice.")
		ok
		_acOut_ + _cCh_
	next
	return _acOut_

func _StzOutputTruth(pv)
	if isNumber(pv)
		if pv = 0
			return 0
		ok
		return 1
	ok
	_c_ = StzLower(ring_trim("" + pv))
	if _c_ = "1" or _c_ = "yes" or _c_ = "true"
		return 1
	ok
	return 0

# The last gate of the declaration: everything a type needs, it must
# have; everything it cannot use, it must not carry.
func _StzOutputSealField(pcName, pcType, pbRequired, pacChoices, pcOf, paSub, paMustRaw, pcNote, pcPath, pnIndex)

	if pcName = ""
		stzraise("stzOutputSchema" + _StzOutputAt(pcPath) + ": field #" + pnIndex +
			" has no name.")
	ok
	if pcType = ""
		stzraise("stzOutputSchema" + _StzOutputAt(pcPath) + ": field '" + pcName +
			"' has no :type (use string|number|boolean|oneof|list|structure).")
	ok

	_cChild_ = pcName
	if ring_trim("" + pcPath) != ""
		_cChild_ = pcPath + "." + pcName
	ok

	if pcType = "oneof" and len(pacChoices) = 0
		stzraise("stzOutputSchema: field '" + _cChild_ + "' is :oneof and declares no " +
			":choices -- an enumeration with nothing in it can never be satisfied.")
	ok
	if pcType != "oneof" and len(pacChoices) > 0
		stzraise("stzOutputSchema: field '" + _cChild_ + "' declares :choices but is a " +
			pcType + " -- only :oneof closes an enumeration.")
	ok

	if pcType = "list" and pcOf = ""
		stzraise("stzOutputSchema: field '" + _cChild_ + "' is a :list and does not say " +
			":of what (an unconstrained list validates nothing).")
	ok
	if pcType != "list" and pcOf != ""
		stzraise("stzOutputSchema: field '" + _cChild_ + "' declares :of but is a " +
			pcType + " -- :of names the ELEMENT type of a :list.")
	ok
	if pcType = "list" and pcOf = "oneof"
		stzraise("stzOutputSchema: field '" + _cChild_ + "' -- a list :of :oneof needs " +
			"choices the element form cannot carry; declare it :of :string and " +
			"constrain the elements with :must, or use a list of structures.")
	ok
	if pcType = "list" and pcOf = "list"
		stzraise("stzOutputSchema: field '" + _cChild_ + "' -- a list of lists has no " +
			"field names to cite in a refusal; use a list of structures.")
	ok

	_aFields_ = []
	if pcType = "structure"
		_aFields_ = _StzOutputCompileFields(paSub, _cChild_)
	but pcType = "list" and pcOf = "structure"
		_aFields_ = _StzOutputCompileFields(paSub, _cChild_ + "[]")
	but len(paSub) > 0
		stzraise("stzOutputSchema: field '" + _cChild_ + "' declares :fields but is a " +
			pcType + " -- only a :structure (or a :list of structures) has fields.")
	ok

	_aMust_ = _StzOutputCompileMust(paMustRaw, pcType, _cChild_)

	return [
		:name     = pcName,
		:type     = pcType,
		:required = pbRequired,
		:choices  = pacChoices,
		:of       = pcOf,
		:fields   = _aFields_,
		:must     = _aMust_,
		:note     = pcNote
	]

# :must = [ [ ">=", 0 ], [ "<=", 130 ] ] -- pairs of (operator, value),
# the operator drawn from stzGraphRule's vocabulary and normalized by
# ITS normalizer, so one typo is one raise here rather than a rule that
# quietly never fires.
func _StzOutputCompileMust(paMustRaw, pcType, pcWhere)
	_aOut_ = []
	if NOT isList(paMustRaw)
		stzraise("stzOutputSchema: field '" + pcWhere + "' -- :must is a LIST of " +
			"[ operator, value ] pairs.")
	ok
	if len(paMustRaw) = 0
		return _aOut_
	ok

	_acOK_ = _StzOutputOpsFor(pcType)
	_nMust_ = len(paMustRaw)

	for _iMust_ = 1 to _nMust_
		_aP_ = paMustRaw[_iMust_]
		if NOT (isList(_aP_) and len(_aP_) = 2)
			stzraise("stzOutputSchema: field '" + pcWhere + "' -- :must entry #" + _iMust_ +
				" must be [ operator, value ].")
		ok
		_cOp_ = _StzGraphRuleNormalizeOp(_aP_[1])
		if _cOp_ = "exists" or _cOp_ = "missing"
			stzraise("stzOutputSchema: field '" + pcWhere + "' -- 'exists' / 'missing' is " +
				"what :required and :optional already say; :must constrains the VALUE.")
		ok
		if len(_acOK_) = 0
			stzraise("stzOutputSchema: field '" + pcWhere + "' is a " + pcType +
				" and takes no :must constraints -- constrain its fields instead.")
		ok
		if _StzOutputHasWord(_acOK_, _cOp_) = 0
			stzraise("stzOutputSchema: field '" + pcWhere + "' is a " + pcType +
				" and cannot be constrained with '" + _cOp_ + "' (it takes " +
				_StzOutputJoin(_acOK_, ", ") + ").")
		ok
		if pcType = "number" and NOT isNumber(_aP_[2])
			if _StzOutputIsNumeric("" + _aP_[2]) = 0
				stzraise("stzOutputSchema: field '" + pcWhere + "' is a number and '" +
					_aP_[2] + "' is not one.")
			ok
		ok
		_aOut_ + [ _cOp_, _aP_[2] ]
	next

	return _aOut_

#---------------------------------------------------------------------#
#  PARSING WHAT THE MODEL ACTUALLY SAID                                #
#---------------------------------------------------------------------#
/*
	Two shapes are understood, and nothing else is guessed at:

	  JSON  -- the first balanced { .. } found anywhere in the reply, so
	           a model that wraps its answer in prose or a ```json fence
	           is still readable. Parsed by the house parser
	           (JsonToList), not a second one written here.

	  MEMO  -- the yaml-like shape this project writes its own memos in:
	           "key: value" lines, a bare "key:" opening an indented
	           block, and "- " opening a list item. Values stay STRINGS;
	           the field's declared type decides how to read them, which
	           is why "true" for a :string field stays "true" instead of
	           becoming 1.

	Anything else is a parse REFUSAL carrying a reason, never a partial
	list of whatever could be scavenged.
*/

# [ :ok, :value, :shape, :why ]
func StzParseModelOutput(pcRaw)
	_cText_ = _StzOutputStripFences("" + pcRaw)
	if ring_trim(_cText_) = ""
		return [ :ok = 0, :value = [], :shape = "", :why = "the model said nothing" ]
	ok

	_cJson_ = _StzOutputBalancedSpan(_cText_, "{", "}")
	if _cJson_ != ""
		_aJ_ = JsonToList(_cJson_)
		if isList(_aJ_) and len(_aJ_) > 0
			return [ :ok = 1, :value = _aJ_, :shape = "json", :why = "" ]
		ok
		return [ :ok = 0, :value = [], :shape = "json",
			 :why = "the reply looks like JSON but does not parse" ]
	ok

	_aM_ = _StzOutputParseMemo(_cText_)
	if _aM_[:ok] = 1
		return [ :ok = 1, :value = _aM_[:value], :shape = "memo", :why = "" ]
	ok

	return [ :ok = 0, :value = [], :shape = "", :why = _aM_[:why] ]

# A fenced block is the answer; the prose around it is not. When there
# is a fence, only what is inside the FIRST one survives.
func _StzOutputStripFences(pcRaw)
	_c_ = "" + pcRaw
	_aPos_ = StzFind("```", _c_)
	if len(_aPos_) < 2
		return _c_
	ok
	# skip the language tag that may follow the opening fence
	_cInner_ = StzMid(_c_, _aPos_[1] + 3, _aPos_[2] - _aPos_[1] - 3)
	_nNl_ = StzFind(char(10), _cInner_)
	if len(_nNl_) > 0 and ring_trim(StzMid(_cInner_, 1, _nNl_[1] - 1)) != ""
		_cInner_ = StzMidToEnd(_cInner_, _nNl_[1] + 1)
	ok
	return _cInner_

# The first BALANCED span from pcOpen to its matching pcClose, quotes and
# backslash escapes respected.
#
# This walks BYTES on purpose and it is safe to: the delimiters are
# ASCII, and no byte of a UTF-8 multibyte sequence can be mistaken for
# one (they all carry the high bit). The span is rebuilt by appending
# the bytes it spans, so the result is the same well-formed UTF-8 the
# model produced -- no byte-oriented substr() is taken across it.
func _StzOutputBalancedSpan(pcText, pcOpen, pcClose)
	_nLen_ = len(pcText)
	_nStart_ = 0
	for _i_ = 1 to _nLen_
		if pcText[_i_] = pcOpen
			_nStart_ = _i_
			exit
		ok
	next
	if _nStart_ = 0
		return ""
	ok

	_nDepth_ = 0
	_bInStr_ = 0
	_bEsc_ = 0
	_cOut_ = ""

	for _i_ = _nStart_ to _nLen_
		_ch_ = pcText[_i_]
		_cOut_ += _ch_
		if _bEsc_ = 1
			_bEsc_ = 0
			loop
		ok
		if _ch_ = char(92)
			if _bInStr_ = 1
				_bEsc_ = 1
			ok
			loop
		ok
		if _ch_ = char(34)
			_bInStr_ = 1 - _bInStr_
			loop
		ok
		if _bInStr_ = 1
			loop
		ok
		if _ch_ = pcOpen
			_nDepth_++
		but _ch_ = pcClose
			_nDepth_--
			if _nDepth_ = 0
				return _cOut_
			ok
		ok
	next

	return ""

# [ :ok, :value, :why ]
func _StzOutputParseMemo(pcText)
	_acLines_ = StzSplit(StzReplace("" + pcText, char(13), ""), char(10))
	_aL_ = []
	_nRaw_ = len(_acLines_)

	for _i_ = 1 to _nRaw_
		_cLn_ = StzReplace(_acLines_[_i_], char(9), "    ")
		_cT_ = ring_trim(_cLn_)
		if _cT_ = ""
			loop
		ok
		if StzLeft(_cT_, 1) = "#" or StzLeft(_cT_, 3) = "```"
			loop
		ok
		_aL_ + [ _StzOutputIndentOf(_cLn_), _cT_ ]
	next

	if len(_aL_) = 0
		return [ :ok = 0, :value = [], :why = "the model said nothing readable" ]
	ok
	if StzLeft(_aL_[1][2], 2) = "- "
		_cWhy_ = "the reply is a bare list; a structure was declared, " +
			"so it must open with named fields"
		return [ :ok = 0, :value = [], :why = _cWhy_ ]
	ok

	_aR_ = _StzOutputMemoMap(_aL_, 1, _aL_[1][1])
	if _aR_[:ok] = 0
		return [ :ok = 0, :value = [], :why = _aR_[:why] ]
	ok
	return [ :ok = 1, :value = _aR_[:value], :why = "" ]

func _StzOutputIndentOf(pcLine)
	_n_ = len(pcLine)
	for _i_ = 1 to _n_
		if pcLine[_i_] != " "
			return _i_ - 1
		ok
	next
	return _n_

# A "key: value" line, or 0 when the line is not one. The rule that
# keeps "- http://x" a scalar rather than a field: the text before the
# first colon must be a bare word, and the colon must be followed by a
# space or by end of line.
func _StzOutputColonAt(pcLine)
	_aPos_ = StzFind(":", pcLine)
	if len(_aPos_) = 0
		return 0
	ok
	_nAt_ = _aPos_[1]
	if _nAt_ < 2
		return 0
	ok
	_cKey_ = StzMid(pcLine, 1, _nAt_ - 1)
	if len(StzFind(" ", _cKey_)) > 0 or len(StzFind("/", _cKey_)) > 0
		return 0
	ok
	if StzLen(pcLine) > _nAt_
		if StzMid(pcLine, _nAt_ + 1, 1) != " "
			return 0
		ok
	ok
	return _nAt_

# [ :ok, :value, :why, :next ] -- a MAP block: every line at pnIndent is
# "key: value" or "key:" opening a deeper block.
func _StzOutputMemoMap(paL, pnStart, pnIndent)
	_aMap_ = []
	_i_ = pnStart
	_nAll_ = len(paL)

	while _i_ <= _nAll_
		_nInd_ = paL[_i_][1]
		_cLn_ = paL[_i_][2]

		if _nInd_ < pnIndent
			exit
		ok
		if _nInd_ > pnIndent
			_cWhy_ = "unexpected indentation before '" + _cLn_ + "'"
			return [ :ok = 0, :value = [], :why = _cWhy_, :next = _i_ ]
		ok
		if StzLeft(_cLn_, 2) = "- " or _cLn_ = "-"
			exit
		ok

		_nAt_ = _StzOutputColonAt(_cLn_)
		if _nAt_ = 0
			_cWhy_ = "'" + _cLn_ + "' is not a 'field: value' line"
			return [ :ok = 0, :value = [], :why = _cWhy_, :next = _i_ ]
		ok

		_cKey_ = ring_trim(StzMid(_cLn_, 1, _nAt_ - 1))
		_cVal_ = ""
		if StzLen(_cLn_) > _nAt_
			_cVal_ = ring_trim(StzMidToEnd(_cLn_, _nAt_ + 1))
		ok

		if _cVal_ != ""
			_aMap_ + [ _cKey_, _StzOutputUnquote(_cVal_) ]
			_i_++
			loop
		ok

		# "key:" alone -- a deeper block, list or map, or an empty value
		if _i_ = _nAll_ or paL[_i_ + 1][1] <= pnIndent
			_aMap_ + [ _cKey_, "" ]
			_i_++
			loop
		ok

		_nDeep_ = paL[_i_ + 1][1]
		if StzLeft(paL[_i_ + 1][2], 2) = "- " or paL[_i_ + 1][2] = "-"
			_aSub_ = _StzOutputMemoList(paL, _i_ + 1, _nDeep_)
		else
			_aSub_ = _StzOutputMemoMap(paL, _i_ + 1, _nDeep_)
		ok
		if _aSub_[:ok] = 0
			return _aSub_
		ok
		_aMap_ + [ _cKey_, _aSub_[:value] ]
		_i_ = _aSub_[:next]
	end

	return [ :ok = 1, :value = _aMap_, :why = "", :next = _i_ ]

# [ :ok, :value, :why, :next ] -- a LIST block: "- scalar", or
# "- key: value" opening a structure element whose remaining fields are
# indented under it, or "-" alone with the element indented under it.
func _StzOutputMemoList(paL, pnStart, pnIndent)
	_aList_ = []
	_i_ = pnStart
	_nAll_ = len(paL)

	while _i_ <= _nAll_
		_nInd_ = paL[_i_][1]
		_cLn_ = paL[_i_][2]

		if _nInd_ < pnIndent
			exit
		ok
		if _nInd_ > pnIndent
			_cWhy_ = "unexpected indentation before '" + _cLn_ + "'"
			return [ :ok = 0, :value = [], :why = _cWhy_, :next = _i_ ]
		ok
		if StzLeft(_cLn_, 2) != "- " and _cLn_ != "-"
			exit
		ok

		_cRest_ = ""
		if _cLn_ != "-"
			_cRest_ = ring_trim(StzMidToEnd(_cLn_, 3))
		ok
		_i_++

		_nAt_ = 0
		if _cRest_ != ""
			_nAt_ = _StzOutputColonAt(_cRest_)
		ok

		if _cRest_ != "" and _nAt_ = 0
			_aList_ + _StzOutputUnquote(_cRest_)
			loop
		ok

		# a structure element
		_aElem_ = []
		if _nAt_ > 0
			_cKey_ = ring_trim(StzMid(_cRest_, 1, _nAt_ - 1))
			_cVal_ = ""
			if StzLen(_cRest_) > _nAt_
				_cVal_ = ring_trim(StzMidToEnd(_cRest_, _nAt_ + 1))
			ok
			_aElem_ + [ _cKey_, _StzOutputUnquote(_cVal_) ]
		ok

		if _i_ <= _nAll_ and paL[_i_][1] > pnIndent
			_aMore_ = _StzOutputMemoMap(paL, _i_, paL[_i_][1])
			if _aMore_[:ok] = 0
				return _aMore_
			ok
			_nMore_ = len(_aMore_[:value])
			for _j_ = 1 to _nMore_
				_aElem_ + _aMore_[:value][_j_]
			next
			_i_ = _aMore_[:next]
		ok

		if len(_aElem_) = 0
			return [ :ok = 0, :value = [], :why = "a list item is empty", :next = _i_ ]
		ok
		_aList_ + _aElem_
	end

	return [ :ok = 1, :value = _aList_, :why = "", :next = _i_ ]

func _StzOutputUnquote(pcVal)
	_c_ = ring_trim("" + pcVal)
	_n_ = StzLen(_c_)
	if _n_ >= 2
		_cF_ = StzLeft(_c_, 1)
		_cL_ = StzRight(_c_, 1)
		if (_cF_ = char(34) and _cL_ = char(34)) or (_cF_ = "'" and _cL_ = "'")
			return StzMid(_c_, 2, _n_ - 2)
		ok
	ok
	return _c_

#---------------------------------------------------------------------#
#  READING A VALUE AS A DECLARED TYPE                                  #
#---------------------------------------------------------------------#

# A strict numeric test. ring_number() answers 0 for "old" as readily as
# for "0", so it cannot be asked whether something IS a number.
func _StzOutputIsNumeric(pcVal)
	_c_ = ring_trim("" + pcVal)
	_n_ = len(_c_)
	if _n_ = 0
		return 0
	ok
	# ascii() codes, not string comparison: Ring reads `"o" >= "0"` as
	# arithmetic and raises R41 "Invalid numeric string" on the very
	# input this function exists to answer NO about.
	_i_ = 1
	_nFirst_ = ascii(_c_[1])
	if _nFirst_ = 45 or _nFirst_ = 43
		_i_ = 2
	ok
	_nDigits_ = 0
	_nDots_ = 0
	while _i_ <= _n_
		_nA_ = ascii(_c_[_i_])
		if _nA_ >= 48 and _nA_ <= 57
			_nDigits_++
		but _nA_ = 46
			_nDots_++
			if _nDots_ > 1
				return 0
			ok
		else
			return 0
		ok
		_i_++
	end
	if _nDigits_ = 0
		return 0
	ok
	return 1

# Deliberately NOT _StzGraphRuleValEmpty(): that one reads "0" as empty,
# which is right for a graph property and wrong here. A boolean answered
# false, or a count answered zero, is an ANSWER -- treating it as silence
# would refuse the model for saying no.
func _StzOutputIsEmptyValue(pv)
	if isList(pv)
		return (len(pv) = 0)
	ok
	return (ring_trim("" + pv) = "")

func _StzOutputFinding(pcRule, pcWhere, pcSeverity, pcMessage)
	return [ :rule = pcRule, :subject = "structured-output", :where = pcWhere,
		 :severity = pcSeverity, :message = pcMessage ]

func _StzOutputShow(pv)
	if isList(pv)
		return "a list of " + len(pv) + " item(s)"
	ok
	_c_ = ring_trim("" + pv)
	if StzLen(_c_) > 40
		_c_ = StzLeft(_c_, 40) + "..."
	ok
	return "'" + _c_ + "'"

# [ :ok, :value, :findings ] -- one scalar, read as one declared type.
func _StzOutputReadScalar(pv, pcType, pacChoices, pcWhere)
	if pcType = "string"
		if isList(pv)
			return [ :ok = 0, :value = "", :findings = [ _StzOutputFinding("type",
				pcWhere, :error, "field '" + pcWhere + "' was declared a string and " +
				"the model answered " + _StzOutputShow(pv) + ".") ] ]
		ok
		return [ :ok = 1, :value = ring_trim("" + pv), :findings = [] ]
	ok

	if pcType = "number"
		if isNumber(pv)
			return [ :ok = 1, :value = pv, :findings = [] ]
		ok
		if NOT isList(pv)
			if _StzOutputIsNumeric("" + pv) = 1
				return [ :ok = 1, :value = 0 + ring_trim("" + pv), :findings = [] ]
			ok
		ok
		return [ :ok = 0, :value = 0, :findings = [ _StzOutputFinding("type",
			pcWhere, :error, "field '" + pcWhere + "' was declared a number and " +
			"the model answered " + _StzOutputShow(pv) + ".") ] ]
	ok

	if pcType = "boolean"
		if isNumber(pv)
			if pv = 0
				return [ :ok = 1, :value = 0, :findings = [] ]
			ok
			if pv = 1
				return [ :ok = 1, :value = 1, :findings = [] ]
			ok
		but NOT isList(pv)
			_c_ = StzLower(ring_trim("" + pv))
			if _c_ = "true" or _c_ = "yes" or _c_ = "1"
				return [ :ok = 1, :value = 1, :findings = [] ]
			ok
			if _c_ = "false" or _c_ = "no" or _c_ = "0"
				return [ :ok = 1, :value = 0, :findings = [] ]
			ok
		ok
		return [ :ok = 0, :value = 0, :findings = [ _StzOutputFinding("type",
			pcWhere, :error, "field '" + pcWhere + "' was declared a boolean and " +
			"the model answered " + _StzOutputShow(pv) + " (say yes/no or true/false).") ] ]
	ok

	if pcType = "oneof"
		if NOT isList(pv)
			_c_ = StzLower(ring_trim("" + pv))
			if _StzOutputHasWord(pacChoices, _c_)
				return [ :ok = 1, :value = _c_, :findings = [] ]
			ok
		ok
		return [ :ok = 0, :value = "", :findings = [ _StzOutputFinding("oneof",
			pcWhere, :error, "field '" + pcWhere + "' is a closed enumeration (" +
			_StzOutputJoin(pacChoices, " | ") + ") and the model answered " +
			_StzOutputShow(pv) + ".") ] ]
	ok

	return [ :ok = 0, :value = "", :findings = [ _StzOutputFinding("type",
		pcWhere, :error, "field '" + pcWhere + "' has no readable type.") ] ]

# One :must clause against one value. Comparisons on a LIST speak about
# its element COUNT, and every message says which reading was used.
func _StzOutputMustHolds(pvVal, pcType, pcOp, pvWant)
	if pcType = "list"
		if pcOp = "contains"
			_n_ = len(pvVal)
			for _i_ = 1 to _n_
				if NOT isList(pvVal[_i_])
					if StzLower(ring_trim("" + pvVal[_i_])) = StzLower(ring_trim("" + pvWant))
						return 1
					ok
				ok
			next
			return 0
		ok
		return _StzOutputCompareNumbers(len(pvVal), pcOp, pvWant)
	ok

	if pcType = "number"
		return _StzOutputCompareNumbers(pvVal, pcOp, pvWant)
	ok

	if pcOp = "equals"
		return _StzGraphRuleValEq(pvVal, pvWant)
	but pcOp = "not-equals"
		return 1 - _StzGraphRuleValEq(pvVal, pvWant)
	but pcOp = "contains"
		# StzFind is NEEDLE-FIRST; both sides are folded so the
		# containment is case-insensitive like the graph rule's equality.
		return (len(StzFind(StzLower("" + pvWant), StzLower("" + pvVal))) > 0)
	ok
	return 0

func _StzOutputCompareNumbers(pnVal, pcOp, pvWant)
	_nW_ = 0 + pvWant
	if pcOp = "equals"
		return (pnVal = _nW_)
	but pcOp = "not-equals"
		return (pnVal != _nW_)
	but pcOp = "greaterthan"
		return (pnVal > _nW_)
	but pcOp = "lessthan"
		return (pnVal < _nW_)
	but pcOp = "greaterequal"
		return (pnVal >= _nW_)
	but pcOp = "lessequal"
		return (pnVal <= _nW_)
	ok
	return 0

func _StzOutputMustPhrase(pcType, pcOp, pvWant)
	if pcType = "list"
		if pcOp = "contains"
			return "must contain " + _StzOutputShow(pvWant)
		ok
		if pcOp = "equals"
			return "must hold exactly " + pvWant + " element(s)"
		but pcOp = "not-equals"
			return "must not hold exactly " + pvWant + " element(s)"
		but pcOp = "greaterthan"
			return "must hold more than " + pvWant + " element(s)"
		but pcOp = "lessthan"
			return "must hold fewer than " + pvWant + " element(s)"
		but pcOp = "greaterequal"
			return "must hold at least " + pvWant + " element(s)"
		but pcOp = "lessequal"
			return "must hold at most " + pvWant + " element(s)"
		ok
		return "must satisfy " + pcOp
	ok

	if pcOp = "equals"
		return "must equal " + _StzOutputShow(pvWant)
	but pcOp = "not-equals"
		return "must differ from " + _StzOutputShow(pvWant)
	but pcOp = "contains"
		return "must contain " + _StzOutputShow(pvWant)
	but pcOp = "greaterthan"
		return "must be greater than " + _StzOutputShow(pvWant)
	but pcOp = "lessthan"
		return "must be less than " + _StzOutputShow(pvWant)
	but pcOp = "greaterequal"
		return "must be at least " + _StzOutputShow(pvWant)
	but pcOp = "lessequal"
		return "must be at most " + _StzOutputShow(pvWant)
	ok
	return "must satisfy " + pcOp

#---------------------------------------------------------------------#
#  THE COURT: FIELD BY FIELD, WHOLE OR NOTHING                         #
#---------------------------------------------------------------------#

# [ :value, :findings ] -- the validated whole, in DECLARED order, and
# every complaint the declaration has about what it was given.
func _StzOutputVerifyFields(pvValue, paFields, pcPath, pbRefuseUnknown)
	_aFind_ = []
	_aOut_ = []

	if NOT isList(pvValue)
		_aFind_ + _StzOutputFinding("shape", _StzOutputPathOr(pcPath), :error,
			"expected a structure with named fields and got " + _StzOutputShow(pvValue) + ".")
		return [ :value = [], :findings = _aFind_ ]
	ok
	if len(pvValue) > 0 and IsHashList(pvValue) = 0
		_aFind_ + _StzOutputFinding("shape", _StzOutputPathOr(pcPath), :error,
			"expected a structure with named fields and got a bare list of " +
			len(pvValue) + " item(s).")
		return [ :value = [], :findings = _aFind_ ]
	ok

	_nF_ = len(paFields)
	for _iF_ = 1 to _nF_
		_aFld_ = paFields[_iF_]
		_cName_ = _aFld_[:name]
		_cWhere_ = pcPath + _cName_

		_bHas_ = 0
		_vRaw_ = ""
		if len(pvValue) > 0
			if HasKey(pvValue, _cName_)
				_bHas_ = 1
				_vRaw_ = pvValue[_cName_]
			ok
		ok

		if _bHas_ = 1 and _StzOutputIsEmptyValue(_vRaw_) and _aFld_[:type] != "list"
			_bHas_ = 0
		ok

		if _bHas_ = 0
			if _aFld_[:required] = 1
				_aFind_ + _StzOutputFinding("required", _cWhere_, :error,
					"field '" + _cWhere_ + "' is required and the model did not answer it.")
			ok
			loop
		ok

		_aRes_ = _StzOutputVerifyOne(_vRaw_, _aFld_, _cWhere_, pbRefuseUnknown)
		_nAdd_ = len(_aRes_[:findings])
		for _iA_ = 1 to _nAdd_
			_aFind_ + _aRes_[:findings][_iA_]
		next
		if _aRes_[:ok] = 1
			_aOut_ + [ _cName_, _aRes_[:value] ]
		ok
	next

	# fields nobody declared: reported, and dropped from the whole
	_nGiven_ = len(pvValue)
	for _iG_ = 1 to _nGiven_
		_aPair_ = pvValue[_iG_]
		if NOT (isList(_aPair_) and len(_aPair_) = 2)
			loop
		ok
		_cGiven_ = StzLower(ring_trim("" + _aPair_[1]))
		_bKnown_ = 0
		for _iF_ = 1 to _nF_
			if StzLower(paFields[_iF_][:name]) = _cGiven_
				_bKnown_ = 1
				exit
			ok
		next
		if _bKnown_ = 0
			_cSev_ = :warning
			_cTail_ = " -- it is reported and dropped."
			if pbRefuseUnknown = 1
				_cSev_ = :error
				_cTail_ = " -- the schema is closed, so this refuses the answer."
			ok
			_aFind_ + _StzOutputFinding("unknown-field", pcPath + _aPair_[1], _cSev_,
				"the model added a field '" + _aPair_[1] + "' the schema never declared" + _cTail_)
		ok
	next

	return [ :value = _aOut_, :findings = _aFind_ ]

func _StzOutputPathOr(pcPath)
	if ring_trim("" + pcPath) = ""
		return "(the whole answer)"
	ok
	return pcPath

# [ :ok, :value, :findings ] -- one field's value against its declaration.
func _StzOutputVerifyOne(pvRaw, paFld, pcWhere, pbRefuseUnknown)
	_cType_ = paFld[:type]
	_aFind_ = []

	if _cType_ = "structure"
		_aSub_ = _StzOutputVerifyFields(pvRaw, paFld[:fields], pcWhere + ".", pbRefuseUnknown)
		_nS_ = len(_aSub_[:findings])
		for _iS_ = 1 to _nS_
			_aFind_ + _aSub_[:findings][_iS_]
		next
		if _StzOutputHasError(_aFind_) = 1
			return [ :ok = 0, :value = [], :findings = _aFind_ ]
		ok
		return [ :ok = 1, :value = _aSub_[:value], :findings = _aFind_ ]
	ok

	if _cType_ = "list"
		if NOT isList(pvRaw)
			_aFind_ + _StzOutputFinding("type", pcWhere, :error,
				"field '" + pcWhere + "' was declared a list and the model answered " +
				_StzOutputShow(pvRaw) + ".")
			return [ :ok = 0, :value = [], :findings = _aFind_ ]
		ok
		if len(pvRaw) > 0 and paFld[:of] != "structure" and IsHashList(pvRaw) = 1
			_aFind_ + _StzOutputFinding("type", pcWhere, :error,
				"field '" + pcWhere + "' was declared a list of " + paFld[:of] +
				" and the model answered a named structure.")
			return [ :ok = 0, :value = [], :findings = _aFind_ ]
		ok

		_aItems_ = []
		_nI_ = len(pvRaw)
		for _iI_ = 1 to _nI_
			_cAt_ = pcWhere + "[" + _iI_ + "]"
			if paFld[:of] = "structure"
				_aE_ = _StzOutputVerifyFields(pvRaw[_iI_], paFld[:fields], _cAt_ + ".", pbRefuseUnknown)
				_nE_ = len(_aE_[:findings])
				for _iE_ = 1 to _nE_
					_aFind_ + _aE_[:findings][_iE_]
				next
				_aItems_ + _aE_[:value]
			else
				_aS_ = _StzOutputReadScalar(pvRaw[_iI_], paFld[:of], [], _cAt_)
				_nE_ = len(_aS_[:findings])
				for _iE_ = 1 to _nE_
					_aFind_ + _aS_[:findings][_iE_]
				next
				if _aS_[:ok] = 1
					_aItems_ + _aS_[:value]
				ok
			ok
		next

		_aFind_ = _StzOutputApplyMust(_aItems_, paFld, pcWhere, _aFind_)
		if _StzOutputHasError(_aFind_) = 1
			return [ :ok = 0, :value = [], :findings = _aFind_ ]
		ok
		return [ :ok = 1, :value = _aItems_, :findings = _aFind_ ]
	ok

	_aR_ = _StzOutputReadScalar(pvRaw, _cType_, paFld[:choices], pcWhere)
	_nR_ = len(_aR_[:findings])
	for _iR_ = 1 to _nR_
		_aFind_ + _aR_[:findings][_iR_]
	next
	if _aR_[:ok] = 0
		return [ :ok = 0, :value = "", :findings = _aFind_ ]
	ok

	_aFind_ = _StzOutputApplyMust(_aR_[:value], paFld, pcWhere, _aFind_)
	if _StzOutputHasError(_aFind_) = 1
		return [ :ok = 0, :value = "", :findings = _aFind_ ]
	ok
	return [ :ok = 1, :value = _aR_[:value], :findings = _aFind_ ]

func _StzOutputApplyMust(pvVal, paFld, pcWhere, paFind)
	_aOut_ = paFind
	_aMust_ = paFld[:must]
	_nM_ = len(_aMust_)
	for _iM_ = 1 to _nM_
		_cOp_ = _aMust_[_iM_][1]
		_vWant_ = _aMust_[_iM_][2]
		if _StzOutputMustHolds(pvVal, paFld[:type], _cOp_, _vWant_) = 0
			_aOut_ + _StzOutputFinding(_cOp_, pcWhere, :error,
				"field '" + pcWhere + "' " + _StzOutputMustPhrase(paFld[:type], _cOp_, _vWant_) +
				", and the model answered " + _StzOutputShow(pvVal) + ".")
		ok
	next
	return _aOut_

func _StzOutputHasError(paFindings)
	_n_ = len(paFindings)
	for _i_ = 1 to _n_
		if ("" + paFindings[_i_][:severity]) = "error"
			return 1
		ok
	next
	return 0

#---------------------------------------------------------------------#
#  COMPARING TWO VALUES (what a golden case needs)                     #
#---------------------------------------------------------------------#

# Ring's own `=` answers 0 for two identical lists, so a golden case
# holding a structure could never pass while it was compared that way.
# Strings compare trimmed and case-folded, numbers numerically, hash
# lists key by key regardless of the order they were written in.
func StzOutputValuesAgree(pv1, pv2)
	if isList(pv1) or isList(pv2)
		if NOT (isList(pv1) and isList(pv2))
			return 0
		ok
		if len(pv1) != len(pv2)
			return 0
		ok
		if len(pv1) = 0
			return 1
		ok
		if IsHashList(pv1) = 1 and IsHashList(pv2) = 1
			_n_ = len(pv1)
			for _i_ = 1 to _n_
				_cK_ = "" + pv1[_i_][1]
				if HasKey(pv2, _cK_) = 0
					return 0
				ok
				if StzOutputValuesAgree(pv1[_i_][2], pv2[_cK_]) = 0
					return 0
				ok
			next
			return 1
		ok
		_n_ = len(pv1)
		for _i_ = 1 to _n_
			if StzOutputValuesAgree(pv1[_i_], pv2[_i_]) = 0
				return 0
			ok
		next
		return 1
	ok
	if isNumber(pv1) and isNumber(pv2)
		return (pv1 = pv2)
	ok
	return (StzLower(ring_trim("" + pv1)) = StzLower(ring_trim("" + pv2)))

# Where two values disagree, named -- so a failing golden says WHICH
# field moved rather than only that something did.
func StzOutputValueDiff(pvExpected, pvGot, pcPath)
	_aOut_ = []
	_cAt_ = _StzOutputPathOr(pcPath)

	if isList(pvExpected) and isList(pvGot) and IsHashList(pvExpected) = 1 and IsHashList(pvGot) = 1
		_n_ = len(pvExpected)
		for _i_ = 1 to _n_
			_cK_ = "" + pvExpected[_i_][1]
			_cSub_ = _cK_
			if ring_trim("" + pcPath) != ""
				_cSub_ = pcPath + "." + _cK_
			ok
			if HasKey(pvGot, _cK_) = 0
				_aOut_ + _StzOutputFinding("golden", _cSub_, :error,
					"expected field '" + _cSub_ + "' and the answer has none.")
				loop
			ok
			_aD_ = StzOutputValueDiff(pvExpected[_i_][2], pvGot[_cK_], _cSub_)
			_nD_ = len(_aD_)
			for _iD_ = 1 to _nD_
				_aOut_ + _aD_[_iD_]
			next
		next
		_nG_ = len(pvGot)
		for _i_ = 1 to _nG_
			_cK_ = "" + pvGot[_i_][1]
			if HasKey(pvExpected, _cK_) = 0
				_cSub_ = _cK_
				if ring_trim("" + pcPath) != ""
					_cSub_ = pcPath + "." + _cK_
				ok
				_aOut_ + _StzOutputFinding("golden", _cSub_, :error,
					"the answer has a field '" + _cSub_ + "' the golden does not.")
			ok
		next
		return _aOut_
	ok

	if StzOutputValuesAgree(pvExpected, pvGot) = 0
		_aOut_ + _StzOutputFinding("golden", _cAt_, :error,
			"expected " + _StzOutputShow(pvExpected) + " and got " + _StzOutputShow(pvGot) + ".")
	ok
	return _aOut_

#---------------------------------------------------------------------#
#  SAYING THE SHAPE OUT LOUD                                           #
#---------------------------------------------------------------------#

func _StzOutputSampleForType(pcType)
	if pcType = "boolean"
		return "<yes or no>"
	but pcType = "number"
		return "<number>"
	ok
	return "<text>"

func _StzOutputSampleFor(paFld)
	if paFld[:type] = "oneof"
		return "<one of: " + _StzOutputJoin(paFld[:choices], " | ") + ">"
	ok
	return _StzOutputSampleForType(paFld[:type])

func _StzOutputShapeLines(paFields, pnIndent)
	_c_ = ""
	_cPad_ = ""
	for _i_ = 1 to pnIndent
		_cPad_ += "  "
	next
	_n_ = len(paFields)
	for _i_ = 1 to _n_
		_aF_ = paFields[_i_]
		_cT_ = _aF_[:type]
		if _cT_ = "structure"
			_c_ += _cPad_ + _aF_[:name] + ":" + char(10)
			_c_ += _StzOutputShapeLines(_aF_[:fields], pnIndent + 1)
		but _cT_ = "list"
			_c_ += _cPad_ + _aF_[:name] + ":" + char(10)
			if _aF_[:of] = "structure"
				_cInner_ = _StzOutputShapeLines(_aF_[:fields], pnIndent + 2)
				_c_ += _cPad_ + "  - (one per item)" + char(10) + _cInner_
			else
				_c_ += _cPad_ + "  - " + _StzOutputSampleForType(_aF_[:of]) + char(10)
				_c_ += _cPad_ + "  - ..." + char(10)
			ok
		else
			_c_ += _cPad_ + _aF_[:name] + ": " + _StzOutputSampleFor(_aF_) + char(10)
		ok
	next
	return _c_

#---------------------------------------------------------------------#
#  THE FACE                                                            #
#---------------------------------------------------------------------#

func StzOutputSchemaQ(paFields)
	return new stzOutputSchema(paFields)

class stzOutputSchema from stzObject

	@cName = "output"
	@aFields = []
	@bRefuseUnknown = 0

	# The declaration is compiled -- and judged -- HERE. Nothing about a
	# schema is discovered at call time; a defective declaration never
	# reaches a model.
	def init(paFields)
		@aFields = _StzOutputCompileFields(paFields, "")

	  #-- reads -------------------------------------------------------

	def Name()
		return @cName

	def SetName(pcName)
		This.SetNameQ(pcName)

	def SetNameQ(pcName)
		if ring_trim("" + pcName) != ""
			@cName = ring_trim("" + pcName)
		ok
		return This

	def Fields()
		return @aFields

	def NumberOfFields()
		return len(@aFields)

	def FieldNames()
		_ac_ = []
		_n_ = len(@aFields)
		for _i_ = 1 to _n_
			_ac_ + @aFields[_i_][:name]
		next
		return _ac_

	def RequiredFieldNames()
		_ac_ = []
		_n_ = len(@aFields)
		for _i_ = 1 to _n_
			if @aFields[_i_][:required] = 1
				_ac_ + @aFields[_i_][:name]
			ok
		next
		return _ac_

	def HasField(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		_n_ = len(@aFields)
		for _i_ = 1 to _n_
			if StzLower(@aFields[_i_][:name]) = _c_
				return 1
			ok
		next
		return 0

	def Field(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		_n_ = len(@aFields)
		for _i_ = 1 to _n_
			if StzLower(@aFields[_i_][:name]) = _c_
				return @aFields[_i_]
			ok
		next
		stzraise("stzOutputSchema: no field named '" + pcName + "'.")

	def RefusesUnknownFields()
		return @bRefuseUnknown

	  #-- the one knob ------------------------------------------------

	# Closed-world: a field nobody declared REFUSES the answer instead
	# of being reported and dropped.
	def RefuseUnknownFields()
		This.RefuseUnknownFieldsQ()

	def RefuseUnknownFieldsQ()
		@bRefuseUnknown = 1
		return This

	def AllowUnknownFields()
		This.AllowUnknownFieldsQ()

	def AllowUnknownFieldsQ()
		@bRefuseUnknown = 0
		return This

	  #-- the court ---------------------------------------------------

	# An ALREADY-PARSED value against the declaration.
	# [ :ok, :value, :findings ]
	def Verify(pvValue)
		_aR_ = _StzOutputVerifyFields(pvValue, @aFields, "", @bRefuseUnknown)
		_bOK_ = 1
		if _StzOutputHasError(_aR_[:findings]) = 1
			_bOK_ = 0
		ok
		_vVal_ = _aR_[:value]
		if _bOK_ = 0
			_vVal_ = []
		ok
		return [ :ok = _bOK_, :value = _vVal_, :findings = _aR_[:findings] ]

	# The family's rule face: run me, hand me back the findings.
	def Check(pvValue)
		return This.Verify(pvValue)[:findings]

	def Holds(pvValue)
		return This.Verify(pvValue)[:ok]

	def NumberOfFindings(pvValue)
		return len(This.Check(pvValue))

	# RAW MODEL TEXT to a validated whole, or to a refusal that names
	# the rule it failed. [ :ok, :value, :findings, :shape ]
	def ParseOutput(pcRaw)
		_aP_ = StzParseModelOutput(pcRaw)
		if _aP_[:ok] = 0
			return [ :ok = 0, :value = [], :shape = _aP_[:shape],
				 :findings = [ _StzOutputFinding("parse", "(the whole answer)", :error,
					"the answer could not be read as a structure: " + _aP_[:why] + ".") ] ]
		ok
		_aV_ = This.Verify(_aP_[:value])
		return [ :ok = _aV_[:ok], :value = _aV_[:value], :shape = _aP_[:shape],
			 :findings = _aV_[:findings] ]

	def Accepts(pcRaw)
		return This.ParseOutput(pcRaw)[:ok]

	  #-- goldens -----------------------------------------------------

	def Agrees(pvExpected, pvGot)
		return StzOutputValuesAgree(pvExpected, pvGot)

	def Diff(pvExpected, pvGot)
		return StzOutputValueDiff(pvExpected, pvGot, "")

	  #-- saying it out loud ------------------------------------------

	# One sentence per finding, the rule named in every one. Long lists
	# are cut, and the cut is stated rather than silent.
	def CiteFindings(paFindings)
		_n_ = len(paFindings)
		if _n_ = 0
			return "nothing to cite -- the answer satisfied every rule."
		ok
		_nShow_ = _n_
		if _nShow_ > 4
			_nShow_ = 4
		ok
		_c_ = ""
		for _i_ = 1 to _nShow_
			_f_ = paFindings[_i_]
			if _i_ > 1
				_c_ += "; "
			ok
			_c_ += "[" + _f_[:rule] + " @ " + _f_[:where] + "] " + _f_[:message]
		next
		if _n_ > _nShow_
			_c_ += " ... and " + (_n_ - _nShow_) + " more finding(s)"
		ok
		return _c_

	# The shape, written the way the model should write it. Appended to
	# a prompt, it is the difference between hoping and asking.
	# The shape, written the way the model should write it. Appended to a
	# prompt, it is the difference between hoping and asking.
	#
	# THE CLAUSE IS SHORT BECAUSE A LONGER ONE MEASURED WORSE, and that is
	# the only reason. Against the shipped 135M model, ten structured
	# prompts validated 2/10 with the wording below. Adding two instructions
	# aimed at the observed failures -- "do not explain the structure", and
	# "replace every <...> with a real value" -- took it to 0/10: a small
	# model told not to explain explained more, and the negation was the
	# thing it echoed. Reverted on the measurement. Do not re-add
	# instructions here without re-running
	# base/test/neural/_measure_structured.ring; taste is not evidence.
	def PromptClause()
		return "Answer with ONLY this structure, one field per line, " +
			"nothing before it and nothing after it:" + char(10) + char(10) +
			_StzOutputShapeLines(@aFields, 0)

	  #-- the grammar half (prompt 42) --------------------------------
	/*
		THIS COMPILES THE DECLARATION INTO A GRAMMAR. It does NOT
		constrain decoding, and the difference is the whole point.

		The court above parses and refuses what a model already said.
		A grammar makes a violating token unemittable in the first
		place -- but only once a SAMPLER consumes it, which nothing in
		this build does. IsDecodingConstrained() answers 0 and
		DecodingStatus() says why, so no caller can mistake a compiled
		grammar for a constrained one.

		AND A GRAMMAR CONSTRAINS SHAPE, NEVER VALUE. No context-free
		rule says "this number is between 0 and 130", so every :must
		clause is dropped from the grammar -- listed, one line each, by
		UnenforcedByGrammar(). That is why this court does not retire
		when constrained decoding lands: it is the half that checks
		what a grammar structurally cannot.
	*/

	# The GBNF text for this declaration, or a raise naming the construct
	# that cannot be expressed. Nested structures are REFUSED rather than
	# flattened: a grammar that accepted what this schema rejects would
	# put the two layers into disagreement.
	def ToGBNF()
		stzenginegbnfbegin()
		_n_ = len(@aFields)
		for _i_ = 1 to _n_
			_f_ = @aFields[_i_]
			_cOps_ = ""
			_nM_ = len(_f_[:must])
			for _iM_ = 1 to _nM_
				if _iM_ > 1  _cOps_ += ","  ok
				_cOps_ += _f_[:must][_iM_][1]
			next
			_rc_ = stzenginegbnffield(_f_[:name],
				_StzOutputTypeCode(_f_[:type]), _f_[:required],
				_StzOutputTypeCode(_f_[:of]),
				_StzOutputJoin(_f_[:choices], ","), _cOps_)
			if _rc_ != 0
				stzraise("stzOutputSchema.ToGBNF: " + stzenginegbnflastrefusal())
			ok
		next
		if stzenginegbnfcompile() != 0
			stzraise("stzOutputSchema.ToGBNF: " + stzenginegbnflastrefusal())
		ok
		return stzenginegbnftext()

	# TRUE when this declaration can be expressed as a grammar at all.
	def IsExpressibleAsGrammar()
		try
			This.ToGBNF()
		catch
			return 0
		done
		return 1

	# One line per constraint the grammar does NOT carry. Empty means the
	# grammar carries everything this schema declared.
	def UnenforcedByGrammar()
		This.ToGBNF()
		return stzenginegbnfunenforced()

	# Does anything actually CONSTRAIN DECODING with this grammar? Ask
	# before reporting an answer as grammar-constrained -- today this is 0.
	def IsDecodingConstrained()
		return stzenginegbnfdecodingsupported()

	def DecodingStatus()
		return stzenginegbnfdecodingstatus()

	# The declaration read back as prose, for a narrated test or a
	# reader who wants to see what was actually promised.
	def Describe()
		_c_ = "schema '" + @cName + "' -- " + len(@aFields) + " field(s)" + char(10)
		_n_ = len(@aFields)
		for _i_ = 1 to _n_
			_f_ = @aFields[_i_]
			_cLine_ = "  " + _f_[:name] + " : " + _f_[:type]
			if _f_[:type] = "oneof"
				_cLine_ += " (" + _StzOutputJoin(_f_[:choices], " | ") + ")"
			ok
			if _f_[:type] = "list"
				_cLine_ += " of " + _f_[:of]
			ok
			if _f_[:required] = 1
				_cLine_ += " [required]"
			else
				_cLine_ += " [optional]"
			ok
			_nM_ = len(_f_[:must])
			for _iM_ = 1 to _nM_
				_cLine_ += ", " + _StzOutputMustPhrase(_f_[:type],
					_f_[:must][_iM_][1], _f_[:must][_iM_][2])
			next
			_c_ += _cLine_ + char(10)
		next
		if @bRefuseUnknown = 1
			_c_ += "  (closed: an undeclared field refuses the answer)" + char(10)
		ok
		return _c_
