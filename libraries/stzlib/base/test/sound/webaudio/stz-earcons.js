// stz-earcons.js -- SS5. The semantic vocabulary, in a browser, from the SAME
// source the native tier renders.
//
// ── WHY THIS FILE HAS NO MOTIF IN IT ────────────────────────────────────────
//
// There is not one frequency, duration, waveform or envelope below. That is
// the entire point. The four motifs live in `sounddsp.zig`, the seam compiled
// into both `stz_sound.dll` and `stz.wasm`, so there is exactly ONE author of
// what :Danger sounds like.
//
// VC5 deliberately left browser earcons unbuilt and said why: *porting them is
// a second implementation of a vocabulary, and a second implementation drifts.*
// It drifts silently, too, because nobody renders the same meaning on two
// tiers and compares -- so the drift is only ever discovered by a person who
// notices that the web app sounds subtly wrong, years later, with no way to
// tell which side moved. `earcon_guard.html` compares them on every run.
//
// ── NOT A GRAPH, AND NOT A WORKLET ──────────────────────────────────────────
//
// `stz-sound.js` runs the graph in an AudioWorklet because a graph is
// continuous and deadline-bound. A cue is neither: it is 180 ms of arithmetic
// that depends on nothing but its own frame index. So it is pulled out ONCE
// into an AudioBuffer and played with a BufferSource -- fewer moving parts,
// and lower latency, because there is no ring and no quantum to wait for.
//
// ── IT IS PULLED IN CHUNKS, AND THAT IS A SIZE DECISION ─────────────────────
//
// wasm gives back the motif through the block buffer the worklet already uses,
// a few hundred frames at a time. The first cut had the module carry a
// 32768-frame static to render into, which put 128 KB into every download for
// a cue lasting 180 ms. Streaming costs nothing and is bit-identical -- a Zig
// guard asserts chunked and whole renders agree sample for sample.

