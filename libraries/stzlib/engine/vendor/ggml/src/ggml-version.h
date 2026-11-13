#pragma once

// Upstream CMake writes this file from ggml-version.h.in; stzlib builds ggml with zig and passes both values as
// -D flags (engine/build.zig, addGgml), so this header only fills them in when a build does not.
#ifndef GGML_VERSION
#define GGML_VERSION "0.29.0"
#endif
#ifndef GGML_COMMIT
#define GGML_COMMIT  "57e2c2ca"
#endif
