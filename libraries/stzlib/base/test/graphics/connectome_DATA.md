# Connectome witness — the neuron data is not vendored

`connectome_real.ring` renders eight real neuron reconstructions in the standard
**SWC** format. Like the geo atlas, the library does not vendor other people's
data: the reconstructions belong to **[NeuroMorpho.org](https://neuromorpho.org)**
and its contributing archives, and the witness skips by name until the files are
present. Fetch them once with the commands below (run from this directory).

```bash
# NeuroM reference neuron
curl -sL "https://raw.githubusercontent.com/BlueBrain/NeuroM/master/tests/data/swc/Neuron.swc" -o n_neurom.swc

# Wearne/Hof — monkey neocortex pyramidal cells (archive: wearne_hof)
for n in 001 002 003 004 005 006; do
  curl -sL "https://neuromorpho.org/dableFiles/wearne_hof/CNG%20version/cnic_${n}.CNG.swc" -o "nm_cnic_${n}.swc"
done

# Markram — rat somatosensory cortex pyramidal cell (archive: markram)
curl -sL "https://neuromorpho.org/dableFiles/markram/CNG%20version/C010398B-P2.CNG.swc" -o "nm_C010398B-P2.swc"
```

Then `ring connectome_real.ring` writes `connectome_real.png`.

## What the witness proves

The engine draws a publishable connectome plate from real morphology using only
`AddLine` / `AddCircle` and supersampled output — a neuron skeleton is a node→parent
point graph, so polylines are the honest primitive (no Bézier needed). The SWC
reader is ~15 lines (`ReadSwc` at the foot of the script). `connectome.ring` is the
self-contained procedural cousin and needs no download.

## Attribution

Reconstructions from NeuroMorpho.org (Ascoli et al., *J. Neurosci.* 2007) —
Wearne/Hof and Markram archives — and the BlueBrain/NeuroM reference neuron. Please
honor NeuroMorpho's citation policy if you reuse the data.
