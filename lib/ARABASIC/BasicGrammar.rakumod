use v6.d;

#use Grammar::Tracer;
#use Grammar::Debugger;

grammar ARABASIC::BasicGrammar {
    rule TOP        { <statement>* }
    # token t_word {<:Script<Arabic>>+}

    #    %% \n doesn't work at all well; matches only a single line
    rule statement   { [<comment> | <assignment>]<.newline> } # let's not capture newlines
    rule assignment  { <identifier> '=' <term> } # whitespace around the = can be anything
#    rule term        { <identifier> | <number> } # interior whitespace next to { and } is significant
    rule term        { <variable> | <number> }
    rule variable   { <identifier> } # gives interpreter a way to check that the identifier was set already

    token comment    { 'تع:'\V* }
    token number     { '-'?\d+ }
    token identifier { <:alpha>\w* } #must start with an alphabetical char, then 0 or more "word" chars

    # redefine the default whitespace token in Grammar, per Moritz Lenz
    #   without this, the implicit definition of <ws> is { <!ww> \s* } which would clobber <newline>
    token ws         { <!ww> \h* }  # includes any horizontal whitespace; must be a token and not rule, else infinite recursion
    token newline    { \v  #`(any type of vertical whitespace) }
    #    token newline    { <[ \c[LINE SEPARATOR] \n ]> } # required because of Unicode
    # NOTE that \n in Raku regexes conforms to https://unicode.org/reports/tr18/#Line_Boundaries; does \v?
}

#`{
- https://docs.raku.org/language/grammars:

"When rule is used instead of token, :sigspace is enabled by default and any whitespace after terms and closing parenthesis/brackets are turned into a non-capturing call to ws, written as <.ws> where . means non-capturing. That is to say:

rule entry { <key> '=' <value> }
Is the same as:

token entry { <key> <.ws> '=' <.ws> <value> <.ws> }"
}
