# Evidence report: inv

- Subject: inv at 1a2b3c4
- Walked: 2 tours on haro.exe of 2026-11-14, on 2026-11-15
- Judged by: testoor 3.5

## 1. The ladder

5 functions and methods: **2 exemplified, 1 observed, 2 named.**

| grade | what it says | functions |
|---|---|---:|
| exemplified | a tour that kept its claims and finished ran it | 2 |
| observed | a tour ran it; none that ran it kept its claims and finished | 1 |
| named | no tour ran it | 2 |

| file | functions | exemplified | observed | named |
|---|---:|---:|---:|---:|
| inv.haro | 4 | 2 | 1 | 1 |
| invoice.haro | 1 | 0 | 0 | 1 |

## 2. What no tour ran

No tour ran 2 of the 5 functions and methods: **2 owed a tour** -- the graph holds every call each makes, so a tour can prove it -- and **0 capped**: open, or calling an open function at some depth -- one that dispatches by a name built at run time, or that the compiler could not finish -- so no floor above exemplified holds through it.

| file | owed | capped |
|---|---:|---:|
| inv.haro | 1 | 0 |
| invoice.haro | 1 | 0 |

| function | file | line | called by | owed or capped |
|---|---|---:|---|---|
| Today | inv.haro | 13 | Label | owed |
| Invoice.Add | invoice.haro | 4 | no function of the graph | owed |

## 3. Run only by a tour that did not keep its claims

| function | file | line | run by |
|---|---|---:|---|
| Label | inv.haro | 9 | guards/t_label.haro (diverged) |

## 4. The tours

| tour | state | kept | diverged | unreached | unjudged | functions run |
|---|---|---:|---:|---:|---:|---:|
| guards/t_gross.haro | kept | 3 | 0 | 0 | 0 | 2 |
| guards/t_label.haro | diverged | 1 | 1 | 0 | 0 | 2 |

## 5. What a change reaches

**A change to Vat** reaches 4 functions by calls the compiler bound: Vat, Gross, Label, Invoice.Add. Tours to walk again: 2 of 2 (t_gross.haro, t_label.haro).

## 6. Where the evidence is thinnest

The functions below exemplified, the one the most functions call first.

| function | grade | functions that call it |
|---|---|---:|
| Today | named | 1 |
| Label | observed | 0 |
| Invoice.Add | named | 0 |

## 7. What this report does not claim

- that a function no tour ran is wrong, or that one a tour ran is correct;
- a proof: every grade here is evidence from examples;
- a percentage: evidence is counted function by function;
- more than its grade: exemplified means the checks a tour made held, on the inputs it used;
- beyond its stamp: it holds for the commit, the runtime and the judge named above;
- an exact reach where the graph is not complete: the reach is widened then, and the report says why;
- a verdict on what a person perceives, such as a sound, a picture or a sentence.
