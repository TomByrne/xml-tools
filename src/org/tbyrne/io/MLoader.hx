package org.tbyrne.io;

import mloader.Loader;
import mloader.LoaderCache;
import mloader.XmlLoader;
import org.tbyrne.io.IO;
import msignal.Signal;


class MLoader implements IInputProvider
{
	
	private var uriLookup:Hash<Input<Dynamic>>;
	private var loaderCache:LoaderCache;
	
	public function new() {
		uriLookup = new Hash();
		loaderCache = new LoaderCache();
	}
	
	public function getInput<T>(type:Class<T>, uri:String):IInput<T> {
		var old:Input<Dynamic> = uriLookup.get(uri);
		if (old != null && old.type == type) {
			old.refCount++;
			return cast old;
		}
		
		untyped {
			
			if(type==Xml) {
				var ret = new Input(type, new XmlLoader(uri));
				uriLookup.set(uri, ret);
				return ret;
			}else{
				throw "MLoader doesn't support resources of type: " + type;
			}
		
		}
	}
	public function returnInput<T>(input:IInput<T>):Void {
		var castInput:Input<T> = cast input;
		
		castInput.refCount--;
		if (castInput.refCount==0) {
			uriLookup.remove(castInput.loader.url);
		}
	}
	
}
import msignal.EventSignal;
@:build(LazyInst.check())
class Input<T> implements IInput<T> {
	
	public var type:Dynamic;
	public var refCount:Int = 1;
	public var loader:Loader<T>;
	
	private var _inputState:InputState;
	private var _progress:Float = 0;
	private var _total:Float = 100;
	
	public function new(type:Dynamic, loader:Loader<T>) {
		this.loader = loader;
		this.type = type;
		
		loader.loaded.add(onLoadedStatus);
	}
	
	private function onLoadedStatus(event:Event < Loader<T>, LoaderEventType > ):Void {
		Sys.println(event.type);
		switch(event.type) {
			case LoaderEventType.Start:
				setState(InputState.Loading);
				setProgress(0, 100);
				
			case LoaderEventType.Cancel:
				setState(InputState.Unloaded);
				
			case LoaderEventType.Progress:
				setProgress(event.target.progress, 100);
				
			case LoaderEventType.Fail(error):
				setState(InputState.Failed);
				
			case LoaderEventType.Complete:
				setState(InputState.Loaded);
		}
	}
	private function setState(state:InputState):Void {
		if (_inputState == state) return;
		
		_inputState = state;
		LazyInst.exec(inputStateChanged.dispatch(this));
	}
	
	private function setProgress(progress:Float, total:Float):Void {
		if (_progress == progress && _total == total) return;
		
		_progress = progress;
		_total = total;
		LazyInst.exec(inputStateChanged.dispatch(this));
	}
	
	@lazyInst
	public var inputStateChanged:Signal1<IInput<T>>;
	public var inputState(get_state, null):InputState;
	private function get_state():InputState {
		return _inputState;
	}
	
	@lazyInst
	public var inputProgChanged:Signal1<IInput<T>>;
	public function getInputProgress():Float{
		return _progress;
	}
	public function getInputTotal():Float{
		return _total;
	}
	
	public function getData():T {
		return loader.content;
	}
	public function read():Void {
		loader.load();
	}
}