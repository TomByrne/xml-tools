/****
* Copyright 2015 tbyrne.org All rights reserved.
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
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Tools;
import haxe.macro.Type;

class XmlToCode 
{

	macro public static function path(path:String, ?scope:Expr):Expr {
		return interpXmlFile(path, scope);
	}
	macro public static function trace(e:Expr):Expr {
		trace(e);
		return macro null;
	}
	
	#if macro
	
	private static var _done:Map<String, Bool> = new Map();
	
	private static function interpXmlFile(path:String, ?scope:Expr):Expr {
		var pos = Context.currentPos();
		
		var firstChar = path.charAt(0);
		if (firstChar == "/" || firstChar == "\\") {
			var classFile = Context.getPosInfos(pos).file;
			var lastSlash:Int = classFile.lastIndexOf("/");
			if (lastSlash == -1) {
				lastSlash = classFile.lastIndexOf("\\");
			}
			if(lastSlash!=-1){
				path = classFile.substr(0,lastSlash) + path;
			}
		}
		var content = sys.io.File.getContent(path);
		var xmlWithPos = XmlPosParser.parse(content, path);
		return interpXml(xmlWithPos.getPos, xmlWithPos.getRoot().firstElement(), scope);
	}
	
	private static function interpXml(posLookup:Xml->String->Position, xml:Xml, ?scope:Expr):Expr {
		var exprs:Array<Expr> = [];
		interpElement(posLookup, scope, xml, exprs);
		if(exprs.length==1){
			return exprs[0];
		}else {
			return { expr:EBlock(exprs), pos:posLookup(xml, null) };
		}
	}
	private static function interpElement(posLookup:Xml->String->Position, within:Expr, tag:Xml, addTo:Array<Expr>):Void {
		switch(tag.nodeName) {
			case "var": interpVar(posLookup, within, tag, addTo);
			case "class": interpClass(posLookup, tag, addTo);
			case "meth": interpFunc(posLookup, tag, addTo, within);
			default: Context.warning("Unknown tag: "+tag.nodeName, posLookup(tag, null));
		}
	}
	private static function interpClass(posLookup:Xml->String->Position, tag:Xml, addTo:Array<Expr>):Void {
		var classpath:String = tag.get("classpath");
		var pos = posLookup(tag, null);
		
		try {
			var type:Type;
			if ((type = Context.getType(classpath)) != null) {
				if (_done.exists(classpath)) {
					addTo.push(Context.parse(classpath, pos));
				}else{
					Context.error("Error generating class, " + classpath + " already exists", pos);
				}
				return;
			}
		}catch(e:Dynamic){}
		
		var fields:Array<Field> = [];
		for (child in tag.elements()) {
			switch(child.nodeName) {
				case "meth": interpMeth(posLookup, child, fields);
				default: Context.warning("Unknown tag: "+child.nodeName, posLookup(child, null));
			}
		}
		
		_done.set(classpath, true);
		var pack = classpath.split(".");
		var name:String = pack.pop();
		var typeDef:TypeDefinition = { pack:pack, name:name, pos:pos , meta:[{ name : "CodeGenMacro", params :[], pos : pos }], params:[], isExtern:false, kind:TDClass(), fields:fields};
		Context.defineType(typeDef);
		var classE:Expr = Context.parse(classpath, pos);
		addTo.push(Context.parse(classpath, pos));
	}
	private static function interpMeth(posLookup:Xml->String->Position, tag:Xml, addTo:Array<Field>):Void {
		var name:String = tag.get("name");
		var pos = posLookup(tag, null);
		var access:Array<Access> = [];
		if (tag.get("static") == "true") access.push(AStatic);
		if (tag.get("public") == "true") access.push(APublic);
		else access.push(APrivate);
		
		var scope:String = tag.get("scope");
		var scopeE:Expr;
		if (scope != null && scope.length != 0) {
			scopeE = Context.parse(scope, pos);
		}
		
		var func:Function = createFunc(posLookup, tag, scopeE);
		addTo.push({ name:name, access:access, kind:FFun(func), pos:pos});
	}
	private static function interpFunc(posLookup:Xml->String->Position, tag:Xml, addTo:Array<Expr>, within:Expr):Void {
		var pos = posLookup(tag, null);
		var func:Function = createFunc(posLookup, tag, null);
		var funcE:Expr = { expr:EFunction(null, func), pos:pos }
		var ident:Expr;
		
		var name:String = tag.get("name");
		if (name != null && name.length > 0) {
			addTo.push( { expr : EVars([ { expr : funcE, name : name, type : null } ]), pos : posLookup(tag, "name") } );
			ident = Context.parse(name, pos);
		}else {
			ident = funcE;	
		}
		
		
		var addCall:String = tag.get("addCall");
		if (addCall != null && addCall.length > 0) {
			pos = posLookup(tag, "addCall");	
			if (within == null) {
				addTo.push( { expr : ECall( Context.parse(addCall, pos), [ ident ]), pos : pos } );
			}else {
				addTo.push( { expr : ECall( { expr : EField( within, addCall), pos : pos }, [ ident ]), pos : pos } );
			}
		}
	}
	private static function createFunc(posLookup:Xml->String->Position, tag:Xml, within:Expr):Function{
		var args:Array<FunctionArg> = [];
		var pos = posLookup(tag, null);
		
		for (att in tag.attributes()) {
			var nameStart:String = att.substr(0, 2);
			if (nameStart=="a-") {
				createArg(args, att.substr(2), tag.get(att), false);
			}
		}
		for (child in tag.elements()) {
			var nameStart:String = child.nodeName.substr(0, 2);
			if (nameStart == "a-") {
				createArg(args, child.nodeName.substr(2), child.get("value"), child.get("opt")=="true");
			}
		}
		
		var exprs:Array<Expr> = [];
		interpBlock(posLookup, within, tag, exprs);
		var expr:Expr;
		
		var retVal:String = tag.get("ret");
		if (retVal != null && retVal.length > 0) {
			exprs.push(Context.parse("return "+retVal, pos) );
		}
		if(exprs.length==1){
			expr = exprs[0];
		}else {
			expr = { expr:EBlock(exprs), pos:pos };
		}
		/*createComplexType(tag.get("ret-type"))*/
		return { args:args, ret:null , expr: { expr:EBlock(exprs), pos:pos }, params:[] };
	}
	private static function createArg(addTo:Array<FunctionArg>, name:String, value:String, opt:Bool):Void {
		addTo.push( { name:name, opt:opt, type:createComplexType(value)} );
	}
	private static function createComplexType(type:String):Null<ComplexType> {
		if (type == null || type.length == 0) {
			return null;
		}else {
			var pack = type.split(".");
			var name:String = pack.pop();
			return TPath( { pack:pack, name:name, params:[] } ) ;
		}
	}
	private static function interpVar(posLookup:Xml->String->Position, within:Expr, tag:Xml, addTo:Array<Expr>):Void {
		var pos = posLookup(tag, "type");
		var type:String = tag.get("type");
		var hasType = type != null && type.length > 0;
		
		var value:String = getAttOrText(tag, "value");
		var hasValue = value != null && value.length > 0;
		
		var nameE:Expr;
		var subWithin:Expr;
		if(hasType || hasValue){
			
			var name:String = tag.get("name");
			if(name==null || name.length==0)name = "obj_" + addTo.length;
			nameE = Context.parse(name, pos);
			
			var instant:Expr;
			if (hasValue) {
				pos = posLookup(tag, "value");
				instant = Context.parse(value, pos);
			}else {
				var instantPos;
				var params:String = tag.get("params");
				if (params == null) {
					params = "";
				}else {
					pos = posLookup(tag, "params");
				}
				
				// instantiate
				instant = Context.parse("new " + type + "(" + params + ")", pos);
			}
			addTo.push( { expr : EVars([ { expr : instant, name : name, type : null } ]), pos : pos } );
			subWithin = nameE;
		}else{
			subWithin = within;
		}
		
		var subExprs:Array<Expr> = [];
		interpBlock(posLookup, subWithin, tag, subExprs);
		
		if (subExprs.length>0) {
			addTo.push( { expr : EBlock(subExprs), pos : pos } );
		}
		
		if(type!=null && type.length>0){
			// add to parent
			var addCall:String = tag.get("addCall");
			if (addCall != null && addCall.length > 0) {
				if (within == null) {
					addTo.push( { expr : ECall( Context.parse(addCall, pos), [ nameE ]), pos : pos } );
				}else {
					addTo.push( { expr : ECall( { expr : EField( within, addCall), pos : pos }, [ nameE ]), pos : pos } );
				}
			}
		}
	}
	private static function getAttOrText(within:Xml, name:String):Null<String> {
		if(within.exists(name)){
			return within.get(name);
		}else {
			var children = within.elementsNamed(name);
			var ret:String;
			for (child in children) {
				for (subChild in child) {
					if (subChild.nodeType != Xml.CData) continue;
					
					if (ret == null) {
						ret = subChild.toString();
					}else {
						ret += " "+subChild.toString();
					}
				}
			}
			return ret;
		}
	}
	private static function interpBlock(posLookup:Xml->String->Position, within:Expr, tag:Xml, addTo:Array<Expr>):Void {
		for (att in tag.attributes()) {
			var nameStart:String = att.substr(0, 2);
			if (nameStart=="m-") {
				callMethod(posLookup(tag, att), addTo, within, att.substr(2), tag.get(att));
			}else if (nameStart == "p-") {
				setProp(posLookup(tag, att), addTo, within, att.substr(2), tag.get(att));
			}
		}
		
		for (child in tag.elements()) {
			var nameStart:String = child.nodeName.substr(0, 2);
			if (nameStart == "m-") {
				var params = child.get("params");
				callMethod(posLookup(child, "params"), addTo, within, child.nodeName.substr(2), params);
				
			}else if (nameStart == "p-") {
				setProp(posLookup(child, "value"), addTo, within, child.nodeName.substr(2), child.get("value"));
				
			}else if (nameStart == "a-") {
				// ignore
				
			}else{
				interpElement(posLookup, within, child, addTo);
			}
		}
	}
	private static function setProp(pos:Position, addTo:Array<Expr>, within:Expr, prop:String, value:String):Void {
		var field:Expr;
		if (within == null) {
			field = Context.parse(prop, pos);
		}else {
			field = { expr : EField(within, prop), pos : pos };
		}
		addTo.push( { expr : EBinop(OpAssign, field, Context.parse(value, pos)), pos : pos } );
	}
	private static function callMethod(pos:Position, addTo:Array<Expr>, within:Expr, meth:String, params:String):Void {
		var argsE:Expr = Context.parse("[" + params + "]", pos);
		var args:Array<Expr>;
		switch(argsE.expr) {
			case EArrayDecl(arr):
				args = arr;
			default: throw "Something went wrong";
		}
		var field:Expr;
		if (within == null) {
			field = Context.parse(meth, pos);
		}else {
			field = { expr : EField(within, meth), pos : pos };
		}
		addTo.push( { expr : ECall( field, args), pos : pos } );
	}
	
	#end
}