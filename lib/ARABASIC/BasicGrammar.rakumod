use v6.d;

#use Grammar::Tracer;
#use Grammar::Debugger;

grammar ARABASIC::BasicGrammar {
    rule TOP        { <statement>* }
    # token t_word {<:Script<Arabic>>+}
    #    %% \n doesn't work at all well; matches only a single line

    rule statement   { [<comment> | <assignment> | <print> | <ws>]<.newline> } # let's not capture newlines
# | <selection>
#    | <operation>

    #    rule selection   { 'IF' <condition> 'THEN' <expression> }
    #    rule selection   { 'اذا' <condition> 'ثم' <expression> }
#    proto rule comparison {*}
#    rule comparison:sym<equals> { <term> '=' <term> }
#    rule comparison:sym<lessthan> { <term> '<' <term> }
#    rule comparison:sym<greaterthan> { <term> '>' <term> }
#    rule comparison:sym<notequals> { <term> '<>' <term> }
#    rule condition  {}
    rule assignment  { <identifier> '=' <expression> } # whitespace around the = can be anything

#    rule value       { <expression> | <number> }  # Might be a nice abstraction
    #TODO this is a problem, because it interprets all strings in an expression as an operation, even those without any operator!
#    rule expression  { <operation> | <term> } # term with 0 or more operations
    rule expression  { <addition> | <term> } #term must come last, else the rule will always stop when it matches term
    rule term        { <variable> | <number> } # interior whitespace next to { and } is significant
    rule variable    { <identifier> } # gives interpreter a way to check that the identifier was set already
    rule addition    { <term> '+' <term> }

#    proto rule operation  {*};
#    rule operation:sym<addition>  { <term>+ %% '+' }  #TODO this also consumes any lone terms because '+' is just an optional delimiter

    rule print      { 'اطبع' <term> }
    token comment    { 'تع:'\V* }
    token number     { '-'?\d+ }

    #TODO must make it not whitespace (?)
    token identifier { <!before اطبع><:alpha>\w* } #must start with an alphabetical char, then 0 or more "word" chars

    # redefine the default whitespace token in Grammar, per Moritz Lenz
    #   without this, the implicit definition of <ws> is { <!ww> \s* } which would clobber <newline>
    token ws         { <!ww> \h* }  # includes any horizontal whitespace; must be a token and not rule, else infinite recursion
    token newline    { \v  #`(any type of vertical whitespace) } # also could be \n [\h*\n]*
    #    token newline    { <[ \c[LINE SEPARATOR] \n ]> } # required because of Unicode
    # NOTE that \n in Raku regexes conforms to https://unicode.org/reports/tr18/#Line_Boundaries; does \v?
}
