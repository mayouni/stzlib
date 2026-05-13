# Zing -- Product Vision

> *The power of Zig, the beauty of Ring, the soul of Softanza*

## What Is Zing

Zing is a self-contained programming platform for building
applications without dependencies. One download. One binary.
Everything works.

Zing inherits Ring's approachable syntax and Softanza's natural
coding paradigm, rewrites the entire runtime in Zig, and ships
as a single executable that includes the language, the engine,
the standard library, and the IDE.

**Zing is not Ring.** It is not a Ring wrapper, not a Ring
distribution, not a Ring framework. Zing is a distinct language
platform that happens to share Ring's syntax. A Zing program
cannot `load "qtcore.ring"` or use any Ring extension library.
It uses the Zing standard library (descended from Softanza) and
nothing else.

**Softanza lives on** as the name of the programming paradigm --
the coding style, the principles, the innovations. When we say
"Softanza style", we mean natural coding, narrated tests, the
Walker/Checker/Yielder/Performer framework, the Q() elevation,
the XT/Z/W suffix system, and the 300K lines of hard-won design
decisions. Zing is where Softanza runs.

---

## Who Is Zing For

### Primary audiences

1. **Education institutions** teaching programming. Zing's
   narrated coding style makes programs readable as stories.
   Students write code that explains itself. The IDE includes
   notebooks for interactive learning.

2. **Professional developers** in small enterprises who need
   productive tools without the weight of Java/.NET/Qt stacks.
   The kind of developers who today choose WinDev, 4D, Delphi,
   or FileMaker -- and suffer their lock-in and licensing costs.

3. **Solo developers and startups** building data-driven
   applications (APIs, automation, data processing) who want
   one tool that handles everything from prototype to production.

### What they get

- A language that reads like English but compiles to native code
- A single binary with zero dependencies (no runtime, no SDK)
- An IDE that understands the Softanza paradigm natively
- Deployment to desktop, server, mobile, web (WASM), and MCU
- A standard library of 300K+ lines covering strings, lists,
  dates, files, regex, graphs, tables, i18n, and natural coding

---

## The Zing Language

### Syntax

Zing uses Ring's syntax exactly: `if/ok`, `for/next`, `while/end`,
`class/func/def`, `?` for print. No changes. A Ring programmer
reads Zing instantly.

But Zing programs are written in Softanza style:

```zing
# Standard Ring style (NOT Zing):
for i = 1 to len(aList)
    if substr(aList[i], "test") > 0
        ? aList[i]
    ok
next

# Zing style (Softanza paradigm):
Q(aList).FindW('Q(@item).Contains("test")') {
    ? @item
}

# Or in natural code:
If _("programming").IsA(:String).Which(:Contains = "gram")._
    ? "Pattern found!"
ok
```

### What Zing keeps from Softanza

1. **Natural Coding (CnC)** -- code as narrative. The `_()` chain,
   the `Q()` elevator, the `@@()` inspector. Programs read like
   sentences: `If _("hello").IsA(:String).Which(:IsLowercase)._`

2. **The Suffix System** -- method variants that express intent:
   - `XT` (extended): more options, richer output
   - `Z` (positioned): returns positions as numbers
   - `ZZ` (sectioned): returns position pairs
   - `W` (conditional): walks with a filter expression
   - `CS` (case-sensitive): explicit case handling

3. **Walker/Checker/Yielder/Performer** -- the four verbs of
   collection processing. Walk a structure, check conditions,
   yield transformed values, perform mutations. All composable.

4. **Narrated Tests** -- tests as executable documentation.
   Expected output marked with `#-->`. Every test file is a
   tutorial. The IDE renders them as interactive notebooks.

5. **The Q() Elevator** -- promotes any value to its Softanza
   type in one character. `Q("hello")` gives a stzString with
   3969 methods. `Q([1,2,3])` gives a stzList with 3026 methods.

