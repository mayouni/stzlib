// stz_gui: RmlUi behind a flat C ABI -- G1 of base/gui/SOFTANZA_GUI_PLAN.md.
//
// WHAT THIS FILE IS: the eight pure virtuals of Rml::RenderInterface,
// implemented as a RECORDER rather than a painter. RmlUi hands out
// vertices and indices; this records them into one flat buffer, and the
// graphics plane draws it through stzCanvas.AddMesh. Nothing here touches
// a GPU, a canvas or Ring.
//
// WHY A RECORDER AND NOT A PAINTER: the house already settled this shape
// in GR2b -- one display list, two renderers, so the GPU and SVG tiers
// cannot disagree about where anything sits. A UI that painted itself
// would be a third renderer, outside that discipline and outside the
// counted-fallback rule. Recording keeps RmlUi's output as DATA, which is
// also what lets it cross a C ABI at all.
//
// WHY ITS OWN DLL: RmlUi requires C++ EXCEPTIONS and RTTI (measured in
// G0: itlib/flat_map throws, Traits.h calls typeid). stz_gpu.dll compiles
// HarfBuzz with -fno-exceptions -fno-rtti and is guarded for cross-
// compilation. Linking RmlUi into it would impose both on the whole GPU
// plane. This is the stz_window.dll precedent: a dependency with
// different requirements gets its own DLL.
//
// TWO SEAM DETAILS, both paid for rather than assumed:
//
//   1. RmlUi's vertex colour is PREMULTIPLIED alpha. The scene's blend is
//      SrcAlpha / OneMinusSrcAlpha -- STRAIGHT alpha. So the recorder
//      divides the colour back out. Without it, every translucent UI
//      surface renders too dark, and opaque ones look fine, which is the
//      worst way for a bug like this to present.
//   2. RenderGeometry carries a TRANSLATION per draw. The recorder bakes
//      it into the positions, because the display list downstream has no
//      per-draw transform and should not grow one for this.
//
// WHAT IS DROPPED, AND COUNTED (the house rule: a bounded record counts
// what it drops): textured draws and scissor regions. In G1 the font
// engine is a stub that generates no textures, so a nonzero textured
// count means something arrived that this phase cannot draw -- which is
// exactly what G2 turns on. The counters are readable from Ring.
//
// AND THE ONE THAT COST A DAY, recorded so nobody pays it twice:
//
//   A `zig build-lib -dynamic` DLL with a Zig root module gets Zig's own
//   entry point, which never runs the C CRT startup -- so C++ STATIC
//   CONSTRUCTORS NEVER RUN. Measured: a global whose constructor sets a
//   flag to 42 still reads 0 after LoadLibrary, and a DllMain added for
//   the test was never called either.
//
// It does not present as an initialisation problem. RmlUi initialises and
// creates contexts perfectly well without its constructors, then corrupts
// the HEAP (0xC0000374, raised inside ntdll) the moment a document is
// loaded. Two false trails were followed first -- forcing the `.ctors`
// list by hand, which crashes, and function-local statics, which crash
// earlier still because their guard machinery is equally absent.
//
// The fix is one flag in build.zig on this domain only:
// `lib.entry = .{ .symbol_name = "DllMainCRTStartup" }` -- mingw's real
// DLL startup, constructors included. It is verified by an isolated
// build: the same sources linked with `zig c++ -shared` (which uses that
// entry by default) work, `build-lib` without the flag does not, and
// `build-lib` with it does.
//
// The objects below are still constructed EXPLICITLY, behind POD
// pointers, rather than being file-scope globals. That is belt and
// braces: it costs nothing, and if the entry flag is ever lost this file
// keeps working instead of corrupting a heap three layers down.

#include <RmlUi/Core.h>
#include <RmlUi/Core/Input.h>

#include <cstring>
#include <string>
#include <unordered_map>
#include <vector>

#define STZ_API extern "C" __declspec(dllexport)

namespace {

// ------------------------------------------------------------- recorder

struct Geometry {
	std::vector<Rml::Vertex> vertices;
	std::vector<int> indices;
	// >= 0 when this compiled geometry IS a string: an index into the
	// font engine's text bank. See kTextMarker below.
	int text_index = -1;
};

// A string does not become quads here -- it becomes a COMMAND the
// graphics plane paints with its own copy of the same shaper. But it must
// ride RmlUi's geometry CACHE, or the command vanishes on every frame
// after the first: RmlUi calls GenerateString only when the text is
// dirty, and re-renders the compiled result forever after (G0 measured
// 500 still frames re-compiling zero geometry).
//
// So GenerateString emits a real 4-vertex quad -- the text's own box, so
// culling and sizing behave -- and hides the bank index in the first
// vertex's texture coordinate behind a marker no real UV can reach.
// CompileGeometry recognises it, RenderGeometry replays it with that
// frame's translation, and the cache does the rest.
static const float kTextMarker = 987654.0f;

// G3: an event as DATA, drained by the caller -- never a callback across
// the C ABI. Ring cannot be re-entered safely from a C++ event dispatch,
// and the house has settled this shape twice already (the display list,
// the text commands). It also keeps the Ringine charter's rule that no
// per-entity callback ever crosses the seam.
//
// `source` is the INPUT SOURCE frame, surfaced on the event because that
// is where it belongs (§7, M3): Rule 80 makes "reachable by a human
// keyboard" materially different from "something dispatched a click",
// and G4 needs an assistive activation distinguishable from a pointer.
struct Recorder_Event {
	int type = 0;     // see kEv* below
	int source = 0;   // 0 pointer, 1 keyboard, 2 gamepad, 3 synthetic, 4 assistive
	float x = 0, y = 0;
	int button = 0, key = 0, mods = 0;
	std::string target; // the element's id, "" when it has none
};

// A closed set, deliberately. An open one would make the drain loop a
// dispatch table nobody can enumerate, and G4's accessibility mapping
// needs to know every event that can reach it.
enum {
	kEvClick = 1,
	kEvPointerDown = 2,
	kEvPointerUp = 3,
	kEvPointerEnter = 4,
	kEvPointerLeave = 5,
	kEvFocus = 6,
	kEvBlur = 7,
	kEvKeyDown = 8,
	kEvText = 9,
};

struct Recorder_TextCmd {
	long long font = 0;
	float size = 0, x = 0, y = 0;
	unsigned colour = 0; // 0xRRGGBBAA, straight alpha
	std::string text;
};

struct Recorder {
	// the flattened display list: x,y,r,g,b,a per vertex, then triangles
	std::vector<float> verts;
	std::vector<unsigned> idx;

