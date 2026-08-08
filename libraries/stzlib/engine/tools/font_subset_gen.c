/* font_subset_gen -- generates the committed Arabic subset-font fixture
 * (GR2 of SOFTANZA_GRAPHICS_PLAN.md; the tiny_bert.gguf pattern applied
 * to fonts: a small, committed, deterministically regenerable fixture so
 * CI shapes REAL Arabic with no download).
 *
 * Inputs (documented, pinned, NOT committed):
 *   - HarfBuzz 14.3.0 source tarball (the SAME release pinned in
 *     vendor/harfbuzz/VERSION.txt, SHA-256
 *     16070d77cfc4ba1f1e7327e83bf9b3f55898081cabdb94e56a33e04fc8874eae):
 *     provides harfbuzz-subset.cc, which this tool compiles against.
 *     The subset machinery is deliberately NOT vendored (see VERSION.txt).
 *   - Amiri 1.003 (OFL 1.1), official release asset Amiri-1.003.zip,
 *     SHA-256 81af0aff7d2086d8af24cea7202f7546130997982534691373485cd96744d05e
 *     from https://github.com/aliftype/amiri/releases/tag/1.003 --
 *     source font Amiri-Regular.ttf. Its OFL.txt is committed BESIDE the
 *     fixture, as the license requires.
 *
 * Kept subset: Basic Latin printable (U+0020..U+007E) + the Arabic
 * letters/marks/digits/punctuation region (U+060C..U+066F -- the corpus
 * shapes words, not the Quranic annotation range; the full block tripled
 * the fixture for glyphs no guard reads) + U+200C..U+200F (ZWNJ/ZWJ/
 * LRM/RLM -- bidi controls a corpus legitimately contains). Layout
 * features (GSUB/GPOS -- joining, lam-alef ligature, marks) are
 * RETAINED: they are the fixture's point.
 *
 * Build + run (from libraries/stzlib/engine, HB = extracted tarball src):
 *   zig c++ -c <HB>/harfbuzz-subset.cc -o hb-subset.o -O2 \
 *       -fno-exceptions -fno-rtti -I <HB>
 *   zig cc tools/font_subset_gen.c hb-subset.o -o font_subset_gen \
 *       -O2 -I <HB> -lc++
 *   ./font_subset_gen Amiri-Regular.ttf \
 *       ../base/test/gpu/fixtures/amiri_arabic_subset.ttf
 */
#include <stdio.h>
#include <stdlib.h>
#include "hb.h"
#include "hb-subset.h"

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "usage: font_subset_gen <in.ttf> <out.ttf>\n");
        return 1;
    }

    hb_blob_t *src = hb_blob_create_from_file(argv[1]);
    if (hb_blob_get_length(src) == 0) {
        fprintf(stderr, "cannot read %s\n", argv[1]);
        return 1;
    }
    hb_face_t *face = hb_face_create(src, 0);

    hb_subset_input_t *input = hb_subset_input_create_or_fail();
    hb_set_t *unicodes = hb_subset_input_unicode_set(input);
    hb_set_add_range(unicodes, 0x0020, 0x007E); /* Basic Latin printable */
    hb_set_add_range(unicodes, 0x060C, 0x066F); /* Arabic letters/marks/digits */
    hb_set_add_range(unicodes, 0x200C, 0x200F); /* ZWNJ/ZWJ/LRM/RLM */

    hb_face_t *subset = hb_subset_or_fail(face, input);
    if (!subset) {
        fprintf(stderr, "subset failed\n");
        return 1;
    }
    hb_blob_t *out = hb_face_reference_blob(subset);
    unsigned int len = 0;
    const char *data = hb_blob_get_data(out, &len);

    FILE *f = fopen(argv[2], "wb");
    if (!f || fwrite(data, 1, len, f) != len) {
        fprintf(stderr, "cannot write %s\n", argv[2]);
        return 1;
    }
    fclose(f);
    printf("wrote %s: %u bytes, %u glyphs\n", argv[2], len,
           hb_face_get_glyph_count(subset));
    return 0;
}
