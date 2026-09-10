# THE FAMILY TREE SCENES, AS FUNCTIONS TWO FILES SHARE (DN18).
#
# The catalogue renders them; the gate holds them to their rules and
# reads kinship off them. Functions only: loading this file draws nothing.

# THREE GENERATIONS. A couple, their two children, one of whom marries
# and has two children of their own -- and one single parent, said so.
func StzFamilyScene01(paOpt)
	_o_ = new stzFamilyTree("generations")
	_o_.AddPersonXT("ali", "Ali", 1940, 2015)
	_o_.AddPersonXT("mona", "Mona", 1944, 0)
	_o_.AddPersonXT("sami", "Sami", 1968, 0)
	_o_.AddPersonXT("leila", "Leila", 1971, 0)
	_o_.AddPersonXT("nour", "Nour", 1972, 0)
	_o_.AddPersonXT("yara", "Yara", 1998, 0)
	_o_.AddPersonXT("omar", "Omar", 2001, 0)
	_o_.AddPersonXT("lina", "Lina", 2004, 0)
	_o_.ChildOf("ali", "mona", "sami")
	_o_.ChildOf("ali", "mona", "leila")
	_o_.ChildOf("sami", "nour", "yara")
	_o_.ChildOf("sami", "nour", "omar")
	# Leila raises Lina alone
	_o_.AddUnion("solo", [ "leila" ])
	_o_.Child("solo", "lina")
	_o_.ToCanvasXT(paOpt)
	return _o_

# THE WITNESS: one of each mistake. A person who is their own ancestor;
# a union of three; a child born of two unions; a child older than a
# parent; a union joining a person to their own descendant. And a note.
func StzFamilySceneWitness(paOpt)
	_o_ = new stzFamilyTree("witness")
	_o_.AddPersonXT("a", "Adam", 1950, 0)
	_o_.AddPersonXT("b", "Bea", 1952, 0)
	_o_.AddPersonXT("c", "Cal", 1975, 0)
	_o_.AddPersonXT("d", "Dana", 1948, 0)
	_o_.AddPersonXT("e", "Eli", 1980, 0)
	_o_.AddPerson("f", "Fay")
	_o_.AddPerson("g", "Gus")
	_o_.AddNote("n1", "draft, 10 Sep")
	# Adam and Bea have Cal -- and Dana, who is older than both
	_o_.ChildOf("a", "b", "c")
	_o_.Child(_o_.UnionOf("a", "b"), "d")
	# a union of three: Cal, Eli and Fay
	_o_.AddUnion("trio", [ "c", "e", "f" ])
	# Gus is born of it -- and of Adam and Bea: two unions
	_o_.Child("trio", "g")
	_o_.Child(_o_.UnionOf("a", "b"), "g")
	_o_.ToCanvasXT(paOpt)
	return _o_

# KIN JOINED: a father married to his own daughter, on its own, because
# the union it needs spans three ranks and would tangle the witness.
func StzFamilySceneKin(paOpt)
	_o_ = new stzFamilyTree("kin")
	_o_.AddPersonXT("a", "Adam", 1950, 0)
	_o_.AddPersonXT("b", "Bea", 1952, 0)
	_o_.AddPersonXT("d", "Dana", 1975, 0)
	_o_.ChildOf("a", "b", "d")
	_o_.Marry("a", "d")
	_o_.ToCanvasXT(paOpt)
	return _o_

# THE CYCLE, on its own: a person born of their own grandchild. Kept
# apart from the witness because a cycle makes everyone everyone's
# ancestor, and every other rule then speaks at once.
func StzFamilySceneCycle(paOpt)
	_o_ = new stzFamilyTree("cycle")
	_o_.AddPerson("p", "Pia")
	_o_.AddPerson("q", "Quin")
	_o_.AddPerson("r", "Rae")
	_o_.AddPerson("s", "Sol")
	_o_.ChildOf("p", "q", "r")
	_o_.ChildOf("r", "s", "p")
	_o_.ToCanvasXT(paOpt)
	return _o_
