module salix::lib::Blockly

import salix::Node;
import salix::Core;


Attr onChange(Msg(str) msg) = event("change", handler("blocklyChange", encode(msg)));

Msg parseMsg(str id, "blocklyChange", Handle h, map[str, str] p) 
 = applyMaps(id, h, decode(id, h.id, #Msg(str))(p["msg"]));

void blockly(str id, value vals...)
  = build(vals, Node(list[Node] _, list[Attr] attrs){
      return native("blockly", id, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
  });
  
  
Attr toolbox(str toolbox) = prop("toolbox", toolbox);