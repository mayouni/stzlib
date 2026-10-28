# Only the last three digits of each part can reach the answer: 1664525 ends in 525, 1013904223 in 223.
k = StzKernelMakerQ()
k.TakesIntVector(:a)
k.ReturnsIntVector(:c)
k.ForEachElement('{ @c = (@a * 525 + 223) % 1000 }')
? StzKernelPuzzleQ("kp-14").Grade(k)
