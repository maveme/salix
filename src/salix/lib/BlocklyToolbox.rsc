module salix::lib::BlocklyToolbox

import lang::xml::DOM;


	Node toolbox(list[Node] children) = document(element(none(), "xml", [attribute("id", "toolbox")] + children));

	Node category(str name, list[Node] children) = category(name, children, -1, "", "", false);
	Node category(str name, list[Node] children, int color, str custom, str style, bool expanded) {
		list[Node] attrs = [attribute("name", name)];
		
		if( color >= 0 && color <= 360 ){
			attrs += attribute("color", "<color>");
		}
		
		if(custom != ""){
			attrs += attribute("custom", custom);
		}
		
		if(style != ""){
			attrs += attribute("categorystyle", style);
		}

		if(expanded == true){
			attrs += attribute("expanded", "<expanded>");
		}
		return element("category", attrs + children);
	} 
	
	Node separator() = element("sep", []);
	Node separator(int gap) = element("sep", [attribute("gap", "<gap>")]);
	
	Node block(str \type) = block(\type, [], false);
	Node block(str \type, list[Node] children) = block(\type, children, false);
	Node block(str \type, list[Node] children, bool disabled) {
		list[Node] attrs = [attribute("type", \type)];
		if (disabled) {
			attrs += attribute("disabled", "<disabled>");
		}
		
		return element("block", attrs + children);
	}

	// TODO Shadow blocks cannot include variable fields or have children that are not shadows.
	Node shadow(str \type) = shadow(\type, [], false);
	Node shadow(str \type, list[Node] children) = shadow(\type, children, false);
	Node shadow(str \type, list[Node] children, bool disabled) {
		list[Node] attrs = [attribute("type", \type)];
		if (disabled) {
			attrs += attribute("disabled", "<disabled>");
		}
		
		return element("shadow", attrs + children);
	}
	
	Node \value(str name, list[Node] children) = element("value", [attribute("name", name)] + children);

	Node field(str name, value \value) = field(name, \value, "", "");
	Node field(str name, value \value, str id, str \type){
		list[Node] attrs = [attribute("name", name)];
		
		if(id != "") {
			attrs += attribute("id", id);
		}
		
		if(\type != "") {
			attrs += attribute("type", \type);
		}

		return element("field", attrs + [charData("<\value>")]);
	}
	
	Node button(str text, str callbackKey) = button(text, callbackKey, "");
	Node button(str text, str callbackKey, str webclass) {
		list[Node] attrs = [attribute("text", text), attribute("callbackKey", callbackKey)];
		
		if(webclass != "") {
			attrs += attribute("web-class", webclass);
		}
		return element("button", attrs);	
	}
	
	Node label(str text) = label(text, "");
	Node label(str text, str webclass) {
		list[Node] attrs = [attribute("text", text)];
		
		if(webclass != "") {
			attrs += attribute("web-class", webclass);
		}
		return element("button", attrs);	
	}