6. **Alternative Forms** -- multiple natural names for the same
   method. `Sort()`, `SortUp()`, `SortInAscending()`,
   `SortedInAscending()`. Write the name that fits the sentence
   you're building.

7. **Three-Layer Architecture** -- Core (stk*, lean), Base
   (stz*, rich), Max (stx*, advanced). Choose the weight class
   for your project.

### What Zing removes

- All Qt dependencies (QString2, QChar, QDate, QFile, QLocale...)
- All Ring extension libraries (no `load "guilib.ring"`)
- The Ring standard library (replaced by Zing stdlib)
- Any external C/C++ dependency

### What Zing adds

- Native Zig engine for all core operations (strings, dates,
  files, locale, regex, JSON)
- Native Zig HTTP server for API deployment
- WASM compilation target
- MCU deployment target (via Zig cross-compilation)
- The Zing IDE
- Package system (`.zpk` archives with manifest)

---

## The Zing Engine

The Zig-based runtime that powers everything:

```
zing (executable)
  |
  +-- Language Runtime
  |     Ring interpreter (embedded, no external ring.exe)
  |     Zing stdlib loader (auto-loads Softanza classes)
  |
  +-- Engine (native Zig)
  |     string.zig    -- UTF-8 string ops (20 functions)
  |     char.zig      -- Unicode char ops (6 functions)
  |     datetime.zig  -- Date/time/calendar (35 functions)
  |     file.zig      -- File/dir ops (17 functions)
  |     locale.zig    -- Locale formatting (10 functions)
  |     regex.zig     -- Pattern matching (planned)
  |     json.zig      -- JSON parse/generate (planned)
  |     http.zig      -- HTTP server (planned)
  |     crypto.zig    -- Hashing/encryption (planned)
  |     db.zig        -- SQLite embedded (planned)
  |
  +-- Compiler Backends
  |     native    -- Zig cross-compilation to any OS/arch
  |     wasm      -- WebAssembly for browser/edge
  |     mcu       -- Bare-metal for microcontrollers
  |
  +-- IDE Server
        LSP-compatible language server
        Notebook renderer
        Live REPL
```

---

## Output Types

Zing programs compile to five deployment forms:

### 1. Notebook (.zing)
Interactive narrated programs. Code cells interleaved with
markdown documentation and live output. The primary format for
education and prototyping.

```
Rendered in the IDE as:

+--------------------------------------------------+
| # String Operations                              |
| Learn how Softanza handles text naturally         |
+--------------------------------------------------+
| o1 = Q("Hello, Zing!")                           |
| ? o1.NumberOfChars()     #--> 12                 |
| ? o1.Contains("Zing")   #--> TRUE               |
| ? @@(o1.Chars())         #--> ["H","e","l",...]  |
+--------------------------------------------------+
| # Finding patterns                               |
| The W() suffix walks with a condition...         |
+--------------------------------------------------+
| ? o1.FindW('Q(@char).IsUppercase()')             |
|                          #--> [1, 8]             |
+--------------------------------------------------+
```

### 2. Executable (.exe / native binary)
Standalone desktop applications. No runtime needed on the target
machine. Cross-compiled via Zig to Windows, Linux, macOS, ARM.

```bash
zing build myapp.zing --target windows-x86_64
zing build myapp.zing --target linux-aarch64
zing build myapp.zing --target macos-arm64
```

### 3. Library (.dll / .so / .dylib)
Reusable Zing modules that other Zing programs can import.
Also callable from C/C++/Zig via the Engine's C ABI.

```bash
zing build mylib.zing --output library
```

### 4. API Service
HTTP API server with automatic endpoint generation. The Zing
HTTP server is native Zig -- no Node, no Python, no Apache.

