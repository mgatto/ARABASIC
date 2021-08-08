use v6.d;
use MONKEY-SEE-NO-EVAL;
use Data::Dump;

# this script functions as an interpreter

use lib '../lib';
use ARABASIC::TokenizingGrammar;
use ARABASIC::Parser;
use ARABASIC::AST;

my $interpreter = ARABASIC::Parser.new;

sub MAIN(
        Str $file  #= a file containing Arabic BASIC source code
) {
    my $parsedArabic = ARABASIC::TokenizingGrammar.parsefile($file, actions => $interpreter);
    #NOTE: subparse() doesn't require the whole passed string to match

    say "The parse tree:\n";
    say $parsedArabic;
    say '-------';

    say "The AST:\n";
    my $st_line_number = 0;

    # loop through the statements
    for $interpreter.statements -> $st {
        print "line #{$st_line_number} ";

        given $st -> $_ {
            # start a loop construct
            when $_ ~~ ARABASIC::AST::Label {
                $_.line_number = $st_line_number;
                $interpreter.loops{$_.name} = {starts_at => $st_line_number, ends_at => Whatever, test => Whatever, body => []};
            }

            # perform print
            when $_ ~~ ARABASIC::AST::Print {
                say $_.printable.value if $_.printable ~~ ARABASIC::AST::Number;
                say $interpreter.variables{$_.printable.name} if $_.printable ~~ ARABASIC::AST::Variable;
            }

            # perform "assignment"
            when $_ ~~ ARABASIC::AST::Assignment {
                perform_assignment(ast => $_);
            }

            # perform selection
            when $_ ~~ ARABASIC::AST::Selection  {
                # abstract eval of the condition into a sub, so we can call it from a GOTO
                my $test_expr = evaluate_condition(ast => $_.test);

                if $test_expr {
                    perform_assignment(ast => $_.predicate) if $_.predicate ~~ ARABASIC::AST::Assignment;

                    if $_.predicate ~~ ARABASIC::AST::GoTo {
                        my $loop = $interpreter.loops{$_.predicate.target};

                        $loop.{"ends_at"} = $st_line_number;
                        $_.predicate.line_number = $st_line_number;

                        # capture the test's AST
                        $loop{"test"} = $_.test;

                        # capture the statements to repeat
                        for $loop.{"starts_at"}^..^$loop.{"ends_at"} {
                            $loop.{"body"}.push($interpreter.statements[$_]);
                        }

                        loop {
                            # evaluate the test again; if false => break out
                            last unless evaluate_condition(ast => $loop{"test"});

                            # process the loop body
                            # exec all body statements after "last"
                            #TODO the statement in the body did execute once for sure. This is not good: what happens when IF == false and GOTO is skipped??
                            for $loop.{"body"}.kv -> $i, $node {
                                perform_assignment(ast => $node) if $node ~~ ARABASIC::AST::Assignment;
                                say $interpreter.variables{$node.identifier.name};
                            }
                        }
                    }
                }
            }
        }

        say Dump($st, :gist);  # :skip-methods(True)
        $st_line_number++;
    }
    say '-------';

    #say "notice how the numbers are Latin now!";
    say "Symbol table:\n", Dump($interpreter.variables);
    say "Loop hash:\n", Dump($interpreter.loops, :gist);
    say '-------';
}


sub perform_addition(ARABASIC::AST::Addition :$ast!) {
    my $sum = 0;

    for $ast.terms {
        if $_ ~~ ARABASIC::AST::Variable {
            $sum += $interpreter.variables{$_.name};
        } elsif $_ ~~ ARABASIC::AST::Number {
            $sum += $_.value;
        }
    }

    return $sum;
}

# abstract out the execution of assignment, since it will be called also for the predicate of selection statements
sub perform_assignment(ARABASIC::AST::Assignment :$ast!) {
    $interpreter.variables{$ast.identifier.name} = $ast.value.value if $ast.value ~~ ARABASIC::AST::Number;
    $interpreter.variables{$ast.identifier.name} = $interpreter.variables{$ast.value.name} if $ast.value ~~ ARABASIC::AST::Variable;
    $interpreter.variables{$ast.identifier.name} = perform_addition(ast => $ast.value) if $ast.value ~~ ARABASIC::AST::Addition;
}

sub evaluate_condition(ARABASIC::AST::Condition :$ast!) {
    my $term0_val;
    if $ast.first_term ~~ ARABASIC::AST::Variable {
        $term0_val = $interpreter.variables{$ast.first_term.name};
    } elsif $ast.first_term ~~ ARABASIC::AST::Number {
        $term0_val = $ast.first_term.value;
    }

    my $term1_val;
    if $ast.second_term ~~ ARABASIC::AST::Variable {
        $term1_val = $interpreter.variables{$ast.second_term.name};
    } elsif $ast.second_term ~~ ARABASIC::AST::Number {
        $term1_val = $ast.second_term.value;
    }

    return EVAL("{$term0_val} {$ast.comparator} {$term1_val}");
}

