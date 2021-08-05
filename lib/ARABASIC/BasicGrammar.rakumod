use v6.d;

grammar ARABASIC::BasicGrammar {
    rule TOP        { <statement>* }
    # token t_word {<:Script<Arabic>>+}
    #    %% \n doesn't work at all well; matches only a single line

    rule statement   { [<comment> | <assignment> | <print> | <selection> | <ws>]<.newline> } # let's not capture newlines
#    | <operation>

    rule selection   { 'اذا' <condition> 'ثم' <predicate> }
    rule predicate   { <assignment> }
    rule condition   { <term> <comparison> <term> }
    proto rule comparison {*}
    rule comparison:sym<==> {<sym>}
    rule comparison:sym<\<> {<sym>}
    rule comparison:sym<\>> {<sym>}
    rule comparison:sym<\<\>> {<sym>}

    rule assignment  { <identifier> '=' <expression> } # whitespace around the = can be anything

    rule expression  { <addition> | <term> } #term must come last, else the rule will always stop when it matches term
    rule term        { <variable> | <number> } # interior whitespace next to { and } is significant
    rule variable    { <identifier> } # gives interpreter a way to check that the identifier was set already
    rule addition    { <number>+ %% '+' }  # { <term> '+' <term> }
    rule print      { 'اطبع' <term> }

    token comment    { 'تع:'\V* }
    token number     { '-'?\d+ }

    #TODO must make it not whitespace (?)
    token identifier { <!before [اطبع|اذا]><:alpha>\w* } #must start with an alphabetical char, then 0 or more "word" chars

    # redefine the default whitespace token in Grammar, per Moritz Lenz
    #   without this, the implicit definition of <ws> is { <!ww> \s* } which would clobber <newline>
    token ws         { <!ww> \h* }  # includes any horizontal whitespace; must be a token and not rule, else infinite recursion

    token newline    { \v  #`(any type of vertical whitespace) } # also could be \n [\h*\n]*
    #    token newline    { <[ \c[LINE SEPARATOR] \n ]> } # required because of Unicode
        # NOTE that \n in Raku regexes conforms to https://unicode.org/reports/tr18/#Line_Boundaries; does \v?
}
