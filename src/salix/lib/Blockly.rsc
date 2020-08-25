module salix::lib::Blockly

import salix::Node;
import lang::xml::DOM;
import salix::Core;
import IO;


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

// ---- 

// definition

// Definition for the internal Toolbox/Workspace/Block representation (the omnibox).
private data _Element
	= _toolbox(list[_Element] elements = [])
	| _category(map[str, str] attrs, list[_Element] elements = [])
	| _separator(map[str, str] attrs)
	| _block(map[str,str] attrs , list[_Element] messages = [], list[_Element] elements = [])
	| _shadow(map[str,str] attrs, list[_Element] messages = [], list[_Element] elements = [])
	| _value(map[str,str] attrs, list[_Element] elements = [])
	| _field(map[str,str] attrs)
	| _button(map[str,str] attrs)
	| _label(map[str,str] attrs)
	| _message(str msg);
	
// Attributes for the configuration of the internal omnibox.
Attr \type(str val) = attr("type", val);
Attr disabled(bool val) = attr("disabled", "<( val ? val : "")>");
Attr expanded(bool val) = attr("expanded", "<(!val ? val : "")>");
Attr hue(int val) = attr("colour", "<((val >= 0 && val <= 360) ? val : "")>"); // I may be English but I hate the use of 'colour' and other British English in computing science. I will use the word hue because that's the only thing the "colour" attribute can set.  
Attr custom(str val) = attr("custom", val);
Attr categoryStyle(str val) = attr("categorystyle", val);
Attr gap(int val) = attr("gap", "<((val >= 0 && val <= 360) ? val : "")>");
Attr id(str val) = attr("id", val);
Attr webClass(str val) = attr("web-class", val);

// compile

// Conversion of the attr map to attributes, but only for the ones that we want. 
list[Node] attrs2xml(list[str] keys, map[str, str] attrs) {
	list[Node] ats = [];
	
	for (k <- keys){
		if ( k in attrs && attrs[k] != "" ){
			ats += [attribute(k, attrs[k])];
		};
	};
	
	return ats;
} 

// Conversion of an Omnibox element to an XML element for the toolbox.
Node element2xml(_Element elmnt) {
	switch(elmnt) {
		case _category(map[str, str] attrs):
			return element("category", attrs2xml(["name", "colour", "custom", "categoryStyle", "expanded"], attrs) + [element2xml(e) | e <-elmnt.elements]);
		case _separator(map[str, str] attrs):
			return element("sep", attrs2xml(["gap"], attrs));
		case _block(map[str, str] attrs):
			return element("block", attrs2xml(["name", "type", "colour", "disabled"], attrs) + [element2xml(e) | e <-elmnt.elements]);
		case _shadow(map[str, str] attrs):
			return element("shadow", attrs2xml(["name", "type", "colour", "disabled"], attrs) + [element2xml(e) | e <-elmnt.elements]);
		case _value(map[str, str] attrs):
			return element("value", attrs2xml(["name"], attrs) + [element2xml(e) | e <-elmnt.elements]);
		case _field(map[str, str] attrs):
			return element("field", attrs2xml(["name", "value", "id", "type"], attrs));
		case _button(map[str, str] attrs):
			return element("button", attrs2xml(["name", "callbackKey", "web-class"], attrs));
		case _label(map[str, str] attrs):
			return element("label", attrs2xml(["name", "web-class"], attrs));
		default:
			return comment("None");
	}
}

// Conversion of an Omnibox to an XML DOM for the toolbox.
Node toolbox2xml(_Element tbox) =
	document(element("xml",[element2xml(e) | e <- tbox.elements]));

// --

// construct

// The stack of the omnibox.
private list[_Element] stack = [_toolbox()];

// The top of the stack.
private _Element top() = stack[-1];

// push to the stack.
private void push(_Element e) {
	stack += [e];
}

// pop off the stack.
private _Element pop() {
	_Element e = top();
	stack = stack[0..-1];
	return e;
}

// Add all the children in the sub-closure (if there is one).
private _Element addChildren(_Element cur, list[value] vals){
	if(vals != [], void () blk := vals[-1]){
		push(cur);
		blk();
		cur = pop();
	}
	
	return cur;
}

// Add the element to it's parent. 
private void addToParent(_Element element) {
	if(_message(_) := element){
		stack = stack[0..-1] + stack [-1][elements = stack[-1].messages + [element]];	
	} else {
		stack = stack[0..-1] + stack [-1][elements = stack[-1].elements + [element]];	
	}
}

private map[str,str] getAttrs(list[value] vals) = (k: v | attr(str k, str v) <- vals);

// the closure for a category.
void category(str name, value vals...){
	_Element cur = addChildren(_category(getAttrs(vals)), vals);
	cur.attrs["name"] = name;
	addToParent(cur);	
}

// the closure for a separator.
void separator(value vals...) = addToParent(_separator(getAttrs(vals)));

// the closure for a block.
void block(str name, value vals...){
	_Element cur = addChildren(_block(getAttrs(vals)), vals);
	cur.attrs["name"] = name;
	addToParent(cur);
}

// the closure for a shadow block.
void shadow(str name, value vals...){
	_Element cur = addChildren(_shadow(getAttrs(vals)), vals);
	cur.attrs["name"] = name;
	addToParent(cur);
}

void message(str msg) = addToParent(_message(msg));

// the closure for a value.
void \value(str name, value vals...) = addToParent(addChildren(_value(("name": name)), vals));

// the closure for a field.
void field(str name, value val, value vals...){
	_Element cur = _field(getAttrs(vals));
	cur.attrs["name"] = name;
	cur.attrs["value"] = val;
	addToParent(cur);
}

// the closure for a button.
void button(str text, str callbackKey, value vals...){
	_Element cur = _button(getAttrs(vals));
	cur.attrs["name"] = text;
	cur.attrs["callbackKey"] = callbackKey;
	addToParent(cur);
}

// the closure for a label.
void label(str text, value vals...){
	_Element cur = _label(getAttrs(vals));
	cur.attrs["name"] = text;
	addToParent(cur);
}

private void() oldT = (){};

void blockly(str id, value vals...){

	// if a omnibox is supplied as a closure, construct the omnibox using black magic.	
	if( vals != [], void() T := vals[-1]) {
		stack = [_toolbox()];
		T();
	}
  	
  	build(vals[0..-1], Node(list[Node] _, list[Attr] attrs){
    	return native("blockly", id, attrsOf(attrs), propsOf(attrs), eventsOf(attrs), extra = ("toolbox": xmlPretty(toolbox2xml(stack[0]))));
  	});
}  
  