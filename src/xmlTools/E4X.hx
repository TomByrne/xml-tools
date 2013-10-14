/****
* Copyright 2013 tbyrne.org All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without modification, are
* permitted provided that the following conditions are met:
* 
*    1. Redistributions of source code must retain the above copyright notice, this list of
*       conditions and the following disclaimer.
* 
*    2. Redistributions in binary form must reproduce the above copyright notice, this list
*       of conditions and the following disclaimer in the documentation and/or other materials
*       provided with the distribution.
* 
* THIS SOFTWARE IS PROVIDED BY MASSIVE INTERACTIVE "AS IS" AND ANY EXPRESS OR IMPLIED
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
* FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MASSIVE INTERACTIVE OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
****/







package xmlTools;

#if macro
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
#end

/**
 * Based on http://code.google.com/p/e4xu/source/browse/trunk/haxe/src/org/wvxvws/xml/W.hx
	
 * @author wvxvw
 * @author Tom Byrne
 */

class E4X 
{
	macro public static function x(expr:Expr):Expr {
		return doE4X(expr, true, false, null, true, null, ReturnType.List);
	}
	
	#if macro
	
	private static var DESC_SHORTCUT:String = "_";
	private static var DESC_METHOD:String = "desc";
	private static var ATTR_METHOD:String = "a";
	private static var TEXT_METHOD:String = "text";
	
	
	public static function doE4X(expr:Expr, wrapField:Bool, allowBlock:Bool, xmlParam:String, doXmlProps:Bool, filterType:Null<FilterType>, returnType:ReturnType):Expr {
		var wrapInfo:WrapInfo = { wrapped:false, type:null };
		expr = checkExpr(expr, wrapField, allowBlock, xmlParam, doXmlProps, wrapInfo, filterType);
		if (wrapInfo.wrapped && !isE4XFinalAccess(expr)) {
			var pos = Context.currentPos();
			
			if (returnType == null && filterType != null) {
				returnType = ReturnType.Boolean;
			}
			
			switch(returnType) {
				case Str:
					if(wrapInfo.type!=null){
						switch(wrapInfo.type) {
							case Node, IndNode:
								return macro E4X.doGetNodeNames($expr);
							case Attribute:
								return macro E4X.doGetAttribs($expr);
							case Text:
								return macro E4X.doGetText($expr);
						}
					}else {
						return macro E4X.doStr($expr);
					}
					
				case Boolean:
					if(wrapInfo.type!=null){
						switch(wrapInfo.type) {
							case Node, IndNode:
								return macro E4X.doHasNodes($expr);
							case Attribute:
								return macro E4X.doHasAttribs($expr);
							case Text:
								return macro E4X.doHasText($expr);
						}
					}else {
						return macro E4X.doHas($expr);
					}
					
				default:
					if(wrapInfo.type!=null){
						switch(wrapInfo.type) {
							case Node, IndNode:
								return macro E4X.doRetNodes($expr);
							case Attribute:
								return macro E4X.doRetAttribs($expr);
							case Text:
								return macro E4X.doRetText($expr);
						}
					}else {
						return macro E4X.doRet($expr);
					}
					
			}
			
			/*if (filterType != null) {
				switch(wrapInfo.type) {
					case Node, IndNode:
						return macro E4X.doHasNodes($expr);
					case Attribute:
						return macro E4X.doHasAttribs($expr);
					case Text:
						return macro E4X.doHasText($expr);
					default:
						return macro E4X.doHas($expr);
				}
			}else if(wrapInfo.type!=null){
				switch(wrapInfo.type) {
					case Node, IndNode:
						return macro E4X.doRetNodes($expr);
					case Attribute:
						return macro E4X.doRetAttribs($expr);
					case Text:
						return macro E4X.doRetText($expr);
				}
			}*/
		}
		return expr;
	}
	
