package  
{
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Tom Byrne
	 */
	public class PerfTestRunner 
	{
		private static var _funcBenchmark:PerfTest;
		private static var _tests:Vector.<PerfTest>;
		private static var _currentTest:int;
		private static var _enterFrameHook:Shape;

		
		public static function addTest(name:String, testFunc:Function, iterations:int):void 
		{
			if (!_tests) {
				_enterFrameHook = new Shape();
				_tests = new Vector.<PerfTest>();
				_funcBenchmark = new PerfTest("Function Benchmark", funcBenchmark, 1000000);
			}
			_tests.push(new PerfTest(name, testFunc, iterations));
		}
		public static function runTests():void 
		{
			_enterFrameHook.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_currentTest = -1;
			runNextTest();
		}
		private static function runNextTest():void 
		{
			var test:PerfTest =  (_currentTest == -1?_funcBenchmark:_tests[_currentTest]);
			trace("Running Test: "+test.name);
			var start:int = getTimer();
			var func:Function = test.testFunc;
			for (var i:int = 0; i < test.iterations; i++) {
				func();
			}
			var end:int = getTimer();
			test.time = end - start;
			if (_currentTest != -1) {
				test.time -= (_funcBenchmark.time/_funcBenchmark.iterations)*test.iterations;
			}
			var perThousand:Number = (test.time / test.iterations);
			trace(perThousand + "s per 1000 iterations\n");
			
			_currentTest++;
			if (_currentTest >= _tests.length) {
				_enterFrameHook.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		private static function onEnterFrame(e:Event):void 
		{
			runNextTest();
		}
		
		private static function funcBenchmark():void {  };
	}

}
class PerfTest {
	
	public var name:String;
	public var testFunc:Function;
	public var iterations:int;
	public var time:int;
	
	public function PerfTest(name:String, testFunc:Function, iterations:int) {
		this.name = name;
		this.testFunc = testFunc;
		this.iterations = iterations;
	}
}