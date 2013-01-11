
import org.tbyrne.io.MLoader;
import org.tbyrne.xmlCombiner.IXmlCombineTask;
import org.tbyrne.xmlCombiner.XmlCombineTask;
import org.tbyrne.xmlCombiner.XmlCombiner;
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
   
   
   public function new() {
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
			
			Sys.println("Combining XML: " + rootFile);
			
			_xmlCombiner.startCombine();
			while (!_xmlCombiner.isComplete()) {
				Sys.print(_xmlCombiner.currentTask.getRootFile() + "\r");
				Sys.sleep(1);
			}
		}else {
			printHelp();
		}
	}
	public function add(rootFile:String, outputFile:String, withinDirectory:String):Void {
		if (outputFile == null) {
			outputFileError(rootFile);
		}
		
		var task:IXmlCombineTask = _xmlCombiner.add(rootFile, withinDirectory);
		
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