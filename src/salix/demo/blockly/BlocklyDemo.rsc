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
import salix::Node;
import salix::Core;
import salix::lib::Blockly;
import salix::lib::BlocklyToolbox;
import lang::xml::DOM;
import String;
import List;

// inits the app
SalixApp[BlocklyModel] blocklyApp(str id = "blocklyDemo") = makeApp(id, blocklyInit, blocklyView, blocklyUpdate);

// inits the app
App[BlocklyModel] blocklyWebApp() 
  = webApp(
      blocklyApp(),
      index = |project://salix/src/salix/demo/blockly/index.html|, 
      static = |project://salix/src|
    ); 

// the model for the IDE.
alias BlocklyModel = tuple[
  str src 
];
  
// init the IDE  
BlocklyModel blocklyInit() {
  BlocklyModel model = <"">;
  
  // init the model with the doors state machine.
  model.src = workspace();
  return model;
}


// The doors state machine.
str workspace() = "Start using blockly and your code will be generated here!";

str toolboxXML = xmlPretty(toolbox([
					category("Control", [
						block("controls_if"),
						block("controls_whileUntil"),
						block("controls_for")
					]),
					category("Logic", [
						block("logic_compare"),
						block("logic_operation"),
						block("logic_boolean")
					]),
					category("Math", [
						block("math_number"),
						block("math_arithmetic", [
							field("OP", "add"),
							\value("A", [
								shadow("math_number", [
									field("NUM", 1)
								])
							]),
							\value("B", [
								shadow("math_number", [
									field("NUM", 1)
								])
							])
						])
					])	
				]));

data Msg
  = blocklyChange(str text);

// update the model with from the msg.
BlocklyModel blocklyUpdate(Msg msg, BlocklyModel model) {

  switch (msg) {
    // update from blockly
    case blocklyChange(str text): model.src = xmlPretty(parseXMLDOM(text));
    
  }
  
  return model;
}

// render the IDE.
void blocklyView(BlocklyModel model) {
  div(() {
    div(class("row"), () {
      div(class("col-md-12"), () {
	      h3("Simple live Blockly IDE demo");
	    });
    });
    
    div(class("row"), () {
      div(class("col-md-8"), () {
        h4("Edit");

        blockly("myBlockly", onChange(Msg::blocklyChange), toolbox(xmlPretty(toolbox([
					category("Control", [
						block("controls_if"),
						block("controls_whileUntil"),
						block("controls_for")
					]),
					category("Logic", [
						block("logic_compare"),
						block("logic_operation"),
						block("logic_boolean")
					]),
					category("Math", [
						block("math_number"),
						block("math_arithmetic", [
							field("OP", "add"),
							\value("A", [
								shadow("math_number", [
									field("NUM", 1)
								])
							]),
							\value("B", [
								shadow("math_number", [
									field("NUM", 1)
								])
							])
						])
					])	
				]))));
      });
        
      div(class("col-md-4"), () {
        h4("xml");
      	pre(class("prettyprint"), model.src);
      });
    });
  });
}
