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



package xmlTools.include;

import haxe.xml.Fast;
import msignal.Signal;
import cmtc.ds.hash.ObjectHash;
import org.tbyrne.io.IO;
import xmlTools.E4X;

import xmlTools.include.IXmlIncludeTask;

@:build(LazyInst.check())
class XmlIncludeTask implements IXmlIncludeTask  {
	
	public static var XI_NAMESPACE = "http://www.w3.org/2001/XInclude";
	public static var XI_TAG_NAME = "include";
	public static var XI_URL_ATT = "href";
	public static var XI_IN_PARENT = "inParent";
	public static var XI_PARSE = "parse";
	
	
	@lazyInst
	public var progressChanged:Signal1<IXmlIncludeTask>;
	@lazyInst
	public var stateChanged:Signal1<IXmlIncludeTask>;
	
	
	
	private var _inputProvider:IInputProvider;
	
	
	public function getData():Xml{
		return _rootData;
	}
	
	public function getProgress():Float {
		return _progress;
	}
	public function getTotal():Float {
		return _total;
	}
	public function getState():XmlIncludeTaskState {
		return _state;
	}
	
	public function getRootFile():String{
		return _contentPath;
	}
	
	private var _contentPath:String;
	private var _withinDir:String;
	private var _rootData:Xml;
	private var _resources:Array<IInput<String>>;
	private var _resourceToNode:ObjectHash<IInput<String>, Array<Xml>>;
	private var _resourceToData:ObjectHash<IInput<String>, Array<Xml>>;
	private var _rootResource : IInput<String>;
	private var _progress:Float = 0;
	private var _total:Float = 0;
	private var _state:XmlIncludeTaskState;
	private var _lastError:String;

	public function new(inputProvider:IInputProvider = null, contentPath:String = null, withinDir:String = null) {
		_state = XmlIncludeTaskState.Waiting;
		_inputProvider = inputProvider;
		_contentPath = contentPath;
		_withinDir = withinDir;
	}
	
	private function setState(state:XmlIncludeTaskState):Void {
		if (state == _state) return;
		
		_state = state;
		LazyInst.exec(stateChanged.dispatch(this));
	}
	
	public function startInclude():Void {
		if(_rootResource!=null){
			_inputProvider.returnInput(_rootResource);
			_rootResource = null;
		}
		
		setState(XmlIncludeTaskState.Working);
		
		if(_contentPath!=null){
			_rootResource = _inputProvider.getInput(String, createUri(_contentPath));
			_rootResource.inputStateChanged.add(onRootStateChanged);
			onRootStateChanged(_rootResource);
			_rootResource.read();
		}
	}
	
	private function createUri(path:String) : String {
		if(_withinDir!=null && path.indexOf(":")==-1){
			if(path.charAt(0)!="/" && _withinDir.charAt(_withinDir.length-1)!="/"){
				path = "/"+path;
			}
			path = _withinDir + path;
		}
		return path;
	}

	private function onRootStateChanged(from:IInput<String>) : Void {
		if(from.inputState==InputState.Loaded){
			
			_rootData = Xml.parse(_rootResource.getData());
			
			_resources = new Array<IInput<String>>();
			_resourceToNode = new ObjectHash();
			_resourceToData = new ObjectHash();
			
			addResources(_rootData.firstElement(), true);
		}else {
			
			if(_resources!=null){
				for(resource in _resources){
					resource.inputStateChanged.remove(onInputStateChanged);
				}
				_resourceToNode = null;
				_resources = null;
			}
			checkState();
		}
	}

	private function addResources(root : Xml, allowCheck:Bool) : Void {
		
		var namespaces = root.attributes();
		var xcfNs:String = null;
		for (ns in namespaces) {
			if (root.get(ns)==XI_NAMESPACE) {
				xcfNs = ns.substr(ns.indexOf(":") + 1);
				break;
			}
		}
		
		var xcfTag:String;
		if (xcfNs == null) {
			xcfTag = XI_TAG_NAME;
		}else {
			xcfTag = xcfNs + ":"+XI_TAG_NAME;
		}
		var nodes:Iterator<Xml> = E4X.x(root._(nodeType==Xml.Element && nodeName == xcfTag && a(XI_URL_ATT)));
		for(node in nodes){
			addResource(node);
		}
		if(root.nodeName==xcfTag && root.get(XI_URL_ATT)!=null){
			addResource(root);
		}
		if (allowCheck) checkState();
		
		checkProgress();
	}