	// G2: text as COMMANDS, not quads -- font id, size, baseline, colour,
	// bytes. The graphics plane paints them with its own copy of the same
	// shaper, which is why this DLL needs no glyph atlas, no textured
	// vertex format and no second rasterizer.
	//
	// `texts` is THIS FRAME's list, rebuilt by RenderGeometry as the
	// cached string geometry replays. `bank` is the persistent store
	// GenerateString writes to, freed when RmlUi releases the geometry.
	std::vector<Recorder_TextCmd> texts;

	// The event queue. BOUNDED: a caller that never drains must not grow
	// this without limit, and what is dropped is COUNTED rather than
	// silently discarded -- the house rule for every bounded record.
	std::vector<Recorder_Event> events;
	int events_dropped = 0;

	// what this phase cannot draw, counted rather than silently skipped
	int dropped_textured_draws = 0;
	int ignored_scissors = 0;
	int draws = 0;

	void Reset()
	{
		verts.clear();
		idx.clear();
		texts.clear();
		// events are NOT cleared here: they outlive a frame and are
		// drained by the caller, not by rendering
		dropped_textured_draws = 0;
		ignored_scissors = 0;
		draws = 0;
	}
};

// See the header: constructed explicitly, never implicitly.
Recorder* g_rec_p = nullptr;

Recorder& Rec()
{
	if (!g_rec_p) g_rec_p = new Recorder();
	return *g_rec_p;
}

class StzRender : public Rml::RenderInterface {
public:
	Rml::CompiledGeometryHandle CompileGeometry(Rml::Span<const Rml::Vertex> vertices, Rml::Span<const int> indices) override
	{
		const Rml::CompiledGeometryHandle h = ++next_geometry;
		Geometry& g = geometries[h];
		g.vertices.assign(vertices.begin(), vertices.end());
		g.indices.assign(indices.begin(), indices.end());
		// a string arrives wearing the marker in its first UV
		if (g.vertices.size() == 4 && g.vertices[0].tex_coord.x == kTextMarker)
		{
			g.text_index = (int)g.vertices[0].tex_coord.y;
			marker_compiles++;
		}
		return h;
	}

	void RenderGeometry(Rml::CompiledGeometryHandle handle, Rml::Vector2f translation, Rml::TextureHandle texture) override
	{
		auto it = geometries.find(handle);
		if (it == geometries.end()) return;
		Rec().draws++;

		// A STRING replays here, once per frame, with this frame's
		// translation -- which is what makes a scrolled or moved label
		// land in the right place without re-shaping it.
		if (it->second.text_index >= 0)
		{
			text_renders++;
			EmitText(it->second.text_index, translation);
			return;
		}

		if (texture != 0)
		{
			// G1 has no texture path: the stub font engine makes none, and
			// image decorators are G5's business. Counted, not hidden.
			Rec().dropped_textured_draws++;
			return;
		}

		const Geometry& g = it->second;
		const unsigned base = (unsigned)(Rec().verts.size() / 6);
		Rec().verts.reserve(Rec().verts.size() + g.vertices.size() * 6);
		for (const Rml::Vertex& v : g.vertices)
		{
			// un-premultiply: the scene blends with straight alpha
			const float a = (float)v.colour.alpha;
			const float s = (a > 0.0f) ? (255.0f / a) : 0.0f;
			float r = (float)v.colour.red * s;
			float gg = (float)v.colour.green * s;
			float b = (float)v.colour.blue * s;
			if (r > 255.0f) r = 255.0f;
			if (gg > 255.0f) gg = 255.0f;
			if (b > 255.0f) b = 255.0f;

			Rec().verts.push_back(v.position.x + translation.x);
			Rec().verts.push_back(v.position.y + translation.y);
			Rec().verts.push_back(r);
			Rec().verts.push_back(gg);
			Rec().verts.push_back(b);
			Rec().verts.push_back(a);
		}
		Rec().idx.reserve(Rec().idx.size() + g.indices.size());
		for (int i : g.indices) Rec().idx.push_back(base + (unsigned)i);
	}

	void ReleaseGeometry(Rml::CompiledGeometryHandle handle) override
	{
		auto it = geometries.find(handle);
		if (it != geometries.end())
		{
			// the bank slot dies with the geometry that named it, so a
			// long-lived document does not accumulate dead strings
			if (it->second.text_index >= 0) { FreeTextSlot(it->second.text_index); releases++; }
			geometries.erase(it);
		}
	}

	// defined after the font engine, which owns the bank
	void EmitText(int index, Rml::Vector2f translation);
	void FreeTextSlot(int index);

	Rml::TextureHandle LoadTexture(Rml::Vector2i& texture_dimensions, const Rml::String&) override
	{
		texture_dimensions = Rml::Vector2i(1, 1);
		return 0; // refuse: G1 draws no textures, and 0 says so honestly
	}
	Rml::TextureHandle GenerateTexture(Rml::Span<const Rml::byte>, Rml::Vector2i) override { return 0; }
	void ReleaseTexture(Rml::TextureHandle) override {}

