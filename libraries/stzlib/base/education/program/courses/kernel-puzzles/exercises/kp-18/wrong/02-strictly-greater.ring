# Stops only when the state PASSES the size, so a size that is already a power of two doubles: element 2 asks for 1 and gets 2.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = iterate(k, 0, 40, s, 0.5, s * 2, s > @a) }')
? StzKernelPuzzleQ("kp-18").Grade(k)
