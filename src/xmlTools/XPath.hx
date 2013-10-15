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
import msignal.Signal;
import org.tbyrne.ProcessTick;
import xmlTools.XPath;

using Lambda;

/**
 * Currently unsupported features:
	 * following-sibling
	 * 
 * 
 * Known bugs:
	 * Strings containing "/" will break it.
 * 
 * @author Tom Byrne
 */
@:build(LazyInst.check())
class XPath
{
	private static var SCHEMES:Array<String> = ["xpath", "xpointer"];
	
	private static var ABSOLUTE_SEL:String = "/";
	private static var PATH_DELIMIT:String = "/";
	
	private static var SELECTOR_DELIMIT:String = "::";
	private static var CHILDREN_SEL:String = "child";
	private static var DESC_SEL:String = "descendant";
	private static var ANCE_SEL:String = "ancestor";
	private static var PREV_SEL:String = "following-sibling";
	private static var NEXT_SEL:String = "preceding-sibling";
	private static var THIS_SEL:String = "self";
	private static var ANCE_THIS_SEL:String = "ancestor-or-self";
	private static var DESC_THIS_SEL:String = "descendant-or-self";
	
	private static var ATT_SEL:String = "attribute::";
	
	private static var POSITION_METH:String = "position()";
	private static var LAST_METH:String = "last()";
	
	private static var ALL_FILTER:String = "*";
	
	private static var FILTER_START:String = "[";
	private static var FILTER_END:String = "]";
	
	private static var OP_EQUAL:String = "=";
	private static var OP_GRTHAN:String = "<";
	private static var OP_LSTHAN:String = ">";
	private static var EQ_OPERATORS:Array<String> = [OP_EQUAL, OP_GRTHAN, OP_LSTHAN];
	
	private static var OP_ADD:String = "+";
	private static var OP_SUB:String = "-";
	private static var MATH_OPERATORS:Array<String> = [OP_ADD, OP_SUB];
	
	private static var OP_OR:String = " or ";
	private static var LOGIC_OPERATORS:Array<String> = [OP_OR];
	
	@lazyInst
	public var stateChanged:Signal1<XPath>;
	
	
	public function getState():XPathState {
		return _state;
	}
	public function getResult():Iterable<Xml> {
		return _result;
	}
	
	
	private var _result:Array<Xml>;
	private var _context:Xml;
	private var _currContext:Array<Xml>;
	private var _path:String;
	private var _pathParts:Array<String>;
	private var _state:XPathState;
	private var _pathIndex:Int;
	private var _lastError:String;
	private var _subXPath:XPath;
	
	public function new() {
		_state = XPathState.Waiting;
	}

	public function resolve(context:Xml, path:String, stripScheme:Bool=true):Iterable<Xml> 
	{
		startResolve(context, path, stripScheme);
		while (_state == XPathState.Working) doProcess();
		return _result;
	}
	public function resolveAsync(context:Xml, path:String, stripScheme:Bool=true):Void 
	{
		startResolve(context, path, stripScheme);
		ProcessTick.tick().add(doAsyncProcess);
	}
	
	private function startResolve(context:Xml, path:String, stripScheme:Bool):Void {
		if(stripScheme){
			for (scheme in SCHEMES) {
				if (path.indexOf(scheme) == 0) {
					path = path.substring(scheme.length + 1, path.length - 1);
				}
			}
		}
		_context = context;
		_path = path;
		if (path.indexOf(ABSOLUTE_SEL) == 0) {
			path = path.substring(ABSOLUTE_SEL.length);
			_currContext = [getRoot(_context)];
		}else{
			_currContext = [_context];
		}
		_pathParts = path.split(PATH_DELIMIT);
		_pathIndex = 0;
		setState(XPathState.Working);
	}
	