	void EnableScissorRegion(bool enable) override
	{
		if (enable) Rec().ignored_scissors++;
	}
	void SetScissorRegion(Rml::Rectanglei) override {}

	Rml::CompiledGeometryHandle next_geometry = 0;
	std::unordered_map<Rml::CompiledGeometryHandle, Geometry> geometries;
	int marker_compiles = 0, text_renders = 0, emit_drops = 0, releases = 0;
};

// ------------------------------------------------------------ interfaces

class StzSystem : public Rml::SystemInterface {
public:
	double GetElapsedTime() override { return elapsed; }

	bool LogMessage(Rml::Log::Type type, const Rml::String& message) override
	{
		if (type <= Rml::Log::LT_WARNING)
		{
			if (!last_error.empty()) last_error += "; ";
			last_error += message;
		}
		return true;
	}

	// THE IME positioning hook. Recorded here so a Ring caller can SEE it
	// fire; feeding it is G2's and the IME work's job, not G1's.
	void ActivateKeyboard(Rml::Vector2f caret_position, float line_height) override
	{
		keyboard_activations++;
		caret_x = caret_position.x;
		caret_y = caret_position.y;
		caret_line_height = line_height;
	}

	double elapsed = 0;
	std::string last_error;
	int keyboard_activations = 0;
	float caret_x = 0, caret_y = 0, caret_line_height = 0;
};

// The G2 font engine: the SAME SheenBidi -> HarfBuzz -> stb_truetype
// pipeline the canvas paints with, compiled into THIS DLL (gui_font.zig
// exports it over a C ABI). RmlUi therefore lays out with real shaped
// widths -- Arabic joins, kerning kerns -- and GenerateString RECORDS a
// text command instead of emitting quads: the graphics plane paints it
// with its own copy of the same pipeline, so measure and paint cannot
// disagree.
//
// THE WIDTH CACHE IS NOT AN OPTIMIZATION. G0 measured 988 GetStringWidth
// calls per re-layout on a four-card screen, unmemoized by RmlUi. At
// ~1 us per real shape that is ~1 ms/frame before a glyph is drawn --
// the plan makes the cache a PRECONDITION of this phase. The key carries
// every input that changes a width: face, size, direction and
// letter-spacing from the shaping context, and the bytes themselves.
//
// WITH NO FONT REGISTERED it falls back to the G1 monospace stub, so a
// document that declares font-family but loads no face keeps laying out
// (and the G1 guards keep passing) instead of collapsing.
extern "C" {
long long stz_guifont_load(const unsigned char* bytes, int len);
int stz_guifont_free(long long id);
int stz_guifont_metrics(long long id, double size_px, double* out6);
double stz_guifont_width(long long id, const char* utf8, int len, double size_px);
}

class StzFontEngine : public Rml::FontEngineInterface {
public:
	struct Face {
		long long font = 0; // gpu_text handle inside THIS DLL
		int size = 16;
		Rml::FontMetrics metrics = {};
	};

	bool LoadFontFace(const Rml::String&, int, bool, Rml::Style::FontWeight) override
	{
		// Path loading is refused on purpose: fonts arrive as BYTES via
		// stz_gui_font_register, the same way stzFont takes them, so the
		// two DLLs are guaranteed to hold the same file.
		return false;
	}

	bool LoadFontFace(Rml::Span<const Rml::byte> data, int, const Rml::String& family, Rml::Style::FontStyle, Rml::Style::FontWeight,
		bool) override
	{
		// REGISTERING A FAMILY TWICE IS A NO-OP, and that is a bug fix.
		//
		// The first version freed the previous id and installed a new
		// one. But `faces` -- the (font, size) table RmlUi holds handles
		// into -- still pointed at the OLD id, which was now stale. The
		// gen-keyed table then answered -1 to every width query, the
		// quads came out zero-wide, RmlUi culled them, and TEXT SILENTLY
		// VANISHED from whichever panel had been built first.
		//
		// It needed two panels sharing a family to appear, which is why
		// every single-panel guard was green. Counted, not guessed:
		// generateCalls 6 against markerCompiles 4.
		//
		// Keeping the first registration is right for the case that
		// actually happens -- several panels naming the same font -- and
		// it makes a dangling id structurally impossible. Swapping a
		// face at runtime means a new family name, which is a fair price
		// and is said out loud here rather than discovered.
		Rml::String key = Rml::StringUtilities::ToLower(family);
		auto existing = families.find(key);
		if (existing != families.end()) return true;

		const long long id = stz_guifont_load(reinterpret_cast<const unsigned char*>(data.data()), (int)data.size());
		if (id == 0) return false;
		families[key] = id;
		return true;
	}

	Rml::FontFaceHandle GetFontFaceHandle(const Rml::String& family, Rml::Style::FontStyle, Rml::Style::FontWeight, int size) override
	{
		long long font = 0;
		auto it = families.find(Rml::StringUtilities::ToLower(family));
		if (it != families.end())
			font = it->second;
		else if (!families.empty())
			font = families.begin()->second; // any face beats no face

		// one handle per (font, size): metrics are size-scaled
		for (size_t i = 0; i < faces.size(); i++)
			if (faces[i].font == font && faces[i].size == size) return (Rml::FontFaceHandle)(i + 1);

		Face f;
		f.font = font;
		f.size = size;
		f.metrics.size = size;
		double m[6] = { 0, 0, 0, 0, 0, 0 };
		if (font != 0 && stz_guifont_metrics(font, (double)size, m) == 0)
		{
			f.metrics.ascent = (float)m[0];
			f.metrics.descent = (float)m[1];
			f.metrics.line_spacing = (float)(m[0] + m[1] + m[2]);
			f.metrics.x_height = (float)m[3];
		}
		else
		{
			// the G1 stub's numbers, kept bit-for-bit so unregistered
			// documents lay out exactly as they did
			f.metrics.ascent = size * 0.8f;
			f.metrics.descent = size * 0.2f;
			f.metrics.line_spacing = size * 1.2f;
			f.metrics.x_height = size * 0.5f;
		}
		f.metrics.underline_position = f.metrics.descent * 0.5f;
		f.metrics.underline_thickness = (float)size / 14.0f;
		if (f.metrics.underline_thickness < 1.0f) f.metrics.underline_thickness = 1.0f;
		f.metrics.has_ellipsis = false;
		faces.push_back(f);
		return (Rml::FontFaceHandle)faces.size();
	}

