package
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.Sfx;
	import flash.utils.getQualifiedClassName;
	
	public class Ball extends Entity
	{
		public var vel : Array;
		public var muted : Boolean;

		private var colTypes:Array;

		public function Ball(pos:Array, vel:Array, muted:Boolean) {
			// Set the initial velocity of the ball
			this.vel = [vel[0],vel[1]];
			// I can't think of anything to collide with at the moment.
			colTypes = [];
			// Collide with the players
			for (var i:int = 0; i < GC.noPlayers; i++) {
				colTypes.push("player" + i);
			}
			// set collide type
			type = "ball";
			this.muted = muted;
			// set possition
			super(pos[0], pos[1]);
			// Add sprites
			// TODO: make these not rubish circles
			addGraphic(Image.createCircle(GC.ballRadius, 0x00FF00));
		}
		
		override public function update():void {
			super.update();
			// Damp the velocity if needed
			vel[0] *= GC.ballDamp[0];
			vel[1] *= GC.ballDamp[1];

			// Avoid anoying pass by reference
			var remainingVel : Array = [vel[0],vel[1]];
			// If we are moving (sufficiently fast) move!
			while (remainingVel[0]*remainingVel[0] + remainingVel[1]*remainingVel[1] > 0.001) {
				var collisionData : Array = Level.CalculateCollideTimes([x,y], remainingVel, [0,GC.ballRadius*2,0, GC.ballRadius*2]);
				if (collisionData) {
					// We have collided so move to the colision point
					moveBy(remainingVel[0]*collisionData[0], remainingVel[1]*collisionData[0], colTypes);
					switch (collisionData[1])
					{
						case 0:
							// We have hit the left wall
							// bounce, remove the current movement and repeat
							remainingVel[0] *= GC.ballBounce[0] * (1 - collisionData[0]);
							remainingVel[1] *= (1 - collisionData[0]);
							// Set the velocity for the next frame
							vel[0] *= GC.ballBounce[0];
							break;
						case 1:
							// We have hit the right wall
							// bounce, remove the current movement and repeat
							remainingVel[0] *= GC.ballBounce[1] * (1 - collisionData[0]);
							remainingVel[1] *= (1 - collisionData[0]);
							// Set the velocity for the next frame
							vel[0] *= GC.ballBounce[1];
							break;
						case 2:
							// We have hit the bottom wall
							// bounce, remove the current movement and repeat
							remainingVel[0] *= (1 - collisionData[0]);
							remainingVel[1] *= GC.ballBounce[2] * (1 - collisionData[0]);
							// Set the velocity for the next frame
							vel[1] *= GC.ballBounce[2];
							break;
						case 3:
							// We have hit the bottom wall
							// bounce, remove the current movement and repeat
							remainingVel[0] *= (1 - collisionData[0]);
							remainingVel[1] *= GC.ballBounce[3] * (1 - collisionData[0]);
							// Set the velocity for the next frame
							vel[1] *= GC.ballBounce[3];
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
		}

		public function attachToPlayer():void {
		}
	}
}

// vim: foldmethod=indent:cindent
