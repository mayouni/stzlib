// stz.js -- the Softanza <-> wasm bridge for the emulator's device windows.
//
// Loads stz.wasm (the differential engine edge, built by `zig build wasm`) and
// exposes it with a small marshalling surface: scalars pass by value, arrays are
// written into the module's shared linear memory via stz_alloc. This is what
// lets a device window run the REAL engine instead of a rehearsed value.
//
// Authored asset -- copied verbatim into each bundle by stzEmulator.ring.

(function (global) {
	'use strict';

	async function load(url) {
		var memory = new WebAssembly.Memory({ initial: 32, maximum: 256 });
		var bytes = await fetch(url).then(function (r) { return r.arrayBuffer(); });
		var mod = await WebAssembly.compile(bytes);
		// provide exactly what the module imports (only env.memory today); stub any
		// unexpected function import so instantiate never throws.
		var env = { memory: memory };
		WebAssembly.Module.imports(mod).forEach(function (i) {
			if (i.kind === 'function' && !env[i.name]) { env[i.name] = function () { return 0; }; }
		});
		var inst = await WebAssembly.instantiate(mod, { env: env });
		var e = inst.exports;
		return {
			exports: e,
			memory: memory,
			abi: (typeof e.stz_abi_version === 'function') ? e.stz_abi_version() : 0,
			// marshal a JS number[] into wasm as f64; returns { ptr, len }
			f64s: function (arr) {
				var ptr = e.stz_alloc(arr.length * 8);
				new Float64Array(memory.buffer, ptr, arr.length).set(arr);
				return { ptr: ptr, len: arr.length };
			},
			// marshal a JS string into wasm as UTF-8 bytes; returns { ptr, len }
			bytes: function (s) {
				var b = new TextEncoder().encode(s);
				var ptr = e.stz_alloc(b.length || 1);
				new Uint8Array(memory.buffer, ptr, b.length).set(b);
				return { ptr: ptr, len: b.length };
			},
			reset: function () { if (e.stz_reset) e.stz_reset(); }
		};
	}

	global.StzWasm = { load: load };
})(typeof window !== 'undefined' ? window : this);