	private function doAsyncProcess() {
		var start:Float = haxe.Timer.stamp();
		while (haxe.Timer.stamp() - start < 1000 / 60) {
			if (_state != XPathState.Working) {
				ProcessTick.tick().remove(doAsyncProcess);
			}else{
				doProcess();
			}
		}
	}
	private function doProcess(){
		if (_pathIndex == _pathParts.length) {
			_result = _currContext;
			setState(XPathState.Succeeded);
			return;
		}
		var part:String = _pathParts[_pathIndex];
		var selIndex:Int = part.indexOf(SELECTOR_DELIMIT);
		if (selIndex == -1) {
			if (_pathIndex == 0) {
				// if not using a selector, the context node must be referenced first
				// ignore here and name gets checked below
			}else {
				_currContext = getChildren(_currContext);
			}
		}else {
			var sel:String = part.substr(0, selIndex);
			part = part.substr(selIndex + SELECTOR_DELIMIT.length);
			switch(sel) {
				case XPath.CHILDREN_SEL:
					_currContext = getChildren(_currContext);
					
				case XPath.DESC_SEL:
					_currContext = getDescendants(_currContext);
				case XPath.DESC_THIS_SEL:
					_currContext = getDescendants(_currContext, _currContext.concat([]));
					
				case XPath.ANCE_SEL:
					_currContext = getAncestors(_currContext);
				case XPath.ANCE_THIS_SEL:
					_currContext = getAncestors(_currContext, _currContext.concat([]));
					
				case XPath.PREV_SEL:
					_currContext = getSibling(_currContext, -1);
				case XPath.NEXT_SEL:
					_currContext = getSibling(_currContext, 1);
					
				case XPath.THIS_SEL:
					// no change
			}
		}
		var filterStart:Int;
		var filters:Array<String> = [];
		while ((filterStart = part.lastIndexOf(FILTER_START)) != -1) {
			var filterEnd:Int = part.indexOf(FILTER_END, filterStart);
			filters.unshift(part.substring(filterStart + FILTER_START.length, filterEnd));
			part = part.substr(0, filterStart);
		}
		if (part != ALL_FILTER) {
			var unfiltered = _currContext;
			_currContext = [];
			for (node in unfiltered) {
				if (node.nodeName == part) {
					_currContext.push(node);
				}
			}
		}
		for(filter in filters) {
			var operators:Array<String> = [];
			var expressions:Array<String> = [];
			splitOperators(filter, operators, expressions, LOGIC_OPERATORS);
			
			var unfiltered = _currContext;
			_currContext = [];
			for (node in unfiltered) {
				solveEquations(node, operators, expressions, _currContext);
			}
		}
		++_pathIndex;
	}
	
	inline private function splitOperators(expression:String, operators:Array<String>, expressions:Array<String>, opDefs:Array<String>) 
	{
		expressions.push(expression);
		for (op in opDefs) {
			var i = 0;
			while (i<expressions.length) {
				var expr = expressions[i];
				var index:Int;
				while ((index = expr.indexOf(op)) != -1) {
					expressions[i] = expr.substr(0, index);
					operators[i] = op;
					
					i += 1;
					expr = expr.substr(index + op.length);
					expressions.insert(i, expr);
				}
				++i;
			}
		}
	}
	
	inline private function solveEquations(node:Xml, operators:Array<String>, expressions:Array<String>, addTo:Array<Xml>):Void
	{
		var lastValue:Bool;
		for (i in 0 ... expressions.length) {
			var expr:String = expressions[i];
			solveEquation(expr, node, addTo);
		}
	}
	
	inline private function solveEquation(expr:String, node:Xml, addTo:Array<Xml>):Void
	{
		var operators:Array<String> = [];
		var expressions:Array<String> = [];
		splitOperators(expr, operators, expressions, EQ_OPERATORS);
		
		if (operators.length > 1) {
			_lastError = "Incorrectly formatted xpath expression (index:" + _pathIndex + "), too many operators: "+expr;
			setState(XPathState.Failed);
			return;
		}else if(operators.length==0) {
			var val = solveExpression(node, expressions[0]);
			if (val.index != null && val.index < node.parent.count() && val.index >= 0) {
				var index:Int = getElemIndex(node);
				if (index == val.index) {
					add(addTo, node);
				}
			}else if (val.str != null) {
				_lastError = "Incorrectly formatted xpath expression (index:" + _pathIndex + "), string must be part of equality check: "+val.str;
				setState(XPathState.Failed);
			}else if (val.nodes!=null) {
				for (child in val.nodes) {
					add(addTo, child);
				}
			}
		}else {
			var val1 = solveExpression(node, expressions[0]);
			var val2 = solveExpression(node, expressions[1]);
			if (((val2.index == null) != (val2.index == null)) || ((val2.str == null) != (val2.str == null))) {
				_lastError = "Incorrectly formatted xpath expression (index:" + _pathIndex + "), incomparible types: "+expr;
				setState(XPathState.Failed);
			}
			if (val1.index != null) {
				if (val2.index == val1.index) {
					add(addTo, node);
				}
			}else if (val1.str != null) {
				if (val2.str == val1.str) {
					add(addTo, node);
				}
			}else if (val1.nodes!=null) {
				_lastError = "Incorrectly formatted xpath expression (index:" + _pathIndex + "), xpath lookup cannot be part of equality check: "+expr;
				setState(XPathState.Failed);
			}
		}
	}
	
