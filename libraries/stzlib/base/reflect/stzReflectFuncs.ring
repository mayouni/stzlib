#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZ REFLECT FUNCS              #
#--------------------------------------------------------------#
#   Shared, pure-function helpers for the reflection domain     #
#   (stzSelfDoc + stzLibDoc): source harvesting, class->source  #
#   resolution, method-text building, and the semantic RANKING  #
#   brain (reranker > embeddings > lexical). Kept in a class-    #
#   free file loaded BEFORE the reflect classes so BOTH can call #
#   them -- a `func` defined after a `class` is not visible to   #
#   another file's class. Also dodges the class-scope len()/     #
#   trim() R20 gotcha.                                           #
#--------------------------------------------------------------#

# Session cache for class-name -> source-file resolution (top-level init: reading
# an uninitialized $global raises R24, so it must exist before any func runs).
$aStzClassSrcCache = []

# Function words filtered out of a QUERY before lexical scoring, so a question
# matches on its CONTENT words ("mood", "language") not its glue ("what", "is",
# "the"). Top-level init for the same R24 reason.
# Session cache for the test-sample index (Layer 3): method name -> the scenario
# titles that exercise it (extra retrieval keywords) + one runnable example. Built
# lazily once from test/**/*_narrated.ring. Top-level init for the R24 reason.
$aStzExampleIndex = []      # [ [ methodLower, titles, exampleCode, file ], ... ]
$aStzExampleKeys  = []      # parallel keys list for fast ring_find
$bStzExampleIndexBuilt = FALSE

# Ubiquitous PLUMBING methods -- called for display/setup in nearly every scenario
# (? o.Content(), o.Show()...), so linking them to those scenarios' titles is pure
# noise (they are never the answer to "how do I X"). Excluded from the L3 index.
$aStzExamplePlumbing = [ "content", "show", "string", "tostring", "stztype", "copy",
	"init", "q", "qq", "qqq", "stringify", "print", "display", "value", "object" ]

# NAME GENERATION -- user verb -> Softanza base verb (the head of the expression).
# Top-level init (statements after a func in a loaded file don't run -> R24).
$aStzVerbMap = [
	[ "remove", "Remove" ], [ "delete", "Remove" ], [ "strip", "Remove" ], [ "erase", "Remove" ],
	[ "reverse", "Reverse" ], [ "flip", "Reverse" ], [ "invert", "Reverse" ],
	[ "find", "Find" ], [ "locate", "Find" ], [ "search", "Find" ],
	[ "replace", "Replace" ], [ "substitute", "Replace" ],
	[ "uppercase", "Uppercase" ], [ "capitalize", "Uppercase" ],
	[ "lowercase", "Lowercase" ],
	[ "sort", "Sort" ], [ "add", "Add" ], [ "insert", "Insert" ],
	[ "count", "Count" ], [ "contain", "Contains" ], [ "trim", "Trim" ],
	[ "split", "Split" ], [ "join", "Join" ], [ "repeat", "Repeat" ] ]

$aStzStopwords = [ "the", "a", "an", "of", "to", "in", "on", "at", "by", "for",
	"from", "with", "and", "or", "but", "is", "are", "was", "were", "be", "been",
	"being", "am", "this", "that", "these", "those", "it", "its", "i", "me", "my",
	"you", "your", "he", "she", "him", "her", "they", "them", "their", "we", "us",
	"our", "what", "which", "whom", "how", "do", "does", "did", "done",
	"can", "could", "would", "should", "will", "shall", "may", "might", "must",
	"have", "has", "had", "here", "there", "where", "when", "why", "as", "into",
	"over", "under", "about", "if", "then", "else", "so", "not", "no", "yes",
	"all", "any", "some", "each", "one", "get", "want", "need", "please",
	# form-directive words: they steer the FORM (see _StzQueryFormCue), they are
	# not content -- so exclude them from lexical scoring ("in place" must not let
	# "place" match a spurious method, especially under IDF).
	"place", "modify", "mutate", "destructive", "continue",
	# container nouns: the string/list IS the implicit object, not a search term,
	# so the imperative "reverse the string" reduces to the verb "reverse" and the
	# ACTIVE-form preference decides -- exactly the natural reading.
	"string", "list" ]

func _StzMethodText(paMethod)
	_c_ = _StzSplitCamel(paMethod[1])
	if len(paMethod) >= 2 and paMethod[2] != ""
		_c_ += ". " + paMethod[2]
	ok
	if len(paMethod) >= 3 and paMethod[3] != ""   # aka synonyms (retrieval only)
		_c_ += " " + paMethod[3]
	ok
	return _c_

# The full RETRIEVAL text of a method = its own text (name + intent + folded #@
# aka) PLUS the intent phrases of any test scenarios that exercise it (Layer 3)
# PLUS form-derived base-verb variants (so the active verb "reverse" finds the
# passive form "Reversed"). One place, so lexical scoring, the embedding index,
# and stzLibDoc all agree.
func _StzMethodRetrievalText(paMethod)
	# CURATED zone: name + intent + aka + form-base variants (high signal).
	_c_ = _StzMethodText(paMethod)
	_cFv_ = _StzFormBaseVariants(paMethod[1])
	if _cFv_ != "" _c_ += " " + _cFv_ ok
	# EXAMPLE-TITLE zone after a "|||" sentinel (the alnum tokenizer ignores it):
	# lexical IDF scoring weights this zone DOWN, so a rare word buried in a
	# method's test-title soup can't hijack the ranking (the IDF lesson). The
	# embedding/reranker paths just see the full text; the sentinel is inert.
	_cEg_ = _StzExampleTitlesFor(lower(paMethod[1]))
	if _cEg_ != "" _c_ += " ||| " + _cEg_ ok
	return _c_

  #==========================================================#
 #   FUNCTION FORMS -- the linguistic taxonomy of a name    #
#==========================================================#
# Softanza encodes SEMANTICS in a method's name FORM (see the function-forms
# narration): the ACTIVE form (Reverse) mutates in place; the PASSIVE form
# (Reversed / ...ed) returns a transformed COPY, original untouched; the FLUENT
# form (ReverseQ / ...Q) mutates AND returns for chaining; plus Deep.../...Many/
# IsNot.../...W/...X etc. Reading this off the name lets the NL layer stay
# semantically honest (a passive form is NOT the mutating verb) and lets Explain
# teach the distinction -- by design, no per-method hand-tagging.

# _StzParseName(name) -> [ baseWords, [formTags...] ]. A Softanza method name is a
# COMPOSITIONAL linguistic expression -- prefix* + baseVerb(+object) + form* + suffix*
# -- so it PARSES like a sentence: voice (active/passive), fluency (Q/QC), number
# (Many), mood (X statement / IsNot negative), aspect (Deep recursive / F future),
# modality (rnd random / viz visual), and parameter grammar (CS/ST/IB). This is the
# core of Softanza's design (functions-as-linguistic-expressions narration): the
# name IS the meaning. The NL layer reads that grammar instead of guessing keywords.
func _StzParseName(pcName)
	_n_ = pcName
	_tags_ = []
	# -- prefixes --
	if len(_n_) >= 1 and left(_n_, 1) = "@"  _tags_ + "partial"  _n_ = substr(_n_, 2, len(_n_) - 1) ok
	if len(_n_) > 3 and left(_n_, 3) = "viz"  _tags_ + "visual"       _n_ = substr(_n_, 4, len(_n_) - 3) ok
	if len(_n_) > 3 and left(_n_, 3) = "rnd"  _tags_ + "random"       _n_ = substr(_n_, 4, len(_n_) - 3) ok
	if len(_n_) > 3 and left(_n_, 3) = "inf"  _tags_ + "introspect"   _n_ = substr(_n_, 4, len(_n_) - 3) ok
	if len(_n_) > 3 and left(_n_, 3) = "dft"  _tags_ + "default"      _n_ = substr(_n_, 4, len(_n_) - 3) ok
	if len(_n_) > 4 and left(_n_, 4) = "Deep" _tags_ + "deep"         _n_ = substr(_n_, 5, len(_n_) - 4) ok
	# -- fluency / immutability --
	if _StzEndsWith(_n_, "QC")  _tags_ + "immutable"  _n_ = left(_n_, len(_n_) - 2)
	but len(_n_) > 1 and right(_n_, 1) = "Q"  _tags_ + "fluent"  _n_ = left(_n_, len(_n_) - 1) ok
	# -- parameter suffixes (may stack: ...STIBCS) --
	_more_ = TRUE
	while _more_
		_more_ = FALSE
		if _StzEndsWith(_n_, "CS") _tags_ + "case-sensitive" _n_ = left(_n_, len(_n_)-2) _more_ = TRUE
		but _StzEndsWith(_n_, "IB") _tags_ + "inclusive-bounds" _n_ = left(_n_, len(_n_)-2) _more_ = TRUE
		but _StzEndsWith(_n_, "ST") _tags_ + "from-position" _n_ = left(_n_, len(_n_)-2) _more_ = TRUE ok
	end
	# -- conditional / extended / statement / future / freeform --
	if _StzEndsWith(_n_, "WXT") _tags_ + "conditional" _n_ = left(_n_, len(_n_)-3)
	but _StzEndsWith(_n_, "WF")  _tags_ + "conditional" _n_ = left(_n_, len(_n_)-2)
	but _StzEndsWith(_n_, "XT")  _tags_ + "extended"    _n_ = left(_n_, len(_n_)-2)
	but _StzEndsWith(_n_, "FX")  _tags_ + "freeform"    _n_ = left(_n_, len(_n_)-2)
	but len(_n_) > 1 and right(_n_,1) = "W"  _tags_ + "conditional" _n_ = left(_n_, len(_n_)-1)
	but len(_n_) > 1 and right(_n_,1) = "X"  _tags_ + "statement"   _n_ = left(_n_, len(_n_)-1) ok
	# -- number (plural) --
	if _StzEndsWith(_n_, "Many") _tags_ + "plural" _n_ = left(_n_, len(_n_)-4) ok
	# -- exception --
	if substr(lower(_n_), "except") > 0 _tags_ + "exceptional" ok
	# -- mood: predicate / negation --
	_low_ = lower(_n_)
	if left(_low_,5) = "isnot" or left(_low_,6) = "arenot" or left(_low_,7) = "doesnot" or left(_low_,5) = "hasno"
		_tags_ + "negative"
		_tags_ + "predicate"
	but left(_low_,2) = "is" or left(_low_,3) = "are" or left(_low_,3) = "has"
		_tags_ + "predicate"
	ok
	# -- voice: active vs passive (past participle) --
	if ring_find(_tags_, "predicate") = 0
		if len(_low_) > 3 and right(_low_,2) = "ed"
			_tags_ + "passive"
		else
			_tags_ + "active"
		ok
	ok
	return [ _StzSplitCamel(_n_), _tags_ ]

