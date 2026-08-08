/* The single translation unit that owns the stb implementations for
   stz_gpu.dll (GR1). Everything else includes the headers as declarations.
   Scope trims are recorded in VERSION. */

#define STB_TRUETYPE_IMPLEMENTATION
#include "stb_truetype.h"

#define STB_IMAGE_IMPLEMENTATION
#define STBI_NO_STDIO
#define STBI_NO_HDR
#define STBI_NO_PIC
#define STBI_NO_PNM
#include "stb_image.h"