	private function solveExpression(node:Xml, expr:String):{index:Null<Int>, str:Null<String>, nodes:Null<Iterable<Xml>>}
	{
		var operators:Array<String> = [];
		var expressions:Array<String> = [];
		splitOperators(expr, operators, expressions, MATH_OPERATORS);
		
		var index:Int = 0;
		
		for (i in 0 ... expressions.length) {
			var ex = expressions[i];
			var thisInd:Int;
			switch(ex) {
				case XPath.POSITION_METH:
					thisInd = getElemIndex(node);
				case XPath.LAST_METH:
					thisInd = getSiblingCount(node) - 1;
				default:
					var asInt:Int = Std.parseInt(ex);
					var firstChar:String;
					if (Std.string(asInt) == ex) {
						thisInd = asInt;
					}else {
						if (((firstChar = ex.charAt(0)) == "'" || firstChar == '"') && firstChar == ex.charAt(ex.length - 1)) {
							nonMathOpCheck(ex, operators);
							return { index:null, str:ex.substring(1, ex.length - 1), nodes:null };
						}else if (ex.indexOf(ATT_SEL) == 0) {
							var attVal:String = node.get(ex.substr(ATT_SEL.length));
							var attInt:Int = Std.parseInt(attVal);
							if (Std.string(attInt) == attVal) {
								thisInd = attInt;
							}else {
								nonMathOpCheck(ex, operators);
								return { index:null, str:attVal, nodes:null }
							}
						}else {
							nonMathOpCheck(ex, operators);
							if (_subXPath==null)_subXPath = new XPath();
							var found:Iterable<Xml> = _subXPath.resolve(node, ex, false);
							return { index:null, str:null, nodes:found};
						}
					}
			}
			if (i == 0) {
				index = thisInd;
			}else {
				switch(operators[i - 1]) {
					case XPath.OP_ADD:
						index += thisInd;
						
					case XPath.OP_SUB:
						index -= thisInd;
				}
			}
		}
		return { index:index, str:null, nodes:null};
	}
	
	inline private function nonMathOpCheck(ex:String, operators:Array<String>) 
	{
		if (operators.length > 0) {
			_lastError = "Incorrectly formatted xpath expression (index:" + _pathIndex + "), cannot perform mathematical operations on this value: "+ex;
			setState(XPathState.Failed);
		}
	}
	
	inline private function getChildren(nodes:Array<Xml>):Array<Xml> {
		var ret:Array<Xml> = [];
		for (node in nodes) {
			for (child in node) {
				if(child.nodeType==Xml.Element)add(ret, child);
			}
		}
		return ret;
	}
	inline private function getDescendants(nodes:Iterable<Xml>, addTo:Array<Xml>=null):Array<Xml> {
		if (addTo == null) addTo = [];
		for (node in nodes) {
			for (child in node) {
				if (child.nodeType == Xml.Element) {
					add(addTo, child);
					getDescendants(child, addTo);
				}
			}
		}
		return addTo;
	}
	inline private function getAncestors(nodes:Array<Xml>, addTo:Array<Xml>=null):Array<Xml> {
		if (addTo == null) addTo = [];
		for (node in nodes) {
			while (node.parent!=null) {
				addTo.push(node.parent);
				node = node.parent;
			}
		}
		return addTo;
	}
	
	inline private function getSibling(nodes:Array<Xml>, offset:Int) 
	{
		var ret:Array<Xml> = [];
		for (node in nodes) {
			var par:Xml = node.parent;
			var index:Int = getElemIndex(node) + offset;
			var sibCount = getSiblingCount(node);
			if (index >= 0 && index < sibCount) {
				for (sibling in par) {
					if (sibCount == index) {
						ret.push(sibling);
						break;
					}
					sibCount++;
				}
			}
		}
		return ret;
	}
	private function getElemIndex(node:Xml):Int
	{
		var i:Int = 0;
		for (sibling in node.parent.elements()) {
			if (sibling == node) return i;
			++i;
		}
		return -1;
	}
	inline private function getSiblingCount(node:Xml):Int
	{
		var ret:Int = 0;
		for (sibling in node.parent.elements()) {
			++ret;
		}
		return ret;
	}
	inline private function getRoot(context:Xml):Xml {
		while (context.parent!=null) context = context.parent;
		return context;
	}
	inline private function add(to:Array<Xml>, node:Xml):Void {
		if (to.indexOf(node) == -1) {
			to.push(node);
		}
	}
	
	private function setState(state:XPathState):Void {
		if (state == _state) return;
		
		_state = state;
		LazyInst.exec(stateChanged.dispatch(this));
	}
}

enum XPathState {
	Waiting;
	Working;
	Succeeded;
	Failed;
}