# ==== NAME GENERATION -- the gloss run BACKWARDS ==========================
# The payoff of a designed, regular, invertible grammar: compose a method name
# from a natural-language intent, deterministically, NO model. _StzComposeName
# maps intent -> a candidate name by grammar; callers then VERIFY it against the
# real method inventory (so it never hallucinates -- it composes, then grounds).

# Public: audit a class's function-FORM coverage. For each single-word base verb
# that behaves like a transformation (has a passive ...ed OR fluent ...Q form), it
# reports which of the core triad {active Verb, passive Verbed, fluent VerbQ} are
# PRESENT vs MISSING -- an incomplete triad is a concrete gap for the "implement the
# forms uniformly" mission. Returns [ [baseVerb, hasActive, hasPassive, hasFluent], ...]
# for verbs missing at least one. The same grammar that generates names audits them.
func StzFormAudit(pcClass)
	_cSrc_ = _StzResolveSource(pcClass)
	if _cSrc_ = "" or NOT fexists(_cSrc_) return [] ok
	_aM_ = _StzHarvestClass(_cSrc_, pcClass)
	_aSet_ = []
	_nM_ = len(_aM_)
	for _i_ = 1 to _nM_ _aSet_ + lower(_aM_[_i_][1]) next
	# candidate base verbs = single-word bases of the class's methods
	_aBases_ = []
	for _i_ = 1 to _nM_
		_p_ = _StzParseName(_aM_[_i_][1])
		_b_ = _p_[1]
		if substr(_b_, " ") = 0 and len(_b_) >= 3 and ring_find(_aBases_, _b_) = 0
			_aBases_ + _b_
		ok
	next
	_aOut_ = []
	_nb_ = len(_aBases_)
	for _i_ = 1 to _nb_
		_v_ = _aBases_[_i_]
		_hA_ = ring_find(_aSet_, _v_) > 0
		_hP_ = (ring_find(_aSet_, _v_ + "ed") > 0) or (ring_find(_aSet_, _v_ + "d") > 0)
		_hF_ = ring_find(_aSet_, _v_ + "q") > 0
		# HIGH-SIGNAL gap: a PASSIVE form (...ed) confirms this is a transformation
		# that returns a copy -- so it SHOULD have the active + fluent siblings too.
		# Missing-passive-only is excluded (queries/actions legitimately lack it).
		if _hP_ and NOT (_hA_ and _hF_)
			_aOut_ + [ _v_, _hA_, _hP_, _hF_ ]
		ok
	next
	return _aOut_

# Public: compose a Softanza method name from an intent, grounded against a class's
# real API. Returns [ composedName, bExists, cClass ]. bExists FALSE means the
# grammar produced a valid form the class does not implement yet (a coverage gap).
func StzComposeMethodFor(pcIntent, pcClass)
	_cName_ = _StzComposeName(pcIntent)
	if _cName_ = "" return [ "", FALSE, pcClass ] ok
	_oSd_ = new stzSelfDoc(pcClass)
	return [ _cName_, _oSd_.HasMethod(_cName_), pcClass ]

func _StzComposeName(pcIntent)
	_q_ = lower(pcIntent)
	_aTok_ = _StzAlnumTokens(_q_)
	_verb_ = ""
	_nVi_ = 0
	_nT_ = len(_aTok_)
	for _i_ = 1 to _nT_
		_p_ = _StzVerbLookup(_aTok_[_i_])
		if _p_ != "" _verb_ = _p_ _nVi_ = _i_ exit ok
	next
	if _verb_ = "" return "" ok
	# form cues (word-level, so "case sensitively" etc. still tokenise to hits)
	_passive_ = _StzHasAny(_q_, [ "copy", "version", "without changing", "leaving the original", "a reversed", "an uppercase" ])
	_fluent_  = _StzHasAny(_q_, [ "and then", "then continue", "chain", "keep working" ])
	_plural_  = _StzHasAny(_q_, [ "these", "many", "several", "each of", "all of them" ])
	_deep_    = _StzHasAny(_q_, [ "nested", "recursively", "deep", "at all levels", "everywhere in" ])
	_cs_      = _StzHasAny(_q_, [ "case sensitive", "case-sensitive", "case sensitively" ])
	_random_  = _StzHasAny(_q_, [ "random", "randomly" ])
	_viz_     = _StzHasAny(_q_, [ "show", "visualize", "visualise", "see the" ])
	# object = capitalised content tokens AFTER the verb that aren't cue words
	_obj_ = ""
	for _i_ = _nVi_ + 1 to _nT_
		_w_ = _aTok_[_i_]
		if ring_find($aStzStopwords, _w_) > 0 loop ok
		if _StzIsCueWord(_w_) loop ok
		# The CONTAINER noun (the string/list/etc.) is the implicit main object,
		# not a sub-object part -- drop it, so "reverse the string" -> Reverse.
		if _StzIsContainerNoun(_w_) loop ok
		_obj_ += _StzCapFirst(_w_)
	next
	# compose: prefix* + base(voice) + object + Many + CS + Q
	_name_ = ""
	if _deep_   _name_ += "Deep" ok
	if _viz_    _name_ += "viz" ok
	if _random_ _name_ += "rnd" ok
	_base_ = _verb_
	if _passive_ _base_ = _StzPastParticiple(_verb_) ok
	_name_ += _base_ + _obj_
	if _plural_ _name_ += "Many" ok
	if _cs_     _name_ += "CS" ok
	if _fluent_ _name_ += "Q" ok
	return _name_

func _StzVerbLookup(pcWord)
	# try the word, then a couple of de-inflected stems ("reversed"/"removes"->base)
	_aCand_ = [ pcWord ]
	_lw_ = len(pcWord)
	if _lw_ > 3 and right(pcWord, 2) = "ed" _aCand_ + left(pcWord, _lw_ - 1) _aCand_ + left(pcWord, _lw_ - 2) ok
	if _lw_ > 3 and right(pcWord, 1) = "s" _aCand_ + left(pcWord, _lw_ - 1) ok
	if _lw_ > 4 and right(pcWord, 3) = "ing" _aCand_ + left(pcWord, _lw_ - 3) ok
	_nc_ = len(_aCand_)
	_nm_ = len($aStzVerbMap)
	for _c_ = 1 to _nc_
		for _i_ = 1 to _nm_
			if $aStzVerbMap[_i_][1] = _aCand_[_c_] return $aStzVerbMap[_i_][2] ok
		next
	next
	return ""

func _StzIsContainerNoun(pcW)
	return ring_find([ "string", "list", "text", "number", "numbers", "item", "items",
		"char", "chars", "character", "characters", "it", "them", "this", "that",
		"me", "some", "value", "values", "word", "words", "substring", "substrings" ], pcW) > 0

func _StzHasAny(pcHay, paNeedles)
	_n_ = len(paNeedles)
	for _i_ = 1 to _n_
		if substr(pcHay, paNeedles[_i_]) > 0 return TRUE ok
	next
	return FALSE

func _StzIsCueWord(pcW)
	return ring_find([ "copy","version","nested","recursively","deep","random","randomly",
		"show","visualize","case","sensitive","sensitively","then","chain","these","many",
		"several","original","changing","leaving","without","continue","everywhere","give",
		"get","keep","working" ], pcW) > 0

func _StzCapFirst(pcW)
	if len(pcW) = 0 return "" ok
	return upper(left(pcW, 1)) + substr(pcW, 2, len(pcW) - 1)

func _StzPastParticiple(pcVerb)
	_n_ = len(pcVerb)
	if _n_ = 0 return pcVerb ok
	if right(pcVerb, 1) = "e" return pcVerb + "d" ok
	return pcVerb + "ed"

# TRUE if the parsed tags carry a compositional MODIFIER worth spelling out in a
# gloss (beyond a plain active/passive/fluent voice, which the form-note covers).
func _StzHasRichFormTag(paTags)
	_aRich_ = [ "deep", "plural", "exceptional", "conditional", "partial",
		"negative", "statement", "immutable", "random", "visual", "extended",
		"case-sensitive", "from-position" ]
	_n_ = len(_aRich_)
	for _i_ = 1 to _n_
		if ring_find(paTags, _aRich_[_i_]) > 0 return TRUE ok
	next
	return FALSE

