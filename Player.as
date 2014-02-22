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
			addGraphic(Image.createRect(GC.playerWidth, GC.playerHeight, 0xFF0000));
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
			var remainingVel : Array = [vel[0],vel[1]];
			// If we are moving (sufficiently fast) move!
			while (remainingVel[0]*remainingVel[0] + remainingVel[1]*remainingVel[1] > 0.5) {
				var collisionData : Array = Level.CalculateCollideTimes([x,y], remainingVel, [0,GC.playerWidth,0, GC.playerHeight]);
				if (collisionData) {
					// We have collided so move to the colision point
					moveBy(remainingVel[0]*collisionData[0], remainingVel[1]*collisionData[0], colTypes);
					switch (collisionData[1])
					{
						case 0:
							// We have hit the left wall
							// bounce, remove the current movement and repeat
							remainingVel[0] *= GC.playerBounce[0] * (1 - collisionData[0]);
							remainingVel[1] *= (1 - collisionData[0]);
							// Set the velocity for the next frame
							vel[0] *= GC.playerBounce[0];
							break;
						case 1:
							// We have hit the right wall
							// bounce, remove the current movement and repeat
							remainingVel[0] *= GC.playerBounce[1] * (1 - collisionData[0]);
							remainingVel[1] *= (1 - collisionData[0]);
							// Set the velocity for the next frame
							vel[0] *= GC.playerBounce[1];
							break;
						case 2:
							// We have hit the bottom wall
							// bounce, remove the current movement and repeat
							remainingVel[0] *= (1 - collisionData[0]);
							remainingVel[1] *= GC.playerBounce[2] * (1 - collisionData[0]);
							// Set the velocity for the next frame
							vel[1] *= GC.playerBounce[2];
							break;
						case 3:
							// We have hit the bottom wall
							// bounce, remove the current movement and repeat
							remainingVel[0] *= (1 - collisionData[0]);
							remainingVel[1] *= GC.playerBounce[3] * (1 - collisionData[0]);
							// Set the velocity for the next frame
							vel[1] *= GC.playerBounce[3];
							break;
						default:
							// Ok this shouldn't have happened lets pretend it didn't and just update normally
							moveBy(remainingVel[0], remainingVel[1], colTypes);
							remainingVel = [0,0];
							break;
					}
				} else {
					// We haven't collided
					moveBy(remainingVel[0], remainingVel[1], colTypes);
					remainingVel = [0,0];
				}
			}
			// Resorting to terrible clampling
			if (x < 0) {
				x = 0;
				vel[0] *= -1;
			} else if (x + GC.playerWidth > GC.windowWidth) {
				x = GC.windowWidth - GC.playerWidth - 1;
				vel[0] *= -1;
			}
			if (y < 0) {
				y = 0;
				vel[1] *= -1;
			} else if (y + GC.playerHeight > GC.windowHeight) {
				y = GC.windowHeight - GC.playerHeight - 1;
				vel[1] *= -1;
			}
		}
	}
}

// vim: foldmethod=indent:cindent
