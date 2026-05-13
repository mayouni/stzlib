#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#            SOFTANZA LIBRARY (V0.9)                  #
#  An accelerative library for Ring applications,     #
#  and more!                                          #
#                                                     #
#  Author: Mansour Ayouni (kalidianow@gmail.com)      #
#  300K+ lines of code, handcrafted over 5 years      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# Softanza software design follows these 7 principles:

# 1. LAYERED
#~~~~~~~~~~~~

#	Structured into SoftanzaCore (stk*), SoftanzaBase (stz*),
#	and SoftanzaMax (stx*).

#	The three layers share the same folder structure. For example,
#	string management exists at each level: stkString (lean, fast),
#	stzString (rich, semantic), and stxMultiString (advanced).

#	Each layer builds on the one beneath it. Enhancements to a lower
#	layer automatically benefit those above.

#	See: base/doc/internals/softanza-layer-architecture.md

# 2. MODULAR
#~~~~~~~~~~~~

#	Classes are organized by functional domain, and the codebase's folder
#	structure clearly reflects these domains. The four core domains match
#	the four types supported by Ring: NUMBER, STRING, LIST, and OBJECTS.
#	Additional domains: file, datetime, regex, graph, stats, i18n,
#	natural, reactive, network, and more.

# 3. GRANULAR
#~~~~~~~~~~~~~

#	Programmers can operate at desired abstraction levels:

#	~> By using only the required layer:

#		=> SoftanzaCore: for quick features, efficiency, small code,
#		   or performance-critical development on supported platforms
#		   (web, mobile, microcontrollers, MS-DOS).

#		=> SoftanzaBase: for a wide range of functionalities covering
#		   number, character, string, list, graph, regex, datetime,
#		   i18n, stats, reactive, and natural coding.

#		=> SoftanzaMax: for advanced features enabling innovative,
#		   industry-grade software solutions (walkers, parsers,
#		   big numbers, text encoding, wings plugins, testing).

#	~> By loading only necessary modules or specific files.

# 4. CONFIGURABLE
#~~~~~~~~~~~~~~~~~

#	Library gymnastics, that may not be useful to everyone, like function
#	alternative forms, misspelled forms, multilingual forms, and case
#	sensitivity can be dynamically configured for each object at runtime.
#	Programmers specify tuning using syntax like:

#		Use([
#			:stzStringClass = [
#				:@AllAlternativeForms,
#				:@TheseMisspelledForms = [ ..., ... ],
#				:@NFirstMultilingualForms = 10, etc ]
#			],
#			stzListClass = [ ... ]
#		])

# 5. OPTIMIZED
#~~~~~~~~~~~~~~

#	A future script will create, based on a codebase that uses Softanza,
#	a lightweight, dependency-free file (SoftanzaMine.ring) containing only
#	used classes and methods in that particular codebase.

# 6. APIFIED
#~~~~~~~~~~~~

#	All Softanza classes, modules, or layers can be delivered as
#	a unified service-oriented API under a dedicated application
#	server working over HTTP. This allows the use of the library
#	in production settings, on the cloud or on-premise, for
#	developing web and mobile backend services, and professional
#	client-server applications.

# 7. BATTLE-TESTED & DOCUMENTED
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#	All Softanza classes and functions are made hand in hand with
#	tests crafted at design time, then enriched by using the library
#	in solving real-world algorithmic cases.

#	The library is documented through comments inside the codebase,
#	narrated test files (executable tutorials), and 97+ narration
#	markdown files covering every major feature.
#	See: base/doc/narrations/

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  END OF THE ARCHITECTURE OVERVIEW   #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#