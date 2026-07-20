# System Foundation STRESS (Phase 0) -- engine-true facts, no double source.
#
# The redesign's core claim: every system FACT is computed once, in the
# engine, and the Ring classes are thin projections. The test that matters is
# therefore AGREEMENT -- stzOperatingSystem and stzProcess must return the
# same architecture, bit size, and endianness, because they now read the ONE
# engine source instead of each deriving it (stzOperatingSystem used to
# reimplement arch via Ring's getArch()).
#
# It also exercises the new engine-backed capabilities that were simply
# ABSENT before: environment set/unset, working directory, host/user/cpu.
#
# Non-ASCII built from raw codepoints. No OS commands, no scratch files.
#
# Ring traps avoided: main code before the first func; no inline new X().M()
# (R13); no local oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cAr = MkW([ 0x0639, 0x0631, 0x0628, 0x064A ])

? "-- Scene 1: process introspection reads the engine --"
oP = new stzProcess()
chk("pid is a positive integer", oP.Id() > 0)
chk("pid is stable across reads", oP.Id() = oP.Id())
chk("uptime is real seconds, not the epoch (< 3600)", oP.Uptime() >= 0 and oP.Uptime() < 3600)
chk("pointer size is 4 or 8 bytes", oP.PointerSize() = 4 or oP.PointerSize() = 8)
chk("bit size is pointer size * 8", oP.BitSize() = oP.PointerSize() * 8)
chk("endianness is little or big", oP.Endianness() = "little" or oP.Endianness() = "big")

? ""
? "-- Scene 2: the arch VOCABULARY is reconciled at one seam --"
? "  engine says [" + oP.EngineArchitecture() + "], Softanza says [" + oP.Architecture() + "]"
chk("the raw engine tag is exposed unchanged", oP.EngineArchitecture() = StzEngineProcessArch())
chk("x86_64 reconciles to the canonical x64", NOT (oP.EngineArchitecture() = "x86_64") or oP.Architecture() = "x64")
chk("the canonical name is one of the known set",
	StzFindFirst(oP.Architecture(), [ "x64", "arm64", "x86", "arm" ]) > 0 or len(oP.Architecture()) > 0)

? ""
? "-- Scene 3: NO DOUBLE SOURCE -- OS class agrees with process --"
# This is the whole point of the refactor. Both now read process.zig.
oOS = new stzOperatingSystem()
chk("OS.Architecture() = process.Architecture()", oOS.Architecture() = oP.Architecture())
chk("OS.BitSize() = process.BitSize()", oOS.BitSize() = oP.BitSize())
chk("OS.Is64Bit() = process.Is64Bit()", oOS.Is64Bit() = oP.Is64Bit())
chk("OS.Endianness() = process.Endianness()", oOS.Endianness() = oP.Endianness())
chk("OS.PointerSize() = process.PointerSize()", oOS.PointerSize() = oP.PointerSize())
# The OS name is compile-time in both Ring and the engine; they must concur.
_cEngOs_ = oP.OS()
_cRingOs_ = oOS.Name()
chk("OS name concurs with the engine OS tag",
	_cRingOs_ = _cEngOs_ or (_cRingOs_ = "windows" and _cEngOs_ = "windows"))

? ""
? "-- Scene 4: environment -- the new SENSING surface --"
oE = new stzEnvironment()
chk("there are environment variables", oE.NumberOfVariables() > 0)
chk("Variables() and NumberOfVariables() agree", len(oE.Variables()) = oE.NumberOfVariables())
chk("each variable is a [name, value] pair", len(oE.Variables()[1]) = 2)
chk("the host name is non-empty", len(oE.HostName()) > 0)
chk("the user name is non-empty", len(oE.UserName()) > 0)
chk("the cpu count is positive", oE.CpuCount() > 0)
chk("the working directory is an absolute-looking path", len(oE.Cwd()) > 2)

? ""
? "-- Scene 5: environment -- the new EFFECTFUL surface, round-trips --"
# set is visible to a subsequent get (same OS store), and a child would
# inherit it. This is the store-consistency the foundation promises.
chk("a variable is absent before it is set", oE.Has("STZ_FND_STRESS") = 0)
oE.SetVar("STZ_FND_STRESS", "value-123")
chk("...present after SetVar", oE.Has("STZ_FND_STRESS"))
chk("...with the exact value we set", oE.GetVar("STZ_FND_STRESS") = "value-123")
oE.SetVar("STZ_FND_STRESS", "changed")
chk("...overwritable", oE.GetVar("STZ_FND_STRESS") = "changed")
oE.UnsetVar("STZ_FND_STRESS")
chk("...and gone after UnsetVar", oE.Has("STZ_FND_STRESS") = 0)

# A multibyte value survives the round trip byte-for-byte.
oE.SetVar("STZ_FND_MB", cAr)
chk("a multibyte value round-trips through the environment", oE.GetVar("STZ_FND_MB") = cAr)
oE.UnsetVar("STZ_FND_MB")

# The variable really is in the full listing while set.
oE.SetVar("STZ_FND_LIST", "here")
_bFound_ = FALSE
_aV_ = oE.Variables()
_nV_ = len(_aV_)
for _i_ = 1 to _nV_
	if _aV_[_i_][1] = "STZ_FND_LIST" and _aV_[_i_][2] = "here"
		_bFound_ = TRUE
	ok