	const Rml::FontMetrics& GetFontMetrics(Rml::FontFaceHandle handle) override
	{
		static Rml::FontMetrics empty = {};
		if (handle == 0 || handle > faces.size()) return empty;
		return faces[handle - 1].metrics;
	}

	int GetStringWidth(Rml::FontFaceHandle handle, Rml::StringView string, const Rml::TextShapingContext& ctx, Rml::Character) override
	{
		width_calls++;
		const Face* f = FaceOf(handle);
		if (!f || f->font == 0) return StubWidth(handle, string);

		// the cache key carries EVERYTHING that changes a width
		key.clear();
		key.reserve(string.size() + 24);
		key.append(reinterpret_cast<const char*>(&f->font), sizeof(f->font));
		key.push_back((char)f->size);
		key.push_back((char)ctx.text_direction);
		key.append(reinterpret_cast<const char*>(&ctx.letter_spacing), sizeof(float));
		key.append(string.begin(), string.size());
		auto it = width_cache.find(key);
		if (it != width_cache.end())
		{
			width_cache_hits++;
			return it->second;
		}

		shape_calls++;
		double w = stz_guifont_width(f->font, string.begin(), (int)string.size(), (double)f->size);
		if (w < 0) w = 0;
		if (ctx.letter_spacing != 0.0f) w += (double)ctx.letter_spacing * (double)Codepoints(string);
		const int result = (int)(w + 0.5);
		// bounded: a UI's working set is small, but a runaway caller must
		// not grow this forever. Dropping ALL on overflow is crude and
		// correct -- the next frame refills what it actually uses.
		if (width_cache.size() > 100000) width_cache.clear();
		width_cache[key] = result;
		return result;
	}

	int GenerateString(Rml::RenderManager&, Rml::FontFaceHandle handle, Rml::FontEffectsHandle, Rml::StringView string,
		Rml::Vector2f position, Rml::ColourbPremultiplied colour, float, const Rml::TextShapingContext& ctx,
		Rml::TexturedMeshList& mesh_list) override
	{
		generate_calls++;
		const Face* f = FaceOf(handle);
		if (!f || f->font == 0) return StubWidth(handle, string);

		double w = stz_guifont_width(f->font, string.begin(), (int)string.size(), (double)f->size);
		if (w < 0) w = 0;
		if (ctx.letter_spacing != 0.0f) w += (double)ctx.letter_spacing * (double)Codepoints(string);

		if (string.size() == 0) return (int)(w + 0.5);

		// un-premultiply, as the vertex recorder does
		const float a = (float)colour.alpha;
		const float sc = (a > 0.0f) ? (255.0f / a) : 0.0f;
		unsigned r = (unsigned)((float)colour.red * sc);
		unsigned g = (unsigned)((float)colour.green * sc);
		unsigned b = (unsigned)((float)colour.blue * sc);
		if (r > 255) r = 255;
		if (g > 255) g = 255;
		if (b > 255) b = 255;

		Recorder_TextCmd cmd;
		cmd.font = f->font;
		cmd.size = (float)f->size;
		cmd.x = position.x;
		cmd.y = position.y;
		cmd.colour = (r << 24) | (g << 16) | (b << 8) | (unsigned)a;
		cmd.text.assign(string.begin(), string.size());
		const int slot = TakeSlot(cmd);

		// The quad IS the text's box, so RmlUi culls and sizes it the way
		// it would any geometry; the marker in the first UV is what says
		// "this is a string, replay it as a command" (see kTextMarker).
		Rml::TexturedMesh tm;
		Rml::Mesh& m = tm.mesh;
		const float x0 = position.x;
		const float y0 = position.y - f->metrics.ascent;
		const float x1 = x0 + (float)w;
		const float y1 = position.y + f->metrics.descent;
		m.vertices.resize(4);
		m.vertices[0].position = Rml::Vector2f(x0, y0);
		m.vertices[1].position = Rml::Vector2f(x1, y0);
		m.vertices[2].position = Rml::Vector2f(x1, y1);
		m.vertices[3].position = Rml::Vector2f(x0, y1);
		for (int i = 0; i < 4; i++) m.vertices[i].colour = colour;
		m.vertices[0].tex_coord = Rml::Vector2f(kTextMarker, (float)slot);
		m.indices = { 0, 1, 2, 0, 2, 3 };
		mesh_list.push_back(std::move(tm));

		return (int)(w + 0.5);
	}

	// The persistent bank: a slot lives from GenerateString until RmlUi
	// releases the geometry that named it, which is exactly as long as the
	// string is on screen.
	int TakeSlot(const Recorder_TextCmd& cmd)
	{
		if (!free_slots.empty())
		{
			const int k = free_slots.back();
			free_slots.pop_back();
			bank[(size_t)k] = cmd;
			return k;
		}
		bank.push_back(cmd);
		return (int)bank.size() - 1;
	}

	int GetVersion(Rml::FontFaceHandle) override { return 1; }

