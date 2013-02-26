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



package org.tbyrne.io;

import mloader.Loader;
import mloader.LoaderCache;
import mloader.StringLoader;
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
		
		/*untyped {
			
			if (type == Xml) {
				var ret = new Input(type, new XmlLoader(uri));
				uriLookup.set(uri, ret);
				return ret;
			}else{
				throw "MLoader doesn't support resources of type: " + type;
			}
		
		}*/
		var ret = new Input(type, new StringLoader(uri));
		uriLookup.set(uri, ret);
		return ret;
	}
	public function returnInput<T>(input:IInput<T>):Void {
		var castInput:Input<T> = cast input;
		
		castInput.refCount--;
		if (castInput.refCount == 0) {
			uriLookup.remove(castInput.loader.url);
		}
	}
	
}
import msignal.EventSignal;
@:build(LazyInst.check())
class Input<T> implements IInput<T> {
	
	public var type:Dynamic;
	public var refCount:Int = 1;
	public var loader:Loader<String>;
	
	private var _inputState:InputState;
	private var _progress:Float = 0;
	private var _total:Float = 100;
	
	private var _lastError:String;
	
	public function new(type:Dynamic, loader:Loader<String>) {
		this.loader = loader;
		this.type = type;
		
		_inputState = InputState.Unloaded;
		
		loader.loaded.add(onLoadedStatus);
	}
	
	private function onLoadedStatus(event:Event < Loader<String>, LoaderEventType > ):Void {
		switch(event.type) {
			case LoaderEventType.Start:
				setState(InputState.Loading);
				setProgress(0, 100);
				
			case LoaderEventType.Cancel:
				setState(InputState.Unloaded);
				
			case LoaderEventType.Progress:
				setProgress(event.target.progress, 100);
				
			case LoaderEventType.Fail(error):
				_lastError = Std.string(error);
				setState(InputState.Failed);
				
			case LoaderEventType.Complete:
				setProgress(100, 100);
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
	public var inputState(get, null):InputState;
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
	
	public function getLastError():String {
		return _lastError;
	}
	
	public function getData():T {
		switch(type) {
			case String:
				return untyped loader.content;
			case Xml:
				return untyped Xml.parse(loader.content);
			default:
				throw "Unknown content type";
		}
	}
	public function read():Void {
		switch(_inputState) {
			case InputState.Failed, InputState.Unloaded:
				Sys.println("loader: "+loader.url);
				loader.load();
			default:
				//ignore
		}
	}
}