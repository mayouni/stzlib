# The whole claim, end to end: adjacency uploaded ONCE, reachability solved
# on device, the instance buffer written BY A KERNEL from the result, and
# the frame drawn -- with the only bus traffic being the picture coming back.
load "../../stzBase.ring"
C_BYTES = 2
StzGraphicsDevice()

nN = 10000  nLayers = 20  nPerL = ceil(nN / nLayers)
aOff = []  aTgt = []  nSeedV = 12345
for i = 0 to nN - 1
    aOff + len(aTgt)
    if floor(i / nPerL) < nLayers - 1
        for d = 1 to 3
            nSeedV = (nSeedV * 1103515245 + 12345) % 2147483648
            nT = i + nPerL + (nSeedV % nPerL)
            if nT < nN  aTgt + nT  ok
        next
    ok
next
aOff + len(aTgt)
nW = ceil(nN / 32)
? "graph: " + nN + " nodes, " + len(aTgt) + " edges, " + nLayers + " layers"

# the scene, one cube per node -- placeholders; the GPU will place them
oCube = StzMeshQ(:Cube)
oS = new stzScene(900, 500)
oS.SetBackgroundQ("#07090e").SetCameraQ(26, 20, 34, 0, -1, 0).
   SetLensQ(38, 0.1, 400).SetLightQ(-0.45, -1, -0.35, "#fff4e2", "#20263a")
for i = 1 to nN
    oS.AddMesh(oCube, 0, 0, 0)
next
oS.ToPixels()                       # one render so the instance buffer exists
hInst = oS.InstanceBuffer()
? "instance buffer: " + hInst + "  stride " + oS.InstanceStride() + " floats"

cSeed = read("graph_k_seed.wgsl")
cProp = read("graph_k_prop.wgsl")
cPlace = read("graph_k_place.wgsl")
hSeed = StzEngineGpuKernelCompile(cSeed)
hProp = StzEngineGpuKernelCompile(cProp)
hPlace = StzEngineGpuKernelCompile(cPlace)

hOff = StzEngineGpuBufferNew(len(aOff)*4)   hTgt = StzEngineGpuBufferNew(len(aTgt)*4)
hPar = StzEngineGpuBufferNew(16)
hA = StzEngineGpuBufferNew(nN*nW*4)         hB = StzEngineGpuBufferNew(nN*nW*4)
StzEngineGpuBufferUploadListU32(hOff, aOff)
StzEngineGpuBufferUploadListU32(hTgt, aTgt)
StzEngineGpuBufferUploadListU32(hPar, [ nN, nW, nPerL, nLayers ])
StzEngineGpuSync()

oS.SetGpuDriven(TRUE)               # the face stops writing transforms
StzEngineGpuCountersReset()
nT0 = clock()
nWX = ceil(nN / 64)
StzEngineGpuDispatch(hSeed, [ hA, hPar ], nWX, 1)
b = TRUE
for it = 1 to nLayers
    if b  StzEngineGpuDispatch(hProp, [ hA, hB, hOff, hTgt, hPar ], nWX, 1)
    else  StzEngineGpuDispatch(hProp, [ hB, hA, hOff, hTgt, hPar ], nWX, 1)  ok
    b = NOT b
next
if b  StzEngineGpuDispatch(hPlace, [ hA, hInst, hPar ], nWX, 1)
else  StzEngineGpuDispatch(hPlace, [ hB, hInst, hPar ], nWX, 1)  ok
cPng = oS.ToPNG("graph_gpu_10k.png")
nMs = (clock() - nT0) / clocksPerSecond() * 1000

aSt = oS.Stats()
? ""
? "solve + place + draw: " + nMs + " ms"
? "draw calls: " + aSt[3] + "   geometryUploads: " + aSt[4] +
  "   transformUploads: " + aSt[5] + " (frozen -- the kernel owns them)"
? "bytes on the bus for the WHOLE frame: " + StzEngineGpuCounter(C_BYTES)
? "  (the picture alone is " + (900*500*4) + " bytes)"
? "png: " + len(cPng) + " bytes"
