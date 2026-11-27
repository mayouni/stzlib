# Evidence report: pay

- Subject: pay, a planted case
- Judged by: testoor

## 1. The ladder

7 functions and methods: **2 exemplified, 5 named.**

| grade | what it says | functions |
|---|---|---:|
| exemplified | a tour that kept its claims and finished ran it | 2 |
| named | no tour ran it | 5 |

| file | functions | exemplified | named |
|---|---:|---:|---:|
| pay.haro | 5 | 0 | 5 |
| log.haro | 2 | 2 | 0 |

## 2. What no tour ran

No tour ran 5 of the 7 functions and methods: **1 owed a tour** -- the graph holds every call each makes, so a tour can prove it -- and **4 capped**: open, or calling an open function at some depth -- one that dispatches by a name built at run time, or that the compiler could not finish -- so no floor above exemplified holds through it.

| file | owed | capped |
|---|---:|---:|
| pay.haro | 1 | 4 |

| function | file | line | called by | owed or capped |
|---|---|---:|---|---|
| Pay | pay.haro | 1 | no function of the graph | capped by Lookup |
| Rate | pay.haro | 5 | Pay, Fee | capped by Lookup |
| Lookup | pay.haro | 9 | Rate | open |
| Fee | pay.haro | 14 | no function of the graph | capped by Lookup |
| Round | pay.haro | 18 | no function of the graph | owed |

## 3. Run only by a tour that did not keep its claims

Every function a tour ran was run by one that kept its claims and finished.

## 4. The tours

| tour | state | kept | diverged | unreached | unjudged | functions run |
|---|---|---:|---:|---:|---:|---:|
| tours/t_note.haro | kept | 2 | 0 | 0 | 0 | 2 |

## 5. What a change reaches

No change was named for this report.

## 6. Where the evidence is thinnest

The functions below exemplified, the one the most functions call first.

| function | grade | functions that call it |
|---|---|---:|
| Rate | named | 2 |
| Lookup | named | 1 |
| Pay | named | 0 |
| Fee | named | 0 |
| Round | named | 0 |

## 7. What this report does not claim

- that a function no tour ran is wrong, or that one a tour ran is correct;
- a proof: every grade here is evidence from examples;
- a percentage: evidence is counted function by function;
- more than its grade: exemplified means the checks a tour made held, on the inputs it used;
- beyond its stamp: it holds for the commit, the runtime and the judge named above;
- an exact reach where the graph is not complete: the reach is widened then, and the report says why;
- a verdict on what a person perceives, such as a sound, a picture or a sentence.
