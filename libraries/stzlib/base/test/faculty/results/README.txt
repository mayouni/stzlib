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

2026-11-12 (BOLT-PLACEMENT-01 (c)): a FRESH extraction set -- 24 French and 24 Arabic tickets (../_data/tickets_fresh_frar.tsv,
written by an author who saw no floor, no model and no result; its labels kept as written), run with STZ_TICKETS_FRESH=fr|ar
as golden versions fresh1-fr / fresh1-ar, read by probability, CPU unthrottled:
                 keyword-rules   granite-1b-choice   bolt-e4b-choice   court, bolt over granite
  fresh1-fr          0.29             0.75               1 (24/24)       6-0, P = 0.016, upheld
  fresh1-ar          0.21             0.67               1 (24/24)       8-0, P = 0.004, upheld
Bolt's English win (0.94 against 0.72) holds in French and Arabic. A perfect score on 24 items also says this set may be
easier than the English one; the floor's keywords are English, which its scores show.

2026-11-14 (RADAR-TPUSYNC-BUDGET-01 (a), ../_measure_ready.haro): what each support-desk model costs to be READY -- from its
file to its first token -- and the memory it holds then. Twelve files, each in a new process twice: the file put out of the
system's cache first (cold), then in it (cached); and in the same process, the file loaded again (reload) and the system
turn put back from a prefix file (prefix). Two rounds, the second in the reverse order. Table: ready.txt; rows: ready.tsv.
What it shows:
  - the loader READS the whole file into memory after hashing it; it does not map it. Ready memory is the file's size plus
    5 to 92 MB, on every model, and does not move between rounds.
  - the SHA-256 check is most of a load: a reload in the same process (the digest kept) takes a third to two fifths of a
    new process's load (0.34 to 0.44 on 11 files), and a file of up to 2 GB put out of the cache loads at most 30 percent
    slower than a cached one, because the hash, not the disk, sets the pace.
  - the process's PEAK, over the load and the first token, is 1.2 to 2.1 times the ready memory: 2,404 MB for granite-1b, 7,349 MB for bolt-e4b.
  - a prefix file comes back in 12 to 600 ms and cuts the first token to the ticket's own tokens (granite42-3b 6.6 s to
    3.2 s with the reload counted). LFM3 refuses to save one by design (its convolution state is not in the format).
  - the times of the files over 2 GB moved up to three times between rounds on this machine, shared with other sessions;
    the ranges are in ready.tsv. The memory figures did not move.

2026-11-14 (RADAR-TPUSYNC-BUDGET-01 (b), ../_measure_ready.haro slots <budget MB>): the engine holds several models at once,
each in a named slot, under one budget in bytes (base/test/neural/model_slots_narrated.haro: 31 assertions). The support desk's
eleven files in the models folder were loaded into slots under 4 GB and 8 GB, then served twice: every model in turn
("cycle"), and the small models mostly ("skewed"). Table: slots.txt; rows: slots.tsv. What it shows:
  - a request to a model held in memory is a select of 0 ms and a first token of about 75 ms (median); a model read back from
    its file costs 1.1 to 2.7 s, so what a budget buys is the share of requests that find their model held.
  - skewed: 22 of 29 and 22 of 30 requests found their model in memory; cycle: none -- every model in turn over a set larger
    than the budget evicts each one just before it is asked again (the known limit of least-recently-used eviction).
  - room is made from a file's size BEFORE the file is read: the process's peak was 5.9 GB under 4 GB and 10.1 GB under
    8 GB, the rest being a forward pass's working memory, which no budget counts. The first run evicted AFTER the read
    and peaked at 9.8 and 14.1 GB; Bolt E4B (6 GB) under 4 GB is now refused unread, in 0 ms, where it was read for 27 s.

2026-11-14 (PRINCIPAL-RELAY-FABRIC-01, ../_measure_fabric.haro): can several small models together do what the large one does?
The 204 option questions, asked of Bolt E4B and of the eight other generative models, every model's whole distribution over
the options kept (fabric.tsv). Every combination is CHOSEN on the odd tickets (102 questions) and JUDGED on the even ones
(102), so no fabric is scored on the questions that chose it. Table: fabric.txt. What it shows:
  - no fabric of small models matches Bolt: the one best on dev (five models, their shares summed) answers 88 of 102 against
    Bolt's 98, and the court upholds Bolt (12-2, P 0.0066) -- with 7.9 GB of members against Bolt's 6.0 and 2.8 times its time.
    Routers, the most confident member, the product of shares and a two-model cascade all land between 79 and 89.
  - the knowledge is in the fabric and the SELECTION is what fails: on every one of the 102 test questions at least one small
    model is right; per question and language a small one matches or leads Bolt in five of seven cells (LFM3 16 of 18 on
    kind, against Bolt's 15); the best small model of each cell picked on test gives 93 -- a bound, since it sees the test.
    Chosen on dev, the router reached 79: 12 to 18 questions a cell do not choose a specialist that holds on the other half.
  - the fabric RUNS: served from one process with its five members held at once in slots (7,702 MB), it answers the same 88
    of 102 the analysis counts (fabric_serve.tsv) -- the slots and the per-model rows agree.
  - the times are the machine's on a day shared with other sessions: Bolt took 921 s for 204 questions here, 283 s on 11-12.