	void ReleaseFontResources() override
	{
		// The face table is NOT cleared. RmlUi documents these handles as
		// invalid afterwards, but a face here is a font id, a size and
		// eight floats -- keeping them costs nothing, and a handle that
		// stops resolving makes GenerateString return early with no mesh,
		// which loses text silently. Cheap insurance either way.
	}

	const Face* FaceOf(Rml::FontFaceHandle handle) const
	{
		if (handle == 0 || handle > faces.size()) return nullptr;
		return &faces[handle - 1];
	}

	int StubWidth(Rml::FontFaceHandle handle, Rml::StringView string) const
	{
		const int size = (handle != 0 && handle <= faces.size()) ? faces[handle - 1].size : 16;
		return (int)Codepoints(string) * (size / 2);
	}

	static size_t Codepoints(Rml::StringView s)
	{
		size_t n = 0;
		for (const char* p = s.begin(); p != s.end(); ++p)
			if ((*p & 0xC0) != 0x80) n++;
		return n;
	}

	std::unordered_map<Rml::String, long long> families;
	std::vector<Face> faces;
	std::vector<Recorder_TextCmd> bank;
	std::vector<int> free_slots;
	std::unordered_map<std::string, int> width_cache;
	std::string key; // reused scratch: 988 lookups/frame must not allocate
	int width_calls = 0, generate_calls = 0;
	int width_cache_hits = 0, shape_calls = 0;
};

using StubFont = StzFontEngine; // the accessor below keeps its name

// ------------------------------------------------------------- events
//
// ONE listener on the document root, subscribed in the bubble phase to a
// closed set of event types. RmlUi has already done the routing by the
// time this runs -- it walked the tree, found the target, and bubbled --
// so the listener's whole job is to write down what arrived.
//
// The current input source is a global rather than an event parameter
// because RmlUi has no field for it: the caller says "the next input is
// a keyboard" by which verb it calls, and the listener stamps whatever
// is in force. A synthetic Activate() sets it to synthetic, which is
// what makes the keyboard-sovereignty guard falsifiable.

int g_input_source = 0;

class StzEventListener : public Rml::EventListener {
public:
	void ProcessEvent(Rml::Event& event) override;
};

StzEventListener* g_listener_p = nullptr;

StzEventListener& Listener()
{
	if (!g_listener_p) g_listener_p = new StzEventListener();
	return *g_listener_p;
}

// ------------------------------------------------------------- contexts

struct Ctx {
	Rml::Context* ctx = nullptr;
	Rml::ElementDocument* doc = nullptr;
	unsigned gen = 1;
	bool live = false;
};

StzSystem* g_sys_p = nullptr;
StzRender* g_rend_p = nullptr;
StubFont* g_font_p = nullptr;
std::vector<Ctx>* g_ctx_p = nullptr;

StzSystem& Sys()
{
	if (!g_sys_p) g_sys_p = new StzSystem();
	return *g_sys_p;
}

StzRender& Rend()
{
	if (!g_rend_p) g_rend_p = new StzRender();
	return *g_rend_p;
}

StubFont& Font()
{
	if (!g_font_p) g_font_p = new StubFont();
	return *g_font_p;
}

void StzEventListener::ProcessEvent(Rml::Event& event)
{
	Recorder& rec = Rec();
	// bounded: 4096 undrained events is far past any real frame, and the
	// overflow is COUNTED so a caller that stopped draining can see why
	// it stopped receiving
	if (rec.events.size() >= 4096)
	{
		rec.events_dropped++;
		return;
	}

	int type = 0;
	switch (event.GetId())
	{
	case Rml::EventId::Click: type = kEvClick; break;
	case Rml::EventId::Mousedown: type = kEvPointerDown; break;
	case Rml::EventId::Mouseup: type = kEvPointerUp; break;
	case Rml::EventId::Mouseover: type = kEvPointerEnter; break;
	case Rml::EventId::Mouseout: type = kEvPointerLeave; break;
	case Rml::EventId::Focus: type = kEvFocus; break;
	case Rml::EventId::Blur: type = kEvBlur; break;
	case Rml::EventId::Keydown: type = kEvKeyDown; break;
	case Rml::EventId::Textinput: type = kEvText; break;
	default: return; // the set is closed; an unlisted event is not ours
	}

	Recorder_Event e;
	e.type = type;
	e.source = g_input_source;
	e.x = event.GetParameter<float>("mouse_x", 0.f);
	e.y = event.GetParameter<float>("mouse_y", 0.f);
	e.button = event.GetParameter<int>("button", -1);
	e.key = event.GetParameter<int>("key_identifier", -1);
	e.mods = 0;
	if (event.GetParameter<int>("ctrl_key", 0)) e.mods |= 1;
	if (event.GetParameter<int>("shift_key", 0)) e.mods |= 2;
	if (event.GetParameter<int>("alt_key", 0)) e.mods |= 4;
	if (Rml::Element* t = event.GetTargetElement()) e.target = t->GetId();
	rec.events.push_back(e);
}

// The two StzRender methods that needed the font engine's bank -- and so
// had to wait until Font() existed.
void StzRender::EmitText(int index, Rml::Vector2f translation)
{
	StzFontEngine& fe = Font();
	if (index < 0 || index >= (int)fe.bank.size()) { emit_drops++; return; }
	Recorder_TextCmd cmd = fe.bank[(size_t)index];
	cmd.x += translation.x;
	cmd.y += translation.y;
	Rec().texts.push_back(cmd);
}

void StzRender::FreeTextSlot(int index)
{
	StzFontEngine& fe = Font();
	if (index < 0 || index >= (int)fe.bank.size()) return;
	fe.bank[(size_t)index].text.clear();
	fe.free_slots.push_back(index);
}

std::vector<Ctx>& Contexts()
{
	if (!g_ctx_p) g_ctx_p = new std::vector<Ctx>();
	return *g_ctx_p;
}

// A plain bool is safe at file scope: zero IS its correct initial value,
// and it has no constructor to skip.
bool g_initialised = false;

// Gen-keyed handles, the same discipline as every other handle table in
// this engine: a freed id answers by NAME rather than with another
// context's geometry.
long long MakeId(size_t slot, unsigned gen)
{
	return ((long long)gen << 32) | (long long)(slot + 1);
}

Ctx* SlotOf(long long id)
{
	const long long idx = id & 0xffffffffLL;
	if (idx <= 0 || idx > (long long)Contexts().size()) return nullptr;
	Ctx& c = Contexts()[(size_t)(idx - 1)];
	const unsigned gen = (unsigned)((id >> 32) & 0xffffffffLL);
	if (!c.live || c.gen != gen) return nullptr;
	return &c;
}

} // namespace

