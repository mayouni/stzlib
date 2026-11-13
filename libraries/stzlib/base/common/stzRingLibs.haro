
# Loading additional Ring libs required by Softanza Base layer
#NOTE Core layer already has "../../core/common/stkRingLibs.ring"

# Load Base Engine bridges (stz_* DLLs -- superset of Core stk_* DLLs)

load "../../engine/stz_string.haro"
load "../../engine/stz_datetime.haro"
load "../../engine/stz_file.haro"
load "../../engine/stz_locale.haro"
load "../../engine/stz_unicode.haro"
load "../../engine/stz_regex.haro"
load "../../engine/stz_bytes.haro"
load "../../engine/stz_json.haro"
load "../../engine/stz_url.haro"
load "../../engine/stz_system.haro"
load "../../engine/stz_value.haro"
load "../../engine/stz_number.haro"
load "../../engine/stz_list.haro"
load "../../engine/stz_hashmap.haro"
load "../../engine/stz_table.haro"
load "../../engine/stz_matrix.haro"
load "../../engine/stz_unidata.haro"
load "../../engine/stz_random.haro"
load "../../engine/stz_csv.haro"
load "../../engine/stz_stats.haro"
load "../../engine/stz_graph.haro"
load "../../engine/stz_polyglot.haro"
load "../../engine/stz_yielder.haro"
load "../../engine/stz_text.haro"
load "../../engine/stz_uuid.haro"
load "../../engine/stz_codec.haro"
load "../../engine/stz_bits.haro"
load "../../engine/stz_html.haro"
load "../../engine/stz_http.haro"
load "../../engine/stz_tcp.haro"
load "../../engine/stz_ws.haro"
load "../../engine/stz_image.haro"
load "../../engine/stz_fswatch.haro"
load "../../engine/stz_time.haro"
load "../../engine/stz_pool.haro"
load "../../engine/stz_resilience.haro"
load "../../engine/stz_histogram.haro"
load "../../engine/stz_reactor.haro"
load "../../engine/stz_tracectx.haro"
load "../../engine/stz_testsrv.haro"
load "../../engine/stz_geo.haro"
load "../../engine/stz_compress.haro"
load "../../engine/stz_solver.haro"
load "../../engine/stz_db.haro"
load "../../engine/stz_watch.haro"
load "../../engine/stz_perf.haro"
load "../../engine/stz_testoor.haro"
load "../../engine/stz_seclog.haro"
load "../../engine/stz_cache.haro"
load "../../engine/stz_stream.haro"
load "../../engine/stz_process.haro"
load "../../engine/stz_arith.haro"
load "../../engine/stz_profiler.haro"
load "../../engine/stz_crypto.haro"
load "../../engine/stz_embed.haro"
load "../../engine/stz_smallfn.haro"
load "../../engine/stz_numtheory.haro"
load "../../engine/stz_splitter.haro"
load "../../engine/stz_pattern.haro"
load "../../engine/stz_stringart.haro"
load "../../engine/stz_display.haro"
load "../../engine/stz_constraint.haro"
load "../../engine/stz_natlang.haro"
load "../../engine/stz_ccode.haro"
load "../../engine/stz_reactive.haro"
load "../../engine/stz_namedvars.haro"
load "../../engine/stz_adverb.haro"
load "../../engine/stz_timeline.haro"
load "../../engine/stz_gridnav.haro"
load "../../engine/stz_sectmerge.haro"
load "../../engine/stz_deepops.haro"
load "../../engine/stz_reaxis.haro"
load "../../engine/stz_softanzuter.haro"
load "../../engine/stz_similarity.haro"
load "../../engine/stz_validator.haro"
load "../../engine/stz_sequence.haro"
load "../../engine/stz_intseq.haro"
load "../../engine/stz_relations.haro"
load "../../engine/stz_statemachine.haro"

# Modern / neural tier (vendored ggml runtime)
load "../../engine/stz_neural.haro"

# GPU plane lifecycle (vendored wgpu-native, loaded at Init time)
load "../../engine/stz_gpu.haro"

# Windowing and input (vendored GLFW). Its own DLL because it is the one
# module that cannot cross-compile; absent is a legitimate state.
load "../../engine/stz_window.haro"

# Layout and markup (vendored RmlUi). Its own DLL because RmlUi needs C++
# exceptions AND RTTI, which stz_gpu deliberately compiles without; absent
# is a legitimate state, exactly like the window above.
load "../../engine/stz_gui.haro"

# The accessibility bridge (vendored AccessKit). Its own DLL because
# AccessKit is per-OS -- UI Automation, NSAccessibility, AT-SPI -- which is
# the same property that put windowing in its own DLL above. Absent is a
# legitimate state: no bridge, everything else unchanged.
load "../../engine/stz_a11y.haro"

# Sound plane (vendored miniaudio), TWO DLLs on purpose -- FACT 3 of
# SOFTANZA_SOUND_PLAN.md. The portable half carries the whole sample tier and
# needs no hardware; the device half is per-OS and absent is a legitimate
# state, exactly like the window above.
load "../../engine/stz_sound.haro"
load "../../engine/stz_audiodev.haro"
load "../../engine/stz_voice.haro"

load "../../engine/stzMeta.haro"

# Initialize the meta-engine (named params, error catalog, aliases)
StzMetaInit()
