module TestCompile
import Syntax;
import ParseTree;
import AST;
import CST2AST;
import Resolve;
import Compile;

public void runAllTests_Compile(){
    testCompile(|project://sle-rug/examples/tax.myql|);
}

public void testCompile(loc input){
    Tree parsed = parse(#start[Form], input);
    AForm f = cst2ast(parsed);
    compile(f);
}
