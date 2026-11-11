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

2026-11-11 (RADAR-NVIDIA-EMBEDSET-01): retrieve moves to golden v2 -- the 12 English questions and 12 French and 12 Arabic
ones, each over its own language's 12 help articles (../_data/retrieval_v2.tsv, written before any challenger ran on it),
measured per language (v2/en, v2/fr, v2/ar). A hit is the right article in the top 4 of 12, so chance is 0.33. Measured:
floor 0.50/0.33/0.33, minilm-cosine 1/0.67/0.33, siglip2-text 0.67/0.83/0.50 (en/fr/ar). With 12 items a language, the
court upholds a challenger there only from about five discordant wins with none lost (5-0 is P = 0.031). The court file
is LOADED before a run and saved after it, so a run replaces the pairs it scores and keeps the others.

2026-11-11 (RADAR-LFM3-DECISIONSHAPE-01, ../_measure_d1shape.haro): three option questions about each of the 36 tickets,
read by probability; right answers kind/product/severity of 36, tokens actually read, seconds (CPU, heartbeat 179/182):
  bolt-e4b     today, reuse off  29 34 36   9,939 tokens  387 s
               today, reuse on   29 34 36   3,215 tokens  138 s   (identical answers: the logits are equal to the bit)
               d1 shape          28 33 36   5,712 tokens  268 s
  granite-1b   today, reuse off  24 27 35   9,915 tokens  176 s
               today, reuse on   24 27 35   3,191 tokens   62 s
               d1 shape          30 29 26   5,704 tokens  112 s
The d1 shape shares the INPUT across the questions; today's question-by-question order, with the prefix cache, shares
the QUESTION across the inputs. Which reads less depends on which is longer: with Q questions the d1 shape reads less
when the input is longer than about Q/(Q-1) times a question -- here the tickets (about 30 tokens) are shorter than the
questions (about 45), so today's order wins. Moving the question after the input moves the answers: by one or two on
Bolt, by up to nine on granite-1b (severity 35 -> 26), so a shape is chosen per model, on its golden set.

2026-11-11 (RADAR-LFM3-FAMILY-01): lfm3-1.7b (Liquid AI's LFM3-1.7B, Q8_0) on kind, triage_extract and brief, with
granite-1b in the same run (624 s; kind again, 118 s, after _TkChoice was fixed -- in LFM3's vocabulary "Bug" and
"Billing" begin with the same token, so the capitalised twin is now added only when its first token is unclaimed;
granite-1b's numbers did not move). Of 36:  kind 0.61 / 0.42 by probability (floor 0.69); triage_extract 0.64 / 0.39
(granite-1b-choice 0.72, bolt-e4b-choice 0.94); brief 0.17 (floor 0.69). The court refuses LFM3 on every faculty.
