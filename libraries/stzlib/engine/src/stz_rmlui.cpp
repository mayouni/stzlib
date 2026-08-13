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
};

struct Recorder {
	// the flattened display list: x,y,r,g,b,a per vertex, then triangles
	std::vector<float> verts;
	std::vector<unsigned> idx;

	// what this phase cannot draw, counted rather than silently skipped
	int dropped_textured_draws = 0;
	int ignored_scissors = 0;
	int draws = 0;

	void Reset()
	{
		verts.clear();
		idx.clear();
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
		return h;
	}

	void RenderGeometry(Rml::CompiledGeometryHandle handle, Rml::Vector2f translation, Rml::TextureHandle texture) override
	{
		auto it = geometries.find(handle);
		if (it == geometries.end()) return;
		Rec().draws++;

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

	void ReleaseGeometry(Rml::CompiledGeometryHandle handle) override { geometries.erase(handle); }

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

// A MONOSPACE stub. Not a font engine -- a placeholder that lets layout
// have widths. G2 replaces it with SheenBidi -> HarfBuzz -> stb_truetype,
// and until then a panel has chrome and no glyphs, which is the honest
// state of this phase rather than a bug.
class StubFont : public Rml::FontEngineInterface {
public:
	bool LoadFontFace(const Rml::String&, int, bool, Rml::Style::FontWeight) override { return true; }
	bool LoadFontFace(Rml::Span<const Rml::byte>, int, const Rml::String&, Rml::Style::FontStyle, Rml::Style::FontWeight, bool) override
	{
		return true;
	}
	Rml::FontFaceHandle GetFontFaceHandle(const Rml::String&, Rml::Style::FontStyle, Rml::Style::FontWeight, int size) override
	{
		last_size = size;
		metrics.size = size;
		metrics.ascent = size * 0.8f;
		metrics.descent = size * 0.2f;
		metrics.line_spacing = size * 1.2f;
		metrics.x_height = size * 0.5f;
		metrics.underline_position = size * 0.1f;
		metrics.underline_thickness = 1.0f;
		metrics.has_ellipsis = false;
		return 1;
	}
	const Rml::FontMetrics& GetFontMetrics(Rml::FontFaceHandle) override { return metrics; }

	int GetStringWidth(Rml::FontFaceHandle, Rml::StringView string, const Rml::TextShapingContext&, Rml::Character) override
	{
		width_calls++;
		return (int)Codepoints(string) * (last_size / 2);
	}
	int GenerateString(Rml::RenderManager&, Rml::FontFaceHandle, Rml::FontEffectsHandle, Rml::StringView string, Rml::Vector2f,
		Rml::ColourbPremultiplied, float, const Rml::TextShapingContext&, Rml::TexturedMeshList&) override
	{
		generate_calls++;
		return (int)Codepoints(string) * (last_size / 2);
	}
	int GetVersion(Rml::FontFaceHandle) override { return 1; }

	static size_t Codepoints(Rml::StringView s)
	{
		size_t n = 0;
		for (const char* p = s.begin(); p != s.end(); ++p)
			if ((*p & 0xC0) != 0x80) n++;
		return n;
	}

	Rml::FontMetrics metrics = {};
	int last_size = 16;
	int width_calls = 0, generate_calls = 0;
};

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
//  keyboardActivations]
STZ_API void stz_gui_counters(int* out6)
{
	if (!out6) return;
	out6[0] = Rec().draws;
	out6[1] = Rec().dropped_textured_draws;
	out6[2] = Rec().ignored_scissors;
	out6[3] = Font().width_calls;
	out6[4] = Font().generate_calls;
	out6[5] = Sys().keyboard_activations;
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
