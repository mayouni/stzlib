# The declarative surface -- G4 of the GPU plane (SOFTANZA_GPU_PLAN.md).
#
# stzKernelMaker describes an elementwise computation; the ENGINE
# transpiles it to WGSL (gpu_wgsl.zig -- the capability lives below the
# faces, any binding gets it); stzGpu runs it; stzGpuBuffer keeps results
# resident so chains pay one upload and one download, total.
#
# What this suite asserts:
#   - kernel AUTHORING needs no device: ToWGSL() transpiles and shows the
#     generated kernel before any GPU init (and on GPU-less machines)
#   - the transpiler REFUSES by name: undeclared vectors, unknown
#     identifiers, reading the output, uncalled functions, foreign
#     characters -- each raises with the offender in the message
#   - a one-shot Run() computes exact values (f32-exact data)
#   - the RESIDENT form is real, asserted by the TRANSFER COUNTER: a
#     3-link chain moves exactly one upload + one download of bytes,
#     nothing between the links -- the mechanism of residency, not a vibe
#   - binding mistakes raise by name (missing vector, missing scalar,
#     unequal lengths); a missing scalar must NOT silently bind 0
#   - after Shutdown(), data paths raise clearly; authoring still works
#
# Runs the REAL classes over the real engine (narration style: every
# block runs).

load "../../stzBase.ring"

nPass = 0
nFail = 0

C_DISP = 0
C_BYTES = 2

pr()

? "-- Scene 1: authoring needs no device --"
k1 = StzKernelMakerQ()
k1.TakesVector(:A)
k1.TakesVector(:B)
k1.TakesScalar(:alpha)
k1.ReturnsVector(:C)
k1.ForEachElement('{ @C = alpha * @A + @B }')
cW = k1.ToWGSL()
? "  generated kernel (excerpt): v_c[i] = ..."
chk("the spec collapses declarations in order",
    StzFindFirst("in a", k1.Spec()) > 0 and StzFindFirst("scalar alpha", k1.Spec()) > 0)
chk("the transpile is TRANSPARENT: @C = alpha*@A+@B became WGSL verbatim",
    StzFindFirst("v_c[i] = p.s_alpha * v_a[i] + v_b[i];", cW) > 0)
chk("the kernel binds the house contract (tile at 0, params at 1)",
    StzFindFirst("@binding(0) var<uniform> tile", cW) > 0 and
    StzFindFirst("@binding(1) var<uniform> p", cW) > 0)

? ""
? "-- Scene 2: the transpiler refuses by NAME --"
chk("an undeclared vector is refused", _Refuses("a", "c", "@c = @zz + 1", "undeclared"))
chk("an unknown identifier is refused", _Refuses("a", "c", "@c = @a * mystery", "unknown name"))
chk("reading the output is refused", _Refuses("a", "c", "@c = @c + @a", "cannot be read"))
chk("a function without '(' is refused", _Refuses("a", "c", "@c = sqrt", "needs '('"))
chk("a foreign character is refused", _Refuses("a", "c", "@c = @a * 2 ; 1", "not part"))
chk("a body assigning the wrong name is refused", _Refuses("a", "c", "@a = @a", "assigns"))

? ""
? "-- Scene 3: one-shot Run, exact values --"
oG = new stzGpu
if NOT oG.IsAvailable()
    ? "  NO GPU ON THIS MACHINE -- authoring scenes above are the CI coverage"
