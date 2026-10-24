# guard none: 4,096 threads, 4,000 elements -- the last 96 write past the region, and the margin names the first.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.WithoutGuard()
k.ForEachElement('{ @c = @a * 2 }')
? StzKernelPuzzleQ("kp-05").Grade(k)