# _StzNameGloss(name) -- re-verbalize a name's grammar into a natural sentence
# (deterministic; the inverse is name GENERATION -- the near-natural-programming
# endgame). E.g. "AllRemovedCS" -> "returns a copy with all removed (case-sensitive)".
func _StzNameGloss(pcName)
	_p_ = _StzParseName(pcName)
	_base_ = _p_[1]
	_t_ = _p_[2]
	_lead_ = ""
	if ring_find(_t_, "predicate") > 0
		if ring_find(_t_, "negative") > 0
			_lead_ = "a negated test -- " + _base_
		else
			_lead_ = "tests whether " + _base_
		ok
	but ring_find(_t_, "passive") > 0
		_lead_ = "returns a copy: " + _base_ + " (original unchanged)"
	but ring_find(_t_, "statement") > 0
		_lead_ = "asserts that " + _base_
	else
		# active form: the imperative/acting form (states the operation; whether it
		# mutates depends on the verb -- transformers do, queries return data).
		_lead_ = _base_
	ok
	_mods_ = []
	if ring_find(_t_, "partial") > 0    _mods_ + "on a part of the object" ok
	if ring_find(_t_, "deep") > 0       _mods_ + "recursively through nested structures" ok
	if ring_find(_t_, "plural") > 0     _mods_ + "over many values at once" ok
	if ring_find(_t_, "exceptional") > 0 _mods_ + "with exceptions" ok
	if ring_find(_t_, "conditional") > 0 _mods_ + "where a condition holds" ok
	if ring_find(_t_, "case-sensitive") > 0 _mods_ + "case-sensitively" ok
	if ring_find(_t_, "from-position") > 0 _mods_ + "from a start position" ok
	if ring_find(_t_, "fluent") > 0     _mods_ + "and returns the object for chaining" ok
	if ring_find(_t_, "immutable") > 0  _mods_ + "on a safe copy (original preserved)" ok
	if ring_find(_t_, "random") > 0     _mods_ + "on random elements" ok
	if ring_find(_t_, "visual") > 0     _mods_ + "with a visual view of the result" ok
	if ring_find(_t_, "extended") > 0   _mods_ + "with extended options" ok
	if len(_mods_) = 0 return _lead_ ok
	_cM_ = ""
	_nm_ = len(_mods_)
	for _i_ = 1 to _nm_
		_cM_ += _mods_[_i_]
		if _i_ < _nm_ _cM_ += ", " ok
	next
	return _lead_ + " -- " + _cM_

# _StzFormOf(name) -> [ formLabel, baseVerb(lowercased, markers stripped) ].
func _StzFormOf(pcName)
	_n_ = pcName
	_low_ = lower(_n_)
	_len_ = len(_n_)
	if _len_ >= 5 and left(_low_, 5) = "isnot" return [ "negative", substr(_low_, 6, _len_ - 5) ] ok
	if _len_ >= 2 and left(_low_, 2) = "is"  return [ "predicate", substr(_low_, 3, _len_ - 2) ] ok
	if _len_ >= 3 and left(_low_, 3) = "are" return [ "predicate", substr(_low_, 4, _len_ - 3) ] ok
	if _len_ >= 3 and left(_low_, 3) = "has" return [ "predicate", substr(_low_, 4, _len_ - 3) ] ok
	if _len_ >= 4 and left(_low_, 4) = "deep" return [ "deep", substr(_low_, 5, _len_ - 4) ] ok
	if _len_ > 1 and right(_n_, 1) = "Q" return [ "fluent", lower(left(_n_, _len_ - 1)) ] ok
	if _len_ > 2 and right(_n_, 2) = "XT" return [ "extended", lower(left(_n_, _len_ - 2)) ] ok
	if _len_ > 2 and right(_n_, 2) = "WF" return [ "conditional", lower(left(_n_, _len_ - 2)) ] ok
	if _len_ > 1 and right(_n_, 1) = "W" return [ "conditional", lower(left(_n_, _len_ - 1)) ] ok
	if _len_ > 1 and right(_n_, 1) = "X" return [ "statement", lower(left(_n_, _len_ - 1)) ] ok
	if _len_ > 4 and right(_low_, 4) = "many" return [ "plural", left(_low_, _len_ - 4) ] ok
	if _len_ > 3 and right(_low_, 2) = "ed" return [ "passive", _low_ ] ok
	return [ "active", _low_ ]

# Active/passive/fluent TAGGING SYMMETRY: #@ aka describes the OPERATION (user
# words like "capitals", "backwards"), which is voice-NEUTRAL, so a method inherits
# its voice-sibling's aka -- tag once, all three forms of the op become findable.
# Fills the EMPTY aka of any method whose active/passive/fluent sibling HAS aka.
# In place on the harvested records; construct-and-verify (only fills siblings that
# actually EXIST), so imperfect de-inflection can't invent a bad tag.
func _StzFillSiblingAka(paMethods)
	_n_ = len(paMethods)
	if _n_ = 0 return paMethods ok
	_aNames_ = []
	for _i_ = 1 to _n_ _aNames_ + lower(paMethods[_i_][1]) next
	for _i_ = 1 to _n_
		if len(paMethods[_i_]) < 3 loop ok
		_ak_ = trim(paMethods[_i_][3])
		if _ak_ = "" loop ok
		_aBases_ = _StzSiblingBases(paMethods[_i_][1])
		_nb_ = len(_aBases_)
		for _b_ = 1 to _nb_
			_base_ = _aBases_[_b_]
			_aSibs_ = [ _base_, _base_ + "ed", _base_ + "d", _base_ + "q" ]
			for _s_ = 1 to 4
				_p_ = ring_find(_aNames_, _aSibs_[_s_])
				if _p_ > 0 and _p_ != _i_ and len(paMethods[_p_]) >= 3 and trim(paMethods[_p_][3]) = ""
					paMethods[_p_][3] = _ak_
				ok
			next
		next
	next
	return paMethods

# Candidate base verbs shared by a method's voice-siblings (lowercased): active ->
# itself; fluent -> minus Q; passive -> its de-ed stems (imperfect, but the caller
# only uses bases whose constructed siblings actually exist).
func _StzSiblingBases(pcName)
	_aF_ = _StzFormOf(pcName)
	if _aF_[1] = "fluent" return [ _aF_[2] ] ok
	if _aF_[1] = "passive" return _StzAlnumTokens(_StzEdVariants(lower(pcName))) ok
	return [ lower(pcName) ]

# For a passive/fluent form, the base-verb variants to fold into retrieval so the
# ACTIVE verb finds it ("reverse"->Reversed, "trim"->Trimmed). "" for other forms.
func _StzFormBaseVariants(pcName)
	_aF_ = _StzFormOf(pcName)
	if _aF_[1] = "passive" return _StzEdVariants(lower(pcName)) ok
	if _aF_[1] = "fluent"  return _aF_[2] ok
	return ""

# Candidate base verbs of a "...ed" word, as a keyword string. Adds both the
# drop-d ("reversed"->reverse) and drop-ed ("trimmed"->trimm->trim) stems; extra
# non-words are harmless (they match no query), the real base is always present.
func _StzEdVariants(pcW)
	_n_ = len(pcW)
	if _n_ <= 3 or right(pcW, 2) != "ed" return "" ok
	_s2_ = left(pcW, _n_ - 2)
	_s1_ = left(pcW, _n_ - 1)
	_out_ = _s1_ + " " + _s2_
	_l2_ = len(_s2_)
	if _l2_ >= 2 and _s2_[_l2_] = _s2_[_l2_ - 1]
		_out_ += " " + left(_s2_, _l2_ - 1)
	ok
	return _out_

# A one-line semantics note for Explain, or "" for the (default) active form.
func _StzFormNote(pcName)
	_f_ = _StzFormOf(pcName)[1]
	if _f_ = "passive"
		return "passive form -- returns a new transformed copy, leaving the original unchanged (use the active/mutating or ...Q/chainable sibling if you need those)"
	but _f_ = "fluent"
		return "fluent form -- transforms the object AND returns it, so calls chain"
	but _f_ = "deep"
		return "deep form -- applies recursively through nested structures"
	but _f_ = "negative"
		return "negative form -- the logical negation of the test"
	but _f_ = "plural"
		return "plural form -- applies the operation to many items at once"
	but _f_ = "conditional"
		return "conditional form -- constrains the operation with a per-item condition"
	but _f_ = "statement"
		return "statement form -- reads as a natural logical assertion"
	ok
	return ""

# What FORM the query is really after: "mutate" (in place), "chain" (fluent), or
# "" (no cue -> default to the non-destructive passive form). Keeps the NL layer
# honest about Softanza's active/passive/fluent distinction.
func _StzQueryFormCue(pcQuery)
	_q_ = lower(pcQuery)
	# PASSIVE must be asked for explicitly -- Softanza's imperative default is ACTIVE
	# ("reverse the string" = DO the reversing). Passive = a transformed COPY:
	# "a reversed copy", "a version", "return a ...", "without changing/altering the
	# original", "leaving the original".
	if substr(_q_, "copy") > 0 or substr(_q_, "version") > 0 or
	   substr(_q_, "without changing") > 0 or substr(_q_, "without altering") > 0 or
	   substr(_q_, "leaving the original") > 0 or substr(_q_, "leave the original") > 0 or
	   substr(_q_, "return a") > 0 or substr(_q_, "as a new") > 0
		return "passive"
	ok
	# FLUENT: chaining language.
	if substr(_q_, "and then") > 0 or substr(_q_, "chain") > 0 or
	   substr(_q_, "continue") > 0 or substr(_q_, "keep working") > 0
		return "chain"
	ok
	# Bare imperative -> the ACTIVE form.
	return "active"

