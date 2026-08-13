// G0 SPIKE PROBE -- base/gui/SOFTANZA_GUI_PLAN.md §8.
//
// Drives RmlUi for real with STUB interfaces, to answer the kill criteria
// that only running can answer:
//
//   - does the vendored core build, LINK and RUN outside cmake?
//   - what does layout cost per frame, and does re-layout-on-change
//     actually avoid it? (criterion 2)
//   - are the 8 render virtuals enough to receive a screen? (G1's shape)
//   - what does the font engine ACTUALLY get asked, and in what order?
//     (criterion 1 -- the shaping-context question, measured rather than
//     inferred from a header)
//
// No canvas, no GPU, no Ring, no HarfBuzz. Stubs only: the point is to
// learn what the seam demands BEFORE building the real thing against it.
//
// Build + run: zig build rmlui-g0   (from libraries/stzlib/engine)

#include <RmlUi/Core.h>
#include <chrono>
#include <cstdio>
#include <string>
#include <vector>

using clk = std::chrono::steady_clock;
static clk::time_point g_start = clk::now();

static double NowSeconds()
{
	return std::chrono::duration<double>(clk::now() - g_start).count();
}

static double MsSince(clk::time_point t)
{
	return std::chrono::duration<double, std::milli>(clk::now() - t).count();
}

// ---------------------------------------------------------------- system

class ProbeSystem : public Rml::SystemInterface {
public:
	double GetElapsedTime() override { return NowSeconds(); }

	bool LogMessage(Rml::Log::Type type, const Rml::String& message) override
	{
		if (type <= Rml::Log::LT_WARNING) printf("  [rmlui] %s\n", message.c_str());
		return true;
	}

	// THE IME positioning hook -- the reason §0 exists. Recorded, not used.
	void ActivateKeyboard(Rml::Vector2f caret_position, float line_height) override
	{
		keyboard_activations++;
		last_caret = caret_position;
		last_line_height = line_height;
	}

	int keyboard_activations = 0;
	Rml::Vector2f last_caret = {};
	float last_line_height = 0;
};

// ---------------------------------------------------------------- render
// Counts instead of drawing. The counts ARE the measurement: how much
// geometry one screen costs, and whether a still frame re-compiles it.

class ProbeRender : public Rml::RenderInterface {
public:
	Rml::CompiledGeometryHandle CompileGeometry(Rml::Span<const Rml::Vertex> vertices, Rml::Span<const int> indices) override
	{
		compiles++;
		total_vertices += (int)vertices.size();
		total_indices += (int)indices.size();
		return ++next_handle;
	}
	void RenderGeometry(Rml::CompiledGeometryHandle, Rml::Vector2f, Rml::TextureHandle texture) override
	{
		draws++;
		if (texture) textured_draws++;
	}
	void ReleaseGeometry(Rml::CompiledGeometryHandle) override { releases++; }

	Rml::TextureHandle LoadTexture(Rml::Vector2i& dims, const Rml::String&) override
	{
		dims = Rml::Vector2i(1, 1);
		return ++next_handle;
	}
	Rml::TextureHandle GenerateTexture(Rml::Span<const Rml::byte>, Rml::Vector2i) override
	{
		generated_textures++;
		return ++next_handle;
	}
	void ReleaseTexture(Rml::TextureHandle) override {}
	void EnableScissorRegion(bool enable) override
	{
		if (enable) scissor_enables++;
	}
	void SetScissorRegion(Rml::Rectanglei) override { scissor_sets++; }

	void Reset()
	{
		compiles = draws = textured_draws = releases = scissor_enables = scissor_sets = 0;
		total_vertices = total_indices = 0;
	}

	Rml::CompiledGeometryHandle next_handle = 0;
	int compiles = 0, draws = 0, textured_draws = 0, releases = 0;
	int scissor_enables = 0, scissor_sets = 0;
	int total_vertices = 0, total_indices = 0;
	int generated_textures = 0;
};

// ------------------------------------------------------------------ font
// A MONOSPACE stub: every codepoint advances the same. Not a font engine
// -- an instrument. It records exactly what RmlUi asks and in what units,
// which is criterion 1 measured instead of inferred.

