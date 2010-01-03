package tests {
	import com.automatastudios.data.riff.RIFFChunkInfo;
	import com.automatastudios.data.riff.RIFFParser;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	
	import flexunit.framework.TestCase;
	import flexunit.framework.TestSuite;

	public class RIFFParserTest extends TestCase {
		private const TEST_ASSET:String = "../assets/mono_8bit_11khz.wav";
		
		private var _riffParser:RIFFParser;
		private var _data:URLStream;
		
 		public function RIFFParserTest(methodName:String) {
			super(methodName);
		}
		
		public static function getSuite():TestSuite {
			var suite:TestSuite = new TestSuite();
			
			suite.addTest(new RIFFParserTest("testReadChunk"));
			suite.addTest(new RIFFParserTest("testReadSubChunk"));
			suite.addTest(new RIFFParserTest("testReadChunkData"));
			suite.addTest(new RIFFParserTest("testStreamChunkData"));
			
			return suite;
		}
		
		public function testReadChunk():void {
			loadTestData(testReadChunkReady);
		}
		
		public function testReadSubChunk():void {
			loadTestData(testReadSubChunkReady);
		}
		
		public function testReadChunkData():void {
			loadTestData(testReadChunkDataReady);
		}
		
		public function testStreamChunkData():void {
			loadTestData(testStreamChunkDataReady);
		}
		
		private function loadTestData(callback:Function):void {
			_data = new URLStream();
			_riffParser = new RIFFParser(_data);
			_data.addEventListener(Event.COMPLETE, addAsync(loadTestDataComplete, 2000, callback));
			_data.load(new URLRequest(TEST_ASSET));
		}
		
		private function loadTestDataComplete(event:Event, callback:Function):void {
			callback();
		}
		
		private function testReadChunkReady():void {
			var chunk:RIFFChunkInfo;
			try {
				chunk = _riffParser.readChunk();
			}
			finally {
				assertNotNull("Chunk equals null", chunk);
				assertEquals("Chunk not equal to 'RIFF'", chunk.chunkId, "RIFF");
			}
		}
		
		private function testReadSubChunkReady():void {
			var subChunkId:String;
			try {
				_riffParser.readChunk();
				subChunkId = _riffParser.readSubChunk();
			}
			finally {
				assertNotNull("SubChunk ID equals null", subChunkId);
				assertEquals("SubChunk ID not equal to 'WAVE'", subChunkId, "WAVE");
			}
		}
		
		private function testReadChunkDataReady():void {
			var expectedDataLength:uint = 16;
			var chunkInfo:RIFFChunkInfo;
			var chunkData:ByteArray;

			try {
				_riffParser.readChunk();
				_riffParser.readSubChunk();
				chunkInfo = _riffParser.readChunk();

				while (chunkInfo.chunkId != "fmt " && chunkInfo != null) {
					
					chunkInfo = _riffParser.readChunk();
				}

				chunkData = _riffParser.readChunkData();
			}
			finally {
				assertNotNull("ChunkData equals null", chunkData);
				assertEquals("ChunkData is not 16 bytes long ", chunkData.length, expectedDataLength);
			}
			
/* 			var expectedFormat:uint = 1;
			var expectedChannels:uint = 1;
			var expectedSampleRate:uint = 44100;
			var expectedByteRate:uint = 88200;
			var expectedBlockAlign:uint = 2;
			var expectedBitsPerSample:uint = 16;
			
			var format:uint;
			var channels:uint;
			var sampleRate:uint;
			var byteRate:uint;
			var blockAlign:uint;
			var bitsPerSample:uint;
			
			var chunkData:ByteArray;
			var chunkId:String;
			
			try {
				_riffParser.readChunk();
				_riffParser.readSubChunk();
				chunkId = _riffParser.readChunk();

				while (chunkId != "fmt " && chunkId != null) {
					
					chunkId = _riffParser.readChunk();
				}

				chunkData = _riffParser.readChunkData();
				chunkData.endian = Endian.LITTLE_ENDIAN;
				
				format = chunkData.readUnsignedShort();
				channels = chunkData.readUnsignedShort();
				sampleRate = chunkData.readUnsignedInt();
				byteRate = chunkData.readUnsignedInt();
				blockAlign = chunkData.readUnsignedShort();
				bitsPerSample = chunkData.readUnsignedShort();
			}
			finally {
				assertNotNull("ChunkData equals null", chunkData);
				assertEquals("Unexpected format", format, expectedFormat);
				assertEquals("Unexpected channels", channels, expectedChannels);
				assertEquals("Unexpected sample rate", sampleRate, expectedSampleRate);
				assertEquals("Unexpected byte rate", byteRate, expectedByteRate);
				assertEquals("Unexpected block align", blockAlign, expectedBlockAlign);
				assertEquals("Unexpected bits per sample", bitsPerSample, expectedBitsPerSample);
			}
 */		
 		}
 	
	 	private function testStreamChunkDataReady():void { 
	 		var chunkInfo:RIFFChunkInfo;
			var chunkData:ByteArray = new ByteArray();
			var chunkSize:uint;
			var sizeRead:uint;
			var bufferSize:uint;
			
			try {
				_riffParser.readChunk();
				_riffParser.readSubChunk();
				chunkInfo = _riffParser.readChunk();

				while (chunkInfo.chunkId != "data" && chunkInfo != null) {
					
					chunkInfo = _riffParser.readChunk();
				}
				
				chunkSize = chunkInfo.size;
				bufferSize = Math.floor(chunkSize / 10);
				sizeRead = _riffParser.streamChunkData(bufferSize, chunkData);
				while (sizeRead == bufferSize) {
					sizeRead = _riffParser.streamChunkData(bufferSize, chunkData);
				}
			}
			finally {
				assertNotNull("ChunkData equals null", chunkData);
				assertEquals("Did not stream entire chunk (based on chunkInfo.size)", chunkSize, chunkData.length);
			}
		}
	}
}