```zing
# myapi.zing
service CustomerAPI on port 8080

    endpoint GET "/customers" {
        oTable = Q(LoadTable("customers.db"))
        return oTable.ToJSON()
    }

    endpoint POST "/customers" {
        oData = Q(RequestBody()).FromJSON()
        SaveRecord("customers.db", oData)
        return '{"status": "created"}'
    }
end
```

```bash
zing serve myapi.zing              # Development
zing build myapi.zing --output api  # Production binary
```

### 5. WebAssembly (.wasm)
Browser-deployable modules. Zing programs run in any modern
browser without plugins. Ideal for interactive notebooks shared
as web pages and for edge computing.

```bash
zing build myapp.zing --target wasm
# Produces: myapp.wasm + myapp.html (loader)
```

### 6. MCU Firmware
Programs for microcontrollers (ESP32, STM32, RP2040). The Core
layer (stk*) runs on bare metal with minimal memory. Zig's
cross-compilation handles the toolchain.

```bash
zing build sensor.zing --target thumb-cortex-m4
# Produces: sensor.bin (flash-ready)
```

---

## The Zing IDE

A lightweight, modern IDE built natively in Zig. Not Electron.
Not VS Code with a plugin. A purpose-built environment that
understands Softanza's paradigm from the ground up.

### Design principles

1. **Notebook-first.** The default view is a notebook -- code
   cells, markdown cells, live output. Not a blank text editor.
   This is how Softanza programs are meant to be read.

2. **Narration-aware.** The IDE understands `#-->` output markers,
   `pr()`/`pf()` profiling blocks, and test narration structure.
   It renders them as visual elements, not plain text.

3. **Method discovery.** When you type `Q("hello").`, the IDE
   shows 3969 methods organized by Softanza's semantic categories
   (Finding, Replacing, Splitting, Walking, Checking...), not
   an alphabetical dump. Alternative forms are grouped together.

4. **Suffix guides.** Typing a method name shows its suffix
   variants: `Find` -> `FindCS`, `FindW`, `FindWXT`, `FindZ`,
   `FindZZ`, `FindNth`, `FindNthCS`. Each variant explained
   in one line.

5. **Live output.** Output appears inline next to the code,
   matching the `#-->` markers. The program runs continuously
   as you type (debounced). No "Run" button needed for
   exploration.

6. **Layer indicator.** The status bar shows which layer
   (Core/Base/Max) is active and the memory/performance profile
   of the current code. Switching layers is one click.

7. **Cultural alignment.** The IDE supports RTL languages natively
   (Arabic, Hebrew). Font rendering respects Unicode fully.
   The interface can be localized to any language via JSON
   dictionary files. English default, French first-class.

### IDE components

```
+------------------------------------------------------+
| Zing IDE                                    [_][#][X] |
+----------+-------------------------------------------+
| Explorer | # My First Notebook              [Run All] |
|          |                                            |
| myapp/   | [MD] ## Working with Strings               |
|  main.zing| Zing makes string operations natural...   |
|  data/   |                                            |
|  tests/  | [>>] o1 = Q("Hello, Zing!")                |
|          |      ? o1.UppercaseFirst()                  |
|          |      --> "Hello, zing!"                     |
|          |                                            |
|          | [>>] ? o1.FindW('Q(@char).IsVowel()')      |
|          |      --> [2, 5, 9]                          |
|          |                                            |
|          | [MD] ## Lists and Tables                    |
|          |      Collections work the same way...      |
|          |                                            |
|          | [>>] oList = Q([3, 1, 4, 1, 5, 9])         |
|          |      ? oList.SortedUp()                     |
|          |      --> [1, 1, 3, 4, 5, 9]                |
|          |                                            |
+----------+-------------------------------------------+
| Output   | Doctor  | Terminal  | Problems    | Tests  |
+------------------------------------------------------+
```

### IDE architecture

