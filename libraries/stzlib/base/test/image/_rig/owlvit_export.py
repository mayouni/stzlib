"""IM9f spike, step 2: OWL-ViT's vision side as ONE ONNX graph, and a check that the graph is the reference.

    python owlvit_export.py <owlvit dir> <reference dir from owlvit_reference.py> <out.onnx>

The graph takes the pixel tensor [1, 3, 768, 768] and gives ONE tensor [576, 518]: for each of the 576 patches, 512 numbers of its NORMALISED
class embedding, then its logit shift, its logit scale (elu + 1) and its box (cx, cy, w, h in 0..1). The text side is not in the graph: a
query's logit for a patch is (the dot product of the patch's embedding with the query's normalised text embedding + shift) x scale, and that
is arithmetic the caller does. After exporting, ONNX Runtime runs the graph on the reference's own pixels and its output is compared with the
reference's (image_feats.npy), so what the engine is later held to is a graph already known to be right.
"""
import sys

import numpy as np
import onnxruntime as ort
import torch
from transformers import OwlViTForObjectDetection


def _static_embeddings(self, pixel_values, interpolate_pos_encoding=False):
    """The vision embeddings for a batch of ONE, without the runtime shape the class token's expand reads: the converter turns a graph into
    a fixed program and refuses an Expand to a shape it cannot know. The same arithmetic, the same weights."""
    patch_embeds = self.patch_embedding(pixel_values).flatten(2).transpose(1, 2)
    class_embeds = self.class_embedding.reshape(1, 1, -1)
    embeddings = torch.cat([class_embeds, patch_embeds], dim=1)
    return embeddings + self.position_embedding(self.position_ids)


from transformers.models.owlvit import modeling_owlvit as _mo

_mo.OwlViTVisionEmbeddings.forward = _static_embeddings


class Vision(torch.nn.Module):
    def __init__(self, m):
        super().__init__()
        self.m = m

    def forward(self, pixel):
        # image_embedder, step by step, with the class token multiplied in by plain broadcasting: the model's own torch.broadcast_to
        # becomes an Expand to a runtime shape, which the converter refuses
        vm = self.m.owlvit.vision_model
        emb = vm.post_layernorm(vm(pixel_values=pixel)[0])           # [1, 577, 768]
        emb = self.m.layer_norm(emb[:, 1:, :] * emb[:, :1, :])
        fm = emb.reshape(1, 24, 24, 768)                             # [1, 24, 24, 768]
        b, h, w, d = fm.shape
        feats = fm.reshape(b, h * w, d)
        boxes = self.m.box_predictor(feats, fm)                      # [1, 576, 4]
        ce = self.m.class_head.dense0(feats)
        # (the L2 normalisation of ce is NOT in the graph: ReduceL2 is outside the converter's op set; the caller normalises 576 x 512 numbers)
        shift = self.m.class_head.logit_shift(feats)                 # [1, 576, 1]
        scale = self.m.class_head.logit_scale(feats)                 # RAW: the caller applies elu(x) + 1 (Elu is outside the converter's op set)
        return torch.cat([ce, shift, scale, boxes], dim=-1)[0]       # [576, 518]


def _unit(e):
    return e / (np.linalg.norm(e, axis=-1, keepdims=True) + 1e-6)


def _post(o):
    """what the CALLER does with the graph's output: normalise the 512 embedding numbers, and turn the raw scale into elu(x) + 1"""
    sc = o[:, 513:514]
    sc = np.where(sc > 0, sc + 1.0, np.exp(np.minimum(sc, 0)))
    return np.concatenate([_unit(o[:, :512]), o[:, 512:513], sc, o[:, 514:]], axis=1)


def main(model_dir, ref_dir, out):
    torch.set_grad_enabled(False)
    m = OwlViTForObjectDetection.from_pretrained(model_dir).eval()
    net = Vision(m).eval()
    pixel = torch.from_numpy(np.load(ref_dir + "/inputs.npy"))
    ref = np.load(ref_dir + "/image_feats.npy")
    t = net(pixel).numpy()
    t = _post(t)
    print("the wrapper in torch (embeddings normalised by the caller) equals the reference: max abs difference", float(np.abs(t - ref).max()))
    torch.onnx.export(net, (pixel,), out, input_names=["pixel"], output_names=["feats"], opset_version=17, dynamo=False)
    sess = ort.InferenceSession(out, providers=["CPUExecutionProvider"])
    o = sess.run(None, {"pixel": pixel.numpy()})[0]
    o = _post(o)
    print("ONNX Runtime on the exported graph: shape", o.shape, "| max abs difference from the reference", float(np.abs(o - ref).max()))
    print("  embeddings", float(np.abs(o[:, :512] - ref[:, :512]).max()), "shift/scale", float(np.abs(o[:, 512:514] - ref[:, 512:514]).max()), "boxes", float(np.abs(o[:, 514:] - ref[:, 514:]).max()))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3])
