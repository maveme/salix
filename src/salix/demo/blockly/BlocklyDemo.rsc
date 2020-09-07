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
        	category("Control", hue(90), () {
        		block(
        			"if", 
        			\type("controls_if"),
        			hue(90), 
        			nextStatement(""),
        			previousStatement(""),
					() {
						message("if %1 then", () {
							inputValue("CONDITION", check = ["Boolean"]);
						});
						message("%1", () {
							inputStatement("THEN");
        				});
        			}
        		);
        		block(
        			"omni-block",
        			\type("oni_block"),
        			hue(90),
        			() {
        				message("input value: %1", (){inputValue("VALUE");}); 
        				message("input statement: %1", (){inputStatement("STATEMENT");}); 
        				message("input dummy: %1", (){inputDummy();}); 
        				message("field input: %1", (){fieldInput("INPUT", text="cake", spellcheck=true);}); 
        				//message("field dropdown: %1", (){fieldDropdown("DROP", [item("cale","cale")]);}); // BROKEN 
        				message("field checkbox: %1", (){fieldCheckbox("CHECKBOX", checked=true);}); 
        				message("field color: %1", (){fieldColor("COLOR", color="#ff4040", colorOptions=["#ff4040", "#4040ff"], colorTitles=["dark pink", "dark blue"],columns=0);}); 
        				message("field number: %1", (){fieldNumber("NUMBER", val=7.0, min=0, max=28, precision=2);});
        				message("field angle: %1", (){fieldAngle("ANGLE", angle=90);});
        				message("field variable: %1", (){fieldVariable("VARIABLE");});
        				//message("date input: %1", (){fieldDate("DATE");});// BROKEN; Not part of blockly anymore?!
        				message("field label: %1", (){fieldLabel("Label example");});
        				message("field serializable label: %1", (){fieldLabelSerializable("Label", "sLabel example");});
        				message("field image: %1", (){fieldImage("https://developers.google.com/blockly/images/logos/logo_built_on.png", 496, 179, alt="built on blockly");});
        			}
				);
        	});
        	category("Logic", hue(180), () {
        		block(
        			"equals",
        			\type("logic_equals"),
        			hue(180),
        			output("Boolean"),
        			inputsInline(true),
        			() {
        				message("%1 == %2", () {
        					inputValue("A");
        					inputValue("B");
        				});
        			}
        		);
        		block(
        			"true",
        			\type("logic_true"),
        			hue(180),
        			output("Boolean"),
        			() {
        				message("true");
        			}
        		);
        	});
        	category("Math", hue(270), () {
        		block(
        			"add",
        			\type("math_addition"),
        			hue(270),
        			output("Number"),
        			inputsInline(true),
        			() {
        				message("%1 + %2", () {
        					inputValue("A", check=["Number"]);
        					inputValue("B", check=["Number"]);
        				});
        			}
        		);
        		block(
        			"Number",
        			\type("math_number"),
        			hue(270),
        			output("Number"),
        			() {
        				message("%1", (){
        					fieldNumber("VALUE");
        				});
        			}
        		);
        		
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