# A small ranking prior favouring the FORM the phrasing calls for. Softanza's
# design: a bare imperative maps to the ACTIVE form (do it); the PASSIVE (a
# transformed copy) and FLUENT (chainable) forms must be asked for explicitly.
# Small: tips form ties within one operation, never overrides real relevance.
func _StzFormPreferenceBonus(pcName, pcCue)
	_f_ = _StzFormOf(pcName)[1]
	if pcCue = "passive"
		if _f_ = "passive" return 0.06 ok
		return 0
	but pcCue = "chain"
		if _f_ = "fluent" return 0.06 ok
		return 0
	else
		# default (bare imperative): prefer the ACTIVE form. Do NOT boost fluent --
		# ...Q is for chaining, and boosting it would wrongly beat a plain data
		# method (SplitQ over Split).
		if _f_ = "active" return 0.05 ok
	ok
	return 0

# The runtime class name of an object. A GLOBAL wrapper because inside a class
# with a ClassName() method, a bare `classname(This)` resolves to that method
# (case-insensitive) and raises R20; here at global scope it's the builtin.
func _StzClassNameOf(pObj)
	return classname(pObj)

# Length-ROBUST lexical relevance of a doc to a query. Bag-of-words cosine has a
# fatal length bias -- adding synonyms/aka to a method's description LENGTHENS its
# vector and DILUTES each term, so a well-tagged method can lose to a shorter
# unrelated one on a rare query word. Instead: score = fraction of the query's
# CONTENT tokens (stopwords removed) present in the doc's token set, with a tiny
# density tie-breaker so a focused doc wins an equal-coverage tie. No length
# penalty on the doc, so richer tags only ever help. Zero-setup (no model).
func _StzLexScore(pcQuery, pcDoc)
	return _StzLexScoreH(pcQuery, pcDoc, "")

# Length-robust lexical score: fraction of the query's CONTENT tokens present in
# the doc, with a tiny density tie-breaker. pcHead is accepted (heads are threaded
# through the ranker) but NOT yet used -- a first verb-headed attempt over-promoted
# generic name collisions over the aka/recipe layers and was reverted; verb-headed
# retrieval needs a term-specificity (IDF) basis, deferred. See the info-tagging
# backlog. Keeping the head plumbing inert-but-ready avoids churn when we revisit.
func _StzLexScoreH(pcQuery, pcDoc, pcHead)
	_aQ_ = _StzContentTokens(pcQuery)
	_nQ_ = len(_aQ_)
	if _nQ_ = 0 return 0 ok
	_aD_ = _StzAlnumTokens(lower(pcDoc))
	_nHit_ = 0
	for _i_ = 1 to _nQ_
		if ring_find(_aD_, _aQ_[_i_]) > 0 _nHit_++ ok
	next
	_nCov_ = _nHit_ / _nQ_
	_nDen_ = 0
	_dl_ = len(_aD_)
	if _dl_ > 0 _nDen_ = _nHit_ / _dl_ ok
	return _nCov_ + 0.001 * _nDen_

# IDF-weighted lexical ranking over the whole corpus at once: [[idx, score], ...].
# Each query token is weighted by its rarity across the method set -- a token in
# FEW methods (uppercase, mood) is specific and worth more; one in MANY (text,
# string, the) is generic and worth little. This fixes term SPECIFICITY at the
# root and, unlike the reverted verb-headed bonus, it REINFORCES the aka layer
# (a rare aka word is exactly a high-IDF token) instead of fighting it. df is
# computed only for the query's few tokens, so it stays fast even on 2000 methods.
func _StzLexScoreAllIdf(pcQuery, paTexts)
	_nT_ = len(paTexts)
	_aOut_ = []
	_aQ_ = _StzContentTokens(pcQuery)
	_nq_ = len(_aQ_)
	if _nq_ = 0 or _nT_ = 0
		for _i_ = 1 to _nT_ _aOut_ + [ _i_, 0 ] next
		return _aOut_
	ok
	# light morphological variants per query token (query-side only, so the corpus
	# is untouched and risk is low): "readable"->read, "reversed"->reverse.
	_aQV_ = []
	for _j_ = 1 to _nq_ _aQV_ + _StzStemVariants(_aQ_[_j_]) next
	# split each doc into its CURATED zone and its (down-weighted) TITLE zone at the
	# "|||" sentinel; tokenize each once (reused for df + scoring). df is counted over
	# the CURATED zone only, so IDF rarity reflects the high-signal text.
	_aCur_ = []
	_aTit_ = []
	_aDf_ = []
	for _j_ = 1 to _nq_ _aDf_ + 0 next
	for _i_ = 1 to _nT_
		_full_ = paTexts[_i_]
		_p_ = substr(_full_, "|||")
		if _p_ > 0
			_ct_ = _StzAlnumTokens(lower(left(_full_, _p_ - 1)))
			_tt_ = _StzAlnumTokens(lower(substr(_full_, _p_ + 3, len(_full_) - _p_ - 2)))
		else
			_ct_ = _StzAlnumTokens(lower(_full_))
			_tt_ = []
		ok
		_aCur_ + _ct_
		_aTit_ + _tt_
		for _j_ = 1 to _nq_
			if _StzAnyIn(_aQV_[_j_], _ct_) _aDf_[_j_]++ ok
		next
	next
	# smoothed IDF weight per query token (rarer -> higher; always > 0)
	_aW_ = []
	_wSum_ = 0
	for _j_ = 1 to _nq_
		_df_ = _aDf_[_j_]
		if _df_ < 1 _df_ = 1 ok
		_w_ = log( (_nT_ + 1.0) / _df_ )
		if _w_ <= 0 _w_ = 0.0001 ok
		_aW_ + _w_
		_wSum_ += _w_
	next
	# zone-weighted coverage: a CURATED match earns full IDF weight, a TITLE-only
	# match earns 0.3x (recall without letting the title-soup hijack ranks).
	for _i_ = 1 to _nT_
		_num_ = 0
		_hits_ = 0
		for _j_ = 1 to _nq_
			if _StzAnyIn(_aQV_[_j_], _aCur_[_i_])
				_num_ += _aW_[_j_]
				_hits_++
			but _StzAnyIn(_aQV_[_j_], _aTit_[_i_])
				_num_ += 0.3 * _aW_[_j_]
				_hits_++
			ok
		next
		_sc_ = 0
		if _wSum_ > 0 _sc_ = _num_ / _wSum_ ok
		_dl_ = len(_aCur_[_i_]) + len(_aTit_[_i_])
		if _dl_ > 0 _sc_ += 0.001 * (_hits_ / _dl_) ok
		_aOut_ + [ _i_, _sc_ ]
	next
	return _aOut_

# Conservative morphological variants of a word (itself + a stripped stem), so a
# query word matches the method's differently-inflected wording. Deliberately light
# to limit false conflations; min stem length guards keep short words intact.
func _StzStemVariants(pcW)
	_aV_ = [ pcW ]
	_n_ = len(pcW)
	# Only the SAFE derivational suffixes (-able/-ible/-ing/-ed). The plural -s and
	# adverbial -ly rules were tried and reverted: "capitals"->capital and
	# "verbs"->verb created false ties that regressed the probe set. Morphology on
	# nouns is better handled per-method by #@ aka than by blanket stripping.
	if _n_ > 6 and right(pcW, 4) = "able" _aV_ + left(pcW, _n_ - 4) ok
	if _n_ > 6 and right(pcW, 4) = "ible" _aV_ + left(pcW, _n_ - 4) ok
	if _n_ > 5 and right(pcW, 3) = "ing" _aV_ + left(pcW, _n_ - 3) ok
	if _n_ > 4 and right(pcW, 2) = "ed" _aV_ + left(pcW, _n_ - 2) _aV_ + left(pcW, _n_ - 1) ok
	return _aV_

# TRUE if any token in paNeedles is in paHay.
func _StzAnyIn(paNeedles, paHay)
	_n_ = len(paNeedles)
	for _i_ = 1 to _n_
		if ring_find(paHay, paNeedles[_i_]) > 0 return TRUE ok
	next
	return FALSE

# TRUE if token pcTok matches a token in paSet, tolerating morphology via a prefix
# rule (either is a prefix of the other, min length 4): reverse~reversed, trim~trimmed.
func _StzTokenInSet(pcTok, paSet)
	_n_ = len(paSet)
	_lt_ = len(pcTok)
	for _i_ = 1 to _n_
		_s_ = paSet[_i_]
		if pcTok = _s_ return TRUE ok
		_ls_ = len(_s_)
		if _lt_ >= 4 and _ls_ >= _lt_ and left(_s_, _lt_) = pcTok return TRUE ok
		if _ls_ >= 4 and _lt_ >= _ls_ and left(pcTok, _ls_) = _s_ return TRUE ok
	next
	return FALSE

# Distinct lowercased alphanumeric tokens of a string (a token SET as a list).
func _StzAlnumTokens(pcStr)
	_aOut_ = []
	_cCur_ = ""
	_n_ = len(pcStr)
	for _i_ = 1 to _n_
		_a_ = ascii(pcStr[_i_])
		if (_a_ >= 97 and _a_ <= 122) or (_a_ >= 48 and _a_ <= 57)
			_cCur_ += pcStr[_i_]
		else
			if _cCur_ != ""
				if ring_find(_aOut_, _cCur_) = 0 _aOut_ + _cCur_ ok
				_cCur_ = ""
			ok
		ok
	next
	if _cCur_ != "" and ring_find(_aOut_, _cCur_) = 0 _aOut_ + _cCur_ ok
	return _aOut_

# Distinct content tokens of a query: alphanumeric tokens minus stopwords. Falls
# back to all tokens if the query is entirely stopwords.
func _StzContentTokens(pcStr)
	_aAll_ = _StzAlnumTokens(lower(pcStr))
	_aOut_ = []
	_n_ = len(_aAll_)
	for _i_ = 1 to _n_
		if ring_find($aStzStopwords, _aAll_[_i_]) = 0 _aOut_ + _aAll_[_i_] ok
	next
	if len(_aOut_) = 0 return _aAll_ ok
	return _aOut_