// ---------------------------------------------------------------- C ABI
// Every entry catches: an exception crossing a C ABI into Ring is a crash
// with no diagnosis. RmlUi needs exceptions enabled (G0), so they exist
// here whether or not this code throws.

STZ_API int stz_gui_init(void)
{
	try
	{
		if (g_initialised) return 0;
		Rml::SetSystemInterface(&Sys());
		Rml::SetRenderInterface(&Rend());
		Rml::SetFontEngineInterface(&Font());
		if (!Rml::Initialise()) return 1;
		g_initialised = true;
		return 0;
	}
	catch (...)
	{
		return 2;
	}
}


STZ_API int stz_gui_is_ready(void) { return g_initialised ? 1 : 0; }

STZ_API void stz_gui_shutdown(void)
{
	try
	{
		if (!g_initialised) return;
		for (Ctx& c : Contexts()) c.live = false;
		Contexts().clear();
		Rml::Shutdown();
		g_initialised = false;
	}
	catch (...)
	{
	}
}

STZ_API long long stz_gui_context_new(int w, int h)
{
	try
	{
		if (!g_initialised || w < 1 || h < 1 || w > 16384 || h > 16384) return 0;
		// a name per slot: RmlUi keys contexts by name, and two contexts
		// sharing one would be the same context wearing two handles
		const std::string name = "stz" + std::to_string(Contexts().size() + 1) + "_" + std::to_string(Rml::GetNumContexts());
		Rml::Context* c = Rml::CreateContext(name, Rml::Vector2i(w, h));
		if (!c) return 0;
		Contexts().push_back(Ctx{});
		Ctx& slot = Contexts().back();
		slot.ctx = c;
		slot.live = true;
		return MakeId(Contexts().size() - 1, slot.gen);
	}
	catch (...)
	{
		return 0;
	}
}

STZ_API int stz_gui_context_free(long long id)
{
	try
	{
		Ctx* c = SlotOf(id);
		if (!c) return 2; // STALE, the house's code for a dead handle
		if (c->ctx) Rml::RemoveContext(c->ctx->GetName());
		c->ctx = nullptr;
		c->doc = nullptr;
		c->live = false;
		c->gen++;
		return 0;
	}
	catch (...)
	{
		return 3;
	}
}

STZ_API int stz_gui_context_resize(long long id, int w, int h)
{
	try
	{
		Ctx* c = SlotOf(id);
		if (!c) return 2;
		if (w < 1 || h < 1 || w > 16384 || h > 16384) return 3;
		c->ctx->SetDimensions(Rml::Vector2i(w, h));
		return 0;
	}
	catch (...)
	{
		return 3;
	}
}

STZ_API int stz_gui_load_rml(long long id, const char* rml, int len)
{
	try
	{
		Ctx* c = SlotOf(id);
		if (!c) return 2;
		if (!rml || len <= 0) return 3;
		Sys().last_error.clear();
		Rml::ElementDocument* doc = c->ctx->LoadDocumentFromMemory(Rml::String(rml, (size_t)len));
		if (!doc) return 4;
		doc->Show();
		c->doc = doc;
		// ONE listener on the root, bubble phase: RmlUi has already
		// routed and bubbled by the time it runs, so its whole job is to
		// write down what arrived.
		static const Rml::EventId kWatched[] = { Rml::EventId::Click, Rml::EventId::Mousedown, Rml::EventId::Mouseup,
			Rml::EventId::Mouseover, Rml::EventId::Mouseout, Rml::EventId::Focus, Rml::EventId::Blur, Rml::EventId::Keydown,
			Rml::EventId::Textinput };
		for (Rml::EventId id : kWatched) doc->AddEventListener(id, &Listener());
		return 0;
	}
	catch (...)
	{
		return 3;
	}
}

STZ_API int stz_gui_update(long long id)
{
	try
	{
		Ctx* c = SlotOf(id);
		if (!c) return 2;
		c->ctx->Update();
		return 0;
	}
	catch (...)
	{
		return 3;
	}
}

STZ_API int stz_gui_render(long long id)
{
	try
	{
		Ctx* c = SlotOf(id);
		if (!c) return 2;
		Rec().Reset();
		c->ctx->Render();
		return 0;
	}
	catch (...)
	{
		return 3;
	}
}

// The recorded display list. Pointers stay valid until the next render.
STZ_API const float* stz_gui_verts(int* out_len)
{
	if (out_len) *out_len = (int)Rec().verts.size();
	return Rec().verts.empty() ? nullptr : Rec().verts.data();
}

STZ_API const unsigned* stz_gui_indices(int* out_len)
{
	if (out_len) *out_len = (int)Rec().idx.size();
	return Rec().idx.empty() ? nullptr : Rec().idx.data();
}

