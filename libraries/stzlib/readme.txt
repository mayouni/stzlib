#~~~~~~~~~~~~~~~~~~#
#  IMPORTANT NOTE  #
#~~~~~~~~~~~~~~~~~~#

# NOTE: Softanza software design is being refactored according to these 7 principles:

# Layered:
#~~~~~~~~~

#	Structured into SoftanzaCore, SoftanzaBase, and SoftanzaMax.

#	The three layers have the same fold structure. For example, there is
#	a class for managing string in each level : stkString, stzString,
#	and stxString. And so on.

#	Each layer uses the one beneath it, and enhancements made to a lower
#	layer automatically benefit those above.

# Modular:
#~~~~~~~~~

#	Classes are organized by functional domain, and the codebase's folder
#	structure clearly reflects these domains. The four main domains are
# 	the four types supported by Ring : NUMBER, STRING, LIST, and OBJECTS.

# Granular:
#~~~~~~~~~~

#	Programmers can operate at desired abstraction levels:

#	~> By using only the required layer:

#		=> SoftanzaCore: for quick features, efficiency, small code,
#		   or performance-critical development on supported platforms
# 		   (web, mobile, microcontrollers, MS-DOS).

# 		=> SoftanzaBase: for a wide range of functionalities covering
# 		   number, character, string, and list management.

# 		=> SoftanzaMax: for advanced features enabling innovative,
#		   industry-grade software solutions (natural coding, knowledge-oriented,
# 		   plugin-based, memory profiling, workflow processing, etc.).

#		=> By using only necessary modules: If only STRING management is needed,
#		   load STRING-related files from the selected layer.

#		=> By loading only specific files: For example, load /core/stzCoreChar.ring
# 		   for unicode character operations.

# Configurable:
#~~~~~~~~~~~~~~

#	Library gymnastics, that may not be useful to every one, like function alternative
#	forms, misspelled forms, multilingual forms, and case sensitivity can be dynamically
#	configured for each object at runtime. Programmers specify tuning using syntax like:

#		Use([
#			:stzStringClass = [
# 				:@AllAlternativeForms,
#				:@TheseMisspelledForms = [ ..., ... ],
#				:@NFirstMultilingualForms = 10, etc ]
#			],

#			stzListClass = [ ... ]
#	        ]

# Optimized:
#~~~~~~~~~~~

#	A future script will create, based on a codebase that uses Softanza,
#	a lightweight, dependency-free filz (SoftanzaMine.ring) containing only
# 	used classes and methods in that particular codebase.


# APIfied:
#~~~~~~~~~

#	All Softanza classes, modules, or layers can be delivered as
#	a unified service-oriented API under a dedicated application
#	server working over HTTP. This allows the use of the library
#	in a production setting, on the cloud or in promise, in
#	developing web and mobile backend services, and professional
#	client server applications.

# Battle-tested & documented
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#	All Softanza classes and functions are made hand in hand with
#	tests crafted at design time, and then enritched, by using
#	the library in solving several real world algorithmic cases.

#	The library is carefelly documented through comments inside
#	the code base and a set of narrations prvided as test samples.
#	A documentation file is made to each class, in a strcutered
#	format to enable its export to HTML, PDF or other forms.

#~~~~~~~~~~~~~~~~~~~~~~~~#
#  END OF THE NOTE NOTE  #
#~~~~~~~~~~~~~~~~~~~~~~~~#