# Dot product of two equal-length vectors (embeddings are L2-normalized).
func _StzDotVec(paA, paB)
	if NOT (isList(paA) and isList(paB)) return 0 ok
	_n_ = len(paA)
	if _n_ = 0 or len(paB) != _n_ return 0 ok
	_s_ = 0
	for _i_ = 1 to _n_
		_s_ += paA[_i_] * paB[_i_]
	next
	return _s_

# "MostSimilarByMeaning" -> "most similar by meaning" (better for embedding/match).
func _StzSplitCamel(pcName)
	_cOut_ = ""
	_n_ = len(pcName)
	for _i_ = 1 to _n_
		_c_ = pcName[_i_]
		_nC_ = ascii(_c_)
		if _i_ > 1 and _nC_ >= 65 and _nC_ <= 90
			_cOut_ += " "
		ok
		_cOut_ += _c_
	next
	return lower(_cOut_)

# Harvest [ [name, description], ... ] from a Softanza source file: each public
# `def Name(...)` with the doc-comment block immediately above it. Section header
# boxes (#===#) are not descriptions. Private methods (leading _) are skipped.
# NOTE: whole-file harvest -- grabs every def regardless of which class owns it.
# For multi-class files use _StzHarvestClass(file, name) instead.
func _StzHarvestMethods(pcFile)
	_aLines_ = str2list(read(pcFile))
	return _StzHarvestRange(_aLines_, 1, len(_aLines_))

# Harvest ONLY the methods of class pcName within pcFile (a file may hold several
# classes -- stzObject.ring alone holds many). Scans from that class's `class`
# line to the next `class`/`func` declaration. Empty pcName => whole file.
func _StzHarvestClass(pcFile, pcName)
	_aLines_ = str2list(read(pcFile))
	_nLen_ = len(_aLines_)
	if NOT (isString(pcName) and pcName != "")
		return _StzHarvestRange(_aLines_, 1, _nLen_)
	ok
	_cNL_ = lower(pcName)
	for _i_ = 1 to _nLen_
		if _StzIsClassLineNamed(trim(_aLines_[_i_]), _cNL_)
			_nEnd_ = _nLen_
			for _j_ = _i_ + 1 to _nLen_
				if _StzIsClassOrFuncDecl(trim(_aLines_[_j_]))
					_nEnd_ = _j_ - 1
					exit
				ok
			next
			return _StzHarvestRange(_aLines_, _i_ + 1, _nEnd_)
		ok
	next
	return []

# The shared harvest loop, over a line range [nStart, nEnd]. Tracks the enclosing
# SECTION title (from boxed `#==#` headers) so a method with no doc-comment of its
# own still gets a coarse semantic anchor -- e.g. every method under the "SENTIMENT
# (VADER)" box is at least tagged with that, far better than its name alone. This
# lifts undocumented methods library-wide with no per-method editing.
func _StzHarvestRange(paLines, nStart, nEnd)
	_aMethods_ = []
	_cDesc_ = ""
	_cAka_ = ""
	_cSection_ = ""
	if nStart < 1 nStart = 1 ok
	if nEnd > len(paLines) nEnd = len(paLines) ok
	for _i_ = nStart to nEnd
		_cTrim_ = trim(paLines[_i_])
		if len(_cTrim_) >= 4 and lower(left(_cTrim_, 4)) = "def "
			_cName_ = _StzDefName(_cTrim_)
			if _cName_ != "" and left(_cName_, 1) != "_"
				_cD_ = trim(_cDesc_)
				if _cD_ = "" _cD_ = _cSection_ ok
				# Record = [ name, DISPLAY desc (clean), AKA keywords ]. Keeping
				# aka separate is what lets Explain show a clean description while
				# retrieval still scores against the synonyms.
				_aMethods_ + [ _cName_, _cD_, trim(_cAka_) ]
			ok
			_cDesc_ = ""
			_cAka_ = ""
		but len(_cTrim_) >= 1 and left(_cTrim_, 1) = "#"
			if len(_cTrim_) >= 2 and left(_cTrim_, 2) = "#@"
				# #@ aka/tags/see -> user-language synonyms, into the AKA field
				# (retrieval-only). Other tags ignored here. Never touches desc.
				_cAka_ += _StzInfoTagText(_cTrim_)
			but right(_cTrim_, 1) = "#"   # a boxed line: a border OR a section title
				_cInner_ = ""
				if len(_cTrim_) >= 3 _cInner_ = trim(substr(_cTrim_, 2, len(_cTrim_) - 2)) ok
				_cTitle_ = _StzSectionTitle(_cInner_)
				if _cTitle_ != "" _cSection_ = _cTitle_ ok
				_cDesc_ = ""
			else
				_cDesc_ += " " + trim(substr(_cTrim_, 2, len(_cTrim_) - 1))
			ok
		else
			if _cTrim_ != ""   # code breaks the comment block
				_cDesc_ = ""
				_cAka_ = ""
			ok
		ok
	next
	return _aMethods_

# Extract a section TITLE from the inner text of a boxed header line: strip the
# border runs (= - # * space/tab) off both ends; "" if only border chars remain
# (a plain separator). Keeps parentheticals/digits ("stemming (snowball, 25 ...)").
func _StzSectionTitle(pcInner)
	_c_ = pcInner
	while len(_c_) > 0 and _StzIsBorderChar(left(_c_, 1))
		_c_ = substr(_c_, 2, len(_c_) - 1)
	end
	while len(_c_) > 0 and _StzIsBorderChar(right(_c_, 1))
		_c_ = left(_c_, len(_c_) - 1)
	end
	if _StzHasLetter(_c_) return lower(_c_) ok
	return ""

func _StzIsBorderChar(pc)
	return pc = "=" or pc = "-" or pc = " " or pc = "#" or pc = "*" or pc = char(9)

# Parse a `#@ <tag> <value>` InfoTag line (already trimmed, starts with "#@").
# Returns the text to FOLD into a method's retrieval description -- the value of
# aka/tags/see (commas -> spaces so tokens separate) -- or "" for tags that are
# not retrieval keywords (eg/out/...). See the info-tagging strategy doc.
func _StzInfoTagText(pcLine)
	_cRest_ = ""
	if len(pcLine) > 2 _cRest_ = trim(substr(pcLine, 3, len(pcLine) - 2)) ok
	if _cRest_ = "" return "" ok
	_sp_ = substr(_cRest_, " ")
	_cTag_ = ""
	_cVal_ = ""
	if _sp_ > 0
		_cTag_ = lower(left(_cRest_, _sp_ - 1))
		_cVal_ = trim(substr(_cRest_, _sp_ + 1, len(_cRest_) - _sp_))
	else
		_cTag_ = lower(_cRest_)
	ok
	if (_cTag_ = "aka" or _cTag_ = "tags" or _cTag_ = "see") and _cVal_ != ""
		return " " + _StzCommasToSpaces(_cVal_)
	ok
	return ""

func _StzCommasToSpaces(pcStr)
	_cOut_ = ""
	_n_ = len(pcStr)
	for _i_ = 1 to _n_
		if pcStr[_i_] = "," _cOut_ += " " else _cOut_ += pcStr[_i_] ok
	next
	return _cOut_

func _StzHasLetter(pcStr)
	_n_ = len(pcStr)
	for _i_ = 1 to _n_
		_a_ = ascii(pcStr[_i_])
		if (_a_ >= 65 and _a_ <= 90) or (_a_ >= 97 and _a_ <= 122) return TRUE ok
	next
	return FALSE

# Harvest a class's FULL method surface: its own methods + everything it inherits
# up the domain chain (child overrides parent by name), STOPPING before the
# universal root stzObject -- whose common-ground/reflection methods (Doc/Ask/
# Content...) are not domain capability and would flood every class. This is what
# makes "explain an object AND ITS METHODS" complete: e.g. stzMatrix now surfaces
# the stzListOfLists ops it inherits. Returns [ [name, desc, aka, ownerClass], ... ].
func _StzHarvestChain(pcName)
	_aOut_ = []
	_aSeen_ = []
	_cCur_ = pcName
	_nGuard_ = 0
	while isString(_cCur_) and _cCur_ != "" and _nGuard_ < 15
		_nGuard_++
		if lower(_cCur_) = "stzobject" exit ok
		_cSrc_ = _StzResolveSource(_cCur_)
		if _cSrc_ = "" or NOT fexists(_cSrc_) exit ok
		_aM_ = _StzHarvestClass(_cSrc_, _cCur_)
		_nM_ = len(_aM_)
		for _i_ = 1 to _nM_
			_cKey_ = lower(_aM_[_i_][1])
			if ring_find(_aSeen_, _cKey_) = 0
				_aSeen_ + _cKey_
				# [ name, desc(clean), aka, owner ]
				_aOut_ + [ _aM_[_i_][1], _aM_[_i_][2], _aM_[_i_][3], _cCur_ ]
			ok
		next
		_cParent_ = _StzParentOf(_cCur_)
		if isString(_cParent_) and lower(_cParent_) = lower(_cCur_) exit ok
		_cCur_ = _cParent_
	end
	return _aOut_

# The parent class of pcName (the `from X` in its `class` decl), "" if none / root.
func _StzParentOf(pcName)
	_cSrc_ = _StzResolveSource(pcName)
	if _cSrc_ = "" or NOT fexists(_cSrc_) return "" ok
	_aLines_ = str2list(read(_cSrc_))
	_cNL_ = lower(pcName)
	_n_ = len(_aLines_)
	for _i_ = 1 to _n_
		_cT_ = trim(_aLines_[_i_])
		if _StzIsClassLineNamed(_cT_, _cNL_)
			_aTok_ = _StzWords(_cT_)
			if len(_aTok_) >= 4 and lower(_aTok_[3]) = "from"
				return _aTok_[4]
			ok
			return ""
		ok
	next
	return ""

