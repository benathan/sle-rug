module Test

import Syntax;
import ParseTree;
import AST;
import CST2AST;
import IO;
import Check;
import Resolve;
import vis::Text;
import Eval;
import Compile;

public void cTest(){
    println("TEST");
    Tree parsed = parse(#start[Form], readFile(|project://sle-rug/examples/tax.myql|));
    println("TEST");
    AForm f = cst2ast(parsed);
    compile(f);
    
}

// public void rTest(){
//     println("TEST");
//     VEnv res = testEval(readFile(|project://sle-rug/examples/tax.myql|));
//     println(res);
// }

// public VEnv testEval(str input_str_ql){
//     Tree parsed = parse(#start[Form], input_str_ql);
//     AForm ast = cst2ast(parsed);
//     RefGraph g = resolve(ast);
//     TEnv tenv = collect(ast);
//     set[Message] msgs = check(ast, tenv, g.useDef);

//     VEnv env = initialEnv(ast);
//     println(env);
//     env = eval(ast, input("Did you buy a house in 2010?", vbool(true)), env);
    
//     println("post-eval");

//     return env;
// }


// public void testGetInitialEnv() {
//   str input = readFile(|project://sle-rug/examples/tax.myql|);
//   Tree parsed = parse(#start[Form], input);
//   AForm ast = cst2ast(parsed);

//   VEnv env = initialEnv(ast);

//   println(env);
// }
