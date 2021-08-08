use ARABASIC::TokenizingGrammar;

class ARABASIC::AST::Node {
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
    has ARABASIC::AST::Node $.value;  # Basically, type == Any
}

class ARABASIC::AST::Condition is ARABASIC::AST::Node {
    has ARABASIC::AST::Node $.first_term;
    has Str $.comparator;
    has ARABASIC::AST::Node $.second_term;
}

class ARABASIC::AST::Selection is ARABASIC::AST::Node {
    has ARABASIC::AST::Condition $.test;
    has ARABASIC::AST::Node $.predicate;
}

class ARABASIC::AST::Label is ARABASIC::AST::Node {
    has $.name;
    has $.line_number is rw;
}

class ARABASIC::AST::GoTo is ARABASIC::AST::Node {
    has $.target;
    has $.line_number is rw;
}

#TODO this would best be ARABASIC::AST::Expression instead?
class ARABASIC::AST::Addition is ARABASIC::AST::Node {
    has $.operator;
    has ARABASIC::AST::Node @.terms is rw;
}

class ARABASIC::AST::Print is ARABASIC::AST::Node {
    has $.printable;
}