```
Zing IDE (Zig native)
  |
  +-- Renderer
  |     GPU-accelerated text (Zig + platform graphics)
  |     Notebook cell layout engine
  |     Syntax highlighter (Zing-aware)
  |     Unicode/RTL text shaping
  |
  +-- Language Server (LSP)
  |     Code completion (Softanza-aware categories)
  |     Suffix variant suggestions
  |     Inline documentation from narrations
  |     Error diagnostics with Softanza context
  |
  +-- Notebook Engine
  |     Cell execution (code / markdown / output)
  |     Live output rendering
  |     Export to HTML / PDF / .zing
  |
  +-- Project Manager
  |     Package management (.zpk)
  |     Build targets (exe / lib / api / wasm / mcu)
  |     Test runner integration
  |
  +-- Terminal
        Embedded Zing REPL
        Build output
        Doctor diagnostics
```

---

## The Zing Standard Library

The Softanza codebase, rewritten to use only the Zing Engine.
No Qt, no Ring extensions. 300K+ lines organized in three layers:

### Core Layer (stk*) -- Lean & Fast
For resource-constrained targets (MCU, WASM, embedded).

| Module       | Class        | Methods |
|--------------|-------------|---------|
| Number       | stkNumber   | 53      |
| String       | stkString   | 51      |
| Char         | stkChar     | 7       |
| List         | stkList     | 28      |
| Buffer       | stkBuffer   | 65      |
| Pointer      | stkPointer  | 66      |
| Memory       | stkMemory   | 24      |

### Base Layer (stz*) -- Rich & Semantic
The full Softanza experience. 20 domains, thousands of methods.

| Domain     | Key Classes                        |
|------------|-----------------------------------|
| String     | stzString (~3969 methods)         |
| List       | stzList (~3026 methods)           |
| Number     | stzNumber, stzDecimalToBinary     |
| Char       | stzChar, stzListOfChars           |
| Table      | stzTable (~2472 methods)          |
| DateTime   | stzDate, stzTime, stzDateTime     |
| File       | stzFile, stzFolder, stzZipFile    |
| Regex      | stzRegex                          |
| Graph      | stzGraph, stzTree                 |
| i18n       | stzLocale, stzCountry, stzScript  |
| Natural    | stzNaturalCode, stzChainOfTruth   |
| Reactive   | stzReactive                       |

### Max Layer (stx*) -- Advanced & Innovative
For industrial-grade applications.

| Module        | Purpose                          |
|---------------|----------------------------------|
| Walker        | Custom traversal patterns        |
| Parser        | Text/structure parsing           |
| BigNumber     | Arbitrary precision arithmetic   |
| MultiString   | Parallel string processing       |
| TextEncoding  | Charset conversion               |
| BinaryFile    | Binary data manipulation         |
| Testoor       | Narrated test framework          |

---

## Deployment Targets

### Desktop (Windows, Linux, macOS)
Zig cross-compiles to any OS/architecture. A Zing program built
on Windows runs on Linux ARM without changes.

### Server (Linux, containers)
API services deploy as single static binaries. No runtime
dependencies. Container images are tiny (~10MB).

### Mobile (Android, iOS)
Via Zig's cross-compilation to ARM targets. The Core layer runs
within mobile app frameworks. Zing logic runs native; UI
delegates to platform widgets.

### Web (WebAssembly)
The Engine compiles to WASM. Zing notebooks run in the browser.
Interactive documentation, educational content, and lightweight
web applications.

### Microcontrollers (ESP32, STM32, RP2040)
The Core layer targets bare-metal ARM/RISC-V. Zig handles the
toolchain. Sensor data processing, IoT edge logic, embedded
control systems.

### Edge (Cloudflare Workers, Fastly)
WASM deployment to edge computing platforms. Zing API handlers
run at the CDN edge with sub-millisecond cold starts.

---

## Competitive Positioning

### vs. WinDev
WinDev: proprietary, expensive, Windows-locked, French-only docs.
Zing: open, free, cross-platform, multilingual, modern paradigm.
Same proposition (one tool for everything) without the lock-in.