	/**
	 * Loops through an expression and does some things:
		 * Wraps the initial Xml object in an E4X instance  - i.e. within.node -> new E4X(within).node
		 * Changes property access to child() calls  - i.e. xml.node -> xml.child(function(xml:Xml, i:Int):Bool{return xml.nodeName=="node";})
		 * Wraps string expressions in nodeName checking functions  - i.e. xml.desc("node") -> xml.desc(function(xml:Xml, i:Int):Bool{return xml.nodeName=="node";})
		 * Wraps expressions in functions  - i.e. xml.desc(a("id")!=null)) -> xml.desc(function(xml:Xml, i:Int):Bool{return xml.a("id")!=null;})
		 * Converts underscore to descendants call - i.e. xml._ -> xml.desc()        &        xml._(a("id")!=null) ->  xml.desc(function(xml:Xml, i:Int):Bool{return xml.a("id")!=null;})
	 */
	private static function checkExpr(expr:Expr, wrapField:Bool, allowBlock:Bool, xmlParam:String, doXmlProps:Bool, wrapInfo:WrapInfo, filterType:Null<FilterType>):Expr {
		var pos = expr.pos;
		var exprDef = expr.expr;
		switch(exprDef) {
			case EBlock(eArr):
				if (allowBlock) {
					for (i in 0 ... eArr.length) {
						eArr[i] = doE4X(eArr[i], wrapField, allowBlock, xmlParam, doXmlProps, filterType, null);
					}
					return { expr:EBlock(eArr), pos:pos };
				}else{
					throw "E4X can't handle blocks of code, just a single expression";
				}
			case ECall(e, params):
				var newFilterType:FilterType = IndNode;
				switch(e.expr) {
					case EField(e2, field):
						if (field == DESC_SHORTCUT) {
							// change function calls from '_' to 'desc'
							e.expr = EField(e2, DESC_METHOD);
							newFilterType = Node;
						}else if (field == DESC_METHOD) {
							newFilterType = Node;
						}else if (field == ATTR_METHOD) {
							newFilterType = Attribute;
						}else if (field == TEXT_METHOD) {
							newFilterType = Text;
						}
						e = checkExpr(e, false, allowBlock, xmlParam, doXmlProps, wrapInfo, filterType);
					case EConst(c):
						if(xmlParam!=null){
							switch(c) {
								case CIdent(s):
									if (s == DESC_SHORTCUT) {
										// change function calls from '_' to 'desc'
										e.expr = EConst(CIdent(DESC_METHOD));
										newFilterType = Node;
									}else if (s == DESC_METHOD) {
										newFilterType = Node;
									}else if (s == ATTR_METHOD) {
										newFilterType = Attribute;
									}else if (s == TEXT_METHOD) {
										newFilterType = Text;
									}
									if (newFilterType != null) {
										wrapInfo.wrapped = true;
										e = { expr:EField( { expr : ECall( { expr : EField( { expr : EConst(CIdent("E4X")), pos : pos }, "getNew"), pos : pos }, [ { expr : EConst(CIdent(xmlParam)), pos : pos } ]), pos : pos }, s), pos:pos };
									}
								default: // ignore
							}
						}
					default:
						// ignore
				}
				wrapInfo.type = newFilterType;
					
				for (i in 0 ... params.length) {
					params[i] = checkParam(params[i], newFilterType, wrapInfo);
				}
				return { expr : ECall( e, params), pos : pos };
			case EConst(c):
				switch(c) {
					case CIdent(s):
						if (xmlParam != null && doXmlProps && isXmlProp(s)) {
							expr = { expr:EField( { expr:EConst(CIdent(xmlParam)), pos:pos }, s), pos:pos };
							return checkExpr(expr, wrapField, allowBlock, xmlParam, false, wrapInfo, filterType);
						}else if (wrapField && (filterType == null || s == xmlParam)) {
							wrapInfo.wrapped = true;
							return macro E4X.getNew($expr);
						}else {
							return expr;
						}
					default:
						return expr;
				}
			case EField(e, field):
				if (!wrapField) {
					var checked:Expr = checkExpr(e, true, allowBlock, xmlParam, doXmlProps, wrapInfo, filterType);
					return { expr : EField(checked,field), pos : pos };
				}else {
					if(!isXmlPropAccess(field, e, filterType, xmlParam)){
						e = checkExpr(e, true, allowBlock, xmlParam, doXmlProps, wrapInfo, filterType);
					}
					if (!wrapInfo.wrapped) {
						// This is propbably a property of a special prop (e.g. 'text.length')
						return expr;
					}else{
						wrapInfo.type = Node;
						
						if (field == DESC_SHORTCUT) {
							return macro $e.desc();
						}else {
							// wrap prop access in child() call
							var nameE = {expr:EConst(CString(field)), pos:pos};
							var check = macro function(xml:Xml, _i:Int):Bool { return xml.nodeType==Xml.Element && xml.nodeName == $nameE; };
							return macro $e.child($check);
						}
					}
				}
			case EReturn(e):
				if (e != null) {
					e =  doE4X(e, wrapField, allowBlock, xmlParam, doXmlProps, filterType, null);
					return macro return $e;
				}else {
					return expr;
				}
			case EBinop( op , e1 , e2 ):
				var retType:ReturnType;
				switch(op) {
					case OpEq:
						retType = ReturnType.Str;
					default:
						retType = ReturnType.Boolean;
				}
				return { expr:EBinop(op, doE4X(e1, wrapField, allowBlock, xmlParam, doXmlProps, filterType, ReturnType.Str), doE4X(e2, wrapField, allowBlock, xmlParam, doXmlProps, filterType, retType)), pos:pos };
			default:
				return expr;
		}
	}
	private static function checkParam(expr:Expr, filterType:FilterType, wrapInfo:WrapInfo):Expr {
		var pos = expr.pos;
		var exprDef = expr.expr;
		switch(exprDef) {
			case EConst(c):
				switch(c) {
					case CString(_), CIdent(_):
						switch(filterType) {
							case Node, IndNode:
								expr = macro { return xml.nodeType == Xml.Element && xml.nodeName == $expr; };
							case Attribute:
								expr = macro { return attName == $expr; };
							case Text:
								expr = macro { return text == $expr; };
						}
					default:
						expr = checkExpr(expr, true, true, "xml", true, wrapInfo, filterType);
				}
			case EFunction( name , f ):
				var xmlName:String = f.params[0].name;
				f.expr = checkExpr(f.expr, true, true, xmlName, true, wrapInfo, filterType);
				return { expr:EFunction(name, f), pos:pos };
			case EReturn( _ ):
				expr = checkExpr(expr, true, false, "xml", true, wrapInfo, filterType);
			default:
				expr = doE4X(expr, true, false, "xml", true, filterType, ReturnType.Boolean);
				expr = macro return $expr;
		}
		switch(filterType) {
			case IndNode:
				return macro function(xml:Xml, _i:Int):Bool $expr;
			case Node:
				return macro function(xml:Xml):Bool $expr;
			case Attribute:
				return macro function(attName:String, attVal:String, xml:Xml):Bool $expr;
			case Text:
				return macro function(text:Null<String>, xml:Xml):Bool $expr;
		}
	}
	private static function isXmlPropAccess(field:String, e:Expr, filterType:FilterType, xmlParam:String):Bool {
		switch(e.expr) {
			case EConst(c):
				switch(c) {
					case CIdent(s):
						if (filterType == null || s == xmlParam) {
							return isXmlProp(field);
						}
					default:
						// ignore
				}
			default:
				// ignore
		}
		return false;
	}
	private static function isXmlProp(field:String):Bool {
		return (field == "nodeName" || field == "nodeType"   || field == "nodeValue" ||
				field == "parent"   || field == "addChild"   || field == "attributes" ||
				field == "elements"   || field == "elementsNamed"   || field == "exists" ||
				field == "firstChild"   || field == "firstElement"   || field == "get" ||
				field == "insertChild"   || field == "iterator"   || field == "remove" ||
				field == "removeChild"   || field == "set"   || field == "toString");
	}
	private static function isE4XFinalAccess(e:Expr):Bool {
		switch(e.expr) {
			case ECall(e2, _):
				switch(e2.expr) {
					case EField(_, field):
						if (field == "retNodes" || field == "retAttrib" || field == "retText" || field == "has") {
							return true;
						}
					default:
						// ignore
				}
			default:
				// ignore
		}
		return false;
	}
	
