# Zing -- the Zin-Softanza Bridge

> "The power of Zig, the beauty of Ring"

## What Is Zing

Zing is the architectural bridge between Zin (the declarative
compiler) and Softanza (the imperative library). It makes the
Softanza Engine a first-class part of the Zin stdlib, and lets
Zin pillars delegate heavy computation to Engine modules.

## Architecture

```
    Zin Compiler (Zig)
         |
    Zing Bridge Layer
    +----+----+----+----+----+
    |    |    |    |    |    |
  string char date file locale  <-- Engine modules
    |    |    |    |    |
    +----+----+----+----+
         |
    Softanza Engine (Zig shared lib)
         |
    Ring FFI Bridge (stzengine.ring)
         |
    Softanza Library (Ring)
```

## Module Mapping

| Engine Module | Zin Pillar   | Ring Layer       | Purpose                      |
|---------------|-------------|------------------|------------------------------|
| string.zig    | Zxt (text)  | stkString.ring   | UTF-8 string operations      |
| char.zig      | Zxt (text)  | stkChar.ring     | Unicode character ops        |
| datetime.zig  | Zab (agent) | stzDateTime.ring | Date/time/calendar           |
| file.zig      | Zof (ops)   | stzFile.ring     | File and directory ops       |
| locale.zig    | Zml (i18n)  | stzLocale.ring   | Locale-aware formatting      |
| regex.zig*    | Zxt (text)  | stzRegex.ring    | Pattern matching             |
| json.zig*     | Zql (data)  | stzJSON.ring     | JSON parse/generate          |

*Tier 3, planned

## Integration Points

### 1. Zin Direct Linking (compile-time)

Zin links `softanza_engine_static.a` at compile time. Any Zin
pillar can call Engine functions directly:

```zig
// In a Zin pillar implementation
const engine = @import("softanza_engine");

pub fn processText(input: []const u8) ![]const u8 {
    const s = engine.string.stz_string_from(input.ptr, input.len);
    defer engine.string.stz_string_free(s);
    const upper = engine.string.stz_string_to_upper(s);
    defer engine.string.stz_string_free(upper);
    // ...
}
```

### 2. Ring Dynamic Loading (runtime)

Ring loads `softanza_engine.dll` via FFI. The `stzengine.ring`
bridge wraps every C function. Softanza classes use Engine when
`$STZ_ENGINE_LOADED = TRUE`, falling back to Qt otherwise.

### 3. ZinFoundry Packs (declarative)

ZinFoundry packs can declare Engine dependencies:

```zab
agent TextProcessor {
    requires engine.string
    requires engine.locale
}
```

The pack builder ensures the Engine DLL is bundled.

## Value Proposition

1. **Shared substrate**: Zin and Softanza share the same Zig
   code. A bug fixed in Engine benefits both.

2. **Qt elimination**: Ring no longer needs Qt for core ops.
   The Engine is 1.1MB vs Qt's 30MB+.

3. **Performance**: Zin pillars call Engine directly (no FFI
   overhead). Ring calls via C FFI (fast, no marshalling).

4. **Single binary**: The `softanza` CLI bundles Engine
   statically. The `zin` CLI can link it too.

## Implementation Phases

### Phase A: Static Library Integration (current)
- Engine builds both .dll and .a
- Zin build.zig can add Engine as a dependency
- No source changes needed in Zin -- just link

### Phase B: Pillar Delegation
- Zxt pillar delegates string ops to Engine
- Zml pillar delegates locale ops to Engine
- Zof pillar delegates file ops to Engine

### Phase C: Unified Test Surface
- Engine tests run as part of `zin test`
- Softanza tests run as part of `softanza test`
- Both share the same test data (Unicode tables, locale data)

### Phase D: Pack Integration
- ZinFoundry packs declare Engine requirements
- `zin foundry build` bundles Engine into pack artifacts
- Runtime engine version check at pack load time

## Zin Comparative Advantage

Zing is the realization of the Zin philosophy at library level:
- **Declarative surface** (Zin pillars) backed by
  **imperative substrate** (Engine)
- **One codebase, multiple surfaces**: same Engine powers
  both the compiler CLI and the Ring library
- **Progressive adoption**: start with Ring + Engine,
  migrate to Zin declarations as pillars mature
