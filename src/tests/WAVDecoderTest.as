package tests {
	import com.automatastudios.audio.audiodecoder.decoders.AudioInfo;
	import com.automatastudios.audio.audiodecoder.decoders.WAVDecoder;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	
	import flexunit.framework.TestCase;
	import flexunit.framework.TestSuite;
	
	import mx.controls.Alert;

	public class WAVDecoderTest extends TestCase {
		private const TEST_ASSET:String = "../assets/mono_8bit_11khz.wav";
		
		private var _data:URLStream;
		private var _decoder:WAVDecoder;

		public function WAVDecoderTest(methodName:String=null) {
			super(methodName);
		}

		public static function getSuite():TestSuite {
			var suite:TestSuite = new TestSuite();
			
			suite.addTest(new WAVDecoderTest("testDecoderInit"));

			return suite;
		}
		
		public function testDecoderInit():void {
			loadTestData(testDecoderInitReady);
		}
		
		private function loadTestData(callback:Function):void {
			_data = new URLStream();
			_decoder = new WAVDecoder();
			_decoder.init(_data, 1000, ProgressEvent.PROGRESS);
			_decoder.addEventListener(Event.INIT, addAsync(loadTestDataComplete, 2000, callback));
			
			_data.load(new URLRequest(TEST_ASSET));
		}
		
		private function loadTestDataComplete(event:Event, callback:Function):void {
			callback();
		}
		
		private function testDecoderInitReady():void {
			var audioInfo:AudioInfo = _decoder.getAudioInfo();
			
			assertEquals("Invalid decoder", audioInfo.decoder, "com.automatastudios.audio.audiodecoder.decoders.WAVDecoder");
			assertEquals("Invalid format", audioInfo.format, "PCM");
			assertEquals("Invalid # of channels", audioInfo.channels, 1);
			assertEquals("Invalid sample rate", audioInfo.sampleRate, 11025);
			assertEquals("Invalid upper bit rate", audioInfo.bitRateUpper, 1378);
			assertEquals("Invalid block align", audioInfo.blockAlign, 1);
			assertEquals("Invalid bits per sample", audioInfo.bitsPerSample, 8);
			assertEquals("Invalid sample multipler", audioInfo.sampleMultiplier, 4);
		}	
	}
}