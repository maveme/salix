module salix::lib::Blockly

import salix::Node;
import salix::Core;


Attr onChange(Msg(str) msg) = event("change", handler("blocklyChange", encode(msg)));

Msg parseMsg(str id, "blocklyChange", Handle h, map[str, str] p) 
 = applyMaps(id, h, decode(id, h.id, #Msg(str))(p["msg"]));

Attr toolbox(str toolbox) = prop("toolbox", "<toolbox>");

Attr resizable(bool val) = prop("resizable", "<val>");
Attr width(str val) = prop("width", "<val>");
Attr height(str val) = prop("height", "<val>");


// Blockly injection options. See: https://developers.google.com/blockly/guides/configure/web/configuration_struct
Attr collapse(bool val) = prop("collapse", "<val>");
Attr comments(bool val) = prop("comments", "<val>");
Attr css(bool val) = prop("css", "<val>");
Attr disable(bool val) = prop("disable", "<val>");
//Attr grid(Object obj) = prop("grid", "<obj>");
Attr horizontalLayout(bool val) = prop("horizontalLayout", "<val>");
Attr maxBlocks(int val) = prop("maxBlocks", "<val>");
//Attr maxInstances(Object obj) = prop("maxInstances", "<obj>");
Attr media(str val) = prop("media", "<val>");
//Attr move(Object obj) = prop("move", "<obj>");
Attr oneBasedIndex(bool val) = prop("oneBasedIndex", "<val>");
Attr readOnly(bool val) = prop("readOnly", "<val>");
Attr rtl(bool val) = prop("rtl", "<val>");
Attr scrollbars(bool val) = prop("scrollbars", "<val>");
Attr sounds(bool val) = prop("sounds", "<val>");
Attr toolboxPosition(str val) = prop("toolboxPosition", "<val>");
Attr trashcan(bool val) = prop("trashcan", "<val>");
Attr maxTrashcanContents(int val) = prop("maxTrashcanContents", "<val>");
//Attr zoom(Object obj) = prop("zoom", "<obj>");
Attr renderer(str val) = prop("renderer", "<val>");

data _Toolbox
	= toolbox(list[_Element] elements = []);

data _Element
	= block(str \type)
	| section(str category, list[_Element] elements = []);

alias Toolbox = void(list[value] sections);
alias Section = void(str category, list[value] blocks);
alias Block = void(str \type);

void blockly(str id, value vals...){
	_Toolbox tbox = toolbox();
	
	_Element top() = tbox.elements[-1];
	
	void push(_Element e) {
		tbox.elements += e;
	}
	
	_Element pop() {
		_Element e = top();
		tbox.elements = tbox.elements[0..-1];
		return e;
	}
	
  	build(vals, Node(list[Node] _, list[Attr] attrs){
    	return native("blockly", id, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
  	});
}  
  