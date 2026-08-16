# Recovered plugin-system implementations

Restored from git history 2026-08-16 at the author's direction, after
the plan's first survey wrongly called the plane "claims, not code"
from the current tree alone. Full disposition: `../SOFTANZA_PLUGIN_PLAN.md`
§0.6. **Nothing here is loaded by stzBase** — these are reference
artifacts for the PL1 rebuild, not live library code.

## `2024/` — the single-file system that WORKS

Verbatim from `dfd4b948c:libraries/softanzalib/stzPluginSystem.ring`
(July 6–11, 2024 lineage) plus its four plugin files. Re-run 2026-08-16
under Ring 1.27: discovery, per-call `ring_state` isolation, `@@()`
value injection, `findvar` readback, and the per-object ledger all
work. One seam defect found and fixed:

- **Defect**: the plugin file computes `@plugin_result` at load time
  from its own embedded sample `@plugin_value`; `Xf()` injected the
  host value afterwards but never re-invoked `pluginFunc` — so the
  injected value was dead. The 2024 demo could not see this because
  its demo string equaled every plugin's embedded sample
  ("Hello Ring in Ring!").
- **Fix** (one line, in `Xf()` and `Xff()`): after the two injections,
  `ring_state_runcode(pState, '@plugin_result = pluginFunc(@plugin_value, @plugin_param)')`.

Files:

| file | what |
|---|---|
| `2024/stzPluginSystem.ring` | verbatim recovery (narration + implementation), UNFIXED |
| `2024/impl_fixed.ring` | implementation half only, with the fix applied (2 sites) |
| `2024/demo.ring` | runnable proof on bare Ring + stdlib: `cd 2024 && ring demo.ring` |
| `2024/plugins/` | the four original plugin files, verbatim |

Measured 2026-08-16 (Ring 1.27, Windows): ~3.1 ms per call with a
fresh state created and deleted every call (100-call average). The
2024 `E3: Deleting scope while no scope!` warning did not reproduce.

## `2025-plugma/` — the layered refactor that NEVER RAN

Verbatim from `0276248b2^:libraries/stzlib/max/wings/plugma/` (June
24–26, 2025), deleted 2025-06-26 as silent collateral of the wings
folder renaming. 17 files: foundation / execution / integration
layers. Kept for its ARCHITECTURE — bounded state pool with eviction,
cache with hit/miss stats and file-time invalidation, per-object
ledger mixin, cooperative time/size constraint checks inside the
plugin files, options lists on the executor — which independently
corroborates the plan's D2/D3 rulings.

Known execution defects (measured, do not "fix" this copy — PL1
rebuilds instead): R19 constructor arity on `new stzPluginCacheManager()`;
`fexists()` on a directory makes discovery return zero plugins;
`ring_state_runstring()` does not exist (the API is `ring_state_runcode`);
`pluginFunc(aPluginParams)` passes 1 arg to a 2-param function; the
host value is never transmitted at all; `fgettime()` is a placeholder
returning `clock()`, silently neutralizing both the cache and hot
reload; `stzXString.Content()` is an infinite recursion; one Python
`pass` statement.
