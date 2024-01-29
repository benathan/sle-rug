module Transform

import Syntax;
import Resolve;
import AST;

import IO;


/* 
 * Transforming QL forms
 */
 
 
/* Normalization:
 *  wrt to the semantics of QL the following
 *     q0: "" int; 
 *     if (a) { 
 *        if (b) { 
 *          q1: "" int; 
 *        } 
 *        q2: "" int; 
 *      }
 *
 *  is equivalent to
 *     if (true) q0: "" int;
 *     if (true && a && b) q1: "" int;
 *     if (true && a) q2: "" int;
 *
 * Write a transformation that performs this flattening transformation.
 *
 */
 
AForm flatten(form(str name, list[AQuestion] questions)) {
  list[AQuestion] flattened = [];
  for (AQuestion question <- questions) {
    flattened += flattenQuestion(question);
  }

  return form(name, flattened);
}

list[AQuestion] flattenQuestion(AQuestion ques) {
  switch (ques) {
    // starts with if true: question
    case question(str _, AId _, AType _): {
      return [ifThen(aBool(true), ques)];
    }
    case exprQuestion(str _, AId _, AType _, AExpr _): {
      return [ifThen(aBool(true), ques)];
    }
    case block(list[AQuestion] questions): {
      list[AQuestion] flatQuestions = [];
      for (questionInBlock <- questions) {
        for (flattenedQuestion <- flattenQuestion(questionInBlock)) {
          flatQuestions += flattenedQuestion;
        }
      }
      return flatQuestions;
    }
    case ifThen(AExpr expr, AQuestion ques): {
      list[AQuestion] flatQuestions = [];
      for (ifThen(AExpr e, AQuestion q) <- flattenQuestion(ques)) {
        // removing some unnecessary conditions
        if (e == aBool(true)) {
          flatQuestions += ifThen(expr, q);
        } else if (expr == aBool(true)) {
          flatQuestions += ifThen(e, q);
        } else if (expr == e) {
          flatQuestions += ifThen(expr, q);
        } else {
          flatQuestions += ifThen(and(expr, e), q);
        }
      }
      return flatQuestions;
    }
    case ifThenElse(AExpr expr, AQuestion question0, AQuestion question1): {
      // make ifThen questions from ifThenElse questions
      return flattenQuestion(ifThen(expr, question0)) + flattenQuestion(ifThen(not(expr), question1));
    }
  }
      
  throw "question did not match";
}

// list[AQuestion] flattenIfThen(ifThen(AExpr expr, AQuestion ques)) {
//     println("q: ");
//     println(q);
//     switch (q) {
//       case question(str s, AId _, AType _): {
//         println("ifthen-question " + s);
//         flatQuestions += ifThen(expr, q);
//       }
//       case exprQuestion(str s, AId _, AType _, AExpr _): {
//         println("ifthen-exprquestion " + s);
//         flatQuestions += ifThen(expr, q);
//       }
//       case block(list[AQuestion] _): {
//         println("ifthen-block");
//         for (AQuestion newquestion <- flattenQuestion(q)) {
//           flatQuestions += ifThen(expr, newquestion);
//         }
//       }
//       case ifThen(AExpr e, AQuestion ques): {
//         println("ifthen-ifthen ");

//         for (AQuestion newquestion <- flattenQuestion(ques)) {
//           // flatQuestions += ifThen(and(expr, e), newquestion);
//           switch (newquestion) {
//             case question(str s, AId i, AType t): {
//               flatQuestions += ifThen(and(expr, e), question(s, i, t));
//             }
//             case exprQuestion(str s, AId i, AType t, AExpr ex): {
//               flatQuestions += ifThen(and(expr, e), exprQuestion(s, i, t, ex));
//             }
//             case ifThen(AExpr expr, AQuestion question): {
//               for (AQuestion qu <- flattenQuestion(question)) {
//                 flatQuestions += ifThen(and(expr, e), qu);
//               }
//             }
//             default: {
//               println(newquestion);
//               throw "question didn\'t match";
//             }
//           }
//         }
//       }
//       case ifThenElse(AExpr e, AQuestion q0, AQuestion q1): {
//         println("ifthen-ifthenelse ");
//         // make ifThen questions from ifThenElse questions
//         for (AQuestion newq0 <- flattenQuestion(q0)) {
//           flatQuestions += ifThen(and(expr, e), newq0);
//         }
//         for (newq1 <- flattenQuestion(q1)) {
//           flatQuestions += ifThen(not(and(expr, e)), newq1);
//         }
//       }
//       default: throw "ifthen question did not match";
//     }
//   }
//   return flatQuestions;
// }

/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 */

 
 
//  start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
//   set[loc] equivClass = {};
//   if (useOrDef in useDef<1>) {
//     equivClass += useOrDef;
//     equivClass += {useLoc | <loc useLoc, useOrDef> <- useDef};
//   } else if (useOrDef in useDef<0>) {
//     if (<useOrDef, loc defLoc> <- useDef) {
//       equivClass += defLoc;
//       equivClass += {useLoc | <loc useLoc, defLoc> <- useDef};
//     }
//   } else {
//     return f;
//   }

//   return visit (f) {
//     case Id x => [Id]newName
//       when x.src in equivClass
//   } 
// } 

start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
  set[loc] equivClass = { useOrDef };

  if(useOrDef in useDef<1>) {
    equivClass += { useLoc | <loc useLoc, useOrDef> <- useDef };
  } else {  
    if( <useOrDef, loc defLoc> <- useDef) {
    equivClass += defLoc;
    equivClass += { useLoc | <loc useLoc, defLoc> <- useDef };
  }
  }

  updatedTree = visit(f) {
    case Id x => [Id] newName
      when x.src in equivClass
  }
  
  return updatedTree; 
} 
 