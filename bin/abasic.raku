use v6.d;
#use ARABASIC;
use Grammar::Tracer;
#use Grammar::Debugger

grammar ARABASICGrammar {
    rule TOP {
        <statement>*
    }

    rule statements {
        .* \n
    }

    rule statement {
        \V*  # anything except vertical whitespace
#        .* %% \n #<.ws>*
    }


    token newline {
        <[ \c[LINE SEPARATOR] \n ]>
    }
}

#TODO it's capturing newlines and ws; let's get rid of that
grammar ARABASICGrammar2 {
    token TOP        { <statement>* }
    rule statement   { <assignment> <newline> } # this, then requires a new line after even the last statement!
    #    %% \n doesn't work at all well; matches only a single line

    rule assignment  { <identifier> '=' <term> } # whitespace around the = can be anything
    token term       { <identifier> | <number> }
    token number     { \d+ }
    token identifier { <:alpha> \w* }

    # redefine the default whitespace token in Grammar, - Moritz Lenz
    # without this, it's { <!ww> \s* } which would clobber our <newline>
    token ws         { <!ww> \h* }  # includes any horizontal whitespace

    #    token newline    { <[ \c[LINE SEPARATOR] \n ]> } # required because of Unicode
    rule newline    { \v  #`(any type of vertical whitespace) }
    #    BUT, since \n in Raku regexes conforms to https://unicode.org/reports/tr18/#Line_Boundaries
}

my $arabic = '../test.abas'.IO.slurp();
my $parsedArabic = ARABASICGrammar2.parse($arabic);
#say $arabic;
#say $parsedArabic;
#say $parsedArabic.raku;


