use v6.d;

use lib '../lib';
use ARABASIC::BasicGrammar;
use ARABASIC::Interpreter;

my $arabic = q:to/EOI/;
ص = ٤٢
تع:this is a comment
ص٠=٢٢
ت = -٥
ن = ١٠٥
  ل = ن
EOI


#my $arabic = '../test.abas'.IO.slurp();
my $interpreter = ARABASIC::Interpreter.new;
my $parsedArabic = ARABASIC::BasicGrammar.parse($arabic, actions => $interpreter);

dd $interpreter.variables;
say $parsedArabic;


