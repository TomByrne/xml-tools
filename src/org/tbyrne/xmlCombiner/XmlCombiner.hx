package org.tbyrne.xmlCombiner;

import haxe.io.Bytes;
import msignal.Signal;
import org.tbyrne.io.IO;
/**
 * ...
 * @author Tom Byrne
 */

@:build(LazyInst.check())
class XmlCombiner 
{
	@lazyInst
	public var progressChanged:Signal1<XmlCombiner>;
	@lazyInst
	public var completeChanged:Signal1<XmlCombiner>;
	
	public var inputProvider(get_inputProvider, null):IInputProvider;
	private function get_inputProvider():IInputProvider {
		return _inputProvider;
	}
	
	private var _tasks:Array<XmlCombineTask>;
	private var _finishedTasks:Int;
	private var _complete:Bool;
	private var _inputProvider:IInputProvider;
	private var _currentTask:IXmlCombineTask;

	public function new(inputProvider:IInputProvider) {
		_complete = true;
		_tasks = new Array<XmlCombineTask>();
		_finishedTasks = 0;
		_inputProvider = inputProvider;
	}
	
	public var currentTask(get_currentTask, null):IXmlCombineTask;
	public function get_currentTask():IXmlCombineTask {
		return _currentTask;
	}
	
	public function getProgress():Float {
		return 0;
	}
	public function getTotal():Float {
		return 10;
	}
	public function isComplete():Bool {
		return _complete;
	}
	
	public function add(rootFile:String, ?withinDir:String):IXmlCombineTask {
		var ret:XmlCombineTask = new XmlCombineTask(_inputProvider, rootFile, withinDir);
		_tasks.push(ret);
		ret.progressChanged.add(onProgressChanged);
		ret.completeChanged.add(onCompleteChanged);
		setComplete(false);
		checkProgress();
		return ret;
	}
	
	public function startCombine():Void {
		
	}
	
	private function onProgressChanged(from:IXmlCombineTask):Void {
		checkProgress();
	}
	private function onCompleteChanged(from:IXmlCombineTask):Void {
		var task:XmlCombineTask = cast from;
		if (task.isComplete()) {
			task.progressChanged.remove(onProgressChanged);
			task.completeChanged.remove(onCompleteChanged);
			_tasks.remove(task);
			checkComplete();
		}
	}
	
	
	private function checkProgress():Void {
		
	}
	private function checkComplete():Void {
		setComplete(_tasks.length==0);
	}
	private function setComplete(value:Bool):Void {
		if (_complete == value) return;
		
		_complete = value;
		LazyInst.exec(completeChanged.dispatch(this));
	}
}