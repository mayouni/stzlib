# stzBuilder STRESS -- softanzified builds, real cross-compilation via Zig.
#
# Zig's `cc` is a drop-in C/C++ compiler that cross-compiles to ANY target with
# one -target flag, no per-target toolchain. stzBuilder wraps that declaratively
# and derives the target triple from a stzSystemProfile (a deployment system).
# This suite ACTUALLY invokes zig (auto-located) through the engine-backed
# managed child, and proves the produced binaries are genuine -- by their magic
# bytes -- from a Windows host: an ELF for Linux, a wasm module for the web.
# It also builds a RING part (most Softanza code): `ring -geo` lowers it to a C
# unit that Zig compiles WITH the Ring VM source -> a standalone binary, and the
# same source cross-compiles to a Linux ELF -- no ring.dll anywhere. And a JS
# part: embedded in a C host that links the vendored QuickJS -> one binary, host
# + Linux, no node. And the WEB composite: a freestanding-wasm part + a generated
# stz.js bridge + shell + manifest, assembled by stzWebBundle (the browser run of
# this bundle is verified separately -- Ring has no DOM).
#
# Requires zig on the machine (found via $ZIG / D:/Zig / PATH). Each build takes
# a moment; zig caches after the first.
#
# Ring traps avoided: main code before the first func; no inline new X().M();
# no local oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cCwd0 = WorkingDirectory()
cDir = cCwd0 + "/_build_scratch"
StzEngineDirCreatePath(cDir)

# C sources, written from Ring (no shell escaping). char(34)=" char(92)=\
cHello = "#include <stdio.h>" + nl +
	 "int main(void){ printf(" + char(34) + "built by stzBuilder" + char(92) + "n" + char(34) + "); return 0; }" + nl
cMinimal = "int main(void){ return 0; }" + nl
cBad = "int main(void){ this is not valid c }" + nl

cHelloSrc = cDir + "/hello.c"
cMinSrc   = cDir + "/min.c"
cBadSrc   = cDir + "/bad.c"
write(cHelloSrc, cHello)
write(cMinSrc, cMinimal)
write(cBadSrc, cBad)

? "-- Scene 1: build for the HOST, and run the result --"
oH = new stzBuilder("hello")
oH.Source(cHelloSrc).ForHost().Output(cDir + "/hello_host.exe")
oH.Build()
chk("the host build succeeded", oH.Succeeded())
chk("...exit code 0", oH.ExitCode() = 0)
chk("...the binary exists", oH.OutputExists())
oRun = SpawnProcess(cDir + "/hello_host.exe")
cRunOut = oRun.ReadOutputAll()
oRun.Wait()
oRun.Close()
chk("...and running it prints what the C printed", StzFindFirst("built by stzBuilder", cRunOut) > 0)

? ""
? "-- Scene 2: the build command is legible and rehearsable --"
aArgs = oH.Args()
chk("it is a zig cc invocation", aArgs[1] = "cc")
chk("...naming the source and the -o output", StzFindFirst("hello.c", @@(aArgs)) > 0 and StzFindFirst("-o", @@(aArgs)) > 0)
chk("...with no -target for a host build", StzFindFirst("-target", @@(aArgs)) = 0)
chk("ToCommand() shows the whole line", StzFindFirst("cc", oH.ToCommand()) > 0)

? ""
? "-- Scene 3: a target triple is derived from ANY target form --"
oT = new stzBuilder("t")
oT.ForTarget("x86_64-linux-gnu")
chk("a raw triple passes through", oT.Target() = "x86_64-linux-gnu")
oT.ForTarget(:LinuxServer)
chk("a friendly name (:LinuxServer) -> a linux triple", StzFindFirst("linux", oT.Target()) > 0)
oT.ForTarget(:Windows)
chk("...:Windows -> a windows triple", StzFindFirst("windows", oT.Target()) > 0)
oT.ForTarget(:ESP32)
chk("...:ESP32 -> a riscv MCU triple", StzFindFirst("riscv", oT.Target()) > 0)
oMac = DeclareSystem("mac")
oMac.SetOSName(:macos)
oMac.SetArchitecture(:arm64)
oT.ForTarget(oMac)
chk("a stzSystemProfile -> its triple (aarch64-macos)", oT.Target() = "aarch64-macos-none")
oT.ForHost()
chk("ForHost() clears the triple (native)", oT.Target() = "")

