/* stb_image_write for the image plane (IM1 of SOFTANZA_IMAGE_INTELLIGENCE.md):
   JPEG (and TGA) writing, to memory only. Its own translation unit because
   the JPEG encoder left-shifts negative values -- defined on every compiler
   in use and UB by the letter of C -- so it is built with
   -fno-sanitize=undefined, as the other vendored C (ggml) is, while
   stz_stb_impl.c keeps the sanitizer. Measured 2026-11-01: an
   "Illegal instruction" trap in stbi_write_jpg_to_func under ReleaseSafe. */

#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STBI_WRITE_NO_STDIO
#include "stb_image_write.h"
