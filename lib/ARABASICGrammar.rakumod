grammar ARABASICGrammar2 {
    token TOP        { <statement>* }
    rule statement   { <assignment> <newline> } # this, then requires a new line after even the last statement!
#    %% \n doesn't work at all well; matches only a single line

    rule assignment  { <identifier> '=' <term> } # whitespace around the = can be anything
    token term       { <identifier> | <number> }
    token number     { \d+ }
    token identifier { <:alpha> \w* } # incredible, <:alpha> captures s0 correctly!

    # redefine the default whitespace token in Grammar, - Moritz Lenz
    # without this, it's { <!ww> \s* } which would clobber our <newline>
    token ws         { <!ww> \h* }  # == match any whitespace outside of a word
        # this MUST be a token, not a rule, else we get infinite recursion...not sure why yet.

#    token newline    { <[ \c[LINE SEPARATOR] \n ]> } # required because of Unicode
    rule newline    { \v  #`(any type of vertical whitespace) }  # rule because don't capture it
    #    BUT, since \n in Raku regexes conforms to https://unicode.org/reports/tr18/#Line_Boundaries
}

#`{
- https://docs.raku.org/language/grammars:

"When rule is used instead of token, :sigspace is enabled by default and any whitespace after terms and closing parenthesis/brackets are turned into a non-capturing call to ws, written as <.ws> where . means non-capturing. That is to say:

rule entry { <key> '=' <value> }
Is the same as:

token entry { <key> <.ws> '=' <.ws> <value> <.ws> }"
}