// [draws, droppedTexturedDraws, ignoredScissors, widthCalls, generateCalls,
//  keyboardActivations, widthCacheHits, shapeCalls]
// APPENDED, never reordered -- G1 readers of the first six keep working.
STZ_API void stz_gui_counters(int* out8)
{
	if (!out8) return;
	out8[0] = Rec().draws;
	out8[1] = Rec().dropped_textured_draws;
	out8[2] = Rec().ignored_scissors;
	out8[3] = Font().width_calls;
	out8[4] = Font().generate_calls;
	out8[5] = Sys().keyboard_activations;
	out8[6] = Font().width_cache_hits;
	out8[7] = Font().shape_calls;
	out8[8] = Rend().marker_compiles;
	out8[9] = Rend().text_renders;
	out8[10] = Rend().emit_drops;
	out8[11] = Rend().releases;
}

// -------------------------------------------------------------- G2: fonts

// A registered font's BYTES must outlive Rml::Shutdown (Core.h's stated
// lifetime for LoadFontFace(Span)), so the blobs are kept here.
static std::vector<std::string>* g_font_blobs_p = nullptr;

// Register a font family from memory. The SAME bytes the Ring side hands
// to stzFont, so the measuring copy of the pipeline (this DLL) and the
// painting copy (stz_gpu.dll) hold the identical file. Answers THIS
// DLL's font id (the one text commands will carry), 0 on refusal -- so
// the Ring face can match a recorded command back to the stzFont it
// paints with.
STZ_API long long stz_gui_font_register(const char* family, const unsigned char* bytes, int len)
{
	try
	{
		if (!g_initialised || !family || !bytes || len <= 0) return 0;
		if (!g_font_blobs_p) g_font_blobs_p = new std::vector<std::string>();
		g_font_blobs_p->push_back(std::string(reinterpret_cast<const char*>(bytes), (size_t)len));
		const std::string& blob = g_font_blobs_p->back();
		const bool ok = Rml::LoadFontFace(
			Rml::Span<const Rml::byte>(reinterpret_cast<const Rml::byte*>(blob.data()), blob.size()), Rml::String(family),
			Rml::Style::FontStyle::Normal);
		if (!ok)
		{
			g_font_blobs_p->pop_back();
			return 0;
		}
		auto it = Font().families.find(Rml::StringUtilities::ToLower(Rml::String(family)));
		return (it != Font().families.end()) ? it->second : 0;
	}
	catch (...)
	{
		return 0;
	}
}

STZ_API int stz_gui_font_count(void)
{
	return (int)Font().families.size();
}

// The recorded TEXT COMMANDS of the last render -- what to draw, not how.
// Iterated by index because strings cannot ride a flat array: n from
// stz_gui_text_count, each entry as (font, size, x, y, colour) + bytes.
STZ_API int stz_gui_text_count(void)
{
	return (int)Rec().texts.size();
}

STZ_API int stz_gui_text_at(int i, long long* font, float* size, float* x, float* y, unsigned* colour, const char** bytes, int* len)
{
	if (i < 0 || i >= (int)Rec().texts.size()) return 2;
	const Recorder_TextCmd& t = Rec().texts[(size_t)i];
	if (font) *font = t.font;
	if (size) *size = t.size;
	if (x) *x = t.x;
	if (y) *y = t.y;
	if (colour) *colour = t.colour;
	if (bytes) *bytes = t.text.c_str();
	if (len) *len = (int)t.text.size();
	return 0;
}

// The laid-out box of one element, by id: [x, y, w, h] in context pixels.
// This is what a Softanza-side inspector reads, and what the court's
// paint-time audit will read when it exists.
STZ_API int stz_gui_element_box(long long id, const char* elem_id, float* out4)
{
	try
	{
		Ctx* c = SlotOf(id);
		if (!c || !c->doc || !elem_id || !out4) return 2;
		Rml::Element* e = c->doc->GetElementById(elem_id);
		if (!e) return 4;
		out4[0] = e->GetAbsoluteOffset().x;
		out4[1] = e->GetAbsoluteOffset().y;
		out4[2] = e->GetBox().GetSize().x;
		out4[3] = e->GetBox().GetSize().y;
		return 0;
	}
	catch (...)
	{
		return 3;
	}
}

// The last warning or error RmlUi logged, so a refusal answers by NAME
// instead of leaving the caller with a number.
STZ_API const char* stz_gui_last_error(void)
{
	return Sys().last_error.c_str();
}

STZ_API void stz_gui_set_time(double seconds) { Sys().elapsed = seconds; }

// ---------------------------------------------------------- G3: input
//
// Every verb takes PANEL pixels and nothing else. The coordinate-space
// frame is DISSOLVED rather than surfaced (§7, M3): a panel has exactly
// one space, so there is nothing to confuse it with, and a window or a
// 3D texture converts at its own boundary with a named function.
//
// The input SOURCE is set by which verb the caller uses -- a pointer
// verb stamps pointer, a key verb stamps keyboard -- and Activate()
// stamps synthetic on purpose, so a guard can tell a real keyboard path
// from a dispatched one. Rule 80 is unfalsifiable otherwise.

STZ_API void stz_gui_set_input_source(int source) { g_input_source = source; }

STZ_API int stz_gui_pointer_move(long long id, float x, float y, int mods)
{
	try
	{
		Ctx* c = SlotOf(id);
		if (!c) return 2;
		g_input_source = 0;
		c->ctx->ProcessMouseMove((int)x, (int)y, mods);
		return 0;
	}
	catch (...)
	{
		return 3;
	}
}

