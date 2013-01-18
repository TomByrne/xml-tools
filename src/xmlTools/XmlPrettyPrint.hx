package xmlTools;

/**
 * ...
 * @author Tom Byrne
 */

class XmlPrettyPrint 
{

	public static function print(xml:Xml):String 
	{
		var ret:String = printNode(xml, "");
		if (ret.charAt(0) == "\n") {
			return ret.substr(1);
		}else {
			return ret;
		}
	}
	
	private static function printNode(xml:Xml, tabs:String):String 
	{
		switch(xml.nodeType) {
			case Xml.PCData:
				var val:String = xml.nodeValue;
				if (isWhitespace(val)) {
					return "";
				}else{
					return val;
				}
			case Xml.CData:
				return "\n" + tabs + "<![CDATA[" + xml.nodeValue + "]]>";
			case Xml.Comment:
				return "\n" + tabs + "<!--" + xml.nodeValue + "-->";
			case Xml.DocType:
				return "\n" + tabs + "<!DOCTYPE " + xml.nodeValue + ">";
			case Xml.Prolog:
				return "\n" + tabs + "<? " + xml.nodeValue + "?>";
				
			case Xml.Document:
				return printNodes(xml.iterator(), tabs);
			case Xml.Element:
				var atts = xml.attributes();
				var attrStr:String = "";
				for (att in atts) {
					attrStr += " " + att + "=" + xml.get(att);
				}
				
				var elemStr = printNodes(xml.iterator(), tabs+"\t");
				
				if (elemStr.length > 0) {
					return "\n" + tabs+"<" + xml.nodeName + attrStr+">"+elemStr+"\n"+tabs+"</"+xml.nodeName+">";
				}else {
					return "\n" + tabs+"<" + xml.nodeName + attrStr+"/>";
				}
		}
	}
	private static function printNodes(elems:Iterator<Xml>, tabs:String):String {
		var docTypeStr:String = "";
		var prologueStr:String = "";
		var elemStr:String = "";
		for (elem in elems) {
			switch(elem.nodeType) {
				case Xml.DocType:
					docTypeStr += printNode(elem, tabs);
				case Xml.Prolog:
					prologueStr += printNode(elem, tabs);
				default:
					elemStr += printNode(elem, tabs);
			}
		}
		return docTypeStr+prologueStr+elemStr;
	}
	private static function isWhitespace(str:String):Bool {
		for (i in 0... str.length) {
			var char:String = str.charAt(i);
			if (char != " " && char != "\t" && char != "\n" && char != "\r") {
				return false;
			}
		}
		return true;
	}
}