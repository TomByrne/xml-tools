
import org.tbyrne.io.MLoader;
import org.tbyrne.xmlCombiner.IXmlCombineTask;
import org.tbyrne.xmlCombiner.XmlCombineTask;
import org.tbyrne.xmlCombiner.XmlCombiner;
import cmtc.ds.hash.ObjectHash;
import sys.io.File;
import sys.io.FileOutput;

class XmlCombinerShell {
	
	/**
	 * Usage:
		 * XmlCombiner.n root-file.xml -d C:/xml-directory/ -o C:/output-file.xml
	 * 
	 */
   public static function main() {
		new XmlCombinerShell();
   }
   
   
   private var _xmlCombiner:XmlCombiner;
   private var _taskToOutput:ObjectHash<IXmlCombineTask, String>;
   
   public function new() {
		_taskToOutput = new ObjectHash<IXmlCombineTask, String>();
		_xmlCombiner = new XmlCombiner(new MLoader());
		new XmlCombineTask();
		
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
			if (rootFile!=null) {
				add(rootFile, outputFile, withinDirectory);
			}
			
			Sys.println("\nCombining XML: ");
			
			var i:Int = 0;
			var total:Int = _xmlCombiner.getTaskCount();
			while (i < total) {
				var task:IXmlCombineTask = _xmlCombiner.getTask(i);
				task.startCombine();
				while (task.getState()!=XmlCombineTaskState.Failed && task.getState()!=XmlCombineTaskState.Succeeded) {
					var print:String = "";
					if (total > 1) {
						print += "(" + i + "/" + total + ") ";
					}
					var perc:Int = Std.int((task.getProgress() / task.getTotal()) * 100);
					print += task.getRootFile() + " (" + perc + "%)";
					Sys.print(print + "\r");
					Sys.sleep(1);
				}
				if(task.getState()==XmlCombineTaskState.Succeeded){
					var outputFile:String = _taskToOutput.get(task);
					var output:FileOutput = File.write(outputFile, false);
					output.writeString(task.getData().toString());
					output.close();
					//File.saveContent(outputFile, task.getData().toString());
				}else {
					Sys.println("XML Combine Failed: "+task.getRootFile());
				}
			}
			Sys.println("Finished Combining\n");
		}else {
			printHelp();
		}
	}
	public function add(rootFile:String, outputFile:String, withinDirectory:String):Void {
		if (outputFile == null) {
			outputFileError(rootFile);
		}
		
		var task:IXmlCombineTask = _xmlCombiner.add(rootFile, withinDirectory);
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
		Sys.print("\nUsage:\nXmlCombiner.n root-file.xml -d C:/xml-directory/ -o C:/output-file.xml -- root-file2.xml -o C:/output-file2.xml\n");
		Sys.exit(0);
	}
}
enum ArgState{
	None;
	WithinDir;
	Output;
}