else
    ? "  device: " + oG.DeviceName()
    nN = 1000
    aA = []
    aB = []
    for i = 1 to nN
        aA + ((i-1) / 2.0)
        aB + ((i-1) / 4.0)
    next
    # c = 2.5*(k/2) + k/4 = 1.5k -- every term f32-exact
    aC = oG.Run(k1, [ :A = aA, :B = aB, :alpha = 2.5 ])
    chk("Run returns the full vector", len(aC) = nN)
    bOk = TRUE
    for i = 1 to nN
        if aC[i] != 1.5 * (i-1)
            bOk = FALSE
            exit
        ok
    next
    chk("one-shot Run EXACT: c[k] = 1.5k", bOk)

    ? ""
    ? "-- Scene 4: the resident chain moves bytes exactly TWICE --"
    kDouble = StzKernelMakerQ()
    kDouble.TakesVector(:A)
    kDouble.ReturnsVector(:C)
    kDouble.ForEachElement('{ @C = @A * 2.0 }')
    kShift = StzKernelMakerQ()
    kShift.TakesVector(:A)
    kShift.TakesScalar(:d)
    kShift.ReturnsVector(:C)
    kShift.ForEachElement('{ @C = @A + d }')
    # warm the pipelines OUTSIDE the counted window (first compile is real work)
    oWarm = oG.UploadQ([1, 2, 3])
    oWarm.ApplyQ(kDouble).Free()
    oWarm.ApplyWithQ(kShift, [ :d = 0 ]).Free()
    oWarm.Free()

    StzEngineGpuCountersReset()
    nB0 = StzEngineGpuCounter(C_BYTES)
    b1 = oG.UploadQ(aA)                              # transfer 1: up
    b2 = b1.ApplyQ(kDouble)                          # resident
    b3 = b2.ApplyWithQ(kShift, [ :d = 100 ])         # resident
    aOut = b3.Download()                             # transfer 2: down
    chk("chain answers exactly: (k/2)*2 + 100", _ChainExact(aOut, nN))
    chk("THE RESIDENCY MECHANISM: exactly up + down crossed the bus (" +
        (2 * nN * 4) + " bytes)", StzEngineGpuCounter(C_BYTES) - nB0 = 2 * nN * 4)
    chk("two chain links = exactly two dispatches",
        StzEngineGpuCounter(C_DISP) = 2)
    b1.Free()
    b2.Free()
    b3.Free()

    ? ""
    ? "-- Scene 5: multi-input over resident buffers --"
    kSum2 = StzKernelMakerQ()
    kSum2.TakesVector(:A)
    kSum2.TakesVector(:B)
    kSum2.ReturnsVector(:C)
    kSum2.ForEachElement('{ @C = @A + @B }')
    bA = oG.UploadQ(aA)
    bB = oG.UploadQ(aB)
    bC = oG.ApplyOnQ(kSum2, [ :A = bA, :B = bB ])
    aSum = bC.Download()
    bOk = TRUE
    for i = 1 to nN
        if aSum[i] != 0.75 * (i-1)
            bOk = FALSE
            exit
        ok
    next
    chk("ApplyOnQ combines two residents exactly: k/2 + k/4 = 0.75k", bOk)
    bA.Free()
    bB.Free()
    bC.Free()

    ? ""
    ? "-- Scene 6: binding mistakes raise by name --"
    bRaised = FALSE
    try
        oG.Run(k1, [ :A = aA, :alpha = 2.5 ])
    catch
        bRaised = StzFindFirst("'b'", cCatchError) > 0
    done
    chk("a missing vector names itself", bRaised)
    bRaised = FALSE
    try
        oG.Run(k1, [ :A = aA, :B = aB ])
    catch
        bRaised = StzFindFirst("alpha", cCatchError) > 0
    done
    chk("a missing scalar names itself (never a silent 0.0)", bRaised)
    bRaised = FALSE
    try
        oG.Run(k1, [ :A = aA, :B = [1, 2, 3], :alpha = 1 ])
    catch
        bRaised = TRUE
    done
    chk("unequal vector lengths refuse", bRaised)

    ? ""
    ? "-- Scene 7: the device goes away; authoring stays --"
    StzEngineGpuShutdown()
    bRaised = FALSE
    try
        oG.UploadQ([1, 2, 3])
    catch
        bRaised = StzFindFirst("no GPU device", cCatchError) > 0
    done
    chk("data paths raise clearly without a device", bRaised)
    kAfter = StzKernelMakerQ()
    kAfter.TakesVector(:X)
    kAfter.ReturnsVector(:Y)
    kAfter.ForEachElement('{ @Y = sqrt(@X) }')
    chk("authoring still transpiles without a device",
        StzFindFirst("sqrt(v_x[i])", kAfter.ToWGSL()) > 0)
ok

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

# does a kernel with one input, one output and this body refuse with
# pcFragment in the engine's message?
func _Refuses pcInName, pcOutName, pcBody, pcFragment
	_k_ = StzKernelMakerQ()
	_k_.TakesVector(pcInName)
	_k_.ReturnsVector(pcOutName)
	_k_.ForEachElement("{ " + pcBody + " }")
	_bR_ = FALSE
	try
		_k_.ToWGSL()
	catch
		_bR_ = StzFindFirst(pcFragment, cCatchError) > 0
	done
	return _bR_

func _ChainExact paOut, pnN
	for _i_ = 1 to pnN
		if paOut[_i_] != (_i_ - 1) + 100
			return FALSE
		ok
	next
	return TRUE