class ProbeFont : public Rml::FontEngineInterface {
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
		metrics.has_ellipsis = true;
		return 1;
	}

	const Rml::FontMetrics& GetFontMetrics(Rml::FontFaceHandle) override { return metrics; }

	int GetStringWidth(Rml::FontFaceHandle, Rml::StringView string, const Rml::TextShapingContext& ctx, Rml::Character = Rml::Character::Null) override
	{
		width_calls++;
		if (samples.size() < 10) samples.push_back(Rml::String(string.begin(), string.end()));
		if (ctx.text_direction == Rml::Style::Direction::Rtl) saw_direction_rtl = true;
		if (!ctx.language.empty()) saw_language = true;
		last_letter_spacing = ctx.letter_spacing;
		return (int)CountCodepoints(string) * (last_size / 2);
	}

	int GenerateString(Rml::RenderManager&, Rml::FontFaceHandle, Rml::FontEffectsHandle, Rml::StringView string, Rml::Vector2f,
		Rml::ColourbPremultiplied, float, const Rml::TextShapingContext&, Rml::TexturedMeshList&) override
	{
		generate_calls++;
		generate_bytes += (int)string.size();
		if (generated.size() < 6) generated.push_back(Rml::String(string.begin(), string.end()));
		return (int)CountCodepoints(string) * (last_size / 2);
	}

	int GetVersion(Rml::FontFaceHandle) override { return 1; }

	static size_t CountCodepoints(Rml::StringView s)
	{
		size_t n = 0;
		for (const char* p = s.begin(); p != s.end(); ++p)
			if ((*p & 0xC0) != 0x80) n++;
		return n;
	}

	Rml::FontMetrics metrics = {};
	int last_size = 16;
	int width_calls = 0, generate_calls = 0, generate_bytes = 0;
	bool saw_direction_rtl = false, saw_language = false;
	float last_letter_spacing = 0;
	std::vector<Rml::String> samples, generated;
};

// ------------------------------------------------------------------ main

static const char* kDocument =
	"<rml>\n<head><style>\n"
	"body { font-family: probe; font-size: 16px; display: flex; flex-direction: column; }\n"
	"#bar { display: flex; flex-direction: row; height: 40px; background: #202020; }\n"
	"#bar div { flex: 1 1 auto; padding: 8px; color: #e0e0e0; }\n"
	"#body { display: flex; flex-direction: row; flex: 1 1 auto; }\n"
	"#side { width: 180px; background: #181818; padding: 12px; color: #b0b0b0; }\n"
	"#main { flex: 1 1 auto; padding: 16px; color: #f0f0f0; }\n"
	".card { background: #262626; padding: 10px; margin-bottom: 8px; }\n"
	// NOT `direction: rtl` -- RCSS names it `--rmlui-direction`. The first
	// entry in the profile's divergence table (§3 of the plan).
	"#rtl { --rmlui-direction: rtl; }\n"
	"</style></head>\n<body>\n"
	"  <div id=\"bar\"><div>Softanza</div><div>Graphics</div><div>Sound</div><div>GUI</div></div>\n"
	"  <div id=\"body\">\n"
	"    <div id=\"side\">Panels<br/>Focus<br/>Events<br/>Sense</div>\n"
	"    <div id=\"main\">\n"
	"      <div class=\"card\">A panel laid out by RmlUi, painted by nobody yet.</div>\n"
	"      <div class=\"card\">The renderer is the host's: eight virtuals, vertices and indices out.</div>\n"
	"      <div class=\"card\" id=\"rtl\" lang=\"ar\">ltr and rtl in one document</div>\n"
	"      <div class=\"card\">Flexbox only -- no grid exists in any C or C++ engine.</div>\n"
	"    </div>\n"
	"  </div>\n"
	"</body>\n</rml>\n";