### vs. 4D
4D: database-centric, proprietary runtime, legacy architecture.
Zing: general-purpose, zero dependencies, modern Zig engine.
4D's strength (integrated database) becomes a Zing plugin.

### vs. Delphi
Delphi: Object Pascal, heavy IDE, RAD focus, aging community.
Zing: natural syntax, lightweight IDE, notebook-first, growing.
Delphi's compilation speed? Zing matches it with Zig.

### vs. Python + Jupyter
Python: rich ecosystem, but dependency hell, slow, GIL-limited.
Zing: self-contained, native speed, no `pip install` chain.
Jupyter's notebooks? Zing notebooks are native, not browser-based.

### vs. Node.js
Node: async-first, npm sprawl, V8 dependency, security surface.
Zing: sync-natural, no package manager (stdlib is enough),
native binary, minimal attack surface.

---

## Naming Architecture

| Name      | What it is                                        |
|-----------|---------------------------------------------------|
| **Zing**  | The language platform (CLI, runtime, engine, IDE) |
| **Softanza** | The programming paradigm and stdlib heritage  |
| **Engine**| The Zig native core (string, date, file, etc.)    |
| **Zin**   | The declarative compiler (separate product)       |

Zing can be a Zin product in the future (a domain in the Zin
ecosystem), but that relationship is architectural, not branding.
Zing stands alone as its own product.

---

## Implementation Roadmap

### v0.1 -- Foundation (current state)
- [x] Engine Tier 1: string + char (26 functions)
- [x] Engine Tier 2: datetime + file + locale (62 functions)
- [x] Ring FFI bridge (stzengine.ring)
- [x] Core layer wired to Engine
- [x] CLI skeleton (run/test/build/version/doctor)
- [ ] Remove all Qt code paths (make Engine the only path)

### v0.2 -- Self-Sufficient
- [ ] Engine Tier 3: regex + json + variant + http
- [ ] Base layer wired to Engine (stzString, stzDateTime, etc.)
- [ ] Embedded Ring interpreter (no external ring.exe needed)
- [ ] Package format (.zpk) with manifest
- [ ] `zing serve` with native HTTP server

### v0.3 -- IDE Alpha
- [ ] IDE: text editor with Zig renderer
- [ ] IDE: notebook cell layout
- [ ] IDE: syntax highlighting (Zing-aware)
- [ ] IDE: live output rendering
- [ ] IDE: method completion (category-organized)

### v0.4 -- Deployment
- [ ] Cross-compilation to Windows/Linux/macOS/ARM
- [ ] WASM target for browser deployment
- [ ] MCU target for embedded deployment
- [ ] `zing build --target` command
- [ ] Single-binary production builds

### v0.5 -- Production
- [ ] IDE: LSP language server
- [ ] IDE: suffix variant suggestions
- [ ] IDE: integrated test runner
- [ ] API service framework with routing
- [ ] SQLite embedded database engine
- [ ] Documentation generator from narrated tests

### v1.0 -- Release
- [ ] IDE: complete, polished, documented
- [ ] Stdlib: all Softanza domains Engine-backed
- [ ] All 6 deployment targets working
- [ ] Installer/package for each platform
- [ ] Zing website + interactive playground (WASM)
- [ ] Education curriculum package

---

## The Zing Promise

**To educators:** Your students write code that reads like
English. The IDE shows them what happens as they type. Tests
are stories, not assertions. Programming becomes literacy.

**To professional developers:** One binary replaces your IDE,
your runtime, your framework, and your build tool. Deploy to
any platform. No license fees, no vendor lock-in, no dependency
chain. Your code runs the same everywhere.

**To enterprises:** A single tool for desktop apps, web APIs,
mobile logic, IoT firmware, and data processing. Train one team
in one language. Deploy anywhere. Own your stack.

*Zing -- one tool, every target, zero dependencies.*
