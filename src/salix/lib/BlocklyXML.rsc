@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}
@contributor{Bert Lisser - berlt@cwi.nl - CWI}

module salix::lib::BlocklyXML

import salix::Node;
import salix::Core;
import List;
import String; 

data Msg;
 
@doc{Create a text node.}
void text(value v) = _text(v);


@doc{The element render functions below all call build
to interpret the list of values; build will call the
second argument (_h1 etc.) to construct the actual
Node values.}

void xml(value vals...) = build(vals, _xml);
void category(value vals...) = build(vals, _category);
void block(value vals...) = build(vals, _block);
void field(value vals...) = build(vals, _field);
void shadow(value vals...) = build(vals, _shadow);
void blocklyValue(value vals...) = build(vals, _value);
/*
 * Attributes
 */

Node _xml(list[Node] kids, list[Attr] attrs) = element("xml", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _category(list[Node] kids, list[Attr] attrs) = element("category", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _block(list[Node] kids, list[Attr] attrs) = element("block", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _field(list[Node] kids, list[Attr] attrs) = element("field", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _shadow(list[Node] kids, list[Attr] attrs) = element("shadow", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
Node _value(list[Node] kids, list[Attr] attrs) = element("value", kids, attrsOf(attrs), propsOf(attrs), eventsOf(attrs));
 
Attr style(tuple[str, str] styles...) = attr("style", intercalate("; ", ["<k>: <v>" | <k, v> <- styles ])); 
Attr style(map[str,str] styles) = attr("style", intercalate("; ", ["<k>: <styles[k]>" | k <- styles ])); 

Attr color(str val) = attr("color", val);
Attr custom(str val) = attr("custom", val);
Attr catagorystyle(str val) = attr("catagorystyle", val);
Attr variabletype(str val) = attr("variabletype", val);
Attr expanded(str val) = attr("expanded", val);
Attr expanded(str val) = attr("expanded", val);
