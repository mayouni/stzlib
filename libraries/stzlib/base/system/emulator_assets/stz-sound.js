// stz-sound.js -- the Softanza sound graph, playing in a browser.
//
// SN6's fourth sink. `stz.wasm` built with the `sound` group renders the SAME
// graph the native tier renders (soundwasm.zig calls sounddsp.zig, and so does
// soundgraph.zig -- a guard asserts the two are bit-identical), and an
// AudioWorklet asks it for 128 frames at a time.
//
// WHY A WORKLET AND NOT A ScriptProcessorNode. A worklet runs on the AUDIO
// thread; a ScriptProcessorNode runs on the main thread and stalls behind
// layout, so it glitches whenever the page is busy. This plane spent SN3
// proving a lock-free ring so the native callback would never wait on anything;
// putting the browser render behind the main thread would throw that away.
//
// THE LATENCY, which is the point. The native path carries ~329 ms of ring plus
// ~90 ms of device and OS -- see the sound plan's S.5, and Rule 18's 100 ms.
// Here there is NO ring at all: the worklet asks, wasm fills, it plays. What is
// left is the browser's own output latency, and the page REPORTS it rather than
// assuming: read `outputLatency` after start().
//
// Authored asset. The worklet source is inlined as a blob below because a
// worklet must be fetched from a URL, and a bundle should not need a second
// file to be served for sound to work.

