module Resolve

import AST;

/*
 * Name resolution for QL
 */ 


// modeling declaring occurrences of names
// Name and location of the declaration
alias Def = rel[str name, loc def];

// modeling use occurrences of names
// Location of where is it used, and the name
alias Use = rel[loc use, str name];

// Location of where is it used, and the location of the declaration
alias UseDef = rel[loc use, loc def];

// the reference graph
alias RefGraph = tuple[
  Use uses, 
  Def defs, 
  UseDef useDef
]; 

RefGraph resolve(AForm f) = <us, ds, us o ds>
  when Use us := uses(f), Def ds := defs(f);



//// These functions might be wrong
//// TODO: test if correct

Use uses(AForm f) {
  Use result = {};

  for (/ref(AId i) := f) {
    result += {<i.src, i.name>};
  }
  return result; 
}

Def defs(AForm f) {
  Def result = {};

  for (/question(str _, AId i, AType _) := f) {
    result = result + {<i.name, i.src>};
  }

  for (/exprQuestion(str _, AId i, AType _, AExpr _) := f) {
    result = result + {<i.name, i.src>};
  }

  return result; 
}