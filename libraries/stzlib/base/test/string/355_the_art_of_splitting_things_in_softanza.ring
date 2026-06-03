# Narrative
# --------
# #todo #narration THE ART OF SPLITTING THINGS IN SOFTANZA
#
# Extracted from stzStringTest.ring, block #355.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

		

pr()

# Softanza can do all these splitting cases, both for strings and lists:

 -------------------+--------+--------+-------+--------- 
        SPLITTING   |   At   | Before | After | Around  
 ===================+========+========+=======+========= 
      A Position    |   ✓   |   ✓   |   ✓   |   ✓   
 -------------------+--------+--------+-------+---------
   Many Positions   |   ✓   |   ✓   |   ✓   |   ✓    
 -------------------+--------+--------+-------+---------
      A SubString   |   ✓   |   ✓   |   ✓   |   ✓   
 -------------------+--------+--------+-------+---------
   Many SubStrings  |   ✓   |   ✓   |   ✓   |   ✓    
 -------------------+--------+--------+-------+---------
       Section	    |   ✓   |   ✓   |   ✓   |   ✓    
 -------------------+--------+--------+-------+---------
      SectionIB     |   ✓   |   ✓   |   ✓   |   ✓    
 -------------------+--------+--------+-------+---------
    Many Sections   |   ✓   |   ✓   |   ✓   |   ✓    
 -------------------+--------+--------+-------+---------
   Many SectionsIB  |   ✓   |   ✓   |   ✓   |   ✓    
 -------------------+--------+--------+-------+---------
       Where        |   ✓   |   ✓   |   ✓   |   ...    
 -------------------+--------+--------+-------+---------

# See fellowing examples...

pf()
