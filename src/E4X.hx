package ;
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
		var pos = Context.currentPos();
		trace("before: "+expr);
		expr = doE4X(expr, true, false, null);
		trace("after: "+expr);
		//return { expr : ECall({ expr : EField(expr,"exec"), pos : pos },[]), pos : pos }; // calls the exec() method
		return expr;
	}
	@:macro public static function trace(expr:Expr):Expr {
		trace(expr);
		return expr;
	}
	
	#if macro
	
	private static var DESC_SHORTCUT:String = "_";
	private static var DESC_METHOD:String = "desc";
	private static var ATTR_METHOD:String = "a";
	
	
	private static function doE4X(expr:Expr, wrapField:Bool, allowBlock:Bool, makeFieldOf:String):Expr {
		var isWrapped:IsWrappedFlag = { wrapped:false };
		expr = checkExpr(expr, wrapField, allowBlock, makeFieldOf, isWrapped);
		if (isWrapped.wrapped) {
			return macro $expr.exec();
		}else{
			return expr;
		}
	}
	
	/**
	 * Loops through an expression and does some things:
		 * Wraps the initial Xml object in an E4X instance  - i.e. within.node -> new E4X(within).node
		 * Changes property access to child() calls  - i.e. xml.node -> xml.child(function(xml:Xml, i:Int):Bool{return xml.nodeName=="node";})
		 * Wraps string expressions in nodeName checking functions  - i.e. xml.desc("node") -> xml.desc(function(xml:Xml, i:Int):Bool{return xml.nodeName=="node";})
		 * Wraps expressions in functions  - i.e. xml.desc(a("id")!=null)) -> xml.desc(function(xml:Xml, i:Int):Bool{return xml.a("id")!=null;})
		 * Converts underscore to descendants call - i.e. xml._ -> xml.desc()        &        xml._(a("id")!=null) ->  xml.desc(function(xml:Xml, i:Int):Bool{return xml.a("id")!=null;})
	 */
	private static function checkExpr(expr:Expr, wrapField:Bool, allowBlock:Bool, makeFieldOf:String, isWrapped:IsWrappedFlag):Expr {
		var pos = expr.pos;
		var exprDef = expr.expr;
		switch(exprDef) {
			case EBlock(eArr):
				if (allowBlock) {
					for (i in 0 ... eArr.length) {
						eArr[i] = doE4X(eArr[i], wrapField, allowBlock, makeFieldOf);
					}
					return { expr:EBlock(eArr), pos:pos };
				}else{
					throw "E4X can't handle blocks of code, just a single expression";
				}
			case ECall(e, params):
				// change function calls from '_' to 'desc'
				var attrMode:Bool = false;
				trace("meth: "+e);
				switch(e.expr) {
					case EField(e2, field):
						trace("meth name: "+field);
						if (field == DESC_SHORTCUT) {
							e.expr = EField(e2, DESC_METHOD);
						}
						if (field == ATTR_METHOD) {
							attrMode = true;
						}
					case EConst(c):
						switch(c) {
							case CIdent(s):
								trace("meth name: "+s);
								if (s == DESC_SHORTCUT) {
									e.expr = EConst(CIdent(DESC_METHOD));
								}
								if (s == ATTR_METHOD) {
									attrMode = true;
								}
							default: // ignore
						}
					default:
						// ignore
				}
				for (i in 0 ... params.length) {
					params[i] = checkParam(params[i], attrMode, isWrapped);
				}
				return { expr : ECall( checkExpr(e, false, allowBlock, makeFieldOf, isWrapped), params), pos : pos };
			case EConst(c):
				switch(c) {
					case CIdent(s):
						if (makeFieldOf!=null) {
							expr = { expr:EField( { expr:EConst(CIdent(makeFieldOf)), pos:pos }, s), pos:pos };
							return checkExpr(expr, wrapField, allowBlock, null, isWrapped);
						}else if (!wrapField) {
							return expr;
						}else {
							isWrapped.wrapped = true;
							return macro new E4X($expr);
						}
					default:
						return expr;
				}
			case EField(e, field):
				if (!wrapField) {
					var checked:Expr = checkExpr(e, true, allowBlock, makeFieldOf, isWrapped);
					return { expr : EField(checked,field), pos : pos };
				}else{
					if (field == DESC_SHORTCUT) {
						return macro $e.desc();
					}else {
						// wrap prop access in child() call
						trace("child: "+field);
						e = checkExpr(e, true, allowBlock, makeFieldOf, isWrapped);
						var check = createNameChecker(field, pos);
						return macro $e.child($check);
					}
				}
			case EBinop( op , e1 , e2 ):
				trace("EBinop: "+e1);
				return { expr:EBinop(op, doE4X(e1, wrapField, allowBlock, makeFieldOf), doE4X(e1, wrapField, allowBlock, makeFieldOf)), pos:pos };
			default:
				return expr;
		}
	}
	private static function createNameChecker(name:String, pos:Position):Expr {
		var nameE = {expr:EConst(CString(name)), pos:pos};
		return macro function(xml:Xml, _i:Int):Bool { return xml.nodeName == $nameE; };
	}
	private static function checkParam(expr:Expr, attributeCall:Bool, isWrapped:IsWrappedFlag):Expr {
		trace("checkParam: "+attributeCall+" "+expr);
		var pos = expr.pos;
		var exprDef = expr.expr;
		switch(exprDef) {
			case EConst(c):
				switch(c) {
					case CString(s):
						trace("    name: "+s);
						var strE = {expr:EConst(CString(s)), pos:pos};
						if(attributeCall){
							expr = macro { return attName == $strE; };
						}else {
							expr = macro { return xml.nodeName == $strE; };
						}
					default:
						expr = checkExpr(expr, true, true, "xml", isWrapped);
				}
			case EFunction( name , f ):
				trace("FUNK: "+name);
				f.expr = checkExpr(f.expr, true, true, "xml", isWrapped);
				return { expr:EFunction(name, f), pos:pos };
			default:
				expr = checkExpr(expr, true, false, "xml", isWrapped);
		}
		if(attributeCall){
			return macro function(attName:String, attVal:String, xml:Xml):Bool $expr;
		}else {
			return macro function(xml:Xml, _i:Int):Bool $expr;
		}
	}
	
	#else
	
	private var _root:Xml;
	private var _parent:Xml;
	private var _current:Array<Xml>;
	private var _attributes:Array<Hash<String>>;
	private var _texts:Array<Null<String>>;
	private var _retCode:Int;
	
	/**
		Creates new walking operation.
		<p class="code">param</p>	value	The XML document or fragment to start walking from.
	**/
	public function new(value:Xml)
	{
		this._root = value;
		this._retCode = 0;
		this._current = new Array<Xml>();
		if (value != null && value.nodeType == Xml.Document)
			this._current.push(value.firstElement());
		else if (value != null) this._current.push(value);
	}
	
	/**
		Creates new walking operation.
		<p class="code">param</p>	value	The XML document or fragment to start walking from.
		Note: if XML document is passed, the firstElement is used.
		<p class="code">return</p> new walker, you can chain the further calls to it.
	**/
	//public static function walk(value:Xml):E4X { return new E4X(value); }
	
	/**
		Filters child nodes.
		<p class="code">param</p>	?x	A callback to execute on each <b>child</b> node.
		Note: the child list is not copied.
		Note: if no callback provided, all <b>child</b> nodes are included in result.
		<p class="code">return</p> new walker, you can chain the further calls to it.
	**/
	public function child(?x:Null<Xml>->Int->Bool):E4X
	{
		var it:Iterator<Null<Xml>> = this._current.iterator();
		var itw:Iterator<Null<Xml>>;
		var working:Array<Xml> = null;
		var a:Array<Xml> = null;
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
				if (a == null) a = new Array<Xml>();
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
		this._retCode = 0;
		return this;
	}
	
	/**
		Filters child nodes.
		<p class="code">param</p>	?x	A callback to execute on each <b>descendant</b> node.
		Note: the child list is not copied.
		Note: if no callback provided, all <b>descendant</b> nodes are included in result.
		<p class="code">return</p> new walker, you can chain the further calls to it.
	**/
	public function desc(?x:Null<Xml>->Bool):E4X
	{
		var it:Iterator<Null<Xml>> = this._current.iterator();
		var working:Array<Xml> = null;
		var a:Array<Xml> = null;
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
				if (a == null) a = new Array<Xml>();
				node = it.next();
				if (x != null)
				{
					if (x(node)) a.push(node);
				}
				else a.push(node);
			}
		}
		this._current = a;
		this._retCode = 0;
		return this;
	}
	
	/**
		Filters ancestor nodes.
		<p class="code">param</p>	?x	A callback to execute on each <b>parent</b> node.
		Note: the child list is not copied.
		Note: if no callback provided, all <b>parent</b> nodes are included in result.
		<p class="code">return</p> new walker, you can chain the further calls to it.
	**/
	public function ances(?x:Null<Xml>->Int->Bool):E4X
	{
		var it:Iterator<Null<Xml>> = this._current.iterator();
		var itw:Iterator<Null<Xml>>;
		var working:Array<Xml> = null;
		var a:Array<Xml> = null;
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
				if (a == null) a = new Array<Xml>();
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
		this._retCode = 0;
		return this;
	}
	
	/**
		Filters attributes.
		<p class="code">param</p>	?x	A callback to execute on each <b>attribute</b> node.
		Note: the child list is not copied.
		Note: if no callback provided, all <b>attribute</b> nodes are included in result.
		<p class="code">return</p> new walker, you can chain the further calls to it.
	**/
	public function a(?x:String->String->Xml->Bool):E4X
	{
		var it:Iterator<Null<Xml>> = this._current.iterator();
		var ait:Iterator<String>;
		var node:Xml;
		var atts:Hash<String> = null;
		var allatts:Array<Hash<String>> = null;
		var s:String;
		var vs:String;
		var a:Array<Xml> = null;
		
		while (it.hasNext())
		{
			node = it.next();
			if (node.nodeType != Xml.Element) continue;
			ait = node.attributes();
			atts = null;
			if (allatts == null) allatts = new Array<Hash<String>>();
			while (ait.hasNext())
			{
				if (x == null)
				{
					if (atts == null) atts = new Hash<String>();
					s = ait.next();
					atts.set(s, node.get(s));
					if (a == null) a = new Array<Xml>();
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
						if (a == null) a = new Array<Xml>();
						a.push(node);
					}
				}
			}
			if (atts != null) allatts.push(atts);
		}
		this._attributes = allatts;
		this._current = a;
		this._retCode = 1;
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
		<p class="code">return</p> new walker, you can chain the further calls to it.
	**/
	public function text(?x:Null<String>->Xml->Bool):E4X
	{
		var it:Iterator<Null<Xml>> = this._current.iterator();
		var itt:Iterator<Null<Xml>>;
		var itw:Iterator<Null<String>>;
		var working:Array<Null<String>> = null;
		var a:Array<Null<String>> = null;
		var ca:Array<Xml> = null;
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
						if (ca == null) ca = new Array<Xml>();
						ca.push(vnode);
					}
				}
			}
			else if (node.nodeType == Xml.CData || node.nodeType == Xml.PCData)
			{
				if (working == null) working = new Array<Null<String>>();
				working.push(node.nodeValue);
				if (ca == null) ca = new Array<Xml>();
				ca.push(node);
			}
		}
		if (working != null)
		{
			itw = working.iterator();
			while (itw.hasNext())
			{
				if (a == null) a = new Array<Null<String>>();
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
		this._retCode = 2;
		return this;
	}
	
	/**
		Call this at the end of the procedure if you need the last result returned after filtering.
		<p class="code">return</p> If the last operation filtered either child nodes or descendant nodes or parent nodes
		the returned value will be of type Array&lt;Xml&gt;. If the last operation filtered attributes
		the return value will be of type Arrat&lt;Hash&lt;String&gt;&gt;. If the last operation
		filtered text nodes, the return value will be of type Array&lt;Null&lt;String&gt;&gt;.
	**/
	public function exec():Dynamic
	{
		var u:Dynamic = null;
		switch (this._retCode)
		{
			case 0: u = this._current;
			case 1: u = this._attributes;
			case 2: u = this._texts;
		}
		return u;
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

typedef IsWrappedFlag = {
	var wrapped:Bool;
}