package ;

import haxe.Resource;

import xmlTools.E4X;

class TestE4XPerformance 
{

	public static function main() 
	{
		new TestE4XPerformance();
	}
	
	private var _xml:Xml;

	public function new() 
	{
		_xml = Xml.parse(Resource.getString("sample-xml"));
		
		PerfTestRunner.addTest("Get Children", getChildren, 1000);
		PerfTestRunner.addTest("Get Descendants", getDescendants, 100);
		PerfTestRunner.addTest("Get Descendant Text", getDescText, 100);
		PerfTestRunner.runTests();
	}
	
	private function getChildren():Void {
		E4X.x(_xml.child());
	}
	private function getDescendants():Void {
		E4X.x(_xml.desc());
	}
	private function getDescText():Void {
		E4X.x(_xml.desc().text());
	}
}