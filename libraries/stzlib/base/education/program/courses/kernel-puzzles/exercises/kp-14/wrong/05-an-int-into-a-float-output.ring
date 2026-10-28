# An int written into a float output: refused, it says which conversion to write.
k = StzKernelMakerQ()
k.TakesIntVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = (@a * 1664525 + 1013904223) % 1000 }')
? StzKernelPuzzleQ("kp-14").Grade(k)
