module Eval

import AST;
import Resolve;

import Syntax;
import CST2AST;
import IO;

/*
 * Implement big-step semantics for QL
 */
 
// NB: Eval may assume the form is type- and name-correct.


// Semantic domain for expressions (values)
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

// The value environment
alias VEnv = map[str name, Value \value];

// Modeling user input
data Input = input(str question, Value \value);
  
// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)
VEnv initialEnv(AForm f) {
  VEnv venv = ();

  for (/question(str _, AId i, AType t) := f) {
    venv["<i.name>"] = defaultValue(t);
  }

  for (/exprQuestion(str _, AId i, AType t, AExpr _) := f) {
    venv["<i.name>"] = defaultValue(t);
  }

  return venv;
}


Value defaultValue(AType t) {
  switch (t) {
    case integer(): return vint(0);
    case boolean(): return vbool(false);
    case string(): return vstr("");
  }
  return vint(0);
}


// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  visit (f) {
    case AQuestion q: {
      venv = eval(q, inp, venv);
    }
  }

  return venv;
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {
  switch (q) {
    case question(str questionString, AId i, AType _): {
      // remove quotations
      if (questionString[1..-1] == inp.question) {
        // set value according to input
        venv[i.name] = inp.\value;
      }
    }
    case exprQuestion(str _, AId i, AType _, AExpr expr): {
      venv[i.name] = eval(expr, venv);
    }
    case block(list[AQuestion] questions): {
      for (AQuestion q <- questions) {
        eval(q, inp, venv); 
      }
    }
    case ifThen(AExpr expr, AQuestion question): {
      if (eval(expr, venv) == vbool(true)) {
        eval(question, inp, venv); 
      }
    }
    case ifThenElse(AExpr expr, AQuestion question, AQuestion elseQuestion): {
      if (eval(expr, venv) == vbool(true)) {
        eval(question, inp, venv); 
      } else {
        eval(elseQuestion, inp, venv); 
      }
    }
  }
  return venv;
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(id(str x)): return venv[x];
    case aInt(int n): return vint(n);
    case aBool(bool b): return vbool(b);
    case aString(str s): return vstr(s);
    case aBracket(AExpr expr): return eval(expr, venv);
    case add(AExpr lexpr, AExpr rexpr): return vint(eval(lexpr, venv).n + eval(rexpr, venv).n);
    case sub(AExpr lexpr, AExpr rexpr): return vint(eval(lexpr, venv).n - eval(rexpr, venv).n);
    case mul(AExpr lexpr, AExpr rexpr): return vint(eval(lexpr, venv).n * eval(rexpr, venv).n);
    case div(AExpr lexpr, AExpr rexpr): return vint(eval(lexpr, venv).n / eval(rexpr, venv).n);
    case greater(AExpr lexpr, AExpr rexpr): return vbool(eval(lexpr, venv).b > eval(rexpr, venv).b);
    case greq(AExpr lexpr, AExpr rexpr): return vbool(eval(lexpr, venv).b >= eval(rexpr, venv).b);
    case less(AExpr lexpr, AExpr rexpr): return vbool(eval(lexpr, venv).b < eval(rexpr, venv).b);
    case leq(AExpr lexpr, AExpr rexpr): return vbool(eval(lexpr, venv).b <= eval(rexpr, venv).b);
    case and(AExpr lexpr, AExpr rexpr): return vbool(eval(lexpr, venv).b > eval(rexpr, venv).b);
    case or(AExpr lexpr, AExpr rexpr): return vbool(eval(lexpr, venv).b || eval(rexpr, venv).b);
    case eq(AExpr lexpr, AExpr rexpr): return vbool(eval(lexpr, venv).b == eval(rexpr, venv).b);
    case neq(AExpr lexpr, AExpr rexpr): return vbool(eval(lexpr, venv).b != eval(rexpr, venv).b);
    case not(AExpr expr): return vbool(!eval(expr, venv).b);

    default: throw "Unsupported expression <e>";
  }
}