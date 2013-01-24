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
		PerfTestRunner.addTest("Get Children By Has Attrib", getChildrenWAttrib, 1000);
		PerfTestRunner.addTest("Get Descendants", getDescendants, 100);
		PerfTestRunner.addTest("Get Descendant Text", getDescText, 100);
		PerfTestRunner.addTest("Get Descendants by Name", getDescByName, 100);
		PerfTestRunner.addTest("Get Descendants by Attrib Eq", getDescByAttrib, 100);
		PerfTestRunner.runTests();
	}
	
	private function emptyTest():Void {
	}
	private function getChildren():Void {
		E4X.x(_xml.child());
	}
	private function getChildrenWAttrib():Void {
		E4X.x(_xml.child(a("att")));
	}
	private function getDescendants():Void {
		E4X.x(_xml.desc());
	}
	private function getDescText():Void {
		E4X.x(_xml.desc().text());
	}
	private function getDescByName():Void {
		E4X.x(_xml.desc("sodium"));
	}
	private function getDescByAttrib():Void {
		E4X.x(_xml.desc(a("units") == "g"));
	}
}