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
ش = ٧ + ٣
ش = ن + ٣
اطبع ل
ط = ٩٩

EOI


#my $arabic = '../test.abas'.IO.slurp();
my $interpreter = ARABASIC::Interpreter.new;
say ARABASIC::BasicGrammar.parse($arabic, actions => $interpreter); #

dd $interpreter.variables;
#say $parsedArabic;
#dd $parsedArabic;


