use ARABASIC::BasicGrammar;

class ARABASIC::AST::Node {
#    has Int $!line-number;  will be the position in the @.statements array + 1
    has Int $!starts-at;
}

class ARABASIC::AST::Program is ARABASIC::AST::Node {
    has ARABASIC::AST::Node @.statements;
}

class ARABASIC::AST::Comment is ARABASIC::AST::Node {
    has Str $.text;
}

class ARABASIC::AST::Variable is ARABASIC::AST::Node {
    has Str $.name;
}

class ARABASIC::AST::Number is ARABASIC::AST::Node {
    has $.value;  # Any
}

class ARABASIC::AST::Statement is ARABASIC::AST::Node {
    has Int $.line-number;
    has Str $.code;
}

class ARABASIC::AST::Assignment is ARABASIC::AST::Node {
    has ARABASIC::AST::Variable $.identifier;
#    has Str $.name;
    has ARABASIC::AST::Node $.value;  # Basically, type == Any
}

class ARABASIC::AST::Condition is ARABASIC::AST::Node {
    has ARABASIC::AST::Node $.first_term;
    has Str $.comparator;
    has ARABASIC::AST::Node $.second_term;
}

class ARABASIC::AST::Selection is ARABASIC::AST::Node {
    has ARABASIC::AST::Condition $.test;
    has ARABASIC::AST::Assignment $.predicate;

    multi run-predicate() {}
}



