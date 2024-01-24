module AST

/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(str name, list[AQuestion] questions)
  ; 

data AQuestion(loc src = |tmp:///|)
  = question(str questionString, AId id, AType t)
  | exprQuestion(str questionString, AId id, AType t, AExpr expr)
  | block(list[AQuestion] questions)
  | ifThen(AExpr expr, AQuestion question)
  | ifThenElse(AExpr expr, AQuestion question, AQuestion elseQuestion)
  ; 

data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  | aString(str string)
  | aInt(int integer)
  | aBool(bool boolean)
  | aBracket(AExpr expr)
  | not(AExpr expr)
  | mul(AExpr lexpr, AExpr rexpr)
  | div(AExpr lexpr, AExpr rexpr)
  | add(AExpr lexpr, AExpr rexpr)
  | sub(AExpr lexpr, AExpr rexpr)
  | less(AExpr lexpr, AExpr rexpr)
  | leq(AExpr lexpr, AExpr rexpr)
  | greater(AExpr lexpr, AExpr rexpr)
  | greq(AExpr lexpr, AExpr rexpr)
  | eq(AExpr lexpr, AExpr rexpr)
  | neq(AExpr lexpr, AExpr rexpr)
  | and(AExpr lexpr, AExpr rexpr)
  | or(AExpr lexpr, AExpr rexpr)
  ;


data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
  = string()
  | integer()
  | boolean()
  ;