(function (global) {
	'use strict';

	// The worklet: it owns nothing but a pull loop. Every decision -- which
	// nodes, which gains -- was made before it started, because a worklet
	// cannot allocate and must not block.
	var WORKLET_SRC = `
class StzSoundProcessor extends AudioWorkletProcessor {
	constructor(options) {
		super();
		this.ready = false;
		this.channels = options.processorOptions.channels || 2;
		this.port.onmessage = (e) => {
			if (e.data.type === 'bytes') {
				// COMPILE INSIDE THE WORKLET, from bytes.
				//
				// The first cut compiled on the main thread and posted the
				// WebAssembly.Module through the port. A Module is
				// structured-cloneable to a Worker, but posting one to an
				// AudioWorklet does not deliver -- and it fails with NO error on
				// either side, so the page simply waited for a 'ready' that was
				// never coming. An ArrayBuffer always clones.
				//
				// It has to be the worklet either way: the module and its linear
				// memory must live on the AUDIO thread, or every block would
				// cross a thread boundary to be read.
				const memory = new WebAssembly.Memory({ initial: 32, maximum: 256 });
				WebAssembly.compile(e.data.bytes).then((mod) => {
					const env = { memory: memory };
					WebAssembly.Module.imports(mod).forEach((i) => {
						if (i.kind === 'function' && !env[i.name]) { env[i.name] = () => 0; }
					});
					return WebAssembly.instantiate(mod, { env: env });
				}).then((inst) => {
					this.e = inst.exports;
					this.memory = memory;
					this.build(e.data.build);
					this.ready = true;
					this.port.postMessage({ type: 'ready', nodes: this.e.stz_snd_node_count() });
				}).catch((err) => {
					// A failure on the audio thread is invisible unless it is
					// SENT somewhere. Silence was the actual bug here once.
					this.port.postMessage({ type: 'error', message: String(err) });
				});
			} else if (e.data.type === 'trigger' && this.ready) {
				this.e.stz_snd_trigger(e.data.node);
			}
		};
	}

	// Replay the caller's build script. A plain list of [verb, ...args] so the
	// main thread can describe a graph without shipping a closure to a thread
	// that cannot receive one.
	build(script) {
		const e = this.e;
		e.stz_snd_reset(sampleRate, this.channels, 128);
		for (const step of script) {
			const [verb, ...a] = step;
			e['stz_snd_' + verb](...a);
		}
		e.stz_snd_prepare();
		this.ptr = e.stz_snd_block_ptr();
		this.view = new Float32Array(this.memory.buffer, this.ptr, 128 * this.channels);
	}

	process(inputs, outputs) {
		const out = outputs[0];
		if (!this.ready) { return true; }
		const n = this.e.stz_snd_render();
		if (n === 0) { return true; }
		// DE-INTERLEAVE at the very last step. wasm hands back interleaved f32
		// because that is one contiguous copy out of linear memory; a worklet
		// wants planar, and this is the only place that difference exists.
		const ch = Math.min(out.length, this.channels);
		for (let c = 0; c < ch; c++) {
			const dst = out[c];
			for (let f = 0; f < n; f++) { dst[f] = this.view[f * this.channels + c]; }
		}
		return true;
	}
}
registerProcessor('stz-sound', StzSoundProcessor);
`;

	// A tiny builder so a caller writes verbs rather than array literals. It
	// records the script and hands back node INDICES, exactly as the Ring face
	// does -- names are the caller's business, not the transport's.
	function GraphScript() {
		this.steps = [];
		this.next = 0;
	}
	GraphScript.prototype._add = function (verb, args) {
		this.steps.push([verb].concat(args));
		return this.next++;
	};
	GraphScript.prototype.osc = function (waveform, hz, amp) {
		return this._add('add_osc', [waveform, hz, amp]);
	};
	GraphScript.prototype.gain = function (input, g) {
		return this._add('add_gain', [input, g]);
	};
	GraphScript.prototype.mix = function (inputs) {
		var m = this._add('add_mix', []);
		for (var i = 0; i < inputs.length; i++) { this.steps.push(['mix_add', m, inputs[i]]); }
		return m;
	};
	GraphScript.prototype.pan = function (input, p) {
		return this._add('add_pan', [input, p]);
	};
	GraphScript.prototype.filter = function (input, kind, freq, q) {
		return this._add('add_filter', [input, kind, freq, q]);
	};
	GraphScript.prototype.echo = function (input, secs, feedback, wet) {
		return this._add('add_delay', [input, secs, feedback, wet]);
	};
	GraphScript.prototype.envelope = function (input, a, d, sus, r, gate) {
		return this._add('add_envelope', [input, a, d, sus, r, gate]);
	};
	GraphScript.prototype.output = function (node) {
		this.steps.push(['set_output', node]);
		return this;
	};

	// waveform / filter codes, matching sounddsp.zig so a caller never guesses
	var WAVE = { sine: 0, square: 1, saw: 2, triangle: 3 };
	var FILTER = { lowpass: 0, highpass: 1, bandpass: 2 };

	async function play(wasmUrl, script, opts) {
		opts = opts || {};
		var channels = opts.channels || 2;
		var ctx = new (global.AudioContext || global.webkitAudioContext)({
			latencyHint: opts.latencyHint || 'interactive'
		});
		var blobUrl = URL.createObjectURL(new Blob([WORKLET_SRC], { type: 'text/javascript' }));
		await ctx.audioWorklet.addModule(blobUrl);
		URL.revokeObjectURL(blobUrl);

		var bytes = await fetch(wasmUrl).then(function (r) { return r.arrayBuffer(); });

		var node = new AudioWorkletNode(ctx, 'stz-sound', {
			numberOfInputs: 0,
			numberOfOutputs: 1,
			outputChannelCount: [channels],
			processorOptions: { channels: channels }
		});
		// REJECT rather than hang. A promise that only ever resolves turns any
		// failure on the audio thread into a page that waits forever.
		var ready = new Promise(function (resolve, reject) {
			node.port.onmessage = function (e) {
				if (e.data.type === 'ready') resolve(e.data);
				else if (e.data.type === 'error') reject(new Error('worklet: ' + e.data.message));
			};
			node.onprocessorerror = function () {
				reject(new Error('the worklet processor threw and was stopped'));
			};
			setTimeout(function () {
				reject(new Error('the worklet never reported ready (5 s)'));
			}, 5000);
		});
		node.port.postMessage({ type: 'bytes', bytes: bytes, build: script.steps }, [bytes]);
		node.connect(ctx.destination);
		var info = await ready;

		return {
			context: ctx,
			node: node,
			nodes: info.nodes,
			// what the plane cares about, read rather than assumed
			latencyMs: function () {
				var out = ctx.outputLatency || 0;
				var base = ctx.baseLatency || 0;
				return (out + base) * 1000;
			},
			trigger: function (n) { node.port.postMessage({ type: 'trigger', node: n }); },
			stop: function () { node.disconnect(); return ctx.close(); }
		};
	}

	global.StzSound = {
		play: play,
		Graph: GraphScript,
		WAVE: WAVE,
		FILTER: FILTER
	};
})(typeof window !== 'undefined' ? window : this);
