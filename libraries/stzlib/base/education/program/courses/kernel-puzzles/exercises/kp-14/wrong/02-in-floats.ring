# The same arithmetic in floats: 1013904223 becomes 1013904192, and seed 0 rolls 192.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = (@a * 1664525 + 1013904223) % 1000 }')
? StzKernelPuzzleQ("kp-14").Grade(k)
