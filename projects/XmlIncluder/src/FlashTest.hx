package ;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import org.tbyrne.io.IO;
import org.tbyrne.io.MLoader;
import xmlTools.xinclude.IXmlIncludeTask;
import xmlTools.xinclude.IXmlIncludeTask.XmlIncludeTaskState;
import xmlTools.xinclude.XmlIncludeManager;
import xmlTools.xinclude.XmlIncludeTask;
import xmlTools.XmlPrettyPrint;

/**
 * ...
 * @author Tom Byrne
 */
class FlashTest
{
	static var _statusField:TextField;
	static var _xmlLoader:MLoader;
	static var _xmlIncManager:XmlIncludeManager;
	static var _success:Map<IXmlIncludeTask, Bool>;
	static var _matches:Map<IXmlIncludeTask, IInput<String>>;

	public static function main() 
	{
		_success = new Map();
		_matches = new Map();
		
		_statusField = new TextField();
		_statusField.width = 500;
		_statusField.height = 500;
		_statusField.defaultTextFormat = new TextFormat("_typewriter");
		Lib.current.addChild(_statusField);
		
		_xmlLoader = new MLoader();
		_xmlIncManager = new XmlIncludeManager(_xmlLoader);
		addTest("test1", "/root.xml", "/done.xml");
		addTest("test2", "/root.xml", "/done.xml");
		addTest("test3", "/root.xml", "/done.xml");
		addTest("test4", "/root.xml", "/done.xml");
		addTest("test5", "/root.xml", "/done.xml");
		
		_xmlIncManager.completeChanged.add(onCompleteChanged);
		_xmlIncManager.progressChanged.add(onProgressChanged);
		_xmlIncManager.startInclude();
	}
	
	static private function addTest(dirPath:String, rootPath:String, testPath:String) 
	{
		var task = _xmlIncManager.add(rootPath, dirPath);
		var match:IInput<String> = _xmlLoader.getInput(String, dirPath+testPath);
		match.read();
		_matches.set(task, match);
	}
	
	static private function onCompleteChanged(from:XmlIncludeManager){
		updateStatus();
	}
	static private function onProgressChanged(from:XmlIncludeManager){
		updateStatus();
	}
	
	static private function updateStatus() 
	{
		var status:String = Std.int(_xmlIncManager.getProgress() / _xmlIncManager.getTotal() * 100) + "%\n";
		
		for (i in 0 ... _xmlIncManager.getTaskCount()) {
			var task:IXmlIncludeTask = _xmlIncManager.getTask(i);
			status += "TEST " + (i + 1) + ": " + task.getState();
			if (task.getLastError() != null) status += " " + task.getLastError();
			var success:Null<Bool> = _success.get(task);
			if (success==null && task.getState()==XmlIncludeTaskState.Succeeded) {
				var match:IInput<String> = _matches.get(task);
				if (match.inputState == InputState.Loaded) {
					var value:String = XmlPrettyPrint.print(task.getData());
					var matchVal:String = XmlPrettyPrint.print(Xml.parse(match.getData()));
					success = (value == matchVal);
					_success.set(task, success);
				}
			}
			if (success != null) {
				status += " - test passed: " + success;
			}
			status += "\n";
		}
		
		_statusField.text = status;
	}
	
}