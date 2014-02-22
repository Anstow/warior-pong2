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

		public static var moveSpeed:Number = 1.5;

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

		public static var paddleWidth:int = 100;
		public static var paddleHeight:int = 20;

		public static var playerAirDamp:Array = [.9, .9]; //Damping when !onGround
		public static var playerBounce:Array = [-1, -1, -1]; // [left-wall, right-wall, other-player]

		public static var noPlayers : int = 2;
		public static var playersStart: Array = [ [50, 520 - paddleHeight], [960 - paddleWidth - 50 , 520 - paddleHeight]];
		
		public static var EditorKeys:Object = {
		};
		
		public function GC ():void
		{
		}
	}
}

// vim: foldmethod=indent:cindent
