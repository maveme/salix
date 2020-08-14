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
	| _category(str name, str color = "", str custom = "", str style = "", str expanded = false, list[_Element] elements = [])
	| _separator(str gap = "")
	| _block(str name, str \type = "", str disabled = false, list[_Element] elements = [])
	| _shadow(str name, str \type = "", str disabled = false, list[_Element] elements = [])
	| _value(str name, list[_Element] elements = [])
	| _field(str name, str \value, str id = "", str \type = "")
	| _button(str text, str callbackKey, str class = "")
	| _label(str text, str class = "");
	
// Attributes for the configuration of the internal omnibox.
Attr \type(str val) = attr("type", val);
Attr disabled(bool val) = attr("disabled", "<( val ? val : "")>");
Attr expanded(bool val) = attr("expanded", "<(!val ? val : "")>");
Attr colour(int val) = attr("colour", "<((val >= 0 && val <= 360) ? val : "")>");
Attr custom(str val) = attr("custom", val);
Attr categoryStyle(str val) = attr("categorystyle", val);
Attr gap(int val) = attr("gap", "<((val >= 0 && val <= 360) ? val : "")>");
Attr id(str val) = attr("id", val);
Attr webClass(str val) = attr("web-class", val);
Attr callbackKey(str val) = attr("callbackKey", val);

// compile

list[Node] attr2xml(str name, str val) = ( val == "" ? [] : [attribute(name, val)]);

// Conversion of an Omnibox element to an XML element for the toolbox.
Node element2xml(_Element elmnt) {
	str name = "None";
	list[Node] attrs = [];
	switch(elmnt) {
		case _category(str category): {
			name = "category";
			attrs += attr2xml("name", category);
			attrs += attr2xml("colour", elmnt.color);
			attrs += attr2xml("custom", elmnt.custom);
			attrs += attr2xml("categoryStyle", elmnt.style);
			attrs += attr2xml("expanded", elmnt.expanded);
			attrs += [element2xml(e) | e <-elmnt.elements];
		}
		case _block(str name):
			return element("block", [attribute("type", elmnt.\type)] + [element2xml(e) | e <-elmnt.elements]);
		default:
			return comment("None");
	}
	
	return element(name, attrs);	
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
	stack = stack[0..-1] + stack [-1][elements = stack[-1].elements + [element]];	
}

// the closure for a category.
void category(str name, value vals...){
	_Element cur = addChildren(_category(name), vals);
	
	for( <str atr, str val> <- [<k,v> | attr(str k, str v) <- vals]){
		switch(atr){
			case "color": cur.color = val;
			case "custom": cur.custom = val;
			case "style": cur.style = val;
			case "expanded": cur.expanded = val;
		}
	}	
	addToParent(cur);	
}

// the closure for a separator.
void separator(value vals...){
	_Element cur = _separator();
	for( <str atr, str val> <- [<k,v> | attr(str k, str v) <- vals]){
		switch(atr){
			case "gap": cur.gap = val;
		}
	}
	addToParent(cur);
}

// the closure for a block.
void block(str name, value vals...){
	_Element cur = addChildren(_block(name), vals);
	println("attrs: <attrsOf([a | Attr a <- vals])>");	
	for( <str atr, str val> <- [<k,v> | attr(str k, str v) <- vals]){
		switch(atr){
			case "type": cur.\type = val;
			case "disabled": cur.disabled = val;
		}
	}
	addToParent(cur);
}

// the closure for a shadow block.
void shadow(str name, value vals...){
	_Element cur = addChildren(_shadow(name), vals);
	for( <str atr, str val> <- [<k,v> | attr(str k, str v) <- vals]){
		switch(atr){
			case "type": cur.\type = val;
			case "disabled": cur.disabled = val;
		}
	}
	addToParent(cur);
}

// the closure for a value.
void \value(str name, value vals...){
	_Element cur = addChildren(_value(name), vals);
	addToParent(cur);
}

// the closure for a field.
void field(str name, value val, value vals...){
	_Element cur = _field(name, val);
	for( <str atr, str val> <- [<k,v> | attr(str k, str v) <- vals]){
		switch(atr){
			case "id": cur.id = val;
			case "type": cur.\type = val;
		}
	}
	addToParent(cur);
}

// the closure for a button.
void button(str text, str callbackKey, value vals...){
	_Element cur = _button(text, callbackKey);
	for( <str atr, str val> <- [<k,v> | attr(str k, str v) <- vals]){
		switch(atr){
			case "class": cur.class = val;
		}
	}
	addToParent(cur);
}

// the closure for a label.
void label(str text, value vals...){
	_Element cur = _label(text);
	for( <str atr, str val> <- [<k,v> | attr(str k, str v) <- vals]){
		switch(atr){
			case "class": cur.class = val;
		}
	}
	addToParent(cur);
}

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
  