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

import msignal.Signal;

interface IInputProvider 
{
	public function getInput<T>(T:Class<T>, uri:String):IInput<T>;
	public function returnInput<T>(input:IInput<T>):Void;
}
interface IInput<T> {
	
	public var inputStateChanged(get, null):Signal1<IInput<T>>;
	public var inputState(get, null):InputState;
	
	public var inputProgChanged(get, null):Signal1<IInput<T>>;
	public function getInputProgress():Float;
	public function getInputTotal():Float;
	
	public function getData():T;
	public function read():Void;
	
	public function getLastError():String;
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
	
	public var outputStateChanged(get, null):Signal1<IOutput<T>>;
	public var outputState(get, null):InputState;
	
	public var inputProgChanged(get, null):Signal1<IOutput<T>>;
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