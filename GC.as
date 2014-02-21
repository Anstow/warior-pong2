package
{
	import flash.utils.ByteArray;
	import com.adobe.serialization.json.JSON;

	import net.flashpunk.utils.Key;

	/**
	 * ...
	 * @author David Watson
	 */
	import net.flashpunk.graphics.Image;
	public class GC
	{
		public static var windowHeight:int = 540;
		public static var windowWidth:int = 960;
		public static var FPS:int = 60;

		// Input stuff
		public static var inputKeys:Object = {
			// The keys for player 0
			up0: [Key.W, 188],
			left0: [Key.A],
			down0: [Key.S, Key.O],
			right0: [Key.D, Key.E],
			// The keys for player 1
			up1: [Key.UP],
			left1: [Key.LEFT],
			down1: [Key.DOWN],
			right1: [Key.RIGHT],
			// Other used keys
			skip: [191, 192],
			editor: [Key.F2],
			restart: [Key.R, Key.P],
			mute: [Key.M]
		};
		
		public static var EditorKeys:Object = {
		};
		
		public function GC ():void
		{
		}
	}
}

// vim: foldmethod=indent:cindent