? ""
? "-- Scene 4: CROSS-compile for Linux, from Windows -- a REAL ELF --"
oL = new stzBuilder("min")
oL.Source(cMinSrc).ForTarget(:LinuxServer).ReleaseFast().Output(cDir + "/min_linux")
oL.Build()
chk("the cross build succeeded", oL.Succeeded())
chk("...the command carries -target x86_64-linux-gnu", StzFindFirst("x86_64-linux-gnu", oL.ToCommand()) > 0)
chk("...and the output is a genuine ELF binary (magic 7F 'ELF')", isELF(cDir + "/min_linux"))

? ""
? "-- Scene 5: CROSS-compile for the web -- a REAL wasm module --"
oW = new stzBuilder("min")
oW.Source(cMinSrc).ForTarget("wasm32-wasi").Output(cDir + "/min.wasm")
oW.Build()
chk("the wasm build succeeded", oW.Succeeded())
chk("...and the output is a genuine wasm module (magic 00 'asm')", isWASM(cDir + "/min.wasm"))

? ""
? "-- Scene 6: a broken source fails cleanly, with the compiler's words --"
oB = new stzBuilder("bad")
oB.Source(cBadSrc).ForHost().Output(cDir + "/bad.exe")
oB.Build()
chk("a bad build reports failure", oB.Failed())
chk("...with a non-zero exit", oB.ExitCode() != 0)
chk("...and the compiler diagnostics are captured", StzFindFirst("error", oB.BuildLog()) > 0)

? ""
? "-- Scene 7: build a PART for exactly the system it deploys to --"
# The scope-model connection: a deployment system IS a Zig triple.
oProduct = new stzPlatformProfile("svc")
oProduct.DevelopedOn(:Windows)
oProduct.WithServer(:backend, :LinuxServer)
oBackendSys = oProduct.App(:backend).DeploymentSystem()
oP = new stzBuilder("backend")
oP.Source(cMinSrc).ForTarget(oBackendSys).Output(cDir + "/backend_bin")
chk("the builder took the part's deployment system as its target", StzFindFirst("linux", oP.Target()) > 0)
oP.Build()
chk("...and built the backend for Linux", oP.Succeeded())
chk("...a real ELF, from this Windows box", isELF(cDir + "/backend_bin"))

? ""
? "-- Scene 8: build a RING part -- most Softanza code -- to a native binary --"
# Ring is not C, yet it reaches the SAME backend: `ring -geo` lowers it to a C
# compilation unit, Zig compiles it with the Ring VM source. The result is a
# standalone binary -- no ring.dll on the machine.
cRingSrc = cDir + "/greet.ring"
write(cRingSrc, "see " + char(34) + "built from Ring by stzBuilder" + char(34) + " + nl" + nl)
oRing = new stzBuilder("greet")
oRing.AsRing().Source(cRingSrc).ReleaseFast().Output(cDir + "/greet_host.exe")
oRing.Build()
chk("the Ring host build succeeded", oRing.Succeeded())
chk("...its args carry the generated C plus the Ring VM sources", len(oRing.Args()) > 20)
oG = SpawnProcess(cDir + "/greet_host.exe")
cGOut = oG.ReadOutputAll()
oG.Wait()
oG.Close()
chk("...and the standalone binary runs the Ring program", StzFindFirst("built from Ring by stzBuilder", cGOut) > 0)

? ""
? "-- Scene 9: cross-compile that RING part for Linux, from Windows --"
oRL = new stzBuilder("greet")
oRL.AsRing().Source(cRingSrc).ForTarget(:LinuxServer).ReleaseFast().Output(cDir + "/greet_linux")
oRL.Build()
chk("the Ring cross build succeeded", oRL.Succeeded())
chk("...and produced a genuine Linux ELF -- from a Windows box", isELF(cDir + "/greet_linux"))

