package tests {
	import com.automatastudios.audio.audiodecoder.decoders.AudioInfo;
	import com.automatastudios.audio.audiodecoder.decoders.OggVorbisDecoder;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	
	import flexunit.framework.TestCase;
	import flexunit.framework.TestSuite;
	
	import mx.controls.Alert;

	public class OggVorbisDecoderTest extends TestCase {
		private const TEST_ASSET:String = "../assets/mono_11khz.ogg";
		
		private var _data:URLStream;
		private var _decoder:OggVorbisDecoder;

		public function OggVorbisDecoderTest(methodName:String=null) {
			super(methodName);
		}

		public static function getSuite():TestSuite {
			var suite:TestSuite = new TestSuite();
			
			suite.addTest(new OggVorbisDecoderTest("testDecoderInit"));

			return suite;
		}
		
		public function testDecoderInit():void {
			loadTestData(testDecoderInitReady);
		}
		
		private function loadTestData(callback:Function):void {
			_data = new URLStream();
			_decoder = new OggVorbisDecoder();
			_decoder.init(_data, 1000, ProgressEvent.PROGRESS);
			_decoder.addEventListener(Event.INIT, addAsync(loadTestDataComplete, 2000, callback));
			
			_data.load(new URLRequest(TEST_ASSET));
		}
		
		private function loadTestDataComplete(event:Event, callback:Function):void {
			callback();
		}
		
		private function testDecoderInitReady():void {
			var audioInfo:AudioInfo = _decoder.getAudioInfo();
			
			assertEquals("Invalid decoder", audioInfo.decoder, "com.automatastudios.audio.audiodecoder.decoders.OggVorbisDecoder");
			assertEquals("Invalid # of channels", audioInfo.channels, 1);
			assertEquals("Invalid sample rate", audioInfo.sampleRate, 11025);
			assertEquals("Invalid nominal bit rate", audioInfo.bitRateNominal, 38000);
			assertEquals("Invalid block align", audioInfo.blockAlign, 2);
			assertEquals("Invalid bits per sample", audioInfo.bitsPerSample, 16);
			assertEquals("Invalid sample multipler", audioInfo.sampleMultiplier, 4);
		}	
	}
}