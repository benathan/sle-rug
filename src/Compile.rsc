module Compile

import AST;
import Resolve;
import IO;
import lang::html::AST; // see standard library
import lang::html::IO;

/*
 * Implement a compiler for QL to HTML and Javascript
 *
 * - assume the form is type- and name-correct
 * - separate the compiler in two parts form2html and form2js producing 2 files
 * - use string templates to generate Javascript
 * - use the HTMLElement type and the `str writeHTMLString(HTMLElement x)` function to format to string
 * - use any client web framework (e.g. Vue, React, jQuery, whatever) you like for event handling
 * - map booleans to checkboxes, strings to textfields, ints to numeric text fields
 * - be sure to generate uneditable widgets for computed questions!
 * - if needed, use the name analysis to link uses to definitions
 */

void compile(AForm f) {
  writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(f.src[extension="html"].top, writeHTMLString(form2html(f)));
}

// Booleans -> checkboxes
// Strings -> textfields
// Integers -> numeric text fields
HTMLElement form2html(AForm f) {
  list[HTMLElement] htmlList = [];
  // str name = f.name;

  visit (f) {
    case AQuestion q: {
      htmlList += question2html(q);
    }
  }

  return body(htmlList);
}


list[HTMLElement] question2html(AQuestion q) {
  list[HTMLElement] htmlList = [];
  
  switch (q) {
    case question(str questionString, AId id, AType t): {
      htmlList += p([text(questionString)]);
      htmlList += option2html(t);
    }
    case exprQuestion(str questionString, AId id, AType t, AExpr expr): {
      htmlList += p([text(questionString)]);
      // is calculated
      // htmlList += option2html(t);
    }
    case block(list[AQuestion] questions): {
      for (AQuestion question <- questions) {
        htmlList += question2html(question);
      }
    }
    // case ifThen(AExpr expr, AQuestion question)
    // case ifThenElse(AExpr expr, AQuestion question, AQuestion elseQuestion)
  }

  return htmlList;
}


HTMLElement option2html(AType t) {
  switch (t) {
    case boolean(): {
      HTMLElement checkbox = input();
      checkbox.\type = "checkbox";
      return checkbox;
    }
    case string(): {
      HTMLElement textfield = input();
      textfield.\type = "text";
      return textfield;
    }
    case integer(): {
      HTMLElement numericTextfield = input();
      numericTextfield.\type = "number";
      return numericTextfield;
    }
  }
  throw "html option not found";
}


str form2js(AForm f) {
  return "";
}
