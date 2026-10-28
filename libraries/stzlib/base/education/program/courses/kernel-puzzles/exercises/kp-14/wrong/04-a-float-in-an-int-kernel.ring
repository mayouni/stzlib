# 1000.0 is a float, and it meets an int: refused before anything runs.
k = StzKernelMakerQ()
k.TakesIntVector(:a)
k.ReturnsIntVector(:c)
k.ForEachElement('{ @c = (@a * 1664525 + 1013904223) % 1000.0 }')
? StzKernelPuzzleQ("kp-14").Grade(k)
