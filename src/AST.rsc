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
	  = question(str label, AId id, AType typ)
	  | computedQuestion(str label, AId id, AType typ, AExpr expr)
	  | ifBlock(AExpr expr, list[AQuestion] questions)
	  | ifElse(AExpr expr, list[AQuestion] questionsIf, list[AQuestion] questionsElse)
  ;

data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  | intLit(int integer)
  | strLit(str string)
  | boolLit(bool boolean)
  | add(AExpr left, AExpr right)
  | sub(AExpr left, AExpr right)
  | mul(AExpr left, AExpr right)
  | div(AExpr left, AExpr right)
  | not(AExpr expr)
  | and(AExpr left, AExpr right)
  | or(AExpr left, AExpr right)
  | equal(AExpr left, AExpr right)
  | neq(AExpr left, AExpr right)
  | lt(AExpr left, AExpr right)
  | lte(AExpr left, AExpr right)
  | gt(AExpr left, AExpr right)
  | gte(AExpr left, AExpr right)
  ;



data AId(loc src = |tmp:///|)
  = id(str name);

data AType(loc src = |tmp:///|)
  = integer()
  | string()
  | boolean()
  ;