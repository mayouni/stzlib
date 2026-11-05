# WSP thinking (SOFTANZA_WEIGHT_SPACE_GOVERNANCE.md section 2): every patch of four pictures scored against 30 words, to ask whether a false alarm is a PROMISCUOUS patch (it is not) or a WARM picture (it is)
load "../../stzBase.ring"
decimals(5)
$cD = "D:/GitHub/_wti_models_src/owlvit_spike/"
$cV = "D:/GitHub/_wti_dl_owlvit/vocab.json"
$cM = "D:/GitHub/_wti_dl_owlvit/merges.txt"
aWords = [ "tinfoil", "turtle", "pancake", "tonic", "chandelier", "flowerpot", "bath mat", "christmas tree", "kitchen table",
	"cat", "laptop", "keyboard", "person", "car", "dog", "necktie", "shovel", "fire extinguisher", "violin", "helicopter",
	"zebra", "toaster", "umbrella", "giraffe", "stop sign", "wine glass", "banana", "clock", "scissors", "kite" ]
cQ = ""
for i = 1 to len(aWords)
	if i > 1 cQ += char(10) ok
	cQ += aWords[i]
next
aPics = [ "000000012576.jpg", "000000013004.jpg", "000000001675.jpg", "000000000139.jpg" ]
for p = 1 to len(aPics)
	oImg = StzImageRawQ("D:/GitHub/_wti_models_src/coco/images/" + aPics[p])
	aS = StzEngineNeuralOwlScores($cD + "owlvit_vision.gguf", $cD + "owlvit_text.gguf", $cV, $cM, cQ, oImg.Pixels(), oImg.Width(), oImg.Height(), oImg.Channels(), 4)
	c = ""
	for i = 1 to len(aS)
		c += "" + aS[i] + " "
	next
	write("D:/GitHub/_wti_models_src/owlvit_spike/promisc_" + aPics[p] + ".txt", c)
	? aPics[p] + ": " + len(aS) + " logits"
	oImg.Release()
next
shutdown(0)
