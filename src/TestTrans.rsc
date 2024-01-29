module TestTrans

import Syntax;
import ParseTree;
import AST;
import CST2AST;
import IO;
import Resolve;
import vis::Text; //prettyTree
import Transform;

public void runAllTests_Transform(){
    t = parse(#start[Form], readFile(|cwd:///examples/tests/flatten.myql|));
    ast = cst2ast(t);
    print(ast);
    AForm flat = flatten(ast);
    println(flat);
    printFlattened(flat);


    // t = parse(#start[Form], readFile(|cwd:///examples/tests/flatten.myql|));

    // a_loc_use = |unknown:///|(121,1,<11,7>,<11,8>);
    
    // print(prettyTree(t));

    // start[Form] renamed = rename(t, a_loc_use, "A", resolve(flat).useDef);

    // print(prettyTree(renamed));
}

void printFlattened(AForm flat){
    println();
    println("Flattened: ");
    for(ifThen(AExpr e, AQuestion q) <- flat.questions){
        switch(q) {
            // case ifThen(AExpr e, list[AQuestion] qs): {
            //     switch(qs[0]) {
            case question(str name, AId _, AType _): {
                println("Flat question id <name>: <e>");
                continue;
            }
            case exprQuestion(str name, AId _, AType _, AExpr _): {
                println("Flat calculatedQuestion id <name>: <e>");
                continue;
            }
            default: println("Unexpected question type, inner should be question");
        }
        // throw "Unexpected question type, inner should be question";
        //     }
        // }
    }
}


// public void testSimple(){
//     t = parse(#start[Form], readFile(|cwd:///examples/tests/flatten.myql|));
//     AForm flat = flatten(cst2ast(t));
//     a_loc_use = |unknown:///|(121,1,<11,7>,<11,8>);
//     start[Form] renamed = rename(t, a_loc_use, "A", resolve(flat).useDef);
//     print(prettyTree(renamed));
// }