# TRUE if a trimmed line is `class <pcNameLower> ...` (Ring allows `Class` too).
func _StzIsClassLineNamed(pcTrim, pcNameLower)
	if len(pcTrim) < 6 return FALSE ok
	if lower(left(pcTrim, 6)) != "class " return FALSE ok
	_aTok_ = _StzWords(pcTrim)
	if len(_aTok_) >= 2 and lower(_aTok_[2]) = pcNameLower return TRUE ok
	return FALSE

# TRUE if a trimmed line opens a new class or func declaration (block boundary).
func _StzIsClassOrFuncDecl(pcTrim)
	if len(pcTrim) >= 6 and lower(left(pcTrim, 6)) = "class " return TRUE ok
	if len(pcTrim) >= 5 and lower(left(pcTrim, 5)) = "func " return TRUE ok
	return FALSE

# Split a string on whitespace (space/tab/CR) into words.
func _StzWords(pcStr)
	_aOut_ = []
	_cCur_ = ""
	_n_ = len(pcStr)
	for _i_ = 1 to _n_
		_c_ = pcStr[_i_]
		if _c_ = " " or _c_ = char(9) or _c_ = char(13)
			if _cCur_ != ""
				_aOut_ + _cCur_
				_cCur_ = ""
			ok
		else
			_cCur_ += _c_
		ok
	next
	if _cCur_ != ""
		_aOut_ + _cCur_
	ok
	return _aOut_

func _StzDefName(pcDefLine)   # "def Name(pa, pb)" -> "Name"
	_cRest_ = trim(substr(pcDefLine, 4, len(pcDefLine) - 3))
	_cName_ = ""
	_n_ = len(_cRest_)
	for _i_ = 1 to _n_
		_c_ = _cRest_[_i_]
		if _c_ = "(" or _c_ = " " exit ok
		_cName_ += _c_
	next
	return _cName_