	private function addResource(node : Xml) : Void {
		var url:String = node.get(XI_URL_ATT);
		
		var resource:IInput<String> = _inputProvider.getInput(String, createUri(url));
		
		var list:Array<Xml> = _resourceToNode.get(resource);
		if (list == null) {
			list = [node];
			_resourceToNode.set(resource, list);
			resource.inputStateChanged.add(onInputStateChanged);
			resource.inputProgChanged.add(onProgressChanged);
		}else {
			list.push(node);
		}
		
		_resources.push(resource);
		if (resource.inputState == InputState.Loaded) {
			includeNode(resource, node);
		}else {
			resource.read();
			checkState();
		}
	}
	private function onInputStateChanged(from:IInput<String>):Void {
		var list:Array<Xml> = _resourceToNode.get(from);
		if (from.inputState == InputState.Loaded) {
			var loadedStr = from.getData();
			for (referenceNode in list) {
				includeNode(from, referenceNode);
			}
		}else{
			var nodeList:Array<Xml> = _resourceToData.get(from);
			if (nodeList != null) {
				for (i in 0...nodeList.length) {
					unincludeNode(from, list[i], nodeList[i]);
				}
			}
			_resourceToData.delete(from);
		}
		checkState();
	}
	private function includeNode(input:IInput<String>, referenceNode:Xml):Void {
		var childNode:Xml;
		if (referenceNode.get(XI_PARSE) == "text") {
			childNode = Xml.createCData(input.getData());
		}else {
			childNode = Xml.parse(input.getData()).firstElement();
		}	
		
		var nodeList:Array<Xml> = _resourceToData.get(input);
		if (nodeList == null) {
			nodeList = new Array();
			_resourceToData.set(input, nodeList);
		}
		nodeList.push(childNode);
				
		if(referenceNode.get(XI_IN_PARENT)=="true"){
			var atts:Iterator<String> = childNode.attributes();
			for(att in atts){
				referenceNode.parent.set(att, childNode.get(att));
			}
			var elements:Iterator<Xml> = childNode.elements();
			for(child in elements){
				referenceNode.parent.addChild(child);
				addResources(child, false);
			}
		}else {
			referenceNode.parent.addChild(childNode);
			if(childNode.nodeType==Xml.Element)addResources(childNode, false);
		}
	}
	private function unincludeNode(input:IInput<String>, referenceNode:Xml, childNode:Xml):Void {
		if (referenceNode.get(XI_IN_PARENT) == "true") {
			// @todo - revert in parent behaviour
		}else{
			if (childNode != null && childNode.parent != null) {
				childNode.parent.removeChild(childNode);
			}
		}
	}
	public function getLastError() : String{
		return _lastError;
	}
	private function checkState() : Void {
		var state:XmlIncludeTaskState = XmlIncludeTaskState.Waiting;
		if(_rootResource!=null){
			switch(_rootResource.inputState) {
				case InputState.Loaded:
					state = XmlIncludeTaskState.Succeeded;
				case InputState.Loading:
					state = XmlIncludeTaskState.Working;
				case InputState.Failed:
					_lastError = _rootResource.getLastError();
					setState(XmlIncludeTaskState.Failed);
					return;
				default:
					// ignore
			}
		}
		if(_resources!=null && _resources.length>0){
			state = XmlIncludeTaskState.Waiting;
			for (resource in _resources) {
				switch(resource.inputState) {
					case InputState.Loaded:
						if(state == XmlIncludeTaskState.Waiting)
							state = XmlIncludeTaskState.Succeeded;
					case InputState.Loading:
						state = XmlIncludeTaskState.Working;
					case InputState.Failed:
						_lastError = _rootResource.getLastError();
						state = XmlIncludeTaskState.Failed;
						break;
					default:
						// ignore
				}
			}
		}
		setState(state);
	}
	private function onProgressChanged(from:IInput<String>):Void {
		checkProgress();
	}
	private function checkProgress() : Void {
		var progress:Float = 0;
		var total:Float = 0;
		for (resource in _resources) {
			progress += resource.getInputProgress();
			total += resource.getInputTotal();
		}
		setProgress(progress, total);
	}
	/*private function checkAllLoaded() : Void {
		var allLoaded:Bool = true;
		for(resource in _resources){
			if(resource.inputState==InputState.Loaded){
				allLoaded = false;
				break;
			}
		}
		//setAllLoaded(allLoaded);
		setState(allLoaded?);
	}*/

	/*private function setAllLoaded(value :Bool) : Void {
		if(_contentLoaded!=value){
			_contentLoaded = value;
			//_progressItem.active = !value;
			
			LazyInst.exec(completeChanged.dispatch(this));
		}
		
	}*/
	
	/*private function findAscAttrib(fromNode:Xml, attName:String):String{
		while(fromNode){
			var att:String = fromNode.attribute(attName);
			if(att && att.length)return att;
			fromNode = fromNode.parent();
		}
		return null;
	}*/
	
	
	private function setProgress(progress:Float, total:Float):Void {
		if (_progress == progress && _total == total) return;
		
		_progress = progress;
		_total = total;
		LazyInst.exec(progressChanged.dispatch(this));
	}
}

