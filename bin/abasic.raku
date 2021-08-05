use v6.d;
use MONKEY-SEE-NO-EVAL;

use lib '../lib';
use ARABASIC::BasicGrammar;
use ARABASIC::Interpreter;
use ARABASIC::AST;

my $arabic = q:to/EOI/;
ص = ٤٢
تع:this is a comment
ص٠=٢٢
ت = -٥
ن = ١٠٥
  ل = ن
ش =٧+٣
اطبع ل
ط = ٩٩
اذا ط==  ٩٩ ثم ط =١٠٠
اذا ط==  ٩ ثم ط =١٢٠

EOI
# ش = ن+٣

#my $arabic = '../test.abas'.IO.slurp();
my $interpreter = ARABASIC::Interpreter.new;
my $parsedArabic = ARABASIC::BasicGrammar.parse($arabic, actions => $interpreter);
    #NOTE: subparse() doesn't require the whole passed string to match

say $parsedArabic;

say '-------';

#TODO accept an arg of ARABASIC::AST::Assignment
sub perform_assignment(ARABASIC::AST::Assignment :$ast!) {
    say "{$ast.identifier.name} = {$ast.value.value}" if $ast.value ~~ ARABASIC::AST::Number;
    say "{$ast.identifier.name} = {$ast.value.name}" if $ast.value ~~ ARABASIC::AST::Variable;

    $interpreter.variables{$ast.identifier.name} = $ast.value.value if $ast.value ~~ ARABASIC::AST::Number;
    $interpreter.variables{$ast.identifier.name} = $interpreter.variables{$ast.value.name} if $ast.value ~~ ARABASIC::AST::Variable;
}

# loop through the statements
for $interpreter.statements -> $st {
    given $st -> $_ {
        # perform "assignment"
        when $_ ~~ ARABASIC::AST::Assignment {
            perform_assignment(ast => $_);
        }
        when $_ ~~ ARABASIC::AST::Selection  {
            my $term0_val;
            if $_.test.first_term ~~ ARABASIC::AST::Variable {
                $term0_val = $interpreter.variables{$_.test.first_term.name};
            } elsif $_.test.first_term ~~ ARABASIC::AST::Number {
                $term0_val = $_.test.first_term.value;
            }

            my $term1_val;
            if $_.test.second_term ~~ ARABASIC::AST::Variable {
                $term1_val = $interpreter.variables{$_.test.second_term.name};
            } elsif $_.test.second_term ~~ ARABASIC::AST::Number {
                $term1_val = $_.test.second_term.value;
            }

            my $test_expr = EVAL("{$term0_val} {$_.test.comparator} {$term1_val}");
            if $test_expr {
                say "it's true!";
                say $_.predicate;
                #TODO if $_.predicate == assignment...
                perform_assignment(ast => $_.predicate);
            } else {
                say "it's false!";
            }

            dd $_;
        }
        default                              { say "Just some Node";}
    }
}

say '-------';

say "notice how the numbers are Latin now!";
dd $interpreter.variables;

say '-------';
