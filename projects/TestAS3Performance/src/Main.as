package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Tom Byrne
	 */
	public class Main extends Sprite 
	{
		[Embed(source = "../../../testEmbed/sample-xml.xml",mimeType="application/octet-stream")]
		private static const XML_CLASS:Class;
		
		private var _xml:XML;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_xml = new XML(new XML_CLASS());
			
			PerfTestRunner.addTest("Get Children", getChildren, 100000);
			PerfTestRunner.addTest("Get Descendants", getDescendants, 1000);
			PerfTestRunner.addTest("Get Descendant Text", getDescText, 100);
			PerfTestRunner.runTests();
		}
		
		private function getChildren():void {
			_xml.children();
		}
		private function getDescendants():void {
			_xml.descendants();
		}
		private function getDescText():void {
			_xml.descendants().text();
		}
	}
	
}