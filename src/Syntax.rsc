module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id name "{" Question* questions "}"; 

// TODO: question, computed question, block, if-then-else, if-then

syntax Question
  = question: Str questionString Id i ":" Type type
  | exprQuestion: Str questionString Id id ":" Type type "=" Expr expr
  | block: "{" Question* questions "}"
  | ifThen: "if" "(" Expr expr ")" Question question !>> "else"
  | ifThenElse: "if" "(" Expr expr ")" Question question "else" Question question
  ;

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr 
  = Id \ "true" \ "false"
  | Str 
  | Int 
  | Bool 
  | bracket "(" Expr ")"
  > not: "!" Expr
  > left mul: Expr "*" Expr
  > left div: Expr "/" Expr
  > left add: Expr "+" Expr
  > left sub: Expr "-" Expr
  > non-assoc (
      Expr "\<" Expr
    | Expr "\<=" Expr
    | Expr "\>" Expr
    | Expr "\>=" Expr
    | Expr "!=" Expr
    | Expr "==" Expr
  )
  > left and: Expr "&&" Expr
  > left or: Expr "||" Expr
  ;


lexical Type = "string" | "integer" | "boolean";

lexical Str = [\"] ![\"]* [\"];

lexical Int
  = [0] | ([1-9] [0-9]*);

lexical Bool = "true" | "false";
