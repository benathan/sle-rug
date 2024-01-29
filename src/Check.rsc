//TODO: Integer --------Fixed
module Check

import AST;
import Resolve;
import Message; // see standard library

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str questionString, Type \type];

Type toType(AType t) {
  switch (t) {
    case integer() : return tint();
    case boolean() : return tbool();
    case string() : return tstr();
    default : return tunknown();
  }
}

// gets all the questions with their id, loc and type
// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
  TEnv env = {};

  for (/question(str questionString, id(str s), AType t, src = loc l) := f) {
    env += <l, s, questionString, toType(t)>;
  }

  for (/exprQuestion(str questionString, id(str s), AType t, AExpr _, src = loc l) := f) {
    env += <l, s, questionString, toType(t)>;
  }

  return env;
}

// start point for checking the whole form
set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  set[Message] result = {};

  for (/AQuestion question := f) {
    result += check(question, tenv, useDef);
  }

  for (/AExpr expr := f) {
    result += check(expr, tenv, useDef);
  }

  return result; 
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.
//TODO: return the location where error occurs
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
  set[Message] result = {};
  switch (q) {
    case question(str questionString, id(str st), AType t): 
      for (<loc l, str s, str questionStr, Type ty> <- tenv) {
        if (questionStr == questionString) {
          // same question twice
          result += {error("duplicate question")};
        }
        if (s == st && toType(t) != ty) {
          // same id, different type
          result += {error("question id with multiple types")};
        }
      }
  }

  return result;
}

// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case ref(AId x):
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };
    case aString(_):
      msgs += {};
    case aInt(_):
      msgs += {};
    case aBool(_):
      msgs += {};
    case not(_):
      msgs += {};
    case not(AExpr expr): {
      if (typeOf(expr, tenv, useDef) != tbool()) {
        msgs += { error("Operator not requires boolean operands", e.src) };
      }
    }
    case mul(AExpr lhs, AExpr rhs): {
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Multiplication requires integer operands", e.src) };
      }
    }
    case div(AExpr lhs, AExpr rhs): {
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Division requires integer operands", e.src) };
      }
    }
    case add(AExpr lhs, AExpr rhs): {
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Addition requires integer operands", e.src) };
      }
    }
    case sub(AExpr lhs, AExpr rhs): {
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Subtraction requires integer operands", e.src) };
      }
    }
    case less(AExpr lhs, AExpr rhs): {
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Operator \< requires integer operands", e.src) };
      }
    }
    case greater(AExpr lhs, AExpr rhs): {
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Operator \> requires integer operands", e.src) };
      }
    }
    case leq(AExpr lhs, AExpr rhs): {
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Operator \<= requires integer operands", e.src) };
      }
    }
    case greq(AExpr lhs, AExpr rhs): {
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Operator \>= requires integer operands", e.src) };
      }
    }
    case eq(AExpr lhs, AExpr rhs): {
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Operator == requires integer operands", e.src) };
      }
    }
    case neq(AExpr lhs, AExpr rhs): {
      if (typeOf(lhs, tenv, useDef) != tint() || typeOf(rhs, tenv, useDef) != tint()) {
        msgs += { error("Operator != requires integer operands", e.src) };
      }
    }
    case or(AExpr lhs, AExpr rhs): {
      if (typeOf(lhs, tenv, useDef) != tbool() || typeOf(rhs, tenv, useDef) != tbool()) {
        msgs += { error("Operator || requires boolean operands", e.src) };
      }
    }
    case and(AExpr lhs, AExpr rhs): {
      if (typeOf(lhs, tenv, useDef) != tbool() || typeOf(rhs, tenv, useDef) != tbool()) {
        msgs += { error("Operator && requires boolean operands", e.src) };
      }
    }
  }
  
  return msgs; 
}

// gives the return type of an expression
Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
        return t;
      }
    case aString(str _): return tstr();
    case aBool(bool _): return tbool();
    case aInt(int _): return tint();
    case not(AExpr _): return tbool();
    case add(AExpr _, AExpr _): return tint();
    case sub(AExpr _, AExpr _): return tint();
    case mul(AExpr _, AExpr _): return tint();
    case div(AExpr _, AExpr _): return tint();
    case greater(AExpr _, AExpr _): return tbool();
    case less(AExpr _, AExpr _): return tbool();
    case leq(AExpr _, AExpr _): return tbool();
    case greq(AExpr _, AExpr _): return tbool();
    case eq(AExpr _, AExpr _): return tbool();
    case neq(AExpr _, AExpr _): return tbool();
    case and(AExpr _, AExpr _): return tbool();
    case or(AExpr _, AExpr _): return tbool();
  }
  return tunknown(); 
}

/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(id(_, src = loc u)), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */
 
 

