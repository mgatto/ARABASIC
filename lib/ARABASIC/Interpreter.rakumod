use v6.d;
use MONKEY-SEE-NO-EVAL;

use ARABASIC::AST;

class ARABASIC::Interpreter {
    has ARABASIC::AST::Node @.statements;  #TODO I need an ordered struct / has instead of an array...
    has %.variables; #TODO transfer this to the AST module?

    method TOP($/) {
        # make an array
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

    }

    multi method statement($/ where $<selection>) {
        $/.make($<selection>.made);
    }

    multi method statement($/ where $<ws>) {

    }

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

        # HOWEVER, expressions with identifiers in it will fail!
        # OR, I can update the grammar so int expressions are evaluated as much as possible, but are then stuffed into
        #     AST::Number and identifiers into AST::Variable
    }

    # multi method expression($/ where $<identifier>) {}
    method expression($/) {
        $/.make($<term> ?? $<term>.made !! $<addition>.made);
    }

#    method operation:sym<+> ($/) {
    method addition ($/) {
        make ARABASIC::AST::Number.new(value => Int([+] $<number>».made));
    }

    method print($/) {
#        say $<term>.made;
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
                predicate => $<predicate>.<assignment>.made
            )
        );
    }

}
