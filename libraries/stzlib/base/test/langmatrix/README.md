# The language and context matrix

Softanza is made in Tunisia and Niger and used in France, and its intelligence reads the languages of those places.
This matrix measures the local models cell by cell: a language, a task, a score. Text comes first: French, Modern
Standard Arabic, Tunisian Darija (in Arabic letters and in Latin letters) and Hausa. Speech follows.

## Run it

With `STZ_ENGINE_DIR` (an engine with `stz_neural.dll`) and `STZ_LANG_DIR` (the public test sets) set:

    haro matrix.haro <label> <model file>     one model over every cell, results/<label>.txt
    haro matrix.haro summary                  every model side by side, results/matrix.txt

A model answers each item from its next-token logits over the options: one prefill an item, no sampling.

## The items

| cell | items | source |
|---|---|---|
| sentiment, French and Arabic | 50 each, 25 positive and 25 negative | written for this matrix: `items_fr_ar.tsv` |
| sentiment, Darija in Arabic letters | 50 | TSAC test set (LGPL-3.0), its lines in Arabic letters |
| sentiment, Darija in Latin letters | 50 | TUNIZI |
| sentiment, Hausa | 50 | AfriSenti test set, neutral left out |
| topic, Hausa news | 49, 7 for each of 7 topics | MasakhaNEWS test set |
| language named | 10 a language, drawn from the sentiment items | Darija is expected as "tunisian" |

The public sets are read from `STZ_LANG_DIR` and stay outside the repository; `results/` holds counts only. Items are
taken at an even stride through each file, so every run asks the same ones.

## Results, 2026-11-15

| cell | Bolt E4B | Granite 4.2 3B | LFM3 1.7B | Qwen3 0.6B |
|---|---|---|---|---|
| sentiment, French | 50/50 | 50/50 | 46/50 | 49/50 |
| sentiment, Arabic | 50/50 | 50/50 | 44/50 | 45/50 |
| sentiment, Darija in Arabic letters | 47/50 | 39/50 | 25/50 | 40/50 |
| sentiment, Darija in Latin letters | 36/50 | 37/50 | 25/50 | 27/50 |
| sentiment, Hausa | 37/50 | 35/50 | 25/50 | 25/50 |
| topic, Hausa news | 36/49 | 22/49 | 21/49 | 7/49 |
| language named: French | 10/10 | 10/10 | 10/10 | 8/10 |
| language named: Arabic | 10/10 | 6/10 | 10/10 | 9/10 |
| language named: Darija, Arabic letters | 0/10 | 0/10 | 0/10 | 0/10 |
| language named: Darija, Latin letters | 6/10 | 0/10 | 0/10 | 0/10 |
| language named: Hausa | 8/10 | 0/10 | 2/10 | 0/10 |
| time an item, sentiment | 1.0-1.5 s | 1.8-2.4 s | 0.4-0.7 s | 0.2-0.3 s |

- **French and Modern Standard Arabic are served locally today**: two models answer every sentiment item right.
- **Tunisian Darija in Arabic letters** is read well by Bolt (47 of 50); **in Latin letters** no model passes 37 of
  50. Every model names Darija in Arabic letters as Arabic.
- **Hausa** is the widest cell: sentiment 37 of 50 at best, news topic 36 of 49 (Bolt), and only Bolt names it.
- The cells below 40 of 50 -- Darija in Latin letters and Hausa -- are the ones a local model needs training or a
  specialist for: the labelled sets they were measured on carry training splits of their own.
