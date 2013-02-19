
import org.tbyrne.io.MLoader;
import xmlTools.include.IXmlIncludeTask;
import xmlTools.include.XmlIncludeTask;
import xmlTools.include.XmlIncludeManager;
import cmtc.ds.hash.ObjectHash;
import sys.io.File;
import sys.io.FileOutput;
import sys.FileSystem;
import xmlTools.XmlPrettyPrint;

class XmlIncluderShell {
	
	/**
	 * Usage:
		 * XmlIncluderShell.n root-file.xml -d C:/xml-directory/ -o C:/output-file.xml
	 * 
	 */
   public static function main() {
		new XmlIncluderShell();
   }
   
   
   private var _xmlIncluder:XmlIncludeManager;
   private var _taskToOutput:ObjectHash<IXmlIncludeTask, String>;
   
   public function new() {
		_taskToOutput = new ObjectHash<IXmlIncludeTask, String>();
		_xmlIncluder = new XmlIncludeManager(new MLoader());
		
		var args = Sys.args();
		var state:ArgState = None;
		
		var rootFile:String = null;
		var outputFile:String = null;
		var withinDirectory:String = null;
		
		if(args.length>0){
		
			for (arg in args) {
				if (arg == "--") {
					if (rootFile!=null) {
						add(rootFile, outputFile, withinDirectory);
					}
					state = None;
					rootFile = null;
					outputFile = null;
					withinDirectory = null;
				}else{
					switch(state) {
						case None:
							if (arg == "-o") {
								if(rootFile==null)initialArgError();
								state = Output;
							}else if(arg == "-d") {
								if(rootFile==null)initialArgError();
								state = WithinDir;
							}else {
								rootFile = arg;
							}
						case WithinDir:
							withinDirectory = arg;
							state = None;
						case Output:
							outputFile = arg;
							state = None;
					}
				}
			}
			if (rootFile != null) {
				outputFile = FileSystem.fullPath(outputFile);
				add(rootFile, outputFile, withinDirectory);
			}
			
			Sys.println("\nCombining XML: ");
			
			var total:Int = _xmlIncluder.getTaskCount();
			for (i in 0 ... total) {
				Sys.print("\n");
				var task:IXmlIncludeTask = _xmlIncluder.getTask(i);
				task.startInclude();
				var finished:Bool = false;
				while (!finished) {
					var print:String = "";
					if (total > 1) {
						print += "(" + (i+1) + "/" + total + ") ";
					}
					var total:Float = task.getTotal();
					var perc:Int;
					if(total==0){
						perc = 0;
					}else {
						perc = Std.int((task.getProgress() / total) * 100);
					}
					print += task.getRootFile() + " (" + perc + "%)";
					
					var state = task.getState();
					if (state == XmlIncludeTaskState.Failed) {
						Sys.print(print + " - failed "+task.getLastError()+"\r");
						finished = true;
					}else if(state==XmlIncludeTaskState.Succeeded) {
						Sys.print(print + " - success\r");
						finished = true;
					}else {
						Sys.print(print + "\r");
						Sys.sleep(1);
					}
				}
				if (task.getState() == XmlIncludeTaskState.Succeeded) {
					var outputFile:String = _taskToOutput.get(task);
					var printed:String = XmlPrettyPrint.print(task.getData());
					File.saveContent(outputFile, printed);
				}else {
					Sys.println("XML Include Failed: "+task.getRootFile());
				}
			}
			Sys.println("\nFinished Combining");
		}else {
			printHelp();
		}
	}
	public function add(rootFile:String, outputFile:String, withinDirectory:String):Void {
		if (outputFile == null) {
			outputFileError(rootFile);
		}
		
		var task:IXmlIncludeTask = _xmlIncluder.add(rootFile, withinDirectory);
		_taskToOutput.set(task, outputFile);
	}
	public function initialArgError():Void {
		Sys.println("First argument for each entry must be a root-file path.");
		Sys.exit(1);
	}
	public function outputFileError(rootFile:String):Void {
		Sys.println("Each entry must specify an output file, entry "+rootFile+" doesn't.");
		Sys.exit(2);
	}
	public function printHelp():Void {
		Sys.print("\nUsage:\nXmlIncluder.n root-file.xml -d C:/xml-directory/ -o C:/output-file.xml -- root-file2.xml -o C:/output-file2.xml\n");
		Sys.exit(0);
	}
}
enum ArgState{
	None;
	WithinDir;
	Output;
}