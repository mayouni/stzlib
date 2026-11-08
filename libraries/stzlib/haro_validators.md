# The validators Haro's checker is told about

`haro check` refuses text run as code (`haro/text-run-as-code`) unless the body that runs it
passed the text to a validator named to the checker. stzlib's validators are listed, comma-
separated, in `haro_validators.txt` beside this file, so the count can be reproduced:

    cd libraries/stzlib/base/test/object
    haro check <a program that loads ../../stzBase.ring> --validators=<the line in haro_validators.txt>

Each one accepts only a shape that cannot name anything to run: a plain identifier, a list
literal of data, a query condition on Q(@item) with literal arguments, a tree path made of
[:name] and [n] segments, an arithmetic formula of the shape
stzCoeffExtractor.translateExpression emits. A function joins the list only when it is that strict.

Counted 2026-11-08: 108 sites with the first three named; 51 with all seven, after the first
four rounds of retirement (PRINCIPAL-HAROFIRST-01).
