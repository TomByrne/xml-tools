package org.tbyrne.xmlCombiner;

import haxe.xml.Fast;
import msignal.Signal;
import cmtc.ds.hash.ObjectHash;
import org.tbyrne.io.IO;

@:build(LazyInst.check())
class XmlCombineTask implements IXmlCombineTask  {
	
	
	@lazyInst
	public var completeChanged:Signal1<IXmlCombineTask>;
	@lazyInst
	public var progressChanged:Signal1<IXmlCombineTask>;
	
	
	
	private var _inputProvider:IInputProvider;
	
	
	public function getData():Xml{
		return _rootData;
	}
	
	public function isComplete():Bool{
		return _contentLoaded;
	}
	
	public function getProgress():Float {
		return _progress;
	}
	public function getTotal():Float {
		return _total;
	}
	
	public function getRootFile():String{
		return _contentPath;
	}
	
	private var _contentPath:String;
	private var _withinDir:String;
	private var _rootData:Xml;
	private var _resources:Array<IInput<Xml>>;
	private var _resourceToNode:ObjectHash<IInput<Xml>, Xml>;
	private var _rootResource : IInput<Xml>;
	private var _contentLoaded :Bool;
	private var _progress:Float;
	private var _total:Float;

	public function new(inputProvider:IInputProvider=null, contentPath:String=null, withinDir:String=null) {
		_inputProvider = inputProvider;
		startTask(contentPath);
	}
	
	
	public function startTask(contentPath:String, withinDir:String=null):Void{
		if(_contentPath==contentPath)return;
		
		if(_rootResource!=null){
			_inputProvider.returnInput(_rootResource);
			_rootResource = null;
		}
		
		setAllLoaded(false);
		_contentPath = contentPath;
		_withinDir = withinDir;
		
		if(_contentPath!=null){
			_rootResource = _inputProvider.getInput(Xml, createUri(_contentPath));
			_rootResource.inputStateChanged.add(onRootStateChanged);
			onRootStateChanged(_rootResource);
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

	private function onRootStateChanged(from:IInput<Xml>) : Void {
		
		if(from.inputState==InputState.Loaded){
			
		
			_rootData = _rootResource.getData();
			
			_resources = new Array<IInput<Xml>>();
			_resourceToNode = new ObjectHash();
			
			addResources(_rootData, true);
		}else{
			
			for(resource in _resources){
				resource.inputStateChanged.remove(onInputStateChanged);
			}
			_resourceToNode = null;
			_resources = null;
			setAllLoaded(false);
		}
	}

	private function addResources(within : Xml, allowCheck:Bool) : Void {
		//E4X.trace(new E4X(within).a(function(attName:String, attVal:String, xml:Xml):Bool { return attVal == "id"; } ));
		//E4X.x(within.a("id"));
		
		E4X.trace(new E4X(within).child(function(xml:Xml, _i:Int):Bool { return new E4X(xml).a(function(attName:String, attVal:String, xml:Xml):Bool { return attName == "id"; } ).exec() != null; } ).exec());
		E4X.x(within.child(a("id") != null));
		
		//var nodes:Iterator<Xml> = E4X.x(within._.xml));
		//var nodes:Iterator<Xml> = E4X.x(within._.xml.filt(att(url).length()));
		/*for each(var node:XML in nodes){
			addResource(node);
		}
		if(within.name()=="xml" && within.@url.length()){
			addResource(within);
		}
		if(allowCheck)checkAllLoaded();*/
	}

	private function addResource(node : Xml) : Void {
		/*var url:String = node.@url;
		
		var resource:IInput<Xml> = assetLoader.getXmlAsset(null, url);
		_resources.push(resource);
		_resourceToNode[resource] = node;
		resource.inputStateChanged.add(onInputStateChanged);
		doInputStateCheck(resource, false);*/
	}
	private function onInputStateChanged(from:IInput<Xml>):Void {
		doInputStateCheck(from, true);
	}
	private function doInputStateCheck(from:IInput<Xml>, allowCheck:Bool):Void {
		/*var resourceData:Xml;
		if(from.loaded){
			
			resourceData = from.data;
			var resourceNode:XML = _resourceToNode[from];
			if(resourceNode.@inParent.toString()=="true"){
				var atts:XMLList = resourceData.attributes();
				for each(var att:XML in atts){
					resourceNode.parent().@[att.name()] = att;
				}
				var children:XMLList = resourceData.children();
				for each(var child:XML in children){
					resourceNode.parent().appendChild(child);
					addResources(child, false);
				}
			}else{
				resourceNode.parent().appendChild(resourceData);
				addResources(resourceData, false);
			}
			
			if(allowCheck)checkAllLoaded();
		}else{
			resourceData = from.data;
			if(resourceData && resourceData.parent()){
				delete resourceData.parent().children()[resourceData.childIndex()];
			}
			setAllLoaded(false);
		}*/
	}

	private function checkAllLoaded() : Void {
		var allLoaded:Bool = true;
		for(resource in _resources){
			if(resource.inputState==InputState.Loaded){
				allLoaded = false;
				break;
			}
		}
		setAllLoaded(allLoaded);
	}

	private function setAllLoaded(value :Bool) : Void {
		if(_contentLoaded!=value){
			_contentLoaded = value;
			//_progressItem.active = !value;
			
			LazyInst.exec(completeChanged.dispatch(this));
		}
		
	}
	
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