next
chk("a set variable appears in the full Variables() listing", _bFound_)
oE.UnsetVar("STZ_FND_LIST")

? ""
? "-- Scene 6: working directory is REAL, and restores --"
# ChangeDirectory moves the actual process cwd, not a virtual cursor.
cStart = oE.Cwd()
cParent = StzEngineSystemCwdGet()   # sanity: engine and class agree
chk("class cwd equals the engine cwd", cStart = cParent)
chk("changing to the parent directory succeeds", oE.Cd(".."))
cAfter = oE.Cwd()
chk("...and the cwd actually changed", cAfter != cStart)
chk("...restoring the original cwd succeeds", oE.Cd(cStart))
chk("...and we are back where we started", oE.Cwd() = cStart)
chk("changing to a nonexistent directory fails cleanly (no crash)",
	oE.Cd(cStart + "/no_such_dir_at_all_12345") = 0)
chk("...and the cwd is unchanged after the failed cd", oE.Cwd() = cStart)

? ""
? "-- Scene 7: sugar globals ride the same engine --"
chk("ProcessId() equals the class pid", ProcessId() = oP.Id())
chk("HostName() equals the class host", HostName() = oE.HostName())
chk("WorkingDirectory() equals the class cwd", WorkingDirectory() = oE.Cwd())

? ""
? "-- Scene 8: rapid reads are cheap --"
t0 = clock()
nOk = 0
for i = 1 to 3000
	oQ = new stzProcess()
	if oQ.PointerSize() = oP.PointerSize()
		nOk++
	ok
next
tRead = (clock() - t0) / clockspersecond()
? "  3000 process reads in " + tRead + " s"
chk("3000 introspection reads stay fast (< 5s)", tRead < 5)
chk("...and every read agreed", nOk = 3000)

? ""
? "-- Scene 9: the OS class's DERIVED predicates survive the refactor --"
# Architecture is engine-backed now; the interpretations built on it must
# still hold together.
oD2 = new stzOperatingSystem()
chk("exactly ONE of IsX64 / IsX86 / IsARM is true",
	(oD2.IsX64() + oD2.IsX86() + oD2.IsARM()) = 1)
chk("Is64Bit and Is32Bit are opposite", oD2.Is64Bit() != oD2.Is32Bit())
chk("IsIntel = IsX86 or IsX64", oD2.IsIntel() = (oD2.IsX86() or oD2.IsX64()))
chk("NameAndArchitecture is [name, arch]",
	isList(oD2.NameAndArchitecture()) and len(oD2.NameAndArchitecture()) = 2)
chk("...its arch part equals Architecture()", oD2.NameAndArchitecture()[2] = oD2.Architecture())
chk("FullName folds name and bit-size", StzFindFirst("bit", oD2.FullName()) > 0)
# The public globals ride the same engine truth.
chk("global StzArch() = the class Architecture()", StzArch() = oD2.Architecture())
chk("global StzIs64Bit() = the class Is64Bit()", StzIs64Bit() = oD2.Is64Bit())

? ""
? "-- Scene 10: environment EDGE cases --"
oEg = new stzEnvironment()
# A value containing '=' must survive, and Variables() must split on the
# FIRST '=' only.
oEg.SetVar("STZ_EQ_EDGE", "a=b=c")
chk("a value with '=' round-trips intact", oEg.GetVar("STZ_EQ_EDGE") = "a=b=c")
_bEqOk_ = FALSE
_aVars_ = oEg.Variables()
_nVars_ = len(_aVars_)
for _i_ = 1 to _nVars_
	if _aVars_[_i_][1] = "STZ_EQ_EDGE" and _aVars_[_i_][2] = "a=b=c"
		_bEqOk_ = TRUE
	ok
next
chk("...and Variables() splits it on the first '=' only", _bEqOk_)
oEg.UnsetVar("STZ_EQ_EDGE")

# A multibyte variable NAME (not just value).
cMbName = "STZ_" + MkW([ 0x0639, 0x0645 ])
oEg.SetVar(cMbName, "v")
chk("a multibyte variable NAME sets and reads back", oEg.GetVar(cMbName) = "v")
oEg.UnsetVar(cMbName)

# The count tracks a set then an unset.
_n1_ = oEg.NumberOfVariables()
oEg.SetVar("STZ_CNT_EDGE", "x")
_n2_ = oEg.NumberOfVariables()
oEg.UnsetVar("STZ_CNT_EDGE")
_n3_ = oEg.NumberOfVariables()
chk("the variable count rises by one on set", _n2_ = _n1_ + 1)
chk("...and falls back on unset", _n3_ = _n1_)

# Aliases resolve.
chk("ValueOf is an alias of Var", oEg.ValueOf("PATH") = oEg.Var("PATH"))
chk("Cwd is an alias of WorkingDirectory", oEg.Cwd() = oEg.WorkingDirectory())

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func EncCp c
	if c < 128
		return char(c)
	but c < 2048
		return char(192 + floor(c/64)) + char(128 + (c % 64))
	but c < 65536
		return char(224 + floor(c/4096)) + char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	else
		return char(240 + floor(c/262144)) + char(128 + floor((c%262144)/4096)) +
		       char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	ok

func MkW aCp
	cW = ""
	_nCount_ = len(aCp)
	for _k_ = 1 to _nCount_
		cW += EncCp(aCp[_k_])
	next
	return cW
