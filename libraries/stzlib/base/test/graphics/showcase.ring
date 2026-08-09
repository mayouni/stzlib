# SHOWCASE -- the graphics plane, drawn entirely through the GR4 faces.
# Not a guard: a demonstration, and a usability test of the declarative
# surface. Run from this directory:  ring showcase.ring

load "../../stzBase.ring"

cFixture = "../gpu/fixtures/amiri_arabic_subset.ttf"
oFont = new stzFont(cFixture)

# Arabic strings, composed byte-wise so this file needs no encoding luck
cArTitle = char(0xD8)+char(0xB3)+char(0xD9)+char(0x88)+char(0xD9)+char(0x81)+
           char(0xD8)+char(0xAA)+char(0xD8)+char(0xA7)+char(0xD9)+char(0x86)+
           char(0xD8)+char(0xB2)+char(0xD8)+char(0xA7)
cArLine  = char(0xD8)+char(0xA7)+char(0xD9)+char(0x84)+char(0xD8)+char(0xB1)+
           char(0xD8)+char(0xB3)+char(0xD9)+char(0x88)+char(0xD9)+char(0x85)+
           char(0xD8)+char(0xA7)+char(0xD8)+char(0xAA)

#===========================================================================
# 1 -- stzCanvas: shapes, gradients, strokes, and multilingual text
#===========================================================================

oC = new stzCanvas(900, 520)
oC.SetBackground("#0e1016")

# a gradient header band, then a rule under it
oC.AddGradientRect(0, 0, 900, 132, "#1b2440", "#4a2a5e", FALSE)
oC.AddRect(0, 132, 900, 2)
oC.Fill("#5a6480")

# headline, and its Arabic twin right-aligned by MEASURED width
oC.SetFont(oFont, 46)
oC.AddTextQ("Softanza Graphics", 48, 84).ColorQ("#f2f4f8")
oC.SetFont(oFont, 38)
oC.AddTextQ(cArTitle, 900 - 48 - oFont.WidthOf(cArTitle, 38), 82).
   ColorQ("#e8d4a8")

# a row of circles: fills by hex, by name, and with strokes
oC.AddCircleQ(120, 250, 62).FillQ("#e0a030")
oC.AddCircleQ(258, 250, 62).FillQ(:Cyan).StrokeQ("#ffffff", 3)
oC.AddCircleQ(396, 250, 62).FillQ("#c04070c0")          # with alpha
oC.AddCircleQ(444, 250, 62).FillQ("#3050c0c0")          # overlapping it

# a concave polygon -- ear clipping, not a triangle fan
oC.AddPolygonQ([ 590,300, 660,190, 730,300, 706,300, 706,248, 614,248, 614,300 ]).
   FillQ("#5a9ee6").StrokeQ("#dce8f8", 2)

# a polyline with round joins and caps
oC.AddPolylineQ([ 790,300, 818,206, 846,272, 874,200 ]).StrokeQ("#7ad8c8", 5)

# a small label under each specimen, centred by measuring it
aLabels = [ "hex fill", "named + stroke", "alpha blend", "ear-clipped path", "polyline" ]
aXs     = [ 120, 258, 420, 660, 832 ]
oC.SetFont(oFont, 17)
for i = 1 to len(aLabels)
    oC.AddTextQ(aLabels[i], aXs[i] - oFont.WidthOf(aLabels[i], 17) / 2, 352).
       ColorQ("#98a4bc")
next

# a mixed-direction line: Latin, Arabic and Latin in one string
cMixed = "one model -> " + cArLine + " <- two renderers"
oC.SetFont(oFont, 26)
oC.AddTextQ(cMixed, 48, 428).ColorQ("#cdd6e6")
oC.SetFont(oFont, 16)
oC.AddTextQ("the same display list answers ToSVG() with no GPU, and ToPNG() through one",
    48, 468).ColorQ("#6f7c94")
oC.AddTextQ("bidi + shaping run once, so both tiers place every glyph identically",
    48, 492).ColorQ("#6f7c94")

oC.ToPNG("showcase_canvas.png")
write("showcase_canvas.svg", oC.ToSVG())
? "1. canvas  -> showcase_canvas.png + .svg   (" + oC.ShapeCount() + " shapes)"

#===========================================================================
# 2 -- stzScene: meshes, instancing, a directional light
#===========================================================================

oCube  = StzMeshQ(:Cube)
oBall  = new stzMesh([ :Sphere, 0.55, 40, 20 ])
oFloor = new stzMesh([ :Plane, 40 ])

oS = new stzScene(900, 500)
oS.SetBackgroundQ("#0c0e14").
   SetCameraQ(9, 6.2, 11, 0, 0.4, 0).
   SetLensQ(40, 0.1, 300).
   SetLightQ(-0.55, -1, -0.42, "#fff2dc", "#2b3244")

oS.AddMeshQ(oFloor, 0, -1.2, 0).ColorQ("#39405a")

# a ring of cubes -- ONE mesh, so ONE instanced draw call
nRing = 14
for i = 0 to nRing - 1
    nA = 2 * 3.141592653589793 * i / nRing
    nH = 0.7 + 1.5 * (0.5 + 0.5 * sin(nA * 3))
    oS.AddMeshQ(oCube, 5.2 * cos(nA), -1.2 + nH/2, 5.2 * sin(nA))
    oS.ScaleQ(0.85, nH, 0.85)
    oS.RotateQ(0, 1, 0, i * 26)
    oS.ColorQ(_Wheel(i / nRing))
