class stzMusic
	@oUniverse = NULL       # MU4: the universe In() chose
	def ToSound(pcNotes)
		return This.ScoreOf(pcNotes).ToSound()
