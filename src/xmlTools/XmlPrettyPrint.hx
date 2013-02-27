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
			/*case Xml.Prolog:
				return "\n" + tabs + "<? " + xml.nodeValue + "?>";*/
				
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
				/*case Xml.Prolog:
					prologueStr += printNode(elem, tabs);*/
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