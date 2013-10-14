package org.tbyrne;

import haxe.Timer;
import msignal.Signal;
class ProcessTick
{
	private static var _process:Signal0;
	
	public static function tick():Signal0 {
		if (_process == null) {
			_process = new Signal0();
			
			var timer:Timer = new Timer(Std.int(1000 / 60));
			timer.run = _process.dispatch;
		}
		return _process;
	}
	
}