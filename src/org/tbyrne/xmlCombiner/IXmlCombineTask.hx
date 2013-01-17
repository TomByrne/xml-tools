package org.tbyrne.xmlCombiner;

import msignal.Signal;
/**
 * ...
 * @author Tom Byrne
 */

interface IXmlCombineTask 
{
	public var progressChanged(get_progressChanged, null):Signal1<IXmlCombineTask>;
	public var stateChanged(get_stateChanged, null):Signal1<IXmlCombineTask>;
	
	public function startCombine():Void;
	
	public function getState():XmlCombineTaskState;
	public function getData():Xml;
	public function getRootFile():String;
	public function getProgress():Float;
	public function getTotal():Float;
	
}

enum XmlCombineTaskState {
	Waiting;
	Working;
	Succeeded;
	Failed;
}