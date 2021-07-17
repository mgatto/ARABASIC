use v6.d;

#TODO it's capturing newlines; let's get rid of that
grammar ARABASIC::BasicGrammar {
    token TOP        { <statement>* }
#    rule statement   { <comment><newline> | <assignment><newline> } # this, then requires a new line after even the last statement!
    rule statement   { [<comment> | <assignment>]<newline> }
    #    %% \n doesn't work at all well; matches only a single line

    rule assignment  { <identifier> '=' <term> } # whitespace around the = can be anything
    token term       { <identifier> | <number> } # interior whitespace next to { and } is significant
    token number     { '-'?\d+ }
    token identifier { <:alpha> \w* }
    token comment    { 'تع:'\V* }

    # redefine the default whitespace token in Grammar, - Moritz Lenz
    # without this, it's { <!ww> \s* } which would clobber our <newline>
    token ws         { <!ww> \h* }  # includes any horizontal whitespace; must be a token and not rule: infinite recursion
    #    token newline    { <[ \c[LINE SEPARATOR] \n ]> } # required because of Unicode
    rule newline    { \v  #`(any type of vertical whitespace) }
    #    BUT, since \n in Raku regexes conforms to https://unicode.org/reports/tr18/#Line_Boundaries
}

#`{
- https://docs.raku.org/language/grammars:

"When rule is used instead of token, :sigspace is enabled by default and any whitespace after terms and closing parenthesis/brackets are turned into a non-capturing call to ws, written as <.ws> where . means non-capturing. That is to say:

rule entry { <key> '=' <value> }
Is the same as:

token entry { <key> <.ws> '=' <.ws> <value> <.ws> }"
}