(function (global) {
	'use strict';

	// The engine's order. Kept as a NAME->INDEX map rather than an array
	// position, so reordering one list cannot silently remap every meaning to
	// the wrong sound.
	var VALUE = { danger: 0, warning: 1, info: 2, success: 3, muted: 4 };

	// Rule 118's five. This face does not get to add a sixth -- that would be a
	// constitutional amendment wearing a library's clothes.
	var VALUES = ['danger', 'warning', 'info', 'success', 'muted'];

	// This channel's steps, which are NOT colour's. Both spell a step the same
	// way (value.step) but a SURFACE is not a thing sound has and an ALERT is
	// not a thing colour has -- see SS4.
	var STEPS = ['cue', 'alert', 'ambient'];

	function parse(meaning) {
		var c = String(meaning).toLowerCase();
		var v = c, s = 'cue';
		var d = c.indexOf('.');
		if (d >= 0) { v = c.slice(0, d); s = c.slice(d + 1); }
		if (!(v in VALUE)) {
			return { value: '', step: '', reason: "no semantic value named '" + meaning + "'" };
		}
		// AN UNKNOWN STEP IS REFUSED, exactly as the Ring face refuses it. Two
		// faces sharing a vocabulary must fail the same way, or the vocabulary
		// is only shared when nothing goes wrong.
		if (STEPS.indexOf(s) < 0) {
			return {
				value: '', step: '',
				reason: "'" + v + "' is a semantic value but '" + s +
				        "' is not one of this channel's steps (" + STEPS.join(', ') + ")"
			};
		}
		return { value: v, step: s, reason: '' };
	}

	function Earcons() {
		this._ctx = null;
		this._e = null;
		this._mem = null;
		this._buffers = {};       // value -> AudioBuffer
		this._refusals = 0;
		this._lastError = '';
		this._rate = 0;
	}

	Earcons.prototype.values = function () { return VALUES.slice(); };
	Earcons.prototype.steps = function () { return STEPS.slice(); };
	Earcons.prototype.refusals = function () { return this._refusals; };
	Earcons.prototype.lastError = function () { return this._lastError; };
	Earcons.prototype.sampleRate = function () { return this._rate; };

	// Load the module and render every motif ONCE, at the context's own rate.
	// Rendering at play time would put arithmetic between the event and the
	// cue, on the one channel whose whole job is being fast.
	Earcons.prototype.start = async function (wasmUrl, opts) {
		opts = opts || {};
		this._ctx = opts.context ||
			new (global.AudioContext || global.webkitAudioContext)({
				latencyHint: opts.latencyHint || 'interactive'
			});
		this._rate = this._ctx.sampleRate;

		var memory = new WebAssembly.Memory({ initial: 32, maximum: 256 });
		var bytes = await fetch(wasmUrl).then(function (r) { return r.arrayBuffer(); });
		var mod = await WebAssembly.compile(bytes);
		var env = { memory: memory };
		WebAssembly.Module.imports(mod).forEach(function (i) {
			if (i.kind === 'function' && !env[i.name]) { env[i.name] = function () { return 0; }; }
		});
		var inst = await WebAssembly.instantiate(mod, { env: env });
		this._e = inst.exports;
		this._mem = memory;

		if (typeof this._e.stz_snd_earcon_chunk !== 'function') {
			this._lastError = 'this stz.wasm has no earcon exports -- rebuild with ' +
			                  'the sound group';
			throw new Error(this._lastError);
		}
		// the worklet's block buffer is where a chunk lands; reset gives it a
		// size before anything reads it
		this._e.stz_snd_reset(this._rate, 1, 128);

		for (var i = 0; i < VALUES.length; i++) {
			var v = VALUES[i];
			var pcm = this._render(VALUE[v]);
			this._buffers[v] = pcm;   // null for muted, and that is its rendering
		}
		return this;
	};

	// Pull one motif out of wasm, a chunk at a time, into an AudioBuffer.
	Earcons.prototype._render = function (idx) {
		var total = this._e.stz_snd_earcon_frames(idx, this._rate);
		if (total === 0) return null;              // muted: silence IS the rendering
		var buf = this._ctx.createBuffer(1, total, this._rate);
		var out = buf.getChannelData(0);
		var ptr = this._e.stz_snd_block_ptr();
		var at = 0;
		var guard = 0;
		while (at < total && guard++ < 100000) {
			var n = this._e.stz_snd_earcon_chunk(idx, this._rate, at);
			if (n === 0) break;
			// a FRESH view every time: the memory can grow, and a stale
			// Float32Array over a detached buffer reads zeros without erroring
			var view = new Float32Array(this._mem.buffer, ptr, n);
			out.set(view, at);
			at += n;
		}
		return buf;
	};

	// The motif as DATA, for a caller that wants to measure rather than hear
	// it -- the browser half of stzEarcons.ToSoundOf.
	Earcons.prototype.toBufferOf = function (meaning) {
		var p = parse(meaning);
		if (p.value === '') {
			this._refusals++;
			this._lastError = p.reason;
			return null;
		}
		return this._buffers[p.value] || null;
	};

	Earcons.prototype.isSilentValue = function (meaning) {
		return parse(meaning).value === 'muted';
	};

	// Sound it. Returns the moment it will start, or null if refused.
	Earcons.prototype.fire = function (meaning) {
		var p = parse(meaning);
		if (p.value === '') {
			this._refusals++;
			this._lastError = p.reason;
			return null;
		}
		var buf = this._buffers[p.value];
		if (!buf) return this._ctx.currentTime;   // muted sounds nothing, and succeeds
		var src = this._ctx.createBufferSource();
		src.buffer = buf;
		src.connect(this._ctx.destination);
		src.start();
		return this._ctx.currentTime;
	};

	// WHAT THE BROWSER TIER IS HONEST ABOUT.
	//
	// The Ring face carries a POLICY as well as a vocabulary: priority,
	// refraction, drop counting, and SS3's per-bus ducking. None of that is
	// here, and porting it would repeat exactly the mistake this file was
	// written to avoid -- a second implementation of something that has to
	// agree with itself across tiers. What is shared is the VOCABULARY, which
	// is the part that is pure arithmetic and therefore movable.
	Earcons.prototype.capabilities = function () {
		return {
			tier: 'browser',
			sampleRate: this._rate,
			values: VALUES.slice(),
			steps: STEPS.slice(),
			vocabularyFrom: 'sounddsp.zig, the same seam the native tier renders',
			hasPolicy: false,
			policyNote: 'priority, refraction, drop counting and ducking live in ' +
			            'the Ring face. They are not ported: a second ' +
			            'implementation of a policy drifts exactly as a second ' +
			            'implementation of a vocabulary does.'
		};
	};

	// Frames a value SHOULD occupy at this rate, straight from the engine --
	// what a cross-tier guard compares.
	Earcons.prototype.framesOf = function (meaning) {
		var p = parse(meaning);
		if (p.value === '') return -1;
		return this._e.stz_snd_earcon_frames(VALUE[p.value], this._rate);
	};

	global.StzEarcons = {
		create: function () { return new Earcons(); },
		VALUES: VALUES,
		STEPS: STEPS
	};
})(typeof window !== 'undefined' ? window : this);
