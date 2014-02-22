package
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.Sfx;
	import flash.utils.getQualifiedClassName;
	
	public class Player extends Entity
	{
		public var vel : Vector.<Number>;
		public var id : int;
		public var muted : Boolean;

		private var colTypes:Array;
		public var input : GameInput;

		public function Player(ident:int, pos:Array, inp:GameInput, muted:Boolean) {
			// Set the initial velocity of the player
			vel = new Vector.<Number>(2, true);
			vel[0] = 0;
			vel[1] = 0;
			// set the id of the player
			id  = ident;
			input = inp;
			// I can't think of anything to collide with at the moment.
			colTypes = [];
			// Collide with other players
			for (var i:int = 0; i < GC.noPlayers; i++) {
				if (i != ident) {
					colTypes.push("player" + i);
				}
			}
			// set collide type
			type = "player" + i;
			this.muted = muted;
			// set possition
			super(pos[0], pos[1]);
			// Add sprites
			// TODO: make these not rubish boxes
			addGraphic(Image.createRect(GC.paddleWidth, GC.paddleHeight, 0xFF0000));
		}
		
		override public function update():void {
			super.update();

			// Check for input
			if (input.check("left"+id)) {
				vel[0] -= GC.moveSpeed;
			}
			if (input.check("right"+id)) {
				vel[0] += GC.moveSpeed;
			}
			// Damp the velocity to get smoother movement
			vel[0] *= GC.playerDamp[0];
			vel[1] *= GC.playerDamp[1];

			// Avoid anoying pass by reference
			var remainingVel : Vector.<Number> = new Vector.<Number>(2, true)
			remainingVel[0] = vel[0]; remainingVel[1] = vel[1];
			// If we are moving (sufficiently fast) move!
			while (remainingVel[0]*remainingVel[0] > 0.01) {
				if (remainingVel[0] > 0) {
					// Calculate the proportion of the velocity that didn't include
					// a bounce this should be less than 1
					var rightWallIncidenceProportion : Number = 1 - (x + GC.paddleWidth + remainingVel[0] - GC.windowWidth) / remainingVel[0];
					
					if (rightWallIncidenceProportion >= 0 && rightWallIncidenceProportion <= 1) {
						// We have hit the right wall
						x += remainingVel[0] * rightWallIncidenceProportion;
						// bounce, remove the current movement and repeat
						remainingVel[0] *= GC.playerBounce[1] * (1 - rightWallIncidenceProportion);
						// Set the velocity for the next frame
						vel[0] *= GC.playerBounce[1];
					} else {
						// there have been no colisions we just move
						x += remainingVel[0];
						remainingVel[0] = 0;
					}
				} else { // if (remainingVel[0] < 0)
					// Calculate the proportion of the velocity that didn't include
					// a bounce this should be less than 1
					var leftWallIncidenceProportion : Number = 1 - (x + remainingVel[0]) / remainingVel[0];

					if (leftWallIncidenceProportion >= 0 && leftWallIncidenceProportion <= 1) {
						// We have hit the left all
						x += remainingVel[0] * leftWallIncidenceProportion;
						// bounce, remove the current movement and repeat
						remainingVel[0] *= GC.playerBounce[0] * (1 - leftWallIncidenceProportion);
						// Set the velocity for the next frame
						vel[0] *= GC.playerBounce[0];
					} else {
						// there have been no colisions we just move
						x += remainingVel[0];
						remainingVel[0] = 0;
					}
				}
			}
		}
	}
}

// vim: foldmethod=indent:cindent
