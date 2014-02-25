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
		public var scoreBoxes:Array =  [];
		public var combindedScoreBox:ScoreBox;

		private var input:GameInput;

		public var worldBuffer:BitmapData;
		private var mode:int;
		private var loadLevelCallback:Function;

		public var aiCounter : int;
		public var nextSpawn : int;
		public var currentDificultly : Number;
		public var nextPowerUp : Number;

		public var mobCount : int = 0;

		public var toSpawn : Vector.<Array>;

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

			toSpawn = new Vector.<Array>();

			super();
			add(input);

			this.loadLevelCallback = loadLevelCallback;	
			reset();
		}

		public function reset():void {
			while(players.length > 0) {
				players.pop();
			}
			removeAll();

			var p:Player;
			for (var i : int = 0; i < GC.noPlayers; i++) {
				// Find the x position to spawn the player and score box
				var xPos:int = (i+1)*GC.windowWidth / (GC.noPlayers + 1);
				// Create and spawn the player
				p = new Player(i, [xPos - GC.playerWidth/2, GC.windowHeight - GC.playerStartHeight], input, 0 != (mode & M_MUTED));
				add(p);
				players.push(p);
				// Create a new score and score box for the player set to 0
				scoreBoxes.push(new ScoreBox([xPos, GC.scoreYPos],0,i));
				add(scoreBoxes[i]);
			}

			// Create the combined score
			combindedScoreBox = new ScoreBox(GC.combindedScorePos,0);
			add(combindedScoreBox);
			
				// Set up the spawn counters and difficulty
			aiCounter = 0;
			nextSpawn = 1;
			currentDificultly = 10;
			nextPowerUp = GC.initialPowerUpGap;

			input.restart();
			// TODO: reset function
		}

		public function spawnEnemy(t:int = -1):void {
			spawnEnemyAt(getSpawnPos(), t);
		}
			
		public function spawnEnemyAt(pos:Array, t:int = -1):void {
			if (t == -1) t = 0; //FP.rand(GC.enemies.length);
			add(Enemy.createEnemy(t, pos, 0 != (mode & M_MUTED)));
		}

		public function createPowerUp(t:int = -1):void {
			createPowerUpAt(getSpawnPos(), t);
		}

		public function createPowerUpAt(pos:Array, t:int = -1):void {
			if (t == -1) t = 0; //FP.rand(GC.enemies.length);
			add(PowerUp.createPowerUp(pos, GC.powerUpVel, 0 != (mode & M_MUTED)));
		}

		public function getSpawnPos():Array {
			return [
			   	GC.spawnXLimits[0] + FP.random * (GC.windowWidth - GC.spawnXLimits[0] - GC.spawnXLimits[1]),
				GC.spawnYLimits[0] + FP.random * (GC.spawnYLimits[1] - GC.spawnXLimits[0]) ];
		}

		public function spawner():void {
			aiCounter++;
			if (aiCounter == nextSpawn) {
				aiCounter = 0;
				var temp : int = mobCount;
				while (temp < currentDificultly) {
					// Lets do some spawning
					var s : Array = FP.choose(GC.spawnValues);
					if (s[1] > currentDificultly) continue;
					var pos:Array = getSpawnPos();
					for (var i : int = 0; i < s[2]; i++) {
						temp += GC.enemies[s[0]].value;
						toSpawn.push([pos,s[0]]);
					}
				}

				if (combindedScoreBox.Score > nextPowerUp) {
					createPowerUp(0);
					nextPowerUp+=GC.powerUpGap;
				}
			}
			 
			while (toSpawn.length > 0) {
				var spawn : Array = toSpawn.pop();
				spawnEnemyAt(spawn[0], spawn[1]);
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
			if (e is Enemy) {
				mobCount += (e as Enemy).value;
			}
			return super.add(e);
		}

		//}

		public override function remove(e:Entity):Entity {
			if (e is Enemy) {
				// Check 
				mobCount -= (e as Enemy).value;
				currentDificultly += 0.5;
				if ((e as Enemy).killedBy >= 0) {
					scoreBoxes[(e as Enemy).killedBy].Score += (e as Enemy).value;
				}
				combindedScoreBox.Score += (e as Enemy).value;
			}
			return super.remove(e);
		}

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
			if (minPosition != 4) {
				return [collisions[minPosition], minPosition];
			}
			else
				return null;
		}
	}
}

// vim: foldmethod=indent:cindent
