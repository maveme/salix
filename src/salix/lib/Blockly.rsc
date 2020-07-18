module salix::lib::Blockly

import salix::Node;
import salix::Core;

void blockly(str id, value vals...)
  = build(vals, Node(list[Node] _, list[Attr] attrs){
      return native("blockly", id, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
  });