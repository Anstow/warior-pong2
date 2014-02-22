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
		public static const windowHeight:int = 540;
		public static const windowWidth:int = 960;
		public static const FPS:int = 60;


		// Input stuff
		public static var inputKeys:Object = {
			// The keys for player 0
			//up0: [Key.W, 188],
			//down0: [Key.S, Key.O],
			left0: [Key.A],
			right0: [Key.D, Key.E],
			left_target0: [Key.A],
			right_target0: [Key.D, Key.E],
			fire0: [Key.S, Key.O],
			// The keys for player 1
			//up1: [Key.UP],
			//down1: [Key.DOWN],
			left1: [Key.LEFT],
			right1: [Key.RIGHT],
			left_target1: [Key.LEFT],
			right_target1: [Key.RIGHT],
			fire1: [Key.DOWN],

			// Other used keys
			skip: [191, 192],
			editor: [Key.F2],
			restart: [Key.R, Key.P],
			mute: [Key.M]
		};
		
		public static var EditorKeys:Object = {
		};

		public static var ballRadius:int = 5;
		public static var ballDamp:Array = [1, 1]; // [xDamp, yDamp]
		public static var ballBounce:Array = [-1, -1, -1, -1, -1]; // [left-wall, right-wall, top-wall, bottom-wall, other]

		public static var moveSpeed:Number = 1.5;
		public static var playerWidth:int = 100;
		public static var playerHeight:int = 20;
		public static var playerDamp:Array = [.9, .9]; // [xDamp, yDamp]
		public static var playerBounce:Array = [-1, -1, -1, -1, -1]; // [left-wall, right-wall, top-wall, bottom-wall, other]

		public static var noPlayers : int = 2;
		public static var playersStart: Array = [ [50, 520 - playerHeight], [960 - playerWidth - 50 , 520 - playerHeight]];
		
		public function GC ():void
		{
		}
	}
}

// vim: foldmethod=indent:cindent
