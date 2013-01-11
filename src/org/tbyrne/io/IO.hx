package org.tbyrne.io;

import msignal.Signal;

interface IInputProvider 
{
	public function getInput<T>(T:Class<Dynamic>, uri:String):IInput<T>;
	public function returnInput<T>(input:IInput<T>):Void;
}
interface IInput<T> {
	
	public var inputStateChanged(get_inputStateChanged, null):Signal1<IInput<T>>;
	public var inputState(get_state, null):InputState;
	
	public var inputProgChanged(get_inputProgChanged, null):Signal1<IInput<T>>;
	public function getInputProgress():Float;
	public function getInputTotal():Float;
	
	public function getData():T;
	public function read():Void;
}
enum InputState {
	Unloaded;
	Loading;
	Loaded;
	Failed;
}


interface IOutputProvider 
{
	public function getOutput<T>(T:Class<Dynamic>, uri:String):IOutput<T>;
	public function returnOutput<T>(InputState:IOutput<T>):Void;
}
interface IOutput<T> {
	
	public var outputStateChanged(get_stateChanged, null):Signal1<IOutput<T>>;
	public var outputState(get_state, null):InputState;
	
	public var inputProgChanged(get_stateChanged, null):Signal1<IOutput<T>>;
	public function getOutputProgress():Float;
	public function getOutputTotal():Float;
	
	public function setData(data:T):Void;
	public function write():Void;
}
enum OutputState {
	Valid;
	Invalid;
	Writing;
	Failed;
}