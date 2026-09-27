// stz-music.js -- the Softanza music plane in a browser (MU6).
//
// WHERE LIVE PERFORMANCE LIVES. The native path carries a 16384-frame ring
// (341 ms) plus the device -- the plan's S.5 measured about 419 ms from a
// request to the ear. That is fine for a score and useless for a key. Here
// there is no ring: WebAudio's clock is sample-accurate, a note already
// rendered starts when asked, and what remains is the browser's own latency --
// which this file REPORTS (baseLatency + outputLatency), never assumes.
//
// THE SAME NOTES. Every note is rendered by stz.wasm, which is soundinstr.zig
// compiled for wasm32 -- the twenty instruments of MU1, byte for byte the
// arithmetic the native tier runs. mu6_guard.html holds them against
// mu6_notes_expect.json, which the NATIVE engine writes.
//
// THE SAME PATTERNS. The mini-notation below is a port of base/common/
// stzPattern.ring and base/sound/stzSoundPattern.ring, line for line -- the
// grammar, the per-cycle query, the deterministic '?', the octave that carries.
// A port is a second author, so it is held against mu6_patterns_expect.json,
// which the Ring classes write; a divergence fails the guard, not a listener.
//
// THE SAME LAW OF LIVENESS (MU3): a loop is posted a WHOLE cycle at a time, a
// little ahead of the audio clock, so a redefinition lands on the first cycle
// not yet posted -- never inside one.