	#else
	
	public static function getNew(xml:Xml):E4X {
		var ret:E4X;
		if (_pool.length > 0) {
			ret = _pool.pop();
			ret.setXml(xml);
		}else {
			ret = new E4X(xml);
		}
		return ret;
	}
	public static function doRetNodes(e4X:E4X):Iterator<Xml> {
		var ret:Iterator<Xml> = e4X.retNodes();
		_pool.push(e4X);
		return ret;
	}
	public static function doRetAttribs(e4X:E4X):Iterator<Map<String, String>>{
		var ret:Iterator<Map<String, String>> = e4X.retAttribs();
		_pool.push(e4X);
		return ret;
	}
	public static function doRetText(e4X:E4X):Iterator<Null<String>>{
		var ret:Iterator<Null<String>> = e4X.retText();
		_pool.push(e4X);
		return ret;
	}
	
	public static function doGetNodeNames(e4X:E4X):String {
		var ret = e4X.getNodeNames();
		_pool.push(e4X);
		return ret;
	}
	public static function doGetAttribs(e4X:E4X):String{
		var ret = e4X.getAttribsStr();
		_pool.push(e4X);
		return ret;
	}
	public static function doGetText(e4X:E4X):String{
		var ret = e4X.getText();
		_pool.push(e4X);
		return ret;
	}
	public static function doStr(e4X:E4X):String{
		var ret = e4X.getStr();
		_pool.push(e4X);
		return ret;
	}
	
