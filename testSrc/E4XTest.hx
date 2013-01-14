package ;

import haxe.macro.Expr;
/**
 * ...
 * @author Tom Byrne
 */

class E4XTest 
{
	public static function main() {
		
		var within:Xml = null;
		
		test("Children", within.child(), new E4X(within).child().exec());
		
		test("Descendants", within.desc(), new E4X(within).desc().exec());
		
		test("Descendant Shortcut", within._, new E4X(within).desc().exec());
		
		test("Descendant Shortcut With Filter", within._("Steve"), new E4X(within).desc(function(xml:Xml):Bool { return xml.nodeName == "Steve"; } ).exec());
		
		test("Child Has Attribute", within.a("id"), new E4X(within).a(function(attName:String, attVal:String, xml:Xml):Bool { return attName == "id"; } ).exec());
		
		test("Child Non-Null Attribute", within.child(a("id") != null), new E4X(within).child(function(xml:Xml, _i:Int):Bool return new E4X(xml).a(function(attName:String, attVal:String, xml:Xml):Bool {  return attName == "id"; } ).has() != null ).exec());
		
		test("Child by name", within.node, new E4X(within).child(function(xml:Xml, _i:Int):Bool { return xml.nodeName == "node";} ).exec());
		
		test("Descendant by name", within._.node, new E4X(within).desc().child(function(xml:Xml, _i:Int):Bool { return xml.nodeName == "node";} ).exec());
		
		test("Desc. Text node of min size", within._.text(text.length > 10), new E4X(within).desc().text(function(text:Null<String>, xml:Xml):Bool return text.length > 10 ).exec());
		
		var url:String = "url";
		test("Desc. Nodes with name & Attrib.", within._(nodeName == "xml" && a(url)), new E4X(within).desc(function(xml:Xml):Bool return xml.nodeName == "xml" && new E4X(xml).a(function(attName:String, attVal:String, xml:Xml):Bool {return attName == url;} ).has() ).exec());
		
		
		
	}
	
	@:macro public static function test(testName:String, expr:Expr, match:Expr):Expr {
		expr = E4X.doE4X(expr, true, false, null, null, "exec");
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