(function (global) {
	'use strict';

	// ── the note name reader: StzNoteToHz, ported ──────────────────────────
	function noteToHz(pc) {
		var c = String(pc).trim();
		if (c.length < 2) return 0;
		var n;
		switch (c[0].toUpperCase()) {
			case 'C': n = -9; break; case 'D': n = -7; break; case 'E': n = -5; break;
			case 'F': n = -4; break; case 'G': n = -2; break; case 'A': n = 0; break;
			case 'B': n = 2; break; default: return 0;
		}
		var i = 1;
		if (c[i] === '#') { n++; i++; } else if (c[i] === 'b') { n--; i++; }
		var oct = '';
		while (i < c.length && /[0-9]/.test(c[i])) { oct += c[i]; i++; }
		if (oct === '') return 0;
		var cents = 0;
		if (i < c.length) {
			var sign = c[i];
			if (sign !== '+' && sign !== '-') return 0;
			var d = ''; i++;
			while (i < c.length && /[0-9]/.test(c[i])) { d += c[i]; i++; }
			if (d === '' || i < c.length) return 0;
			cents = Number(d);
			if (sign === '-') cents = -cents;
		}
		var semis = n + 12 * (Number(oct) - 4) + cents / 100;
		return 440 * Math.pow(2, semis / 12);
	}

	// ── the pattern: stzPattern + stzSoundPattern, ported ──────────────────
	var STROKES = { bd: 'kick', sn: 'snare', hh: 'hihat', kick: 'kick', snare: 'snare',
		hihat: 'hihat', hat: 'hihat', dum: 'dum', tak: 'tak', ka: 'ka' };
	var SPECIAL = '[]<>,*/?!@~';

	function Pattern(text) {
		this.text = String(text);
		this.error = '';
		this.seed = 7;
		this.root = this._parse(this.text);
	}
	Pattern.prototype.isValid = function () { return this.root !== null; };

	Pattern.prototype._refuse = function (why) { this.error = why; };

	Pattern.prototype._parse = function (t) {
		this.ch = t.split('');
		this.pos = 0;
		this.oct = '4';
		this.degrades = 0;
		this._ws();
		if (this.pos >= this.ch.length) { this._refuse('an empty pattern'); return null; }
		var n = this._stack('');
		if (n === null) return null;
		this._ws();
		if (this.pos < this.ch.length) { this._refuse('at ' + (this.pos + 1) + ": unexpected '" + this.ch[this.pos] + "'"); return null; }
		return n;
	};
	Pattern.prototype._ws = function () {
		while (this.pos < this.ch.length && /\s/.test(this.ch[this.pos])) this.pos++;
	};
	Pattern.prototype._stack = function (close) {
		var seqs = [];
		for (;;) {
			var s = this._seq(close);
			if (s === null) return null;
			seqs.push(s);
			this._ws();
			if (this.pos < this.ch.length && this.ch[this.pos] === ',') { this.pos++; continue; }
			break;
		}
		return seqs.length === 1 ? seqs[0] : ['stack', seqs];
	};
	Pattern.prototype._seq = function (close) {
		var st = [];
		for (;;) {
			this._ws();
			if (this.pos >= this.ch.length) {
				if (close !== '') { this._refuse("at the end: '" + close + "' is missing"); return null; }
				break;
			}
			var c = this.ch[this.pos];
			if (c === ',' || c === close) break;
			if (c === ']' || c === '>') { this._refuse('at ' + (this.pos + 1) + ": '" + c + "' closes nothing"); return null; }
			var r = this._step();
			if (r === null) return null;
			for (var k = 0; k < r.length; k++) st.push(r[k]);
		}
		if (st.length === 0) { this._refuse('at ' + (this.pos + 1) + ': an empty sequence'); return null; }
		if (st.length === 1 && st[0][1] === 1) return st[0][0];
		return ['seq', st];
	};
	Pattern.prototype._number = function () {
		var s = '';
		while (this.pos < this.ch.length && /[0-9.]/.test(this.ch[this.pos])) { s += this.ch[this.pos]; this.pos++; }
		if (s === '' || s === '.') return null;
		return Number(s);
	};
	Pattern.prototype._step = function () {
		var n = this._term();
		if (n === null) return null;
		var w = 1, rep = 1;
		while (this.pos < this.ch.length) {
			var c = this.ch[this.pos];
			if (c === '*' || c === '/') {
				this.pos++;
				var k = this._number();
				if (k === null) k = 0;
				if (k < 1 || k !== Math.floor(k)) { this._refuse('at ' + (this.pos + 1) + ": '" + c + "' takes a whole number, 1 or more"); return null; }
				n = c === '*' ? ['fast', n, k] : ['slow', n, k];
			} else if (c === '?') {
				this.pos++; this.degrades++;
				n = ['degrade', n, this.degrades];
			} else if (c === '!') {
				this.pos++;
				var r = this._number();
				if (r === null) rep = 2;
				else { if (r < 1 || r !== Math.floor(r)) { this._refuse("'!' takes a whole number"); return null; } rep = r; }
			} else if (c === '@') {
				this.pos++;
				var ww = this._number();
				if (ww === null) ww = 0;
				if (ww <= 0) { this._refuse("'@' takes a positive weight"); return null; }
				w = ww;
			} else break;
		}
		var out = [];
		for (var i = 0; i < rep; i++) out.push([n, w]);
		return out;
	};
	Pattern.prototype._term = function () {
		var c = this.ch[this.pos];
		if (c === '~') { this.pos++; return ['rest']; }
		if (c === '[') {
			this.pos++;
			var n = this._stack(']');
			if (n === null) return null;
			this.pos++;
			return n;
		}
		if (c === '<') {
			this.pos++;
			var alts = [];
			for (;;) {
				this._ws();
				if (this.pos >= this.ch.length) { this._refuse("at the end: '>' is missing"); return null; }
				if (this.ch[this.pos] === '>') { this.pos++; break; }
				if (this.ch[this.pos] === ',') { this._refuse("a ',' inside < >"); return null; }
				var r = this._step();
				if (r === null) return null;
				for (var k = 0; k < r.length; k++) alts.push(r[k][0]);
			}
			if (alts.length === 0) { this._refuse("'< >' with nothing to alternate"); return null; }
			return ['alt', alts];
		}
		return this._word();
	};
	Pattern.prototype._word = function () {
		var w = '';
		while (this.pos < this.ch.length) {
			var c = this.ch[this.pos];
			if (/\s/.test(c) || SPECIAL.indexOf(c) >= 0) break;
			w += c; this.pos++;
		}
		if (w === '') { this._refuse('at ' + (this.pos + 1) + ': expected a note, a stroke, ~, [ or <'); return null; }
		var v = this._value(w);
		if (v === null) return null;
		return ['atom', v];
	};
	Pattern.prototype._value = function (word) {
		var c = word.toLowerCase();
		if (Object.prototype.hasOwnProperty.call(STROKES, c)) return ['stroke', STROKES[c]];
		var full = this._noteName(c);
		if (full === '') { this._refuse("'" + word + "' is neither a note name nor a stroke"); return null; }
		return ['note', full];
	};
	Pattern.prototype._noteName = function (tok) {
		if ('abcdefg'.indexOf(tok[0]) < 0) return '';
		var full = tok[0].toUpperCase(), k = 1;
		if (tok.length >= 2 && (tok[1] === '#' || tok[1] === 'b')) { full += tok[1]; k = 2; }
		var rest = tok.slice(k);
		if (!(rest !== '' && /[0-9]/.test(rest[0]))) rest = this.oct + rest;
		full += rest;
		if (noteToHz(full) === 0) return '';
		var o = '';
		for (var j = 1; j < full.length; j++) {
			if (/[0-9]/.test(full[j])) o += full[j];
			else if (o !== '') break;
		}
		this.oct = o;
		return full;
	};

	// the per-cycle query: [onset, length, value] with onset in [0, 1)
	Pattern.prototype._q = function (n, c) {
		var out = [], e, i, k;
		switch (n[0]) {
			case 'atom': return [[0, 1, n[1]]];
			case 'rest': return [];
			case 'seq': {
				var w = 0;
				for (i = 0; i < n[1].length; i++) w += n[1][i][1];
				var at = 0;
				for (i = 0; i < n[1].length; i++) {
					var share = n[1][i][1] / w;
					var sub = this._q(n[1][i][0], c);
					for (k = 0; k < sub.length; k++) out.push([at + sub[k][0] * share, sub[k][1] * share, sub[k][2]]);
					at += share;
				}
				return out;
			}
			case 'stack':
				for (i = 0; i < n[1].length; i++) out = out.concat(this._q(n[1][i], c));
				return out;
			case 'alt': {
				var m = n[1].length;
				return this._q(n[1][c % m], Math.floor(c / m));
			}
			case 'fast': {
				var f = n[2];
				for (var j = 0; j < f; j++) {
					e = this._q(n[1], c * f + j);
					for (k = 0; k < e.length; k++) out.push([(j + e[k][0]) / f, e[k][1] / f, e[k][2]]);
				}
				return out;
			}
			case 'slow': {
				var s = n[2], mm = c % s;
				e = this._q(n[1], Math.floor(c / s));
				for (k = 0; k < e.length; k++) {
					var o = e[k][0] * s - mm;
					if (o >= 0 && o < 1) out.push([o, e[k][1] * s, e[k][2]]);
				}
				return out;
			}
			case 'degrade':
				e = this._q(n[1], c);
				for (k = 0; k < e.length; k++) if (this._keep(c, n[2], k + 1)) out.push(e[k]);
				return out;
		}
		return out;
	};
	// the deterministic '?', ported step for step (all integers below 2^53)
	Pattern.prototype._keep = function (c, seed, idx) {
		var m = 2147483647;
		var h = 1 + (this.seed % 1000);
		var vs = [c, seed, idx];
		for (var a = 0; a < 3; a++) {
			h = (h + (vs[a] % 1000000) * 7919 + 1) % m;
			for (var r = 0; r < 3; r++) h = (h * 48271) % m;
		}
		return h / m < 0.5;
	};
	// [onset, length, kind, name] sorted by onset (stable)
	Pattern.prototype.cycleEvents = function (c) {
		if (this.root === null) return [];
		var a = this._q(this.root, c).map(function (e) { return [e[0], e[1], e[2][0], e[2][1]]; });
		for (var i = 1; i < a.length; i++) {
			var x = a[i], j = i - 1;
			while (j >= 0 && a[j][0] > x[0]) { a[j + 1] = a[j]; j--; }
			a[j + 1] = x;
		}
		return a;
	};
	Pattern.prototype.isAllStrokes = function () {
		var e = this.cycleEvents(0);
		if (e.length === 0) return false;
		for (var i = 0; i < e.length; i++) if (e[i][2] !== 'stroke') return false;
		return true;
	};

	var STROKE_VARIANT = { dum: 0, tak: 1, ka: 2, kick: 0, snare: 1, hihat: 2, hat: 2 };

	// ── the engine: stz.wasm, on the main thread ────────────────────────────
	async function create(opts) {
		opts = opts || {};
		var rate = opts.rate || 48000;
		var memory = new WebAssembly.Memory({ initial: 32, maximum: 2048 });
		var bytes = await fetch(opts.wasmUrl || 'stz.wasm').then(function (r) { return r.arrayBuffer(); });
		var mod = await WebAssembly.compile(bytes);
		var env = { memory: memory };
		WebAssembly.Module.imports(mod).forEach(function (i) {
			if (i.kind === 'function' && !env[i.name]) env[i.name] = function () { return 0; };
		});
		var inst = await WebAssembly.instantiate(mod, { env: env });
		var E = inst.exports;

		// OUR region: pages grown above everything the module uses. The module
		// never allocates there (its heap is a fixed 8 KiB), so it is ours.
		var regionBase = memory.buffer.byteLength;
		var regionBytes = 16 * 1024 * 1024;
		memory.grow(regionBytes / 65536);

		var names = [];
		var nameBuf = E.stz_alloc(64);
		for (var i = 0; i < E.stz_snd_inst_count(); i++) {
			var len = E.stz_snd_inst_name(i, nameBuf, 64);
			names.push(new TextDecoder().decode(new Uint8Array(memory.buffer, nameBuf, len)));
		}

		var ctx = null;
		var cache = new Map();

		function instIndex(name) { return names.indexOf(String(name).toLowerCase()); }

		// One note, rendered by wasm into our region; a copy comes back.
		function renderNote(name, hz, hold, vel, variant, hzEnd) {
			var i = instIndex(name);
			if (i < 0) throw new Error("no instrument '" + name + "' -- this engine has " + names.join(', '));
			var need = E.stz_snd_note_frames(i, rate, hold);
			var scr = E.stz_snd_scratch_frames(rate);
			if ((need + scr) * 4 > regionBytes) throw new Error('a note that long does not fit the region');
			var outPtr = regionBase, scrPtr = regionBase + need * 4;
			new Float32Array(memory.buffer, outPtr, need).fill(0);
			var got = E.stz_snd_note(i, hz, hzEnd || hz, hold, vel, variant || 0, rate, outPtr, need, scrPtr, scr);
			if (got === 0) throw new Error('the note was refused (reason ' + E.stz_snd_note_reason() + ')');
			return new Float32Array(memory.buffer, outPtr, got).slice();
		}
		function strokeHz(name) {
			var i = instIndex(name);
			return Math.sqrt(E.stz_snd_inst_lo(i) * E.stz_snd_inst_hi(i));
		}

		function audio() {
			if (!ctx) ctx = new (global.AudioContext || global.webkitAudioContext)({ latencyHint: 'interactive', sampleRate: rate });
			return ctx;
		}
		function bufferOf(samples, c) {
			var b = (c || audio()).createBuffer(1, samples.length, rate);
			b.copyToChannel(samples, 0);
			return b;
		}
		// a note as an AudioBuffer, rendered once however often it is played
		function noteBuffer(name, hz, hold, vel, variant, c) {
			var key = name + '|' + hz + '|' + hold + '|' + vel + '|' + (variant || 0);
			if (!cache.has(key)) cache.set(key, renderNote(name, hz, hold, vel, variant));
			return bufferOf(cache.get(key), c);
		}
		function play(buffer, when, gain, c) {
			var cx = c || audio();
			var src = cx.createBufferSource();
			src.buffer = buffer;
			var g = cx.createGain();
			g.gain.value = gain == null ? 0.6 : gain;
			src.connect(g).connect(cx.destination);
			src.start(when || 0);
			return src;
		}

		// ── live loops: whole cycles posted ahead of the audio clock ──────
		function Live(bpm, c) {
			this.bpm = bpm || 120;
			this.cx = c || null;
			this.loops = {};           // name -> { versions: [[fromCycle, pattern, inst, v]], next }
			this.order = [];
			this.lookahead = 0.12;     // s: a cycle is posted this far before it begins
			this.t0 = 0;
			this.timer = null;
			this.log = [];             // [cycle, text], as HEARD
			this.heard = -1;
			this.onCycle = null;
		}
		Live.prototype.cycleSeconds = function () { return 4 * 60 / this.bpm; };
		Live.prototype.now = function () { return (this.cx || audio()).currentTime; };
		Live.prototype.firstUnposted = function () {
			var t = this.now() - this.t0 + this.lookahead;
			return Math.max(0, Math.floor(t / this.cycleSeconds()) + 1);
		};
		// define or redefine; returns the cycle it lands on, or -1 with .error
		Live.prototype.loop = function (name, text, instName) {
			var p = new Pattern(text);
			if (!p.isValid()) { this.error = p.error; return -1; }
			var inst = instName || (p.isAllStrokes() ? (/dum|tak|ka/.test(text) ? 'darbouka' : 'drumkit') : 'piano');
			var k = this.timer ? this.firstUnposted() : 0;
			var L = this.loops[name];
			if (!L) { L = this.loops[name] = { versions: [], next: 0 }; this.order.push(name); }
			if (this.timer && L.next > k) k = L.next;   // cycles already posted keep what they have
			L.versions.push([k, p, inst, L.versions.length + 1]);
			// render its notes now, before they are due
			for (var c = 0; c < 4; c++) this._render(p, inst, c);
			return k;
		};
		Live.prototype._render = function (p, inst, c) {
			var ev = p.cycleEvents(c), cs = this.cycleSeconds(), out = [];
			for (var i = 0; i < ev.length; i++) {
				var e = ev[i], hold = Math.min(4, e[1] * cs);
				var buf = e[2] === 'stroke'
					? noteBuffer(inst, strokeHz(inst), hold, 0.8, STROKE_VARIANT[e[3]], this.cx)
					: noteBuffer(inst, noteToHz(e[3]), hold, 0.8, 0, this.cx);
				out.push([e[0], buf]);
			}
			return out;
		};
		Live.prototype._version = function (L, c) {
			var v = null;
			for (var i = 0; i < L.versions.length; i++) if (L.versions[i][0] <= c) v = L.versions[i];
			return v;
		};
		Live.prototype._post = function () {
			var cs = this.cycleSeconds();
			for (var n = 0; n < this.order.length; n++) {
				var L = this.loops[this.order[n]];
				while (this.t0 + L.next * cs < this.now() + this.lookahead) {
					var v = this._version(L, L.next);
					if (v && v[1]) {
						var notes = this._render(v[1], v[2], L.next);
						for (var i = 0; i < notes.length; i++) {
							play(notes[i][1], this.t0 + (L.next + notes[i][0]) * cs, 0.6, this.cx);
						}
					}
					L.next++;
				}
			}
			// the console, from the HEARD clock (outputLatency aside, which it states)
			var h = Math.floor((this.now() - this.t0) / cs);
			while (h > this.heard) {
				this.heard++;
				var txt = 'cycle ' + this.heard;
				for (var m = 0; m < this.order.length; m++) {
					var vv = this._version(this.loops[this.order[m]], this.heard);
					if (vv) txt += ' | ' + this.order[m] + ' v' + vv[3];
				}
				this.log.push([this.heard, txt]);
				if (this.onCycle) this.onCycle(txt);
			}
		};
		Live.prototype.start = function () {
			var self = this;
			this.t0 = this.now() + 0.05;
			this._post();
			this.timer = setInterval(function () { self._post(); }, 25);
		};
		Live.prototype.stop = function () { clearInterval(this.timer); this.timer = null; };
		Live.prototype.silence = function (name) {
			var L = this.loops[name];
			if (!L) return -1;
			var k = Math.max(this.firstUnposted(), L.next);
			L.versions.push([k, null, '', L.versions.length + 1]);
			return k;
		};

		function latency() {
			var c = audio();
			return { base: c.baseLatency || 0, output: c.outputLatency || 0, rate: c.sampleRate };
		}

		return {
			names: names, rate: rate, exports: E, memory: memory,
			audio: audio, renderNote: renderNote, noteBuffer: noteBuffer, bufferOf: bufferOf,
			play: play, strokeHz: strokeHz, latency: latency,
			live: function (bpm, c) { return new Live(bpm, c); },
			measureHz: function (samples, from, guess) {
				var p = regionBase;
				new Float32Array(memory.buffer, p, samples.length).set(samples);
				return E.stz_snd_measure_hz(p, samples.length, rate, from, guess);
			}
		};
	}

	global.StzMusic = { create: create, Pattern: Pattern, noteToHz: noteToHz, STROKE_VARIANT: STROKE_VARIANT };
})(typeof window !== 'undefined' ? window : globalThis);
