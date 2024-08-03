/* #NOTE #ai #claude Generated with Claude AI
   after feeding it with the content of stzWalkerTest.ring

#todo Use this doc as a basis for writing exahaustive and comprehensive
# tests of all the methods of the stzWalker class



stzWalker: The class provides a variety of methods for walking,
checking positions, and retrieving information about the walk.

Initialization and Configuration:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Walker can be initialized with different parameters (start, end, step).
Example:

new stzWalker(1, 10, 2)

or

new stzWalker(:Start = 1, :End = 10, :Step = 2)


Position Information:
~~~~~~~~~~~~~~~~~~~~~

- StartPosition(): Get the starting position
- EndPosition(): Get the ending position
- CurrentPosition() or Position(): Get the current position
- NumberOfPositions(): Get the total number of positions in the range


Step Information:
~~~~~~~~~~~~~~~~~

- NStep(): Get the step size
- NumberOfSteps(): Get the total number of possible steps


Position Collections:
~~~~~~~~~~~~~~~~~~~~~

- Positions(): Get all positions in the range
- WalkablePositions() or Walkables(): Get all positions that can be walked to
- UnwalkablePositions() or Unwalkables(): Get all positions that can't be walked to


Walking Methods:
~~~~~~~~~~~~~~~~

- Walk(): Walk one step
- WalkN(n): Walk n steps
- WalkTo(position): Walk to a specific position
- WalkToFirst(): Walk to the first position
- WalkToLast(): Walk to the last position
- WalkBetween(start, end): Walk between two positions
- WalkFromEnd(): Walk from the end towards the start
- WalkFromStart(): Walk from the start towards the end


State Checking:
~~~~~~~~~~~~~~~

- HasNext(): Check if there are more positions to walk to


Remaining Walk Information:
~~~~~~~~~~~~~~~~~~~~~~~~~~~

- RemainingWalkables(): Get the remaining positions that can be walked to
- HowManyRemainingWalkables(): Get the count of remaining walkable positions



This rich set of features allows you to:

- Easily retrieve information about the current state of the walk

- Control the walk in various ways (step by step, to specific positions,
  or for a specific number of steps)

- Check the validity of operations before performing them

- Get comprehensive information about the entire range of the walk

Walkig history
~~~~~~~~~~~~~~

- Walks() : Get the list of walks made on the object (using Walk...() methods)
- NumberOfWalks() : Get the size of the walking history
- NthWalk(n): Get the nth walk in the walking history
- RemoveWalks() : Cleans the walking history
