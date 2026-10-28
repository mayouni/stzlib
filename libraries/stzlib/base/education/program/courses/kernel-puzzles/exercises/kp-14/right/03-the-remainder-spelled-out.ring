# The remainder written out: a whole division drops it, so x - x / 1000 * 1000 is what is left.
k = StzKernelMakerQ()
k.TakesIntVector(:a)
k.ReturnsIntVector(:c)
k.ForEachElement('{ @c = (@a * 1664525 + 1013904223) - (@a * 1664525 + 1013904223) / 1000 * 1000 }')
? StzKernelPuzzleQ("kp-14").Grade(k)
