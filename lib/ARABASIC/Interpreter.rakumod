use v6.d;


class ARABASIC::Interpreter {
    has %.variables;

    method TOP($/) {
#        make $/.values[0].made;
#        my %variables;
    }

    method assignment($/) {
        #`(
            set $/<identifier>'s value in the symbol table.
            It will either be a <number> or another identifier whose <number> we
                will retrieve from the symbol table.
        )
        %!variables{$<identifier>.Str} = $/<term>.Int || +%!variables{$/<term><variable><identifier>};
        # say %!variables{~$/<term>.<variable>.<identifier>};
        # can use Str(x)
        # can use ~(x), too
    }

    method variable($/) {
        # check that $/<identifier> is defined
        make %!variables{$/<identifier>} || die "";
    }

    method identifier($/) {
        make ~$/;
    }
}

