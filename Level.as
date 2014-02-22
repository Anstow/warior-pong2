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

		public var players:Array = [];
		private var input:GameInput;

		public var worldBuffer:BitmapData;
		private var mode:int;
		private var loadLevelCallback:Function;

		public var aiCounter : int = 0;
		public var nextSpawn : int = 1;
		public var currentDificultly : int = 1;

		public function Level (loadLevelCallback:Function = null, mode:int=0, replayData:Object = null) {
			// The game input is defined here 0 is the normal mode
			this.mode = mode;
			// check if we a running in buffered mode if so we write to a buffer
			if (mode & M_BUFFERED) {
				worldBuffer = new BitmapData(FP.width, FP.height, false, 0xFF202020);
			}
			// We set the input class based on whether the game is in playback,
			// record or normal mode. Clearly you can't both playback and
			// record.
			if (mode & M_PLAYBACK) {
				input = new GameInput(GameInput.PLAYBACK);
				if (replayData.replay !== undefined) {
					input.loadPlaybackData(replayData.replay);
				}
			} else if (mode & M_RECORD) {
				input = new GameInput(GameInput.RECORD);
			} else {
				input = new GameInput(GameInput.GAME_PLAY);
			}

			super();
			add(input);

			this.loadLevelCallback = loadLevelCallback;	
			reset();
		}

		public function reset():void
		{
			while(players.length > 0) {
				players.pop();
			}
			removeAll();

			var p:Player;
			for (var i : int = 0; i < GC.noPlayers; i++) {
				p = new Player(i, GC.playersStart[i], input, 0 != (mode & M_MUTED));
				trace("player" + i + " added");
				add(p);
				players.push(p);
			}

			input.restart();
			// TODO: reset function
		}

		public function spawnEnemy(t:int = -1):void {
			var pos : Array = [
			   	GC.spawnXLimits[0] + FP.random * (GC.windowWidth - GC.spawnXLimits[0] - GC.spawnXLimits[1]),
				GC.spawnYLimits[0] + FP.random * (GC.spawnYLimits[1] - GC.spawnXLimits[0]) ];
			spawnEnemyAt(pos, t);
		}
			
		public function spawnEnemyAt(pos:Array, t:int = -1):void {
			if (t == -1) t = FP.rand(GC.enemies.length);
			add(new Enemy(0, pos, 0 != (mode & M_MUTED)));
		}

		public function spawner():void {
			aiCounter++;
			if (aiCounter == nextSpawn) {
				currentDificultly++;
				nextSpawn += GC.spawnGap;
				for (var i : int = 0; i < currentDificultly; i++) {
					spawnEnemy();
				}
			}
		}

		override public function update():void {
			super.update();

			spawner();
			// reset key
			if (input.pressed("restart")) {
				loadLevelCallback(new Level(loadLevelCallback));
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

		/*!
		 * \brief This calculates the first collision (as a proportion of the velocity) of a box with a bounding box of your choice.
		 *
		 * \param pos:Array [x,y] The top left corner of the box to collide with
		 * \param vel:Array [vx, vy] The velocity of the item colliding.
		 * \param collisionBox:Array [left, right, top, bottom] The inner box to collide with.
		 * \param boundingBox:Array [left, right, top, bottom] The outer box to collide with.
		 *
		 * \return Array [proportionOfVel:Number, side:int] and null if there is no collision. Where
		 * 		0 is left
		 * 		1 is right
		 *		2 is top
		 * 		3 is bottom
		 */
		public static function CalculateCollideTimes(pos:Array, vel:Array, collisionBox:Array, boundingBox:Array = null):Array {
			if (boundingBox == null) boundingBox = [0,GC.windowWidth,0,GC.windowHeight];
			var collisions:Array = [2,2,2,2,2];
			if (vel[0]*vel[0] > 0.01) {
				if (vel[0] < 0) {
					// Calculate the proportion of the velocity that collides with the left wall
					collisions[0] = 1 - (pos[0] + collisionBox[0] + vel[0] - boundingBox[0]) / vel[0];
					if (collisions[0] < 0 || collisions[0] > 1) collisions[0] = 2;
				} else { // if (vel[0] > 0)
					// Calculate the proportion of the velocity that collides with the right wall
					collisions[1] = 1 - (pos[0] + collisionBox[1] + vel[0] - boundingBox[1]) / vel[0];
					if (collisions[1] < 0 || collisions[1] > 1) collisions[1] = 2;
				}
			}
			if (vel[1]*vel[1] > 0.01) {
				if (vel[1] < 0) {
					// Calculate the proportion of the velocity that collides with the bottom wall
					collisions[2] = 1 - (pos[1] + collisionBox[2] + vel[1] - boundingBox[2]) / vel[1];
					if (collisions[2] < 0 || collisions[2] > 1) collisions[2] = 2;
				} else { // if (vel[1] > 0)
					// Calculate the proportion of the velocity that collides with the top wall
					collisions[3] = 1 - (pos[1] + collisionBox[3] + vel[1] - boundingBox[3]) / vel[1];
					if (collisions[3] < 0 || collisions[3] > 1) collisions[3] = 2;
				}
			}
			var minPosition : int = 4;
			for (var i:int = 0; i<4; i++) {
				if (collisions[i] < collisions[minPosition])
					minPosition = i;
			}
			if (minPosition != 4)
				return [collisions[minPosition], minPosition];
			else
				return null;
		}
	}
}

// vim: foldmethod=indent:cindent
