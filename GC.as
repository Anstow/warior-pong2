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
			left_target0: [Key.A],
			right_target0: [Key.D , Key.E],
			//shoot0: [Key.S, Key.O],
			// The keys for player 1
			left_target1: [Key.LEFT], // , Key.D],
			right_target1: [Key.RIGHT], // , Key.N],
			//shoot1: [Key.DOWN],
			// The keys for player 2 this requires qwerty
			left_target2: [Key.H],
			right_target2: [Key.K],

			// Other used keys
			//skip: [191, 192],
			//editor: [Key.F2],
			restart: [Key.R, Key.P],
			mute: [Key.M]
		};
		
		public static var noPlayers : int = 2;
		public static var playerStartHeight : int = 50;
		//public static var playersStart: Array = [ [50, 520 - playerHeight], [960 - playerWidth - 50 , 520 - playerHeight]];

		public static var EditorKeys:Object = {
		};

		public static var ballSpeed:Number = 7;
		public static var ballRadius:int = 5;
		public static var ballDamp:Array = [1, 1]; // [xDamp, yDamp]
		public static var ballBounce:Array = [-1, -1, -1, -1, -1]; // [left-wall, right-wall, top-wall, bottom-wall, other]

		public static var moveSpeed:Number = 1.5;
		public static var playerWidth:int = 100;
		public static var playerHeight:int = 20;
		public static var playerDamp:Array = [.8, .8]; // [xDamp, yDamp]
		public static var playerBounce:Array = [-1, -1, -1, -1, -1]; // [left-wall, right-wall, top-wall, bottom-wall, other]

		public static var targettingAngleChange : Number = 0.1;
		public static var targettingAngleClamp : Number = Math.PI/6;
		public static var targettingNo:int = 3;
		public static var targettingSizes:Array = [ 10, 6, 3.6 ];
		public static var targettingCenter:Array = [ 0, 15 ];
		public static var targettingOffsets:Array = [ 21, 35.6 ];
		public static var invFireRate : int = 30;

		public static var spawnXLimits: Array = [10,60]; //[xFromLeft, xFromRight]
		public static var spawnYLimits: Array = [10,60]; //[yTopClose, yTopFar]
		public static var spawnGap: int = 180; // In seconds/60

		public static var enemies : Array = [
			{
				aiType: "bouncer",
				speed: 0.5,
				ai_repeat: 240, // The ai is re-ran after this many frames passes
				hitbox: [20, 20]
			}
		]
		
		public function GC ():void
		{
		}
	}
}

// vim: foldmethod=indent:cindent