int main()
{
	ProbeSystem sys;
	ProbeRender render;
	ProbeFont font;

	Rml::SetSystemInterface(&sys);
	Rml::SetRenderInterface(&render);
	Rml::SetFontEngineInterface(&font);

	printf("-- Scene 1: the vendored core initialises outside cmake --\n");
	if (!Rml::Initialise())
	{
		printf("  [FAIL] Rml::Initialise() refused\n");
		return 1;
	}
	printf("  [OK] Rml::Initialise()\n");

	Rml::Context* ctx = Rml::CreateContext("probe", Rml::Vector2i(1280, 800));
	if (!ctx)
	{
		printf("  [FAIL] CreateContext refused\n");
		return 1;
	}
	printf("  [OK] context 1280x800\n");

	printf("\n-- Scene 2: a real document parses and lays out --\n");
	clk::time_point t0 = clk::now();
	Rml::ElementDocument* doc = ctx->LoadDocumentFromMemory(kDocument);
	double t_load = MsSince(t0);
	if (!doc)
	{
		printf("  [FAIL] LoadDocumentFromMemory refused\n");
		return 1;
	}
	doc->Show();
	printf("  [OK] parsed + loaded in %.3f ms\n", t_load);

	t0 = clk::now();
	ctx->Update();
	printf("  [OK] first Update (full layout) %.3f ms\n", MsSince(t0));

	render.Reset();
	t0 = clk::now();
	ctx->Render();
	double t_render = MsSince(t0);
	printf("  [OK] first Render %.3f ms -> %d compiles, %d draws, %d verts, %d indices\n", t_render, render.compiles, render.draws,
		render.total_vertices, render.total_indices);

	printf("\n-- Scene 3: KILL CRITERION 2 -- what does a STILL frame cost? --\n");
	const int N = 500;
	t0 = clk::now();
	for (int i = 0; i < N; i++) ctx->Update();
	double t_still = MsSince(t0) / N;
	printf("  Update on an unchanged tree      : %.4f ms/frame\n", t_still);

	render.Reset();
	t0 = clk::now();
	for (int i = 0; i < N; i++) ctx->Render();
	double t_render_still = MsSince(t0) / N;
	printf("  Render on an unchanged tree      : %.4f ms/frame\n", t_render_still);
	printf("  geometry re-compiles over %d frames: %d  (0 = the cache holds)\n", N, render.compiles);

	printf("\n-- Scene 4: and what does a CHANGE cost? --\n");
	Rml::Element* main_el = doc->GetElementById("main");
	int width_calls_before = font.width_calls;
	t0 = clk::now();
	for (int i = 0; i < N; i++)
	{
		main_el->SetProperty("padding", Rml::String(std::to_string(10 + (i % 20)) + "px"));
		ctx->Update();
	}
	double t_dirty = MsSince(t0) / N;
	double width_per_layout = double(font.width_calls - width_calls_before) / N;
	printf("  Update after a property change   : %.4f ms/frame\n", t_dirty);
	printf("  ratio dirty/still                : %.1fx -- caching is %s\n", t_still > 0 ? t_dirty / t_still : 0.0,
		(t_dirty > t_still * 2) ? "REAL (a still frame skips layout)" : "NOT VISIBLE in these numbers");

	// THE number that sizes G2. RmlUi does NOT memoize width queries: every
	// re-layout re-measures every token. With a stub that counts codepoints
	// that is free; with a real shaper it is the whole frame budget.
	printf("  GetStringWidth per RE-LAYOUT     : %.0f calls\n", width_per_layout);
	printf("  ...at 1 us/shape that alone is   : %.2f ms/frame  <-- G2 must cache\n", width_per_layout / 1000.0);

	printf("\n-- Scene 5: KILL CRITERION 1 -- what the font engine is asked --\n");
	printf("  GetStringWidth calls : %d\n", font.width_calls);
	printf("  GenerateString calls : %d  (%d bytes)\n", font.generate_calls, font.generate_bytes);
	printf("  saw direction=rtl    : %s\n", font.saw_direction_rtl ? "YES" : "no");
	printf("  saw a language tag   : %s\n", font.saw_language ? "YES" : "no");
	printf("  width is asked for   :");
	for (size_t i = 0; i < font.samples.size(); i++) printf(" [%s]", font.samples[i].c_str());
	printf("\n  GenerateString gets  :");
	for (size_t i = 0; i < font.generated.size(); i++) printf(" [%s]", font.generated[i].c_str());
	printf("\n");

	printf("\n-- Scene 6: the box tree is inspectable (G1 needs this) --\n");
	Rml::Element* side = doc->GetElementById("side");
	Rml::Element* bar = doc->GetElementById("bar");
	printf("  #bar   box: %4.0fx%-4.0f at (%.0f,%.0f)\n", bar->GetBox().GetSize().x, bar->GetBox().GetSize().y, bar->GetAbsoluteOffset().x,
		bar->GetAbsoluteOffset().y);
	printf("  #side  box: %4.0fx%-4.0f at (%.0f,%.0f)\n", side->GetBox().GetSize().x, side->GetBox().GetSize().y, side->GetAbsoluteOffset().x,
		side->GetAbsoluteOffset().y);
	printf("  #main  box: %4.0fx%-4.0f at (%.0f,%.0f)\n", main_el->GetBox().GetSize().x, main_el->GetBox().GetSize().y,
		main_el->GetAbsoluteOffset().x, main_el->GetAbsoluteOffset().y);

	printf("\n-- Scene 7: does flexbox actually flex? --\n");
	float main_w_1280 = main_el->GetBox().GetSize().x;
	ctx->SetDimensions(Rml::Vector2i(640, 480));
	ctx->Update();
	float main_w_640 = main_el->GetBox().GetSize().x;
	printf("  #main width 1280 -> 640 viewport : %.0f -> %.0f  (%s)\n", main_w_1280, main_w_640,
		(main_w_640 < main_w_1280) ? "it flexed" : "IT DID NOT FLEX");
	// #side SHRANK, and that is CSS being correct, not RmlUi being wrong:
	// a flex item defaults to `flex: 0 1 auto`, so a declared width is a
	// BASIS, not a floor. Recorded because the first reading of this probe
	// called it a bug. The floor is flex-shrink: 0.
	side->SetProperty("flex-shrink", "0");
	ctx->Update();
	printf("  #side with flex-shrink:0 holds   : %.0f px -- GetSize() is the CONTENT box, and\n", side->GetBox().GetSize().x);
	printf("                                     `width` sets content width (padding is outside it)\n");

	printf("\n-- Scene 8: shutdown is clean --\n");
	render.Reset();
	Rml::Shutdown();
	printf("  [OK] Rml::Shutdown(), %d geometry releases on the way out\n", render.releases);
	return 0;
}
