# One step of the generator, then the last three digits.
k = StzKernelMakerQ()
k.TakesIntVector(:a)
k.ReturnsIntVector(:c)
k.ForEachElement('{ @c = (@a * 1664525 + 1013904223) % 1000 }')
? StzKernelPuzzleQ("kp-14").Grade(k)
