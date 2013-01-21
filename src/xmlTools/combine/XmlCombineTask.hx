package xmlTools.combine;

import haxe.xml.Fast;
import msignal.Signal;
import cmtc.ds.hash.ObjectHash;
import org.tbyrne.io.IO;
import xmlTools.E4X;

import xmlTools.combine.IXmlCombineTask;

@:build(LazyInst.check())
class XmlCombineTask implements IXmlCombineTask  {
	
	public static var XCF_NAMESPACE = "http://tbyrne.org/XCF";
	
	
	@lazyInst
	public var progressChanged:Signal1<IXmlCombineTask>;
	@lazyInst
	public var stateChanged:Signal1<IXmlCombineTask>;
	
	
	
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
	public function getState():XmlCombineTaskState {
		return _state;
	}
	
	public function getRootFile():String{
		return _contentPath;
	}
	
	private var _contentPath:String;
	private var _withinDir:String;
	private var _rootData:Xml;
	private var _resources:Array<IInput<Xml>>;
	private var _resourceToNode:ObjectHash<IInput<Xml>, Array<Xml>>;
	private var _resourceToData:ObjectHash<IInput<Xml>, Xml>;
	private var _rootResource : IInput<Xml>;
	private var _progress:Float = 0;
	private var _total:Float = 0;
	private var _state:XmlCombineTaskState;

	public function new(inputProvider:IInputProvider = null, contentPath:String = null, withinDir:String = null) {
		_state = XmlCombineTaskState.Waiting;
		_inputProvider = inputProvider;
		_contentPath = contentPath;
		_withinDir = withinDir;
	}
	
	private function setState(state:XmlCombineTaskState):Void {
		if (state == _state) return;
		
		_state = state;
		LazyInst.exec(stateChanged.dispatch(this));
	}
	
	public function startCombine():Void {
		if(_rootResource!=null){
			_inputProvider.returnInput(_rootResource);
			_rootResource = null;
		}
		
		setState(XmlCombineTaskState.Working);
		
		if(_contentPath!=null){
			_rootResource = _inputProvider.getInput(Xml, createUri(_contentPath));
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

	private function onRootStateChanged(from:IInput<Xml>) : Void {
		if(from.inputState==InputState.Loaded){
			
		
			_rootData = _rootResource.getData();
			
			_resources = new Array<IInput<Xml>>();
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
			if (root.get(ns)==XCF_NAMESPACE) {
				xcfNs = ns.substr(ns.indexOf(":") + 1);
				break;
			}
		}
		
		var xcfTag:String;
		if (xcfNs == null) {
			xcfTag = "xml";
		}else {
			xcfTag = xcfNs + ":xml";
		}
		var nodes:Iterator<Xml> = E4X.x(root._(nodeType==Xml.Element && nodeName == xcfTag && a("url")));
		for(node in nodes){
			addResource(node);
		}
		if(root.nodeName==xcfTag && root.get("url")!=null){
			addResource(root);
		}
		if (allowCheck) checkState();
		
		checkProgress();
	}

	private function addResource(node : Xml) : Void {
		var url:String = node.get("url");
		
		var resource:IInput<Xml> = _inputProvider.getInput(Xml, createUri(url));
		
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
			combineNode(resource.getData().firstElement(), node);
		}else {
			resource.read();
			checkState();
		}
	}
	private function onInputStateChanged(from:IInput<Xml>):Void {
		var list:Array<Xml> = _resourceToNode.get(from);
		if(from.inputState==InputState.Loaded){
			var loadedData:Xml = from.getData().firstElement();
			for (referenceNode in list) {
				combineNode(loadedData, referenceNode);
			}
			_resourceToData.set(from,loadedData);
		}else{
			var loadedData:Xml = _resourceToData.get(from);
			if(loadedData!=null){
				for (referenceNode in list) {
					uncombineNode(loadedData, referenceNode);
				}
				_resourceToData.delete(from);
			}
		}
		checkState();
	}
	private function combineNode(childNode:Xml, referenceNode:Xml):Void {
		if(referenceNode.get("inParent")=="true"){
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
			addResources(childNode, false);
		}
	}
	private function uncombineNode(childNode:Xml, referenceNode:Xml):Void {
		if (referenceNode.get("inParent") == "true") {
			// @todo - revert in parent behaviour
		}else{
			if (childNode != null && childNode.parent != null) {
				childNode.parent.removeChild(childNode);
			}
		}
	}
	private function checkState() : Void {
		var state:XmlCombineTaskState = XmlCombineTaskState.Waiting;
		if(_rootResource!=null){
			switch(_rootResource.inputState) {
				case InputState.Loaded:
					state = XmlCombineTaskState.Succeeded;
				case InputState.Loading:
					state = XmlCombineTaskState.Working;
				case InputState.Failed:
					setState(XmlCombineTaskState.Failed);
					return;
				default:
					// ignore
			}
		}
		if(_resources!=null){
			state = XmlCombineTaskState.Waiting;
			for (resource in _resources) {
				switch(resource.inputState) {
					case InputState.Loaded:
						if(state == XmlCombineTaskState.Waiting)
							state = XmlCombineTaskState.Succeeded;
					case InputState.Loading:
						state = XmlCombineTaskState.Working;
					case InputState.Failed:
						state = XmlCombineTaskState.Failed;
						break;
					default:
						// ignore
				}
			}
		}
		setState(state);
	}
	private function onProgressChanged(from:IInput<Xml>):Void {
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

