package
{
	import flash.utils.ByteArray;
	import com.adobe.serialization.json.JSON;
	import flash.display.BitmapData;
    import flash.geom.Point;
    import flash.geom.Rectangle;

	import net.flashpunk.utils.Key;
	import net.flashpunk.graphics.Image;

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
			right0: [Key.D , Key.E],
			left0: [Key.A],
			right_target0: [Key.D , Key.E],
			switch_mode0: [Key.W, 188],
			//shoot0: [Key.S, Key.O],
			// The keys for player 1
			left_target1: [Key.LEFT],
			right_target1: [Key.RIGHT],
			left1: [Key.LEFT],
			right1: [Key.RIGHT],
			switch_mode1: [Key.UP],
			//shoot1: [Key.DOWN],
			// The keys for player 2 this requires qwerty
			left_target2: [Key.H], // , Key.D],
			right_target2: [Key.K], // , Key.N],
			left2: [Key.H], // , Key.D],
			right2: [Key.K], // , Key.N],
			switch_mode2: [Key.U], // , Key.G],

			// Other used keys
			//skip: [191, 192],
			//editor: [Key.F2],
			restart: [Key.R, Key.P],
			mute: [Key.M]
		};
		
		public static var EditorKeys:Object = {
		};

		// Player stuff
		public static var noPlayers : int = 2;
		public static var playerStartHeight : int = 50;
		public static var moveSpeed:Number = 1.5;
		public static var playerWidth:int = 70;
		public static var playerHeight:int = 20;
		public static var playerDamp:Array = [.8, .8]; // [xDamp, yDamp]
		public static var playerBounce:Array = [ -1, -1, -1, -1, -1]; // [left-wall, right-wall, top-wall, bottom-wall, other]
		public static var playerStartBallsFired:uint = 1;
		public static var playerMinBallsFired:uint = 1;
		public static var playerMaxBallsFired:uint = 5;
		public static var shotSpread:Number = 0.02;
		public static var shotStartOffset:Number = 0.5;
		public static var shotStartRadius:Number = 10;
		public static var playerGraphicsBoxes:Array = [
			[0, 20, 70, 20],
			[0, 60, 70, 20],
			[0, 0, 70, 20]
		];

		// Player targetting stuff
		public static var targettingAngleChange : Number = 0.05;
		public static var targettingAngleClamp : Number = Math.PI/6;
		public static var targettingNo:int = 3; // no. of targeting circles?
		public static var targettingSizes:Array = [ 5, 3, 2 ]; // radius for the targeting circles in pixels
		public static var targettingCenter:Array = [ 0, 10 ]; // centre of bottom targeting circle relative to top centre of paddle
		public static var targettingOffsets:Array = [ 18, 32 ]; // offsets between the centre of circles starting from the bottom
		public static var invFireRate:int = 30;
		public static var targetingGraphicsBoxes:Array = [
			[162,20,10,10],
			[182,14,6,6],
			[188,14,4,4],
		];

		// Player selector stuff
		public static var selectorRotateSpeed:Number = 0.6;
		public static var selectorGraphicsBoxes:Array = [
			[70,0,28,28],
			[70,0,28,28],
			[70,0,28,28]
		];

		// Player score stuff
		public static var scoreYPos : int = 20;
		public static var combindedScorePos:Array = [windowWidth/2, 0];

		// Ball stuff
		public static var ballSpeed:Number = 7;
		public static var ballRadius:int = 5;
		public static var ballDamp:Array = [1, 1]; // [xDamp, yDamp]
		public static var ballBounce:Array = [-1, -1, -1, -1, -1]; // [left-wall, right-wall, top-wall, bottom-wall, other]

		// Power Up stuff
		public static var powerUpWidth:int = 10;
		public static var powerUpHeight:int = 10;
		public static var powerUpVel:Array = [0, 3];

		public static var initialPowerUpGap:Number = 100;
		public static var powerUpGap:Number = 200;

		// This is only pretending to be well programed; in reality I'm just
		// using this as a list of the hard coded power up types. Actually this
		// list is never looked at in code at all. I guess at some point that
		// should be fixed. (Only the length is used).
		public static var powerUps:Array = [
			{ powerUpType:"ExtraBall" }
		];

		// Enemy spawn stuff
		public static var spawnXLimits: Array = [10,60]; //[xFromLeft, xFromRight]
		public static var spawnYLimits: Array = [10,60]; //[yTopClose, yTopFar]
		public static var spawnGap: int = 180; // In seconds/60
		public static var spawnValues:Array = [
			// [Position in enemies, dificulty to start spawning at, how many to spawn]
			[0, 1, 10],
			[1, 3, 10],
			[2, 10, 1]
		];

		// Enemy types
		public static var enemies : Array = [
			{
				aiType: "bouncer",
				speed: 0.5,
				level: 0,
				addable: true,
				value: 1,
				ai_repeat: 240, // The ai is re-ran after this many frames passes
				hitbox: [18, 20], // width, height
				graphic_box: [162,30,18,20,0] // x,y,w,h,angle
			},
			{
				aiType: "bouncer",
				speed: 0.5,
				level: 1,
				addable: true,
				value: 10,
				ai_repeat: 240, // The ai is re-ran after this many frames passes
				hitbox: [18, 20],
				graphic_box: [162,50,18,20,0]
			},
			{
				aiType: "tail_head",
				speed: 0.5,
				level: 1,
				addable: true,
				value: 20,
				ai_repeat: 1, // The ai is re-ran after this many frames passes
				hitbox: [13,13],
				graphic_box: [198,0,13,13,Math.PI],
				turn_angle_cap: 0.01,
				turn_frequency: 200,
				tailPiece: 3,
				tailLength: 9,
				tailSeparation: 20 // In frames
			},
			{
				aiType: "tail_piece",
				speed: 0.5,
				level: 3,
				addable: false,
				value: 0,
				ai_repeat: -1, // We don't want any ai to run
				hitbox: [13,13],
				graphic_box: [165,102,13,13,0]
			}
		];
		
		// Assets
		[Embed(source = './assets/spritesheet.png')] public static const ASSETS:Class;

		// Getting the assets
		public static function getClippedImg(clipRect:Array, frames:uint = 256, src:Class = null):MyPreRotation {
			if (!src) src = ASSETS;
			return new MyPreRotation(src, clipRect, frames);
		}
		
		public function GC ():void
		{
		}
	}
}

// vim: foldmethod=indent:cindent