next

# spheres in the middle -- a second mesh, a second draw call
oS.AddMeshQ(oBall, 0, 0.5, 0).ScaleQ(1.9, 1.9, 1.9).ColorQ("#e8c060")
oS.AddMeshQ(oBall, -1.7, -0.35, 1.5).ColorQ("#68c8d8")
oS.AddMeshQ(oBall, 1.6, -0.4, 1.7).ColorQ("#c878d0")

oS.ToPNG("showcase_scene.png")
aSt = oS.Stats()
? "2. scene   -> showcase_scene.png   instances=" + aSt[1] +
  " meshes=" + aSt[2] + " drawCalls=" + aSt[3]
aPrj = oS.Project(0, 0.5, 0)
? "   Project(0,0.5,0) lands at " + floor(aPrj[1]) + "," + floor(aPrj[2]) +
  " on the picture (visible=" + aPrj[4] + ")"

#===========================================================================
# 3 -- the door just opened: a COMPUTE kernel drives the transforms
#===========================================================================

nGrid = 26
nN = nGrid * nGrid

oW = new stzScene(900, 500)
oW.SetBackgroundQ("#090b11").
   SetCameraQ(17, 13, 19, 0, -0.5, 0).
   SetLensQ(36, 0.1, 300).
   SetLightQ(-0.5, -1, -0.4, "#fff4e2", "#252b3c")
for i = 1 to nN
    oW.AddMesh(oCube, 0, 0, 0)          # placeholder: the GPU will place them
next
oW.ToPixels()                            # one render, so the buffer exists

hInst = oW.InstanceBuffer()
hPar  = StzEngineGpuBufferNew(16)
nStride = oW.InstanceStride()

cKernel = '
struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
@group(0) @binding(0) var<uniform> tile : StzTile;
@group(0) @binding(1) var<storage, read_write> inst : array<f32>;
@group(0) @binding(2) var<storage, read> par : array<f32>;
@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
  let i = gid.x + tile.xoff * 64u;
  let n = u32(par[1]);
  if (i >= n) { return; }
  let t = par[0];
  let g = u32(par[2]);
  let gx = f32(i % g);
  let gz = f32(i / g);
  let cx = (gx - (f32(g) - 1.0) * 0.5) * 1.12;
  let cz = (gz - (f32(g) - 1.0) * 0.5) * 1.12;
  let d = sqrt(cx * cx + cz * cz);
  let h = 0.35 + 2.3 * (0.5 + 0.5 * sin(d * 0.78 - t));
  let s = 0.82;
  let o = i * 36u;
  inst[o+0u]=s;   inst[o+1u]=0.0; inst[o+2u]=0.0; inst[o+3u]=0.0;
  inst[o+4u]=0.0; inst[o+5u]=h;   inst[o+6u]=0.0; inst[o+7u]=0.0;
  inst[o+8u]=0.0; inst[o+9u]=0.0; inst[o+10u]=s;  inst[o+11u]=0.0;
  inst[o+12u]=cx; inst[o+13u]=h*0.5-1.2; inst[o+14u]=cz; inst[o+15u]=1.0;
  inst[o+16u]=1.0/s; inst[o+17u]=0.0;   inst[o+18u]=0.0;   inst[o+19u]=0.0;
  inst[o+20u]=0.0;   inst[o+21u]=1.0/h; inst[o+22u]=0.0;   inst[o+23u]=0.0;
  inst[o+24u]=0.0;   inst[o+25u]=0.0;   inst[o+26u]=1.0/s; inst[o+27u]=0.0;
  inst[o+28u]=0.0;   inst[o+29u]=0.0;   inst[o+30u]=0.0;   inst[o+31u]=1.0;
  let u = clamp((h - 0.35) / 2.3, 0.0, 1.0);
  inst[o+32u] = 0.30 + 0.62 * u;
  inst[o+33u] = 0.42 + 0.30 * sin(u * 3.14159);
  inst[o+34u] = 0.86 - 0.42 * u;
  inst[o+35u] = 1.0;
}'

hK = StzEngineGpuKernelCompile(cKernel)
oW.SetGpuDriven(TRUE)                    # the face stops writing transforms
StzEngineGpuBufferUploadList(hPar, [ 2.1, nN, nGrid, 0 ])
StzEngineGpuDispatch(hK, [ hInst, hPar ], ceil(nN / 64), 1)
oW.ToPNG("showcase_gpu_driven.png")

aWs = oW.Stats()
? "3. gpu-driven -> showcase_gpu_driven.png   " + nN + " instances placed by a " +
  "COMPUTE kernel"
? "   drawCalls=" + aWs[3] + "  geometryUploads=" + aWs[4] +
  "  transformUploads=" + aWs[5] + " (frozen: the GPU owns them now)"

? ""
? "done."

# a simple colour wheel, hex out
func _Wheel(pnT)
	_nR_ = floor(128 + 110 * sin(6.2831853 * pnT))
	_nG_ = floor(128 + 110 * sin(6.2831853 * pnT + 2.094))
	_nB_ = floor(128 + 110 * sin(6.2831853 * pnT + 4.188))
	return "#" + _Hex2(_nR_) + _Hex2(_nG_) + _Hex2(_nB_)

func _Hex2(pn)
	_aD_ = "0123456789abcdef"
	if pn < 0  pn = 0  ok
	if pn > 255  pn = 255  ok
	return substr(_aD_, floor(pn / 16) + 1, 1) + substr(_aD_, (pn % 16) + 1, 1)