func _StzLooksLikePath(pcT)
	return substr(pcT, ".ring") > 0 or substr(pcT, "/") > 0 or substr(pcT, "\") > 0

func _StzNameFromPath(pcPath)
	# last path segment without extension
	_c_ = pcPath
	_p_ = max([ _StzLastPos(_c_, "/"), _StzLastPos(_c_, "\") ])
	if _p_ > 0 _c_ = substr(_c_, _p_ + 1, len(_c_) - _p_) ok
	_e_ = substr(_c_, ".ring")
	if _e_ > 0 _c_ = left(_c_, _e_ - 1) ok
	return _c_

func _StzLastPos(pcStr, pcCh)
	_pos_ = 0
	_n_ = len(pcStr)
	for _i_ = 1 to _n_
		if pcStr[_i_] = pcCh _pos_ = _i_ ok
	next
	return _pos_

# Softanza's base/ source dir, derived from the auto-discovered $cEngineDir.
func _StzBaseDir()
	_cE_ = $cEngineDir
	if NOT isString(_cE_) or _cE_ = "" return "" ok
	if len(_cE_) >= 7 and right(_cE_, 7) = "/engine"
		return left(_cE_, len(_cE_) - 7) + "/base"
	ok
	return _cE_ + "/../base"

# The SHARED ranking brain (used by stzSelfDoc AND stzLibDoc). Score `paTexts`
# (each a method's "name-as-words + description") against a question with the best
# available model, newest-first strategy:
#   - a RERANKER head loaded -> lexical-narrow to a pool, then CROSS-ENCODE that
#     pool (retrieve-then-rerank; needs only the reranker, never two models);
#   - an EMBEDDING model + a prebuilt vector index -> bi-encoder cosine;
#   - neither -> lexical bag-of-words cosine (zero-setup).
# Returns [[idx, score], ...] sorted desc, top n.
func _StzRankMethodTexts(pcQuestion, paTexts, paVectors, n)
	return _StzRankMethodTextsBonus(pcQuestion, paTexts, paVectors, n, [])

# As above, plus an optional per-text additive BONUS (paBonus[i], same length as
# paTexts). Callers use it to give an object's OWN methods a small prior over the
# generic ones it inherits: when you ask an object about ITSELF, its purpose-built
# methods should win near-ties against inherited utilities (a terse-named inherited
# method must not beat a well-matched own method on a stopword). The bonus is small,
# so it only tips genuine ties -- a strongly-matching inherited method still wins.
func _StzRankMethodTextsBonus(pcQuestion, paTexts, paVectors, n, paBonus)
	return _StzRankMethodTextsHeaded(pcQuestion, paTexts, paVectors, n, paBonus, [])

# As above, plus per-text HEAD words (paHeads[i] = the method's base verb+object,
# from _StzParseName). The lexical path weights a query token that matches the head
# far above one matching a modifier/example word (verb-headed retrieval). paHeads []
# => plain scoring. The head only shapes the LEXICAL path; embeddings/reranker
# already capture semantics.
func _StzRankMethodTextsHeaded(pcQuestion, paTexts, paVectors, n, paBonus, paHeads)
	_nT_ = len(paTexts)
	_bH_ = (isList(paHeads) and len(paHeads) = _nT_)
	_aSc_ = []
	if StzHasRerankerModel()
		_aCand_ = _StzLexicalTopKIdxH(pcQuestion, paTexts, paHeads, 25)
		_nc_ = len(_aCand_)
		for _i_ = 1 to _nc_
			_idx_ = _aCand_[_i_]
			_aSc_ + [ _idx_, StzEngineNeuralRerank(pcQuestion, paTexts[_idx_]) ]
		next
	but StzHasNeuralModel() and len(paVectors) = _nT_
		_qv_ = _StzEmbedInto(pcQuestion)
		for _i_ = 1 to _nT_
			_aSc_ + [ _i_, _StzDotVec(_qv_, paVectors[_i_]) ]
		next
	else
		# zero-setup lexical path: IDF-weighted coverage over the whole corpus.
		_aSc_ = _StzLexScoreAllIdf(pcQuestion, paTexts)
	ok
	if isList(paBonus) and len(paBonus) = _nT_
		_ns_ = len(_aSc_)
		for _i_ = 1 to _ns_
			_aSc_[_i_][2] += paBonus[ _aSc_[_i_][1] ]
		next
	ok
	return _StzTopNScored(_aSc_, n)

# Model-free lexical prefilter: indices of the top-k texts by head-aware lexical
# score (the pool the reranker then cross-encodes).
func _StzLexicalTopKIdx(pcQuestion, paTexts, k)
	return _StzLexicalTopKIdxH(pcQuestion, paTexts, [], k)

func _StzLexicalTopKIdxH(pcQuestion, paTexts, paHeads, k)
	_bH_ = (isList(paHeads) and len(paHeads) = len(paTexts))
	_aSc_ = []
	_n_ = len(paTexts)
	for _i_ = 1 to _n_
		_h_ = ""
		if _bH_ _h_ = paHeads[_i_] ok
		_aSc_ + [ _i_, _StzLexScoreH(pcQuestion, paTexts[_i_], _h_) ]
	next
	_aTop_ = _StzTopNScored(_aSc_, k)
	_aIdx_ = []
	_nt_ = len(_aTop_)
	for _i_ = 1 to _nt_
		_aIdx_ + _aTop_[_i_][1]
	next
	return _aIdx_

# Top-n of [idx, score] pairs by descending score (selection sort; small n).
func _StzTopNScored(paScored, n)
	_aP_ = paScored
	_nn_ = len(_aP_)
	_nTop_ = n
	if _nTop_ > _nn_ _nTop_ = _nn_ ok
	for _i_ = 1 to _nTop_
		_iMax_ = _i_
		for _j_ = _i_ + 1 to _nn_
			if _aP_[_j_][2] > _aP_[_iMax_][2] _iMax_ = _j_ ok
		next
		if _iMax_ != _i_
			_t_ = _aP_[_i_]
			_aP_[_i_] = _aP_[_iMax_]
			_aP_[_iMax_] = _t_
		ok
	next
	_aOut_ = []
	for _i_ = 1 to _nTop_ _aOut_ + _aP_[_i_] next
	return _aOut_

# Resolve a class name to its source file (cached per session). Fast path:
# Softanza's file-per-class convention (<name>.ring in a base subfolder).
# Fallback: scan each subfolder's .ring files for a `class <name>` declaration,
# so classes whose FILE name differs from the class name resolve too (e.g.
# stzListOfStrings lives in stzStringList.ring, stzChar in stzStringChar.ring).
func _StzResolveSource(pcName)
	_cKey_ = lower(pcName)
	_nc_ = len($aStzClassSrcCache)
	for _i_ = 1 to _nc_
		if $aStzClassSrcCache[_i_][1] = _cKey_ return $aStzClassSrcCache[_i_][2] ok
	next
	_cPath_ = _StzResolveSourceScan(pcName)
	$aStzClassSrcCache + [ _cKey_, _cPath_ ]
	return _cPath_

func _StzResolveSourceScan(pcName)
	_cBase_ = _StzBaseDir()
	if _cBase_ = "" return "" ok
	_cRoot_ = _cBase_ + "/" + pcName + ".ring"
	if fexists(_cRoot_) return _cRoot_ ok
	_aEntries_ = dir(_cBase_)
	_n_ = len(_aEntries_)
	# fast path: file named exactly like the class
	for _i_ = 1 to _n_
		if _aEntries_[_i_][2] = 1
			_cCand_ = _cBase_ + "/" + _aEntries_[_i_][1] + "/" + pcName + ".ring"
			if fexists(_cCand_) return _cCand_ ok
		ok
	next
	# fallback: content scan for `class <name>` (file name != class name)
	_cNameLower_ = lower(pcName)
	for _i_ = 1 to _n_
		if _aEntries_[_i_][2] = 1
			_cHit_ = _StzScanFolderForClass(_cBase_ + "/" + _aEntries_[_i_][1], _cNameLower_)
			if _cHit_ != "" return _cHit_ ok
		ok
	next
	return ""

func _StzScanFolderForClass(pcFolder, pcNameLower)
	_aF_ = dir(pcFolder)
	_n_ = len(_aF_)
	for _i_ = 1 to _n_
		if _aF_[_i_][2] = 0 and _StzEndsWith(lower(_aF_[_i_][1]), ".ring")
			_cPath_ = pcFolder + "/" + _aF_[_i_][1]
			if _StzFileHasClass(lower(read(_cPath_)), pcNameLower)
				return _cPath_
			ok
		ok
	next
	return ""

# TRUE if lowercased content declares `class <name>` (name followed by a word
# boundary, so "stzListOfStrings" doesn't match "stzListOfStringsError").
func _StzFileHasClass(pcContentLower, pcNameLower)
	_needle_ = "class " + pcNameLower
	if substr(pcContentLower, _needle_ + " ") > 0 return TRUE ok
	if substr(pcContentLower, _needle_ + nl) > 0 return TRUE ok
	if substr(pcContentLower, _needle_ + char(13)) > 0 return TRUE ok
	if substr(pcContentLower, _needle_ + char(9)) > 0 return TRUE ok
	return FALSE

func _StzEndsWith(pcStr, pcSuffix)
	_ls_ = len(pcSuffix)
	if len(pcStr) < _ls_ return FALSE ok
	return right(pcStr, _ls_) = pcSuffix

  #==========================================================#
 #   INTENT RECIPES (Layer 4 of the info-tagging strategy)  #
#==========================================================#
# Atomic "one intent -> one solution" docs under doc/quickers/recipes/**. Each is
# a knowledge record the retrieval index unions in alongside methods, so a
# conversational "how do I X" query surfaces a runnable snippet, not just a name.

# The standard recipes directory (under base/), or "" if base can't be located.
func _StzRecipesDir()
	_cB_ = _StzBaseDir()
	if _cB_ = "" return "" ok
	return _cB_ + "/doc/quickers/recipes"

# Harvest every recipe under pcFolder (and its immediate subfolders) into records
# [ intent, tags, methodsCSV, example, file ]. Files without an "# Intent:" line
# are skipped (not recipes).
func _StzHarvestRecipes(pcFolder)
	_aOut_ = []
	if NOT (isString(pcFolder) and pcFolder != "") return _aOut_ ok
	_aFiles_ = _StzMdFilesUnder(pcFolder)
	_n_ = len(_aFiles_)
	for _i_ = 1 to _n_
		_aR_ = _StzParseRecipe(_aFiles_[_i_])
		if len(_aR_) > 0 _aOut_ + _aR_ ok
	next
	return _aOut_

# .md files directly in pcFolder plus those one subfolder deep.
func _StzMdFilesUnder(pcFolder)
	_aOut_ = []
	if NOT direxists(pcFolder) return _aOut_ ok
	_aE_ = dir(pcFolder)
	_n_ = len(_aE_)
	for _i_ = 1 to _n_
		_cN_ = _aE_[_i_][1]
		if _aE_[_i_][2] = 0
			if _StzEndsWith(lower(_cN_), ".md") _aOut_ + (pcFolder + "/" + _cN_) ok
		but _cN_ != "." and _cN_ != ".."
			_cSub_ = pcFolder + "/" + _cN_
			if direxists(_cSub_)
				_aS_ = dir(_cSub_)
				_m_ = len(_aS_)
				for _j_ = 1 to _m_
					if _aS_[_j_][2] = 0 and _StzEndsWith(lower(_aS_[_j_][1]), ".md")
						_aOut_ + (_cSub_ + "/" + _aS_[_j_][1])
					ok
				next
			ok
		ok
	next
	return _aOut_

# Parse one recipe file -> [ intent, tags, methodsCSV, example, file ] or [] if it
# has no "# Intent:" line. The example is the concatenated fenced ```ring block(s).
func _StzParseRecipe(pcFile)
	_aLines_ = str2list(read(pcFile))
	_cIntent_ = ""
	_cTags_ = ""
	_cMethods_ = ""
	_cEg_ = ""
	_bCode_ = FALSE
	_n_ = len(_aLines_)
	for _i_ = 1 to _n_
		_cRaw_ = _aLines_[_i_]
		_cT_ = trim(_cRaw_)
		if len(_cT_) >= 3 and left(_cT_, 3) = "```"
			_bCode_ = NOT _bCode_
			loop
		ok
		if _bCode_
			_cEg_ += _cRaw_ + nl
			loop
		ok
		_cV_ = _StzLineTagValue(_cT_, "# intent:")
		if _cV_ != "" _cIntent_ = _cV_ loop ok
		_cV_ = _StzLineTagValue(_cT_, "tags:")
		if _cV_ != "" _cTags_ = _cV_ loop ok
		_cV_ = _StzLineTagValue(_cT_, "methods:")
		if _cV_ != "" _cMethods_ = _cV_ loop ok
	next
	if _cIntent_ = "" return [] ok
	return [ _cIntent_, _cTags_, _cMethods_, trim(_cEg_), pcFile ]

# If the de-marked-down line starts with pcTagLower, return the text after it;
# else "". Strips markdown bold (*) and a leading "- " bullet first.
func _StzLineTagValue(pcLine, pcTagLower)
	_c_ = _StzDeMarkdown(pcLine)
	_cLow_ = lower(_c_)
	_lt_ = len(pcTagLower)
	if len(_cLow_) >= _lt_ and left(_cLow_, _lt_) = pcTagLower
		return trim(substr(_c_, _lt_ + 1, len(_c_) - _lt_))
	ok
	return ""

func _StzDeMarkdown(pcLine)
	_c_ = ""
	_n_ = len(pcLine)
	for _i_ = 1 to _n_
		if pcLine[_i_] != "*" _c_ += pcLine[_i_] ok
	next
	_c_ = trim(_c_)
	if len(_c_) >= 2 and left(_c_, 2) = "- " _c_ = trim(substr(_c_, 3, len(_c_) - 2)) ok
	return _c_

  #==========================================================#
 #   TEST-SAMPLE HARVEST (Layer 3 of the info-tagging plan) #
#==========================================================#
# The narrated scenario suites already pair an intent-titled Scenario(...) with
# runnable code + #--> outputs. Harvest them ONCE into an index keyed by the
# methods each scenario exercises, so (a) a method becomes findable by the real
# intent phrases written in its tests, and (b) Explain can show a provably-running
# example -- library-wide, at zero authoring cost.

# Titles that exercise cMethodLower, as one keyword string ("" if none).
func _StzExampleTitlesFor(pcMethodLower)
	_StzEnsureExampleIndex()
	_pos_ = ring_find($aStzExampleKeys, pcMethodLower)
	if _pos_ = 0 return "" ok
	return $aStzExampleIndex[_pos_][2]

# A runnable example for cMethodLower: [ titles, code, file ] or [].
func _StzExampleFor(pcMethodLower)
	_StzEnsureExampleIndex()
	_pos_ = ring_find($aStzExampleKeys, pcMethodLower)
	if _pos_ = 0 return [] ok
	_r_ = $aStzExampleIndex[_pos_]
	return [ _r_[2], _r_[3], _r_[4] ]

func _StzEnsureExampleIndex()
	if $bStzExampleIndexBuilt return ok
	$bStzExampleIndexBuilt = TRUE
	_cB_ = _StzBaseDir()
	if _cB_ = "" return ok
	# Harvest EVERY test .ring that uses Scenario() -- not just files named
	# *_narrated.ring -- so a module's scenarios light up however the grind has
	# them arranged (stzString alone has ~1000 in numbered files). ~2s, cached.
	_aFiles_ = []
	_StzCollectTestRing(_cB_ + "/test", _aFiles_, 0)
	_nf_ = len(_aFiles_)
	# Fast path: load a valid PERSISTED cache instead of re-reading all ~4693 test
	# files (a ~100s cold-cache stall on the first Ask). The directory WALK above is
	# metadata-cheap; the expensive part was reading every file, which the cache skips.
	# Signature = the test .ring file count (a rename/add/remove invalidates it).
	if _StzLoadExampleCache(_nf_) return ok
	for _i_ = 1 to _nf_
		if NOT fexists(_aFiles_[_i_]) loop ok
		_cContent_ = read(_aFiles_[_i_])
		if substr(_cContent_, "Scenario(") = 0 loop ok
		_aScn_ = _StzParseScenariosText(_cContent_)
		_ns_ = len(_aScn_)
		for _s_ = 1 to _ns_
			_cTitle_ = _aScn_[_s_][1]
			_cCode_  = _aScn_[_s_][2]
			_aMeth_  = _StzExtractMethodCalls(_cCode_)
			_nm_ = len(_aMeth_)
			# Skip kitchen-sink scenarios (many methods -> each link is weak) and
			# plumbing methods (display/setup noise). Focused scenarios give the
			# cleanest method<->intent signal.
			if _nm_ > 6 loop ok
			for _m_ = 1 to _nm_
				_k_ = lower(_aMeth_[_m_])
				if ring_find($aStzExamplePlumbing, _k_) > 0 loop ok
				_pos_ = ring_find($aStzExampleKeys, _k_)
				if _pos_ = 0
					$aStzExampleKeys + _k_
					$aStzExampleIndex + [ _k_, _cTitle_, _cCode_, _aFiles_[_i_] ]
				else
					# Cap accumulated titles so a hot method (contains, split...)
					# used in hundreds of scenarios keeps a bounded record.
					if len($aStzExampleIndex[_pos_][2]) < 800
						$aStzExampleIndex[_pos_][2] += " " + _cTitle_
					ok
				ok
			next
		next
	next
	_StzSaveExampleCache(_nf_)

# The persisted example-index cache path (under doc/, gitignored via *.stzcache).
func _StzExampleCachePath()
	_cB_ = _StzBaseDir()
	if _cB_ = "" return "" ok
	return _cB_ + "/doc/reflect_example_index.stzcache"

# Load the index from the cache IF its signature matches nSig (the current test
# file count). Returns TRUE on a valid load. Any malformed/stale/missing cache ->
# FALSE (caller rebuilds). Reconstructs the 4-field records with code left empty
# (Explain only shows the titles, so the example code is not persisted).
func _StzLoadExampleCache(nSig)
	_cPath_ = _StzExampleCachePath()
	if _cPath_ = "" or NOT fexists(_cPath_) return FALSE ok
	_c_ = read(_cPath_)
	if _c_ = "" return FALSE ok
	_aLines_ = str2list(_c_)
	if len(_aLines_) < 1 return FALSE ok
	_cSig_ = trim(_aLines_[1])
	if len(_cSig_) < 5 or left(_cSig_, 4) != "SIG " return FALSE ok
	if number(substr(_cSig_, 5, len(_cSig_) - 4)) != nSig return FALSE ok
	$aStzExampleIndex = []
	$aStzExampleKeys = []
	_nl_ = len(_aLines_)
	for _i_ = 2 to _nl_
		_ln_ = trim(_aLines_[_i_])
		if _ln_ = "" loop ok
		_aP_ = _StzSplitOnChar(_ln_, char(1))
		if len(_aP_) >= 3
			$aStzExampleKeys + _aP_[1]
			$aStzExampleIndex + [ _aP_[1], _aP_[2], "", _aP_[3] ]
		ok
	next
	return TRUE

# Persist the index: line 1 = "SIG <count>", then one "key\x01titles\x01file" per
# entry (titles/file never contain \x01 or newline). Best-effort -- write failure
# just means the next session rebuilds; never fatal.
func _StzSaveExampleCache(nSig)
	_cPath_ = _StzExampleCachePath()
	if _cPath_ = "" return ok
	_c_ = "SIG " + nSig + nl
	_n_ = len($aStzExampleIndex)
	for _i_ = 1 to _n_
		_r_ = $aStzExampleIndex[_i_]
		_c_ += _r_[1] + char(1) + _r_[2] + char(1) + _r_[4] + nl
	next
	try
		write(_cPath_, _c_)
	catch
	done

# ==== EMBEDDING-INDEX PERSISTENCE ==========================================
# Embedding all of a class's methods is ~80ms each (170s for stzString's 2000+),
# so the neural bi-encoder index is persisted to disk keyed by (model dims + the
# retrieval-texts signature). A warm session LOADS the vectors instead of re-
# embedding. Same idea as the L3 cache. Vectors are stored index-aligned with the
# method order (the signature guarantees the set+order match), so no names needed.

func _StzEmbCachePath(pcClass)
	_cB_ = _StzBaseDir()
	if _cB_ = "" return "" ok
	return _cB_ + "/doc/.emb_" + lower(pcClass) + ".stzcache"

# Cheap signature of the retrieval texts: count + total length + first-char sum.
# Any aka/intent edit changes a length -> the cache invalidates and re-embeds.
func _StzTextsSig(paTexts)
	_n_ = len(paTexts)
	_s_ = _n_
	for _i_ = 1 to _n_
		_s_ += len(paTexts[_i_])
		if len(paTexts[_i_]) > 0 _s_ += ascii(paTexts[_i_][1]) ok
	next
	return _s_

# Load cached vectors IF (model dims, count, texts-signature) all match; else [].
func _StzLoadEmbCache(pcClass, paTexts)
	_cPath_ = _StzEmbCachePath(pcClass)
	if _cPath_ = "" or NOT fexists(_cPath_) return [] ok
	_aLines_ = str2list(read(_cPath_))
	if len(_aLines_) < 1 return [] ok
	_aHW_ = _StzWords(trim(_aLines_[1]))
	if len(_aHW_) < 4 or _aHW_[1] != "EMB" return [] ok
	if number(_aHW_[2]) != StzEngineNeuralModelNEmbd() return [] ok
	if number(_aHW_[3]) != len(paTexts) return [] ok
	if number(_aHW_[4]) != _StzTextsSig(paTexts) return [] ok
	_aV_ = []
	_nl_ = len(_aLines_)
	for _i_ = 2 to _nl_
		_ln_ = trim(_aLines_[_i_])
		if _ln_ != "" _aV_ + _StzStrToFloats(_ln_) ok
	next
	return _aV_

func _StzSaveEmbCache(pcClass, paTexts, paVectors)
	_cPath_ = _StzEmbCachePath(pcClass)
	if _cPath_ = "" return ok
	_c_ = "EMB " + StzEngineNeuralModelNEmbd() + " " + len(paTexts) + " " + _StzTextsSig(paTexts) + nl
	_n_ = len(paVectors)
	for _i_ = 1 to _n_
		_c_ += _StzFloatsToStr(paVectors[_i_]) + nl
	next
	try
		write(_cPath_, _c_)
	catch
	done

func _StzFloatsToStr(paV)
	_c_ = ""
	_n_ = len(paV)
	for _i_ = 1 to _n_
		_c_ += paV[_i_]
		if _i_ < _n_ _c_ += "," ok
	next
	return _c_

func _StzStrToFloats(pcS)
	_aP_ = _StzSplitOnChar(pcS, ",")
	_aV_ = []
	_n_ = len(_aP_)
	for _i_ = 1 to _n_
		_aV_ + number(_aP_[_i_])
	next
	return _aV_

# Split a string on a single-character separator into fields (empty fields kept).
func _StzSplitOnChar(pcStr, pcCh)
	_aOut_ = []
	_cCur_ = ""
	_n_ = len(pcStr)
	for _i_ = 1 to _n_
		if pcStr[_i_] = pcCh
			_aOut_ + _cCur_
			_cCur_ = ""
		else
			_cCur_ += pcStr[_i_]
		ok
	next
	_aOut_ + _cCur_
	return _aOut_

# Recursively collect every .ring file under a folder (depth-bounded).
func _StzCollectTestRing(pcFolder, aOut, nDepth)
	if nDepth > 6 or NOT direxists(pcFolder) return ok
	_aE_ = dir(pcFolder)
	_n_ = len(_aE_)
	for _i_ = 1 to _n_
		_cN_ = _aE_[_i_][1]
		if _aE_[_i_][2] = 0
			if _StzEndsWith(lower(_cN_), ".ring") aOut + (pcFolder + "/" + _cN_) ok
		but _cN_ != "." and _cN_ != ".."
			_StzCollectTestRing(pcFolder + "/" + _cN_, aOut, nDepth + 1)
		ok
	next

# Parse a file's scenarios: [ [title, code], ... ], one per Scenario(...) block.
func _StzParseScenarios(pcFile)
	return _StzParseScenariosText(read(pcFile))

func _StzParseScenariosText(pcContent)
	_aLines_ = str2list(pcContent)
	_aOut_ = []
	_cTitle_ = ""
	_cCode_ = ""
	_bIn_ = FALSE
	_n_ = len(_aLines_)
	for _i_ = 1 to _n_
		_cT_ = trim(_aLines_[_i_])
		if len(_cT_) >= 9 and left(_cT_, 9) = "Scenario("
			_cTitle_ = _StzFirstQuoted(_cT_)
			_cCode_ = ""
			_bIn_ = TRUE
		but len(_cT_) >= 12 and left(_cT_, 12) = "EndScenario("
			if _bIn_ and _cTitle_ != "" _aOut_ + [ _cTitle_, _cCode_ ] ok
			_bIn_ = FALSE
			_cTitle_ = ""
		else
			if _bIn_ _cCode_ += _aLines_[_i_] + nl ok
		ok
	next
	return _aOut_

# The content of the first "..." on a line ("" if none).
func _StzFirstQuoted(pcLine)
	_p1_ = substr(pcLine, '"')
	if _p1_ = 0 return "" ok
	_cRest_ = substr(pcLine, _p1_ + 1, len(pcLine) - _p1_)
	_p2_ = substr(_cRest_, '"')
	if _p2_ = 0 return "" ok
	return left(_cRest_, _p2_ - 1)

# Distinct PascalCase method names called as `.Name(` in a code block.
func _StzExtractMethodCalls(pcCode)
	_aOut_ = []
	_n_ = len(pcCode)
	_i_ = 1
	while _i_ < _n_
		if pcCode[_i_] = "."
			_a_ = ascii(pcCode[_i_ + 1])
			if _a_ >= 65 and _a_ <= 90   # next char is A-Z
				_cId_ = ""
				_j_ = _i_ + 1
				while _j_ <= _n_
					_c_ = pcCode[_j_]
					_ac_ = ascii(_c_)
					if (_ac_ >= 65 and _ac_ <= 90) or (_ac_ >= 97 and _ac_ <= 122) or (_ac_ >= 48 and _ac_ <= 57)
						_cId_ += _c_
						_j_++
					else
						exit
					ok
				end
				if _j_ <= _n_ and pcCode[_j_] = "(" and _cId_ != ""
					if ring_find(_aOut_, _cId_) = 0 _aOut_ + _cId_ ok
				ok
				_i_ = _j_
			else
				_i_++
			ok
		else
			_i_++
		ok
	end
	return _aOut_
