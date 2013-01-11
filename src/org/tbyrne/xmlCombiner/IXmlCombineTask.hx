package org.tbyrne.xmlCombiner;

import msignal.Signal;
/**
 * ...
 * @author Tom Byrne
 */

interface IXmlCombineTask 
{
	public var progressChanged(get_progressChanged, null):Signal1<IXmlCombineTask>;
	public var completeChanged(get_completeChanged, null):Signal1<IXmlCombineTask>;
	
	
	public function getData():Xml;
	public function getRootFile():String;
	public function isComplete():Bool;
	public function getProgress():Float;
	public function getTotal():Float;
	
}