# WSP thinking (SOFTANZA_WEIGHT_SPACE_GOVERNANCE.md section 2): the logit_shift and logit_scale heads of OWL-ViT on every golden picture,
# through ONNX Runtime on the exported vision graph, beside each picture's false alarms and misses from the judged record.
# docling-venv python -I owl_heads.py   -> _wti_models_src/owlvit_spike/heads_all.tsv
import numpy as np, onnxruntime as ort, collections
from PIL import Image
mean=np.array([0.48145466,0.4578275,0.40821073])[:,None,None]; std=np.array([0.26862954,0.26130258,0.27577711])[:,None,None]
sess=ort.InferenceSession("D:/GitHub/_wti_models_src/owlvit_spike/owlvit_vision.onnx",providers=["CPUExecutionProvider"])
G=[l.rstrip("\n").split("\t") for l in open("D:/GitHub/_wti_pub/libraries/stzlib/base/test/image/_golden/owl_find_v1.tsv",encoding="utf-8")]
J=[l.rstrip("\n").split("\t") for l in open("D:/GitHub/_wti_pub/libraries/stzlib/base/test/image/_golden/owl_find_v1_judged.tsv",encoding="utf-8")]
pics=sorted({g[1] for g in G})
fa=collections.Counter(j[0] for j in J if j[3]=="neg" and j[5]=="0")
miss=collections.Counter(j[0] for j in J if j[3]=="pos" and j[5]=="0")
npos=collections.Counter(g[1] for g in G if g[4]=="pos"); nneg=collections.Counter(g[1] for g in G if g[4]=="neg")
split={g[1]:g[0] for g in G}
out=open("D:/GitHub/_wti_models_src/owlvit_spike/heads_all.tsv","w")
out.write("pic\tsplit\tshift_mean\tshift_p90\tscale_mean\tnpos\tnneg\tfalse_alarms\tmisses\n")
for p in pics:
    im=Image.open("D:/GitHub/_wti_models_src/coco/images/"+p).convert("RGB").resize((768,768),Image.BICUBIC)
    t=((np.asarray(im).astype(np.float32).transpose(2,0,1)/255-mean)/std).astype(np.float32)[None]
    o=sess.run(None,{"pixel":t})[0]
    shift=o[:,512]; raw=o[:,513]; scale=np.where(raw>0,raw+1,np.exp(np.minimum(raw,0)))
    out.write("%s\t%s\t%.4f\t%.4f\t%.3f\t%d\t%d\t%d\t%d\n"%(p,split[p],shift.mean(),np.percentile(shift,90),scale.mean(),npos[p],nneg[p],fa[p],miss[p]))
out.close(); print("done",len(pics))
