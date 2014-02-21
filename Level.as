package
{
	import net.flashpunk.World;
	import net.flashpunk.FP;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Spritemap;
	import flash.display.BitmapData;
	
	public class Level extends World
	{
		// Muted
		public static const M_MUTED:int = 1;
		// Buffered
		public static const M_BUFFERED:int = 2;
		// ONCE
		public static const M_ONCE:int = 4;
		// Playback
		public static const M_PLAYBACK:int = 8;
		// Record
		public static const M_RECORD:int = 16;

		public var nPlayers:int = 2;
		public var players:Array = [];
		private var input:GameInput;

		public var worldBuffer:BitmapData;
		private var mode:int;
		private var loadLevelCallback:Function;

		public function Level (data:Object, mode:int=0, loadLevelCallback:Function = null) {
			// The game input is defined here 0 is the normal mode
			this.mode = mode;
			if (mode & M_BUFFERED) {
				worldBuffer = new BitmapData(FP.width, FP.height, false, 0xFF202020);
			}
			// We set the input class based on whether the game is in playback,
			// record or normal mode. Clearly you can't both playback and
			// record.
			if (mode & M_PLAYBACK) {
				input = new GameInput(GameInput.PLAYBACK);
				if (data.replay !== undefined) {
					input.loadPlaybackData(data.replay);
				}
			} else if (mode & M_RECORD) {
				input = new GameInput(GameInput.RECORD);
			} else {
				input = new GameInput(GameInput.GAME_PLAY);
			}

			super();
			add(input);

			this.loadLevelCallback = loadLevelCallback;	
		}

		public function reset()
		{
			for (var i:int = 0; i < GC.noPlayers; i++) {
				remove(p);
			}
			players.empty();

			var p:Player;
			for (var i:int = 0; i < GC.noPlayers; i++) {
				p = new Player(i, GC.playersStart[i], input, 0 != (mode & M_MUTED));
				add(p);
				players.push(p);
			}

			input.restart();

			// TODO: reset function
		}

		override public function update():void
		{
			super.update();
			// reset key
			if (input.pressed("restart")) {
				reset();
			}
			// mute key
			if (input.pressed("mute")) {
				if (FP.volume == 0) FP.volume = 1;
				else FP.volume = 0;
			}
		}

		//{ Overriden for advanced buffering functions
		
		// We override the add function to make the entity draw to a buffer
	   	// instead of the screen 
		public override function add(e:Entity):Entity {
			e.renderTarget = worldBuffer;
			return super.add(e);
		}

		//}
	}
}

// vim: foldmethod=indent:cindent
