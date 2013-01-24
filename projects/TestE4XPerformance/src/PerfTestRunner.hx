package  ;

import haxe.Timer;
	
class PerfTestRunner 
{
	private static var _funcBenchmark:PerfTest;
	private static var _tests:Array<PerfTest>;
	private static var _currentTest:Int;
	
	// Timer.stamp() returns different units on different platforms, this helps fix that.
	#if (flash || neko || cpp || js)
	private static var SECOND_FACTOR:Float = 1;
	#end

	
	public static function addTest(name:String, testFunc:Void->Void, iterations:Int):Void
	{
		if (_tests==null) {
			_tests = new Array<PerfTest>();
			_funcBenchmark = new PerfTest("Function Benchmark", funcBenchmark, 1000000);
		}
		_tests.push(new PerfTest(name, testFunc, iterations));
	}
	public static function runTests():Void
	{
		_currentTest = -1;
		runNextTest();
	}
	private static function runNextTest():Void
	{
		var test:PerfTest =  (_currentTest == -1?_funcBenchmark:_tests[_currentTest]);
		trace("Running Test: "+test.name);
		var start:Float = Timer.stamp();
		var func:Void->Void = test.testFunc;
		for (i in 0 ... test.iterations) {
			func();
		}
		var end:Float = Timer.stamp();
		test.time = end - start;
		if (_currentTest != -1) {
			test.time -= (_funcBenchmark.time/_funcBenchmark.iterations)*test.iterations;
		}
		var perThousand:Float = (test.time / test.iterations)*1000;
		trace((perThousand/SECOND_FACTOR) + "s per 1000 iterations\n");
		
		_currentTest++;
		if (_currentTest < _tests.length) {
			runNextTest();
		}
	}
	
	private static function funcBenchmark():Void{  }
}


class PerfTest {
	
	public var name:String;
	public var testFunc:Void->Void;
	public var iterations:Int;
	public var time:Float;
	
	public function new(name:String, testFunc:Void->Void, iterations:Int) {
		this.name = name;
		this.testFunc = testFunc;
		this.iterations = iterations;
	}
}