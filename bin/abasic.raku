use v6.d;
use lib '../lib';
use ARABASIC::BasicGrammar;
use ARABASIC::Interpreter;

#use Grammar::Tracer;
#use Grammar::Debugger;

my $arabic = '../test.abas'.IO.slurp();
my $parsedArabic = ARABASIC::BasicGrammar.parse($arabic);

say $parsedArabic;
#say $parsedArabic.raku;