STZ_API int stz_gui_pointer_button(long long id, int button, int down, int mods)
{
	try
	{
		Ctx* c = SlotOf(id);
		if (!c) return 2;
		g_input_source = 0;
		if (down) c->ctx->ProcessMouseButtonDown(button, mods);
		else c->ctx->ProcessMouseButtonUp(button, mods);
		return 0;
	}
	catch (...)
	{
		return 3;
	}
}

STZ_API int stz_gui_pointer_leave(long long id)
{
	try
	{
		Ctx* c = SlotOf(id);
		if (!c) return 2;
		g_input_source = 0;
		c->ctx->ProcessMouseLeave();
		return 0;
	}
	catch (...)
	{
		return 3;
	}
}

STZ_API int stz_gui_key(long long id, int key, int down, int mods)
{
	try
	{
		Ctx* c = SlotOf(id);
		if (!c) return 2;
		g_input_source = 1;
		if (down) c->ctx->ProcessKeyDown((Rml::Input::KeyIdentifier)key, mods);
		else c->ctx->ProcessKeyUp((Rml::Input::KeyIdentifier)key, mods);
		return 0;
	}
	catch (...)
	{
		return 3;
	}
}

STZ_API int stz_gui_text_input(long long id, const char* utf8, int len)
{
	try
	{
		Ctx* c = SlotOf(id);
		if (!c || !utf8 || len <= 0) return 2;
		g_input_source = 1;
		c->ctx->ProcessTextInput(Rml::String(utf8, (size_t)len));
		return 0;
	}
	catch (...)
	{
		return 3;
	}
}

// ---------------------------------------------------------- G3: focus

// A SPARSE focus tree, in the sense §5's Flutter numbers mean: what is
// focusable is a small subset of what exists, and it is queried rather
// than mirrored. RmlUi already owns the traversal (tab order in document
// order, and a spatial heuristic for directional moves); this exposes it
// and COUNTS the refusals, which RmlUi does not.

STZ_API int stz_gui_focus(long long id, const char* elem_id)
{
	try
	{
		Ctx* c = SlotOf(id);
		if (!c || !c->doc) return 2;
		if (!elem_id || !*elem_id)
		{
			if (Rml::Element* f = c->ctx->GetFocusElement()) f->Blur();
			return 0;
		}
		Rml::Element* e = c->doc->GetElementById(elem_id);
		if (!e) return 4;
		// focus_visible: true, so a keyboard-driven focus shows a ring --
		// Rule 80 is about a person being able to SEE where they are
		return e->Focus(true) ? 0 : 5;
	}
	catch (...)
	{
		return 3;
	}
}

// The focused element's id, or "" when nothing is focused.
STZ_API const char* stz_gui_focused(long long id)
{
	static std::string out;
	out.clear();
	try
	{
		Ctx* c = SlotOf(id);
		if (!c) return out.c_str();
		if (Rml::Element* e = c->ctx->GetFocusElement()) out = e->GetId();
	}
	catch (...)
	{
	}
	return out.c_str();
}

// Move focus. dir: 0 = next (Tab), 1 = previous (Shift+Tab), and
// 2/3/4/5 = up/down/left/right for the spatial navigation a gamepad or
// an arrow key wants. Answers 0 when focus MOVED, 6 when it refused --
// which is a real answer at the end of a tab ring, not an error.
STZ_API int stz_gui_focus_move(long long id, int dir)
{
	try
	{
		Ctx* c = SlotOf(id);
		if (!c || !c->doc) return 2;
		g_input_source = 1;
		Rml::Element* before = c->ctx->GetFocusElement();
		Rml::Input::KeyIdentifier key = Rml::Input::KI_TAB;
		int mods = 0;
		switch (dir)
		{
		case 0: key = Rml::Input::KI_TAB; break;
		case 1: key = Rml::Input::KI_TAB; mods = Rml::Input::KM_SHIFT; break;
		case 2: key = Rml::Input::KI_UP; break;
		case 3: key = Rml::Input::KI_DOWN; break;
		case 4: key = Rml::Input::KI_LEFT; break;
		case 5: key = Rml::Input::KI_RIGHT; break;
		default: return 3;
		}
		c->ctx->ProcessKeyDown(key, mods);
		c->ctx->ProcessKeyUp(key, mods);
		Rml::Element* after = c->ctx->GetFocusElement();
		return (after != before) ? 0 : 6;
	}
	catch (...)
	{
		return 3;
	}
}

// The element under a point, by id. "" when the point hits nothing that
// carries an id -- which is a fair answer, not a failure.
STZ_API const char* stz_gui_element_at(long long id, float x, float y)
{
	static std::string out;
	out.clear();
	try
	{
		Ctx* c = SlotOf(id);
		if (!c) return out.c_str();
		if (Rml::Element* e = c->ctx->GetElementAtPoint(Rml::Vector2f(x, y))) out = e->GetId();
	}
	catch (...)
	{
	}
	return out.c_str();
}

// ---------------------------------------------------------- G3: events

STZ_API int stz_gui_event_count(void) { return (int)Rec().events.size(); }

STZ_API int stz_gui_events_dropped(void) { return Rec().events_dropped; }

STZ_API void stz_gui_events_clear(void)
{
	Rec().events.clear();
	Rec().events_dropped = 0;
}

STZ_API int stz_gui_event_at(int i, int* type, int* source, float* x, float* y, int* button, int* key, int* mods,
	const char** target, int* target_len)
{
	if (i < 0 || i >= (int)Rec().events.size()) return 2;
	const Recorder_Event& e = Rec().events[(size_t)i];
	if (type) *type = e.type;
	if (source) *source = e.source;
	if (x) *x = e.x;
	if (y) *y = e.y;
	if (button) *button = e.button;
	if (key) *key = e.key;
	if (mods) *mods = e.mods;
	if (target) *target = e.target.c_str();
	if (target_len) *target_len = (int)e.target.size();
	return 0;
}
