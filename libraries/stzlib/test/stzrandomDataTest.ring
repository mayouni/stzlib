load "../max/stzmax.ring"

profon()

? AWord() + NL
#--> "square"

? Five( Words() )
#--> [ "apple", "yacht", "truck", "station", "base" ]

? Three( ArabicWords() ) # Or @3(...) if you want
#o-> [ "كلمة", "كرسيّ", "شجرة" ]

? Q([]).FilledWith( Four( FrenchWords() ) )
#--> [ "question", "chien", "lampe", "chat" ]

? Q("").FilledWith( AnEnglishWord() + ' & ' + AFrenchWord() ) + NL
#--> question & soleil

StzGridQ([10, 10]).FillWithQ( CharsBetween("!", "p") ).Show() #TODO // fix it!
#-->
#   ! " # $ % & ' ( ) *
#   + , - . / 0 1 2 3 4
#   5 6 7 8 9 : ; < = >
#   ? @ A B C D E F G H
#   I J K L M N O P Q R
#   S T U V W X Y Z [ \
#   ] ^ _ ` a b c d e f
#   g h i j k l m n o p

proff()
# Executed in 0.06 second(s) in Ring 1.21
# Executed in 0.20 second(s) in Ring 1.19

