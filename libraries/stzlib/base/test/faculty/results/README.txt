results/measurements.zmdl.txt -- what the registry knows about quality: one row per faculty / implementation / golden version.

Measured 2026-10-21 on the author's laptop (RTX 3050 6GB Laptop, driver 561.00). The CPU was firmware-throttled to 42-57 percent of nominal
during the generative runs, so the SECONDS are not quotable; the SCORES are not affected by speed.

Golden sets: base/test/faculty/_ticket_app.ring (retrieval corpus and queries; the rest read _data/tickets_heldout.tsv, 36 tickets written
by an author who never saw a floor). Model files and sha256: libraries/stzlib/models/MODELS.md. Re-measure with:
    ring _measure_flows.ring all <model ids>

2026-11-11 (RADAR-NVIDIA-BOLTCOURT-01): kind, triage_extract and brief re-measured on haro.exe for the floors, granite-1b and
bolt-e4b (NVIDIA's Nemotron 3.5 Bolt E4B, Gemma 4), by generation and by probability, the CPU unthrottled (bench/heartbeat.py:
195 percent of nominal before, 200 after; 2,532 s in all). The run's ordered pairs are in court.zcourt.txt: the counts are the
evidence and the verdicts are recomputed from them on load. Run as:
    haro _measure_flows.ring kind,triage_extract,brief granite-1b,granite-1b-choice,bolt-e4b,bolt-e4b-choice
with STZ_ENGINE_DIR naming a built engine and STZ_MODELS_DIR the models folder.