? ""
? "-- Scene 10: build a JS part via the vendored QuickJS -> native binary --"
# A second non-C language through the same door: the JS source is embedded in a
# tiny C host that links QuickJS (engine/vendor/quickjs) -- one static binary.
cJsSrc = cDir + "/app.js"
write(cJsSrc, "print(" + char(34) + "built from JS by stzBuilder" + char(34) + ");" + nl)
oJs = new stzBuilder("app")
oJs.AsJs().Source(cJsSrc).Output(cDir + "/app_host.exe")
oJs.Build()
chk("the JS host build succeeded", oJs.Succeeded())
oJx = SpawnProcess(cDir + "/app_host.exe")
cJxOut = oJx.ReadOutputAll()
oJx.Wait()
oJx.Close()
chk("...and the binary runs the JS (QuickJS embedded, no node)", StzFindFirst("built from JS by stzBuilder", cJxOut) > 0)

? ""
? "-- Scene 11: cross-compile that JS part for Linux, from Windows --"
oJL = new stzBuilder("app")
oJL.AsJs().Source(cJsSrc).ForTarget(:LinuxServer).Output(cDir + "/app_linux")
oJL.Build()
chk("the JS cross build succeeded", oJL.Succeeded())
chk("...a genuine Linux ELF with the JS engine inside", isELF(cDir + "/app_linux"))

? ""
? "-- Scene 12: build a part for the WEB -- freestanding wasm, bridge ABI --"
# The web is a COMPOSITE target: a wasm module with a real bridge (JS owns the
# memory; the module imports stz_log; its exports are callable) -- not WASI.
cWebC = cDir + "/mod.c"
write(cWebC,
	"__attribute__((import_module(" + char(34) + "env" + char(34) + "), import_name(" + char(34) + "stz_log" + char(34) + ")))" + nl +
	"extern void stz_log(const char *ptr, int len);" + nl +
	"int stz_add(int a, int b){ return a + b; }" + nl +
	"static const char MSG[] = " + char(34) + "web wasm built by stzBuilder" + char(34) + ";" + nl +
	"void stz_main(void){ stz_log(MSG, sizeof(MSG) - 1); }" + nl)
oWeb = new stzBuilder("app")
oWeb.AsC().Source(cWebC).ForWeb().Export("stz_main").Export("stz_add").Output(cDir + "/app.wasm")
chk("ForWeb targets freestanding wasm", oWeb.Target() = "wasm32-freestanding")
chk("...the command imports memory and exports the named fns",
	StzFindFirst("--import-memory", oWeb.ToCommand()) > 0 and StzFindFirst("--export=stz_main", oWeb.ToCommand()) > 0)
oWeb.Build()
chk("the web wasm build succeeded", oWeb.Succeeded())
chk("...and the output is a genuine wasm module", isWASM(cDir + "/app.wasm"))

? ""
? "-- Scene 13: assemble the web COMPOSITE -- wasm + stz.js + shell + manifest --"
oBun = new stzWebBundle("app")
oBun.Title("Softanza on the Web").OutDir(cDir + "/dist")
oBun.WithWasm("app", cDir + "/app.wasm")
oBun.Build()
chk("the bundle assembled all four files",
	StzEngineFileExists(cDir + "/dist/app.wasm") = 1 and StzEngineFileExists(cDir + "/dist/stz.js") = 1 and
	StzEngineFileExists(cDir + "/dist/index.html") = 1 and StzEngineFileExists(cDir + "/dist/bundle.json") = 1)
chk("...stz.js carries the real bridge (stz_log + WebAssembly)",
	StzFindFirst("stz_log", read(cDir + "/dist/stz.js")) > 0 and StzFindFirst("WebAssembly", read(cDir + "/dist/stz.js")) > 0)
chk("...the shell loads stz.js and the wasm",
	StzFindFirst("stz.js", read(cDir + "/dist/index.html")) > 0 and StzFindFirst("app.wasm", read(cDir + "/dist/index.html")) > 0)
chk("...the manifest declares a web-bundle", StzFindFirst("web-bundle", read(cDir + "/dist/bundle.json")) > 0)

# cleanup
StzEngineDirDelete(cDir)

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

# raw byte magic checks (read() is a raw file read; substr is byte-based).
# Guarded so a build that produced no file yields FALSE, not an R35 crash.
func isELF cPath
	cR = ""
	try
		cR = read(cPath)
	catch
		return FALSE
	done
	return len(cR) >= 4 and substr(cR, 2, 3) = "ELF"

func isWASM cPath
	cR = ""
	try
		cR = read(cPath)
	catch
		return FALSE
	done
	return len(cR) >= 4 and substr(cR, 2, 3) = "asm"
