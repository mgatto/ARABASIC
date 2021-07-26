use v6.d;


class ARABASIC::Interpreter {
    has %.variables;

    method TOP($/) {
    }

    method assignment($/) {
        #`(
            set $/<identifier>'s value in the symbol table.
            It will either be a <number> or another identifier whose <number> we
              will retrieve from the symbol table.
        )
        %!variables{$<identifier>} = $<expression>.made;
    }

    method expression($/) {
        # <operation> | <term> can be covered by
        $/.make($<term> ?? $<term>.made !! $<addition>.made);
        #`[        if $<term> {
                    $/.make($<term>.made);
                }
                elsif $<operation> {
                    make $<operation>; # ??
                }
        ]
    }

#    method operation:sym<addition> ($/) {
    method addition ($/) {
        make ($<term>[0].<number>.made || +%!variables{$/<term>[0].<variable>.<identifier>}) + ($<term>[1].<number>.made || +%!variables{$/<term>[1].<variable>.<identifier>});
        # TODO this or clause seems like a hack
    }

    method print($/) {
        say $<term>.made;
    }

    method term($/) {
        if $<number> {
            $/.make($<number>.made);
        }
        elsif $<variable> {
            # get the value of the variable from the symbol table
            make +%!variables{$/<variable>.<identifier>};
        }
    }

    method variable($/) {
        $/.make($<identifier>);
    }

    method identifier($/) {
        make ~$/;  # can use Str(x), or ~(x)
    }

    method number($/) {
        make Int($/);  # Int($<number>)
    }
}
