@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::blockly::BlocklyDemo

import salix::App;
import salix::HTML;
import salix::Core;
import lang::xml::DOM;
import salix::lib::Blockly;
import IO;

// inits the app
SalixApp[Model] blocklyApp(str id = "blocklyDemo") = makeApp(id, init, view, update, parser = parseMsg);

// inits the app
App[Model] blocklyWebApp() 
  = webApp(
      blocklyApp(),
      index = |project://salix/src/salix/demo/blockly/index.html|, 
      static = |project://salix/src|
    ); 

// the model for the IDE.
alias Model = tuple[
  str src 
];
  
// init the IDE  
Model init() {
  Model model = <"">;
  
  // init the model with the doors state machine.
  model.src = workspace();
  return model;
}


// The doors state machine.
str workspace() = "Start using blockly and your code will be generated here!";


data Msg
  = blocklyChange(str text);

// update the model with from the msg.
Model update(Msg msg, Model model) {

  switch (msg) {
    // update from blockly
    case blocklyChange(str text): model.src = xmlPretty(parseXMLDOM(text));
    
  }
  
  return model;
}

// render the IDE.
void view(Model model) {
  div(() {
    div(class("row"), () {
      div(class("col-md-12"), () {
	      h3("Simple live Blockly IDE demo");
	    });
    });
    
    div(class("row"), () {
      div(class("col-md-8"), () {
        h4("Edit");

        blockly("myBlockly", onChange(Msg::blocklyChange), () {
        	category("Control", () {
        		block("if", \type("controls_if"), () {});
        		block("while", \type("controls_whileUntil"), disabled(true), () {});
        	});
        });
      });
        
      div(class("col-md-4"), () {
        h4("xml");
      	pre(class("prettyprint"), model.src);
      });
    });
  });
}
