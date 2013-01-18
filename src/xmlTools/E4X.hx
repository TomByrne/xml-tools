package xmlTools;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;

/**
 * Based on http://code.google.com/p/e4xu/source/browse/trunk/haxe/src/org/wvxvws/xml/W.hx
	
 * @author wvxvw
 * @author Tom Byrne
 */

class E4X 
{
	@:macro public static function x(expr:Expr):Expr {
		return doE4X(expr, true, false, null, true, null);
	}
	
	#if macro
	
	private static var DESC_SHORTCUT:String = "_";
	private static var DESC_METHOD:String = "desc";
	private static var ATTR_METHOD:String = "a";
	private static var TEXT_METHOD:String = "text";
	
	
	public static function doE4X(expr:Expr, wrapField:Bool, allowBlock:Bool, xmlParam:String, doXmlProps:Bool, filterType:Null<FilterType>):Expr {
		var wrapInfo:WrapInfo = { wrapped:false, type:null };
		expr = checkExpr(expr, wrapField, allowBlock, xmlParam, doXmlProps, wrapInfo, filterType);
		if (wrapInfo.wrapped && !isE4XFinalAccess(expr)) {
			var pos = Context.currentPos();
			if (filterType != null) {
				return macro E4X.doHas($expr);
			}else if(wrapInfo.type!=null){
				switch(wrapInfo.type) {
					case Node, IndNode:
						return macro E4X.doRetNodes($expr);
					case Attribute:
						return macro E4X.doRetAttribs($expr);
					case Text:
						return macro E4X.doRetText($expr);
				}
			}
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
						eArr[i] = doE4X(eArr[i], wrapField, allowBlock, xmlParam, doXmlProps, filterType);
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
							var check = macro function(xml:Xml, _i:Int):Bool { return xml.nodeName == $nameE; };
							return macro $e.child($check);
						}
					}
				}
			case EReturn(e):
				if (e != null) {
					e =  doE4X(e, wrapField, allowBlock, xmlParam, doXmlProps, filterType);
					return macro return $e;
				}else {
					return expr;
				}
			case EBinop( op , e1 , e2 ):
				return { expr:EBinop(op, doE4X(e1, wrapField, allowBlock, xmlParam, doXmlProps, filterType), doE4X(e2, wrapField, allowBlock, xmlParam, doXmlProps, filterType)), pos:pos };
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
					case CString(s), CIdent(s):
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
			case EReturn( e ):
				expr = checkExpr(expr, true, false, "xml", true, wrapInfo, filterType);
			default:
				expr = doE4X(expr, true, false, "xml", true, filterType);
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
			case ECall(e2, p):
				switch(e2.expr) {
					case EField(e3, field):
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
	public static function doRetAttribs(e4X:E4X):Iterator<Hash<String>>{
		var ret:Iterator<Hash<String>> = e4X.retAttribs();
		_pool.push(e4X);
		return ret;
	}
	public static function doRetText(e4X:E4X):Iterator<Null<String>>{
		var ret:Iterator<Null<String>> = e4X.retText();
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
	private var _current:Array<Xml>;
	private var _attributes:Array<Hash<String>>;
	private var _texts:Array<Null<String>>;
	private var _retState:E4XReturnState;
	
	/**
		Creates new walking operation.
		<p class="code">param</p>	value	The XML document or fragment to start walking from.
	**/
	public function new(value:Xml)
	{
		if(value!=null)setXml(value);
	}
	
	public function setXml(xml:Xml):Void {
		this._attributes = new Array<Hash<String>>();
		this._texts = new Array<Null<String>>();
		this._root = xml;
		this._retState = E4XReturnState.Node;
		this._current = new Array<Xml>();
		if (xml != null && xml.nodeType == Xml.Document)
			this._current.push(xml.firstElement());
		else if (xml != null) this._current.push(xml);
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
		var it:Iterator<Null<Xml>> = this._current.iterator();
		var itw:Iterator<Null<Xml>>;
		var working:Array<Xml> = null;
		var a:Array<Xml> = new Array<Xml>();
		var node:Xml;
		var i:Int = 0;
		
		while (it.hasNext())
		{
			node = it.next();
			if (node.nodeType == Xml.Element)
			{
				if (working == null) working = new Array<Xml>();
				itw = node.iterator();
				while (itw.hasNext()) working.push(itw.next());
			}
		}
		if (working != null)
		{
			it = working.iterator();
			while (it.hasNext())
			{
				node = it.next();
				if (x != null)
				{
					if (x(node, i)) a.push(node);
				}
				else a.push(node);
				i++;
			}
		}
		this._current = a;
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
		var it:Iterator<Null<Xml>> = this._current.iterator();
		var working:Array<Xml> = null;
		var a:Array<Xml> = new Array<Xml>();
		var node:Xml;
		
		while (it.hasNext())
		{
			node = it.next();
			if (node.nodeType == Xml.Element)
			{
				if (working == null) working = new Array<Xml>();
				working = working.concat(this.rec(node));
			}
			else
			{
				if (working == null) working = new Array<Xml>();
				working.push(node);
			}
		}
		if (working != null)
		{
			it = working.iterator();
			while (it.hasNext())
			{
				node = it.next();
				if (x != null)
				{
					if (x(node)) a.push(node);
				}
				else a.push(node);
			}
		}
		this._current = a;
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
		var it:Iterator<Null<Xml>> = this._current.iterator();
		var itw:Iterator<Null<Xml>>;
		var working:Array<Xml> = null;
		var a:Array<Xml> = new Array<Xml>();
		var node:Xml;
		var pnode:Xml;
		var i:Int = 0;
		
		while (it.hasNext())
		{
			node = it.next();
			pnode = node.parent;
			if (pnode != null)
			{
				if (working == null) working = new Array<Xml>();
				if (!Lambda.has(working, pnode)) working.push(pnode);
				else if (working.length == 0) working = null;
			}
		}
		if (working != null)
		{
			it = working.iterator();
			while (it.hasNext())
			{
				node = it.next();
				if (x != null)
				{
					if (x(node, i)) a.push(node);
				}
				else a.push(node);
				i++;
			}
		}
		this._current = a;
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
		var it:Iterator<Null<Xml>> = this._current.iterator();
		var ait:Iterator<String>;
		var node:Xml;
		var atts:Hash<String> = null;
		var allatts:Array<Hash<String>> = new Array<Hash<String>>();
		var s:String;
		var vs:String;
		var a:Array<Xml> = new Array<Xml>();
		
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
					if (atts == null) atts = new Hash<String>();
					s = ait.next();
					atts.set(s, node.get(s));
					a.push(node);
				}
				else 
				{
					s = ait.next();
					vs = node.get(s);
					if (x(s, vs, node))
					{
						if (atts == null) atts = new Hash<String>();
						atts.set(s, vs);
						a.push(node);
					}
				}
			}
			if (atts != null) allatts.push(atts);
		}
		this._attributes = allatts;
		this._current = a;
		this._retState = E4XReturnState.Attribute;
		return this;
	}
	
	/*public function ns(?x:Null<Xml>->Bool):E4X
	{
		
		return this;
	}
	
	public function v(?x:Null<Xml>->Bool):E4X
	{
		
		return this;
	}*/
	
	/**
		Filters text nodes.
		<p class="code">param</p>	?x	A callback to execute on each <b>text</b> node.
		Note: the child list is not copied.
		Note: if no callback provided, all <b>text</b> nodes are included in result.
		<p class="code">return</p> new E4X, you can chain the further calls to it.
	**/
	public function text(?x:Null<String>->Xml->Bool):E4X
	{
		var it:Iterator<Null<Xml>> = this._current.iterator();
		var itt:Iterator<Null<Xml>>;
		var itw:Iterator<Null<String>>;
		var working:Array<Null<String>> = null;
		var a:Array<Null<String>> = new Array<Null<String>>();
		var ca:Array<Xml> = new Array<Xml>();
		var node:Xml;
		var vnode:Xml;
		var tnode:String;
		var i:Int = 0;
		
		while (it.hasNext())
		{
			node = it.next();
			if (node.nodeType == Xml.Element)
			{
				itt = node.iterator();
				while (itt.hasNext())
				{
					vnode = itt.next();
					if (vnode.nodeType == Xml.CData || vnode.nodeType == Xml.PCData)
					{
						if (working == null) working = new Array<Null<String>>();
						working.push(vnode.nodeValue);
						ca.push(vnode);
					}
				}
			}
			else if (node.nodeType == Xml.CData || node.nodeType == Xml.PCData)
			{
				if (working == null) working = new Array<Null<String>>();
				working.push(node.nodeValue);
				ca.push(node);
			}
		}
		if (working != null)
		{
			itw = working.iterator();
			while (itw.hasNext())
			{
				tnode = itw.next();
				if (x != null)
				{
					if (x(tnode, ca[i]))
					{
						i++;
						a.push(tnode);
					}
					else ca.splice(i, 1);
				}
				else
				{
					i++;
					a.push(tnode);
				}
			}
		}
		this._current = ca;
		this._texts = a;
		this._retState = E4XReturnState.Text;
		return this;
	}
	
	/**
		Call this at the end of the procedure if you need the last result returned after filtering.
		<p class="code">return</p> If the last operation filtered either child nodes or descendant nodes or parent nodes
		the returned value will be of type Array&lt;Xml&gt;. If the last operation filtered attributes
		the return value will be of type Arrat&lt;Hash&lt;String&gt;&gt;. If the last operation
		filtered text nodes, the return value will be of type Array&lt;Null&lt;String&gt;&gt;.
	**/
	public function exec():Iterator<Dynamic>
	{
		var u:Array<Dynamic> = null;
		switch (this._retState)
		{
			case      Node: u = this._current;
			case Attribute: u = this._attributes;
			case      Text: u = this._texts;
		}
		return u.iterator();
	}
	public function retNodes():Iterator<Xml>
	{
		return _current.iterator();
	}
	public function retAttribs():Iterator<Hash<String>>
	{
		return _attributes.iterator();
	}
	public function retText():Iterator<Null<String>>
	{
		return _texts.iterator();
	}
	public function has():Bool
	{
		switch (this._retState)
		{
			case      Node: return this._current.length>0;
			case Attribute: return this._attributes.length>0;
			case      Text: return this._texts.length > 0;
		}
		throw "Invalid return code";
	}
	
	private function rec(node:Xml):Array<Xml>
	{
		var ret:Array<Xml> = null;
		if (node.nodeType != Xml.Element)
		{
			ret = new Array<Xml>();
			ret.push(node);
			return ret;
		}
		var tmp:Array<Xml>;
		var it:Iterator<Xml> = node.iterator();
		var n:Xml;
		while (it.hasNext())
		{
			if (ret == null) ret = new Array<Xml>();
			n = it.next();
			tmp = this.rec(n);
			ret.push(n);
			if (tmp != null) ret = ret.concat(this.rec(n));
		}
		return ret;
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

#else

enum E4XReturnState {
	Node;
	Attribute;
	Text;
}

#end