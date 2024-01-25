module CST2AST

import Syntax;
import AST;
import String;
// import Exception;
import IO;
import ParseTree;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 *
 * - Use switch to do case distinction with concrete patterns (like in Hack your JS) 
 * - Map regular CST arguments (e.g., *, +, ?) to lists 
 *   (NB: you can iterate over * / + arguments using `<-` in comprehensions or for-loops).
 * - Map lexical nodes to Rascal primitive types (bool, int, str)
 * - See the ref example on how to obtain and propagate source locations.
 */

AForm cst2ast(start[Form] sf) {
  Form f = sf.top; // remove layout before and after form
  return form("<f.name>", [cst2ast(q) | Question q <- f.questions], src=f.src); 
}

default AQuestion cst2ast(Question q) {
  switch (q) {
    case (Question) `<Str s> <Id i> : <Type t>` : return question("<s>", id("<i>"), cst2ast(t));
    case (Question) `<Str s> <Id i> : <Type t> = <Expr e>` : return exprQuestion("<s>", id("<i>"), cst2ast(t), cst2ast(e));
    case (Question) `{<Question* questions>}` : return block([cst2ast(question) | Question question <- questions]);

    case (Question) `if (<Expr e>) <Question q> else <Question elseq>` : return ifThenElse(cst2ast(e), cst2ast(q), cst2ast(elseq));
    case (Question) `if (<Expr e>) <Question q>` : return ifThen(cst2ast(e), cst2ast(q));
  }

  throw "unhandled Question <q>";
}


bool toBool(str s) {
  if (s == "true") {
    return true;
  } else if (s == "false") {
    return false;
  }
  throw "failed toBool";
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(id("<x>"));
    case (Expr)`<Int n>`: return aInt(toInt("<n>"));
    case (Expr)`<Str s>`: return aString("<s>");
    case (Expr)`<Bool b>`: return aBool(toBool("<b>"));
    case (Expr)`(<Expr expr>)` : return aBracket(cst2ast(expr));
    case (Expr)`!<Expr expr>` : return not(cst2ast(expr));
    case (Expr)`<Expr lexpr> * <Expr rexpr>` : return mul(cst2ast(lexpr), cst2ast(rexpr));
    case (Expr)`<Expr lexpr> / <Expr rexpr>` : return div(cst2ast(lexpr), cst2ast(rexpr));
    case (Expr)`<Expr lexpr> + <Expr rexpr>` : return add(cst2ast(lexpr), cst2ast(rexpr));
    case (Expr)`<Expr lexpr> - <Expr rexpr>` : return sub(cst2ast(lexpr), cst2ast(rexpr));
    case (Expr)`<Expr lexpr> \< <Expr rexpr>` : return less(cst2ast(lexpr), cst2ast(rexpr));
    case (Expr)`<Expr lexpr> \<= <Expr rexpr>` : return leq(cst2ast(lexpr), cst2ast(rexpr));
    case (Expr)`<Expr lexpr> \> <Expr rexpr>` : return greater(cst2ast(lexpr), cst2ast(rexpr));
    case (Expr)`<Expr lexpr> \>= <Expr rexpr>` : return greq(cst2ast(lexpr), cst2ast(rexpr));
    case (Expr)`<Expr lexpr> == <Expr rexpr>` : return eq(cst2ast(lexpr), cst2ast(rexpr));
    case (Expr)`<Expr lexpr> != <Expr rexpr>` : return neq(cst2ast(lexpr), cst2ast(rexpr));
    case (Expr)`<Expr lexpr> && <Expr rexpr>` : return and(cst2ast(lexpr), cst2ast(rexpr));
    case (Expr)`<Expr lexpr> || <Expr rexpr>` : return or(cst2ast(lexpr), cst2ast(rexpr));

    default: throw "Unhandled expression: <e>";
  }
}

// AType cst2ast((Type)`<Str s>`) {
//   switch (s) {
//     case "integer" : return integer();
//     case "string" : return string();
//     case "boolean" : return boolean();
//   }
//   throw "Unhandled type: <s>";
// }
AType cst2ast(Type t) {
  switch (t) {
    case (Type)`integer` : return integer();
    case (Type)`string` : return string();
    case (Type)`boolean` : return boolean();
  }
  
  throw "Unhandled type: <t>";
}
