@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::blockly::IDE

import salix::App;
import salix::HTML;
import salix::Node;
import salix::Core;
import salix::demo::ide::StateMachine;
import salix::lib::CodeMirror;
import salix::lib::XTerm;
import salix::lib::Mode;
import salix::lib::REPL;
import salix::lib::Charts;
import salix::lib::UML;
import salix::lib::Blockly;
import salix::lib::Dagre;
import util::Maybe;
import ParseTree;
import String;
import List;
import IO; 

// inits the app
SalixApp[IDEModel] ideApp(str id = "ideDemo") = makeApp(id, ideInit, ideView, ideUpdate, parser = parseMsg);

// inits the app
App[IDEModel] ideWebApp() 
  = webApp(
      ideApp(),
      index = |project://salix/src/salix/demo/blockly/index.html|, 
      static = |project://salix/src|
    ); 

// the model for the IDE.
alias IDEModel = tuple[
  str src, 
  Maybe[start[Controller]] lastParse,
  Maybe[str] currentState,
  list[str] output,
  str currentCommand,
  Mode mode, // put it here, so not regenerated at every click..
  REPLModel repl,
  map[str, int] visitCount
];
  
// maybe parse the state machine.
Maybe[start[Controller]] maybeParse(str src) {
  try {
    return just(parse(#start[Controller], src));
  }
  catch ParseError(loc _): {
    return nothing();
  }
}

// init the IDE  
IDEModel ideInit() {
  replModel = mapCmds(replMsg, REPLModel() { return initRepl("myXterm", "$ "); });
  
  Mode stmMode = grammar2mode("statemachine", #Controller);
 
  IDEModel model = <"", nothing(), nothing(), [], "", stmMode, replModel, ()>;
  
  // init the model with the doors state machine.
  model.src = doors();
  model.lastParse = maybeParse(model.src);
  
  
  if (just(start[Controller] ctl) := model.lastParse) {
    if (salix::demo::ide::StateMachine::State s <- ctl.top.states) {
      model.currentState = just("<s.name>");
    }
  }  
 
  return model;
}

// create the plantuml
str ctl2plantuml(start[Controller] ctl, Maybe[str] currentState) {
  list[str] states = [ "<s.name>" | salix::demo::ide::StateMachine::State s <- ctl.top.states ];
  
  list[str] trans = [ "<s.name> --\> <t.state> : <t.event>" |
     salix::demo::ide::StateMachine::State s <- ctl.top.states,
     Transition t <- s.transitions ];
     
  bool isActive(str s) = s == cur
    when just(str cur) := currentState;
  
  return 
    "@startuml
    '<intercalate("\n", [ "<s> : <isActive(s) ? "active" :"">" | s <- states ])>
    '[*] -\> <states[0]>
    '<intercalate("\n", trans)>
    '@enduml";
}

// 
list[str] stmComplete(IDEModel model, str prefix) {
  list[str] cs = [];
  if (just(start[Controller] ctl) := model.lastParse) {
    if (/<word:[a-zA-Z0-9_]+>$/ := prefix) {
      for (salix::demo::ide::StateMachine::State s <- ctl.top.states, startsWith("<s.name>", word)) {
        cs += ["<prefix[0..size(prefix) - size(word)]><s.name>"];
      }
      for (/salix::demo::ide::StateMachine::Event e := ctl, startsWith("<e.name>", word)) {
        cs += ["<prefix[0..size(prefix) - size(word)]><e.name>"];
      }
    }
  }
  return cs + [prefix];
}

Maybe[str] stmHighlight(str x) {
  if (/goto <rest:.*>/ := x) {
    return just("\u001B[1;35mgoto\u001B[0m <rest>");
  }
  if (/event <rest:.*>/ := x) {
    return just("\u001B[1;35mevent\u001B[0m <rest>");
  }
  else {
    return nothing();
  }
}

// The doors state machine.
str doors() = 
    "events
    '  open OPEN
    '  close CLOSE
    'end
    '
    'state closed
    '  open =\> opened
    'end
    '
    'state opened
    '  close =\> closed
    'end";

data Msg
  = stmChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed)
  | fireEvent(str name)
  | gotoState(str name)
  | replMsg(Msg msg)
  | noOp()
  ;

// Evaluate a command given in the XTerm section.
tuple[Msg, str] myEval(str command) {
  if (/event <event:.*>/ := command) {
    return <fireEvent(event), "ok">;
  }
  if (/goto <state:.*>/ := command) {
    return <gotoState(state), "ok">;
  }
  return <noOp(), "Not a command \"<command>\", try \"event \<eventName\>\", or \"goto \<stateName\>\"">;
}


alias Next = tuple[Maybe[str] token, Maybe[str] state];

// 
Next transition(str currentState, str event, start[Controller] ctl) {
  Next result = <nothing(), nothing()>;
  println("transition: <currentState> (<event>)");
  if (salix::demo::ide::StateMachine::State s <- ctl.top.states, "<s.name>" == currentState) { 
    if (Transition t <- s.transitions, "<t.event>" == event) {
      result.state = just("<t.state>");
      if (just(Event e) := lookupEvent(ctl, event)) {
        result.token = just("<e.token>");
      }
    }
  }
  
  return result;
} 

// update the model with from the msg.
IDEModel ideUpdate(Msg msg, IDEModel model) {

  list[str] myComplete(str prefix) = stmComplete(model, prefix);
  
  void doTransition(str event) {
    println("do trans <event>");
    if (just(start[Controller] ctl) := model.lastParse) {
       println("ctl <ctl>");
      if (just(str current) := model.currentState) {
         println("cur <current>");
        Next nxt = transition(current, event, ctl);
        if (just(str nextState) := nxt.state) {
          model.visitCount[nextState]?0 += 1;
          model.currentState = just(nextState);
        }
        if (just(str token) := nxt.token) {
          model.output += [token];
          do(write(noOp(), model.repl.id, "\b\b\u001B[31m<token>\u001B[0m\r\n<model.repl.prompt>"));
        }
      }
    }
  }
  
  switch (msg) {
  	// If the msg updates the state machine. (change to CodeMirror).
    case stmChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed): { 
      model.src = updateSrc(model.src, fromLine, fromCol, toLine, toCol, text, removed);
      if (just(start[Controller] ctl) := maybeParse(model.src)) {
        model.lastParse = just(ctl);
        if (staleCurrentState(ctl, model)) {
          model.currentState = initialState(ctl);
        }
      }  
    }
    
    // If the message is a goto state. 
    case replMsg(parent(gotoState(str state))): {
       if (just(start[Controller] ctl) := model.lastParse) {
         if (salix::demo::ide::StateMachine::State s <- ctl.top.states, "<s.name>" == state) {
           model.visitCount["<s.name>"]?0 += 1;
           model.currentState = just("<s.name>");
         } 
       }
     }
    // If the message is a fire event.
    case replMsg(parent(fireEvent(str event))): 
      doTransition(event);
      
    case fireEvent(str event): 
      doTransition(event);

	// ?
    case replMsg(Msg sub): 
      model.repl = mapCmds(replMsg, sub, model.repl, replUpdate(myEval, myComplete, stmHighlight));
  }
  
  return model;
}

// ?
list[str] mySplit(str sep, str s) {
  if (/^<before:.*?><sep>/m := s) {
    return [before] + mySplit(sep, s[size(before) + size(sep)..]);
  }
  return [s];
}

// update the state machine src.
str updateSrc(str src, int fromLine, int fromCol, int _, int _, str text, str removed) {
  list[str] lines = mySplit("\n", src);
  int from = ( 0 | it + size(l) + 1 | str l <- lines[..fromLine] ) + fromCol;
  int to = from + size(removed);
  str newSrc = src[..from] + text + src[to..];
  return newSrc;  
}

// get the initial state of the machine.
Maybe[str] initialState(start[Controller] ctl) {
  if (salix::demo::ide::StateMachine::State s <- ctl.top.states) {
	  return just("<s.name>");
  }
  return nothing();
}
 
 // get the current state of the machine.
Maybe[salix::demo::ide::StateMachine::State] lookupCurrentState(start[Controller] ctl, IDEModel model) {
  if (salix::demo::ide::StateMachine::State s <- ctl.top.states, isCurrentState(s, model)) {
    return just(s);
  }
  return nothing();
}
 
 //get an event my name.
Maybe[Event] lookupEvent(start[Controller] ctl, str event) {
  if (/Event e := ctl, event == "<e.name>") {
    return just(e);
  }
  return nothing();
} 
 
 // ?
bool staleCurrentState(start[Controller] ctl, IDEModel model) 
  = !any(salix::demo::ide::StateMachine::State s <- ctl.top.states, isCurrentState(s, model));
 
 // is the current state equal
bool isCurrentState(salix::demo::ide::StateMachine::State s, IDEModel model)
  = just(str current) := model.currentState && current == "<s.name>";

// render the IDE.
void ideView(IDEModel model) {
  div(() {
    div(class("row"), () {
      div(class("col-md-12"), () {
	      h3("Simple live Blockly IDE demo");
	    });
    });
    
    div(class("row"), () {
      div(class("col-md-6"), () {
        h4("Edit");
        blockly("myBlockly");
      });
        
      div(class("col-md-3"), () {
        h4("Raw");
      	text(model.src);
      });
      
      div(class("col-md-3"), () {
        h4("Command line");
        repl(replMsg, model.repl, model.repl.id, cursorBlink(true), cols(30), rows(10));
	  });
   });
  });
}
