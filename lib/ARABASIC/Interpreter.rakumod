use v6.d;
use MONKEY-SEE-NO-EVAL;  # required for using the EVAL macro, which is seen as unsafe when used with unsecured inputs.

use ARABASIC::AST;

class ARABASIC::Interpreter {
    has ARABASIC::AST::Node @.statements;
    has %.variables;
    has %.loops is rw;

    method TOP($/) {
        # make an array of statements
        for $<statement> -> $statement {
#            $program
            @!statements.push($statement.made);
        }
    }

    multi method statement($/ where $<assignment>) {
        $/.make($<assignment>.made);
    }

    multi method statement($/ where $<comment>) {
        $/.make(
            ARABASIC::AST::Comment.new(text => Str($/))
        );
    }

    multi method statement($/ where $<print>) {
        make ARABASIC::AST::Print.new(printable => $<print><term>.made);
    }

    multi method statement($/ where $<selection>) {
        $/.make($<selection>.made);
    }

    multi method statement($/ where $<label>) {
        $/.make($<label>.made);
    }

    # No-op
    multi method statement($/ where $<ws>) {}

    method assignment($/) {
        #`(
            set $/<identifier>'s value in the symbol table.
            It will either be a <number> or another identifier whose <number> we
              will retrieve from the symbol table.
        )
        $/.make(ARABASIC::AST::Assignment.new(
                identifier => ARABASIC::AST::Variable.new(name => $<identifier>.made),
                value => $<expression>.made,
            )
        );
    }

    # expressions can be a single constant, a single variable or an addition operation
    method expression($/) {
        $/.make($<term> ?? $<term>.made !! $<addition>.made);
    }

    # method operation:sym<+> ($/) {}
    multi method addition ($/ where $<number>) {
        my $add_ast = ARABASIC::AST::Addition.new(
                operator => '+',
                terms => ARABASIC::AST::Number.new(value => Int([+] $<number>».made))
                );

        # now loop through any $<variable> and append them
        for $<variable> {
            $add_ast.terms.append(ARABASIC::AST::Variable.new(name => $_.made));
        }
        $/.make($add_ast);
    }

     method print($/) {
         make ARABASIC::AST::Print.new(printable => $<term>.made);
     }

    # Keep these operating here instead of in the AST, for now.
    multi method term($/ where $<number>) {
        make ARABASIC::AST::Number.new(value => $<number>.made);
    }

    multi method term($/ where $<variable>) {
        $/.make(ARABASIC::AST::Variable.new(name => $<variable>.made));
    }

    method variable($/) {
        $/.make($<identifier>.made);
    }

    method identifier($/) {
        make ~$/;  # can use Str(x), or ~(x)
    }

    method number($/) {
        make Int($/);  # Int($<number>)
    }

    method label($/) {
        $/.make(ARABASIC::AST::Label.new(
            name => $<linemarker>.made,
            line_number => 0,
        ));
    }

    method goto($/) {
        $/.make(ARABASIC::AST::GoTo.new(
            target => $<linemarker>.made,
            line_number => 0,
        ));
    }

    method linemarker($/) {
        $/.make(~$/);
    }

    method condition($/) {
        $/.make(ARABASIC::AST::Condition.new(
                first_term => $<term>[0].made,
                comparator => ~$<comparison>,
                second_term => $<term>[1].made
            )
        );
    }

    method selection($/) {
        $/.make(ARABASIC::AST::Selection.new(
                test => $<condition>.made,
                predicate => $<predicate>.made
            )
        );
    }

    multi method predicate($/ where $<assignment>) {
        $/.make($<assignment>.made);
    }
    multi method predicate($/ where $<goto>) {
        $/.make($<goto>.made);
    }

}
