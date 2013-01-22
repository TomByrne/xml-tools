package ;

import haxe.macro.Expr;
import xmlTools.E4X;
/**
 * ...
 * @author Tom Byrne
 */

class TestE4XMacro 
{
	public static function main() {
		
		var within:Xml = null;
		var url:String = "url";
		
		
		
		test("Children", within.child(), E4X.doRetNodes(E4X.getNew(within).child()));
		
		test("Descendants", within.desc(), E4X.doRetNodes(E4X.getNew(within).desc()));
		
		test("Descendant Shortcut", within._, E4X.doRetNodes(E4X.getNew(within).desc()));
		
		test("Descendant Shortcut With Filter", within._("Steve"), E4X.doRetNodes(E4X.getNew(within).desc(function(xml:Xml):Bool { return xml.nodeType==Xml.Element && xml.nodeName == "Steve"; } )));
		
		test("Descendant Shortcut With Attribute", within._(a("att")), E4X.doRetNodes(E4X.getNew(within).desc(function(xml:Xml):Bool return E4X.doHasAttribs(E4X.getNew(xml).a(function(attName:String, attVal:String, xml:Xml):Bool { return attName == "att"; })) )));
		
		test("Child Has Attribute", within.a("id"), E4X.doRetAttribs(E4X.getNew(within).a(function(attName:String, attVal:String, xml:Xml):Bool { return attName == "id"; } )));
		
		test("Child Non-Null Attribute", within.child(a("id") != null), E4X.doRetNodes(E4X.getNew(within).child(function(xml:Xml, _i:Int):Bool return E4X.doHasAttribs(E4X.getNew(xml).a(function(attName:String, attVal:String, xml:Xml):Bool {  return attName == "id"; } )) != null )));
		
		test("Child by name", within.node, E4X.doRetNodes(E4X.getNew(within).child(function(xml:Xml, _i:Int):Bool { return xml.nodeName == "node";} )));
		
		test("Descendant by name", within._.node, E4X.doRetNodes(E4X.getNew(within).desc().child(function(xml:Xml, _i:Int):Bool { return xml.nodeName == "node";} )));
		
		test("Desc. Text node of min size", within._.text(text.length > 10), E4X.doRetText(E4X.getNew(within).desc().text(function(text:Null<String>, xml:Xml):Bool return text.length > 10 )));
		
		test("Desc. Nodes with name", within._(nodeName == url), E4X.doRetNodes(E4X.getNew(within).desc(function(xml:Xml):Bool return xml.nodeName == url )));
		
		test("Desc. Nodes with name & Attrib.", within._(nodeName == url && a(url)), E4X.doRetNodes(E4X.getNew(within).desc(function(xml:Xml):Bool return xml.nodeName == url && E4X.doHasAttribs(E4X.getNew(xml).a(function(attName:String, attVal:String, xml:Xml):Bool {return attName == url;} )) )));
		
		
		
	}
	
	@:macro public static function test(testName:String, expr:Expr, match:Expr):Expr {
		expr = E4X.doE4X(expr, true, false, null, true, null);
		var s1:String = cleanStr(Std.string(expr));
		var s2:String = cleanStr(Std.string(match));
		if (s1!=s2) {
			trace("Test Failed: "+testName);
			trace(s1);
			trace(s2);
		}
		return expr;
	}
	
	#if macro
	private static function cleanStr(str:String):String {
		var reg = ~/#pos\(.*?\)/g;
		str = reg.replace(str, "pos");
		
		reg = ~/, sub => null/g;
		str = reg.replace(str, "");
		
		reg = ~/, value => null/g;
		str = reg.replace(str, "");
		
		return str;
	}
	#end
}