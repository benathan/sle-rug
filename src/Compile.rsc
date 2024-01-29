//TODO: should use for loop instead of visit, complete the exercise
module Compile

import AST;
import Resolve;
import IO;
import lang::html::AST; // see standard library
import lang::html::IO;
import Boolean;
import util::Math;

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

  // HTMLElement scriptTag = script([], src=f.src[extension="js"].file);
  // htmlList += scriptTag;

  // test vue
  // HTMLElement checkbox = input(\type="checkbox");
  // checkbox.id = "test0";
  // htmlList += checkbox;

  // visit (f) {
  //   case AQuestion q: {
  //     htmlList += question2html(q);
  //   }
  // }
  list[HTMLElement] questions = [];
  for(AQuestion q <- f.questions) {
    questions += question2html(q);
  }

  // return body([script([], src="https://unpkg.com/vue@3/dist/vue.global.js"),form([div(htmlList)]), script([], src="tax.js")]);
  return body([div([script([], src="https://unpkg.com/vue@3/dist/vue.global.js"), form([div(htmlList)]), script([], src="tax.js")], \id="app")]);
}


HTMLElement question2html(AQuestion q) {
  list[HTMLElement] htmlList = [];
  
  switch (q) {
    case question(str questionString, id(str i), AType t): {
      htmlList += p([text(questionString)]);
      htmlList += option2html(t, i);
    }
    case exprQuestion(str questionString, AId id, AType t, AExpr expr): {
      htmlList += p([text(questionString)]);
      // is calculated
      // htmlList += option2html(t);
    }
    case block(list[AQuestion] questions): {
      list[HTMLElement] blockList = [];
      for (AQuestion question <- questions) {
        blockList += question2html(question);
      }
      htmlList += div(blockList);
    }
    case ifThen(AExpr expr, AQuestion question): {
      class = "ifThen";
      id = "ifelse<1>";
      list[HTMLElement] ifQ = [];
      for (AQuestion q <- question) ifQ += question2html(q);
      htmlList += div(ifQ, class="if <id>");
    }
    case ifThenElse(AExpr expr, AQuestion question, AQuestion elseQuestion): {
      class = "ifThenElse";
      id = "ifThenElse<1>";
      list[HTMLElement] ifQ = [];
      list[HTMLElement] elseQ = [];
      for (AQuestion q <- question) ifQ += question2html(q);
      for (AQuestion q <- elseQuestion) elseQ += question2html(q);
      htmlList += div(ifQ, class="if <id>");
      htmlList += div(elseQ, class="else <id>");
    }
  }
  return htmlList;
  // return [label([q], \for=q.id), div(htmlList)];
}


HTMLElement option2html(AType t, str i) {
  switch (t) {
    case boolean(): {
      HTMLElement checkbox = input();
      checkbox.\type = "checkbox";
      checkbox.\id = i;
      return checkbox;
    }
    case string(): {
      HTMLElement textfield = input();
      textfield.\type = "text";
      textfield.\id = i;
      return textfield;
    }
    case integer(): {
      HTMLElement numericTextfield = input();
      numericTextfield.\type = "number";
      numericTextfield.\id = i;
      return numericTextfield;
    }
  }
  throw "html option not found";
}


str form2js(AForm f) {
  str jsList = "";

  jsList += "import Vue from \'vue\';\n";
  
  jsList += "var app = new Vue({";
  jsList += "  el: \'#app\',";
  jsList += "  data: { \n";
  

  visit (f) {
    case AQuestion q: {
      jsList += question2js(q);
      jsList += "\n";
    }
  }
  
  jsList += "}";
  
  jsList += "}).mount(\'#app\')";

  return jsList;
}

str question2js(AQuestion q) {
  str jsList = "";
  
  switch (q) {
    case question(str questionString, AId id, AType t): {
      // Add a data property for each question
      jsList += "    " + id.name + ": ";
      jsList += (t == boolean() ? "false" : (t == string() ? "" : "0")) + ",";
    }
    // case exprQuestion(str questionString, AId id, AType t, AExpr expr): {
    // }
    case block(list[AQuestion] questions): {
      for (AQuestion question <- questions) {
        jsList += question2js(question);
      }
    }
    case ifThen(AExpr expr, AQuestion question): {
       jsList += question2js(question);
    }
    case ifThenElse(AExpr expr, AQuestion question, AQuestion elseQuestion): {
       jsList += question2js(question);
    }
  }

  return jsList;
}