	public static function doHasNodes(e4X:E4X):Bool {
		var ret = e4X.hasNodes();
		_pool.push(e4X);
		return ret;
	}
	public static function doHasAttribs(e4X:E4X):Bool{
		var ret = e4X.hasAttribs();
		_pool.push(e4X);
		return ret;
	}
	public static function doHasText(e4X:E4X):Bool{
		var ret = e4X.hasText();
		_pool.push(e4X);
		return ret;
	}
	public static function doHas(e4X:E4X):Bool{
		var ret:Bool = e4X.has();
		_pool.push(e4X);
		return ret;
	}
	
	private static var _pool:Array<E4X> = new Array<E4X>();
	
	private var _root:Xml;
	private var _parent:Xml;
	private var _nodes:List<Xml>;
	private var _attributes:List<Map<String, String>>;
	private var _texts:List<Null<String>>;
	private var _retState:E4XReturnState;
	
	private var _attrStrValid:Bool;
	private var _attributesStr:String;
	
	private var _nodesStrValid:Bool;
	private var _nodesStr:String;
	
	private var _textsStrValid:Bool;
	private var _textsStr:String;
	
	/**
		Creates new walking operation.
		<p class="code">param</p>	value	The XML document or fragment to start walking from.
	**/
	public function new(value:Xml)
	{
		if(value!=null)setXml(value);
	}
	
	public function setXml(xml:Xml):Void {
		this._attributes = new List<Map<String, String>>();
		this._texts = new List<Null<String>>();
		this._root = xml;
		this._retState = E4XReturnState.Node;
		this._nodes = new List<Xml>();
		if (xml != null && xml.nodeType == Xml.Document)
			this._nodes.add(xml.firstElement());
		else if (xml != null) this._nodes.add(xml);
	}
	
	/**
		Creates new walking operation.
		<p class="code">param</p>	value	The XML document or fragment to start walking from.
		Note: if XML document is passed, the firstElement is used.
		<p class="code">return</p> new E4X, you can chain the further calls to it.
	**/
	//public static function walk(value:Xml):E4X { return new E4X(value); }
	
	/**
		Filters child nodes.
		<p class="code">param</p>	?x	A callback to execute on each <b>child</b> node.
		Note: the child list is not copied.
		Note: if no callback provided, all <b>child</b> nodes are included in result.
		<p class="code">return</p> new E4X, you can chain the further calls to it.
	**/
	public function child(?x:Null<Xml>->Int->Bool):E4X
	{
		var it:Iterator<Null<Xml>> = this._nodes.iterator();
		var subIt:Iterator<Null<Xml>>;
		var a:List<Xml> = new List<Xml>();
		var node:Xml;
		var i:Int;
		
		while (it.hasNext()){
			node = it.next();
			if (node.nodeType == Xml.Element){
				i = 0;
				subIt = node.iterator();
				while (subIt.hasNext())
				{
					node = subIt.next();
					if (x != null){
						if (x(node, i)) a.add(node);
					}
					else a.add(node);
					i++;
				}
			}
		}
		this._nodesStrValid = false;
		this._nodes = a;
		this._retState = E4XReturnState.Node;
		return this;
	}
	
	/**
		Filters child nodes.
		<p class="code">param</p>	?x	A callback to execute on each <b>descendant</b> node.
		Note: the child list is not copied.
		Note: if no callback provided, all <b>descendant</b> nodes are included in result.
		<p class="code">return</p> new E4X, you can chain the further calls to it.
	**/
	public function desc(?x:Null<Xml>->Bool):E4X
	{
		var it:Iterator<Xml> = this._nodes.iterator();
		var newNodes = new List<Xml>();
		var node:Xml;
		
		var iterators = new List<Iterator<Xml>>();
		if(it.hasNext()){
			while (true) {
				node = it.next();
				
				if (x != null) {
					if (x(node)) {
						newNodes.add(node);
					}
				}else{
					newNodes.add(node);
				}
				
				if (node.nodeType == Xml.Element)
				{
					var subIt = node.iterator();
					if (subIt.hasNext()) {
						if(it.hasNext())iterators.push(it);
						it = subIt;
					}
				}
				if (!it.hasNext()) {
					if (iterators.length==0) {
						break;
					}else {
						it = iterators.pop();
					}
				}
			}
		}
		this._nodesStrValid = false;
		this._nodes = newNodes;
		this._retState = E4XReturnState.Node;
		return this;
	}
	
	
	/**
		Filters ancestor nodes.
		<p class="code">param</p>	?x	A callback to execute on each <b>parent</b> node.
		Note: the child list is not copied.
		Note: if no callback provided, all <b>parent</b> nodes are included in result.
		<p class="code">return</p> new E4X, you can chain the further calls to it.
	**/
	public function ances(?x:Null<Xml>->Int->Bool):E4X
	{
		var it:Iterator<Null<Xml>> = this._nodes.iterator();
		var itw:Iterator<Null<Xml>>;
		var newNodes:List<Xml> = new List<Xml>();
		var node:Xml;
		var pnode:Xml;
		var i:Int = 0;
		
		while (it.hasNext())
		{
			node = it.next();
			pnode = node.parent;
			if (pnode != null)
			{
				if (!Lambda.has(newNodes, pnode)) {
					if (x != null){
						if (x(node, i)) newNodes.add(node);
					}else {
						newNodes.add(node);
					}
				}
			}
		}
		this._nodesStrValid = false;
		this._nodes = newNodes;
		this._retState = E4XReturnState.Node;
		return this;
	}
	
	/**
		Filters attributes.
		<p class="code">param</p>	?x	A callback to execute on each <b>attribute</b> node.
		Note: the child list is not copied.
		Note: if no callback provided, all <b>attribute</b> nodes are included in result.
		<p class="code">return</p> new E4X, you can chain the further calls to it.
	**/
	public function a(?x:String->String->Xml->Bool):E4X
	{
		var it = this._nodes.iterator();
		var ait:Iterator<String>;
		var node:Xml;
		var atts:Map<String, String> = null;
		var newAttribs = new List<Map<String, String>>();
		var s:String;
		var vs:String;
		var newNodes = new List<Xml>();
		
		while (it.hasNext())
		{
			node = it.next();
			if (node.nodeType != Xml.Element) continue;
			ait = node.attributes();
			atts = null;
			while (ait.hasNext())
			{
				if (x == null)
				{
					if (atts == null) atts = new Map<String, String>();
					s = ait.next();
					atts.set(s, node.get(s));
					newNodes.add(node);
				}
				else 
				{
					s = ait.next();
					vs = node.get(s);
					if (x(s, vs, node))
					{
						if (atts == null) atts = new Map<String, String>();
						atts.set(s, vs);
						newNodes.add(node);
					}
				}
			}
			if (atts != null) newAttribs.add(atts);
		}
		this._attrStrValid = false;
		this._attributes = newAttribs;
		this._nodesStrValid = false;
		this._nodes = newNodes;
		this._retState = E4XReturnState.Attribute;
		return this;
	}
	
	/**
		Filters text nodes.
		<p class="code">param</p>	?x	A callback to execute on each <b>text</b> node.
		Note: the child list is not copied.
		Note: if no callback provided, all <b>text</b> nodes are included in result.
		<p class="code">return</p> new E4X, you can chain the further calls to it.
	**/
	public function text(?x:Null<String>->Xml->Bool):E4X
	{
		var it:Iterator<Null<Xml>> = this._nodes.iterator();
		var itt:Iterator<Null<Xml>>;
		var newText = new List<Null<String>>();
		var newNodes = new List<Xml>();
		var node:Xml;
		var vnode:Xml;
		var tnode:String;
		
		while (it.hasNext())
		{
			node = it.next();
			var type = node.nodeType;
			if (type == Xml.Element)
			{
				itt = node.iterator();
				while (itt.hasNext())
				{
					vnode = itt.next();
					var subType = vnode.nodeType;
					if (subType == Xml.CData || subType == Xml.PCData)
					{
						tnode = vnode.nodeValue;
						
						if (x != null){
							if (x(tnode, vnode))
							{
								newText.add(tnode);
								newNodes.add(vnode);
							}
						}
						else
						{
							newText.add(tnode);
							newNodes.add(vnode);
						}
					}
				}
			}
			else if (type == Xml.CData || type == Xml.PCData)
			{
				tnode = node.nodeValue;
				
				if (x != null){
					if (x(tnode, node))
					{
						newText.add(tnode);
						newNodes.add(node);
					}
				}
				else
				{
					newText.add(tnode);
					newNodes.add(node);
				}
			}
		}
		this._nodesStrValid = false;
		this._nodes = newNodes;
		this._textsStrValid = false;
		this._texts = newText;
		this._retState = E4XReturnState.Text;
		return this;
	}
	
	public function retNodes():Iterator<Xml>
	{
		return _nodes.iterator();
	}
	public function retAttribs():Iterator<Map<String, String>>
	{
		return _attributes.iterator();
	}
	public function retText():Iterator<Null<String>>
	{
		return _texts.iterator();
	}
	
	public function getNodeNames():String
	{
		if (!_nodesStrValid) {
			_nodesStrValid = true;
			
			_nodesStr = null;
			if (hasAttribs()) {
				var it = _nodes.iterator();
				var first:Bool = true;
				while (it.hasNext()) {
					var node:Xml = it.next();
					if (first) {
						_nodesStr = node.nodeName;
						first = false;
					}else {
						_nodesStr += " "+node.nodeName;
					}
				}
			}
			
		}
		return _nodesStr;
	}
	public function getAttribsStr():String
	{
		if (!_attrStrValid) {
			_attrStrValid = true;
			
			_attributesStr = null;
			if (hasAttribs()) {
				var it = _attributes.iterator();
				var first:Bool = true;
				while (it.hasNext()) {
					var attList:Map<String, String> = it.next();
					for (i in attList.keys()) {
						if (first) {
							_attributesStr = attList.get(i);
							first = false;
						}else {
							_attributesStr += " "+attList.get(i);
						}
					}
				}
			}
		}
		return _attributesStr;
	}
	public function getText():String
	{
		if (!_textsStrValid) {
			_textsStrValid = true;
			
			_textsStr = null;
			if (hasAttribs()) {
				var it = _texts.iterator();
				var first:Bool = true;
				while (it.hasNext()) {
					var text:String = it.next();
					if (first) {
						_textsStr = text;
						first = false;
					}else {
						_textsStr += " "+text;
					}
				}
			}
			
		}
		return _textsStr;
	}
	public function getStr():String
	{
		switch (this._retState)
		{
			case      Node: return getNodeNames();
			case Attribute: return getAttribsStr();
			case      Text: return getText();
		}
		throw "Invalid return code";
	}
	
	public function hasNodes():Bool
	{
		return (_nodes!=null) && !_nodes.isEmpty();
	}
	public function hasAttribs():Bool
	{
		return (_attributes != null) && !_attributes.isEmpty();
	}
	public function hasText():Bool
	{
		return (_texts!=null) && !_texts.isEmpty();
	}
	
	public function has():Bool
	{
		switch (this._retState)
		{
			case      Node: return hasNodes();
			case Attribute: return hasAttribs();
			case      Text: return hasText();
		}
		throw "Invalid return code";
	}
	#end
}


#if macro
typedef WrapInfo = {
	var wrapped:Bool;
	var type:FilterType;
}

enum FilterType {
	IndNode;
	Node;
	Attribute;
	Text;
}

enum ReturnType{
	List;
	Str;
	Boolean;
}

#else

enum E4XReturnState {
	Node;
	Attribute;
	Text;
}

#end