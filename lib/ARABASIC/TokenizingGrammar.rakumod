use v6.d;
#use Grammar::Tracer;

grammar ARABASIC::TokenizingGrammar {
    rule TOP        { <statement>* }
    # add this to disallow non-Arabic script characters {<:Script<Arabic>>+} as so token t_word {<:Script<Hebrew>>+}

    rule statement   { [<comment> | <assignment> | <print> | <label> | <selection> | <ws>]<.newline> }
        # let's not capture newlines
    rule selection   { 'اذا' <condition> 'ثم' <predicate> }
    rule predicate   { <goto> | <assignment> }
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
    rule addition    { [<number>|<variable>]** 2..20 %% '+' }  # must specify that there be at least 2 terms.
    rule print       { 'اطبع' <term> }
    token linemarker { <!before [اطبع|اذا|ذهاب|بطاقة]>\w+ }
    rule label      { 'بطاقة' <linemarker> } #
    rule goto       { 'ذهاب' <linemarker> }
    token comment    { 'تع:'\V* }
    token number     { '-'?\d+ }
    token identifier { <!before [اطبع|اذا|بطاقة]><:alpha>\w* } #must start with an alphabetical char, then 0 or more "word" chars

    # redefine the default whitespace token in Grammar, per Moritz Lenz
    #   without this, the implicit definition of <ws> is { <!ww> \s* } which would clobber <newline>
    token ws         { <!ww> \h* }  # includes any horizontal whitespace; must be a token and not rule, else infinite recursion
    token newline    {\n [\h*\n]*} # <-- is better, but it throws off line numbers { \v  #`(any type of vertical whitespace) }
        # also could be \n [\h*\n]*
        # token newline    { <[ \c[LINE SEPARATOR] \n ]> } # required because of Unicode?
        # NOTE that \n in Raku regexes conforms to https://unicode.org/reports/tr18/#Line_Boundaries; does \v?
}
