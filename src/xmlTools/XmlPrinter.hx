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

class XmlPrinter 
{

	public static function print(xml:Xml, addDecl:Bool=false, whitespace:WhiteSpaceType=null):String 
	{
		if (whitespace == null) whitespace = WhiteSpaceType.TABS;
		
		var spaceStr:String;
		var newlineStr:String;
		switch(whitespace) {
			case WhiteSpaceType.TABS:
				spaceStr = "\t";
				newlineStr = "\n";
				
			case WhiteSpaceType.SPACES(count):
				spaceStr = "";
				for (i in 0 ... count) spaceStr += " ";
				newlineStr = "\n";
				
			default:
				spaceStr = "";
				newlineStr = "";
		}
		
		var ret:String = printNode(xml, "", spaceStr, newlineStr);
		var decl:String = (addDecl?'<?xml version="1.0" encoding="UTF-8"?>\n':'');
		if (ret.charAt(0) == "\n") {
			return decl+ret.substr(1);
		}else {
			return decl+ret;
		}
	}
	
	private static function printNode(xml:Xml, leadSpace:String, spaceStr:String, newlineStr:String):String 
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
				return newlineStr + leadSpace + "<![CDATA[" + xml.nodeValue + "]]>";
			case Xml.Comment:
				return newlineStr + leadSpace + "<!--" + xml.nodeValue + "-->";
			case Xml.DocType:
				return newlineStr + leadSpace + "<!DOCTYPE " + xml.nodeValue + ">";
			case Xml.ProcessingInstruction:
				trace("hm: "+xml.nodeValue);
				return newlineStr + leadSpace + "<?" + xml.nodeValue + "?>";
				
			case Xml.Document:
				return printNodes(xml.iterator(), leadSpace, spaceStr, newlineStr);
			case Xml.Element:
				var atts = xml.attributes();
				var attStrings:Array<String> = [];
				for (att in atts) {
					var attVal:String = xml.get(att);
					if (attVal.indexOf('"') == -1) {
						attStrings.push(att + "=\"" + attVal+'"');
					}else if (attVal.indexOf("'") == -1) {
						attStrings.push(att + "='" + attVal+"'");
					}else {
						attVal = StringTools.replace(attVal, '"', '\"');
						attStrings.push(att + "=\"" + attVal+'"');
					}
				}
				attStrings.sort(function(a:String, b:String):Int{
					a = a.toLowerCase();
					b = b.toLowerCase();
					if (a < b) return -1;
					if (a > b) return 1;
					return 0;
				});
				
				var attrStr:String;
				if (attStrings.length > 0) attrStr = " "+attStrings.join(" ");
				else attrStr = "";
				
				var elemStr = printNodes(xml.iterator(), leadSpace+spaceStr, spaceStr, newlineStr);
				
				if (elemStr.length > 0) {
					return newlineStr + leadSpace+"<" + xml.nodeName + attrStr+">"+elemStr+newlineStr+leadSpace+"</"+xml.nodeName+">";
				}else {
					return newlineStr + leadSpace+"<" + xml.nodeName + attrStr+"/>";
				}
			default:
				return "";
		}
	}
	private static function printNodes(elems:Iterator<Xml>, leadSpace:String, spaceStr:String, newlineStr:String):String {
		var docTypeStr:String = "";
		var prologueStr:String = "";
		var elemStr:String = "";
		for (elem in elems) {
			switch(elem.nodeType) {
				case Xml.DocType:
					docTypeStr += printNode(elem, leadSpace, spaceStr, newlineStr);
				/*case Xml.Prolog:
					prologueStr += printNode(elem, leadSpace, spaceStr, newlineStr);*/
				default:
					elemStr += printNode(elem, leadSpace, spaceStr, newlineStr);
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

enum WhiteSpaceType {
	NONE;
	TABS;
	SPACES(count:Int);
}