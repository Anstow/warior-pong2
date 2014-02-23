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
		private var playerShot:int;
		private var image:Image;

		public function Ball(pos:Array, vel:Array, muted:Boolean, playerShot:int = -1) {
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
			this.playerShot = playerShot;
			// set possition
			super(pos[0], pos[1]);
			// Set the hitbox
			setHitbox(GC.ballRadius*2, GC.ballRadius*2, GC.ballRadius, GC.ballRadius);
			// Add sprites
			// TODO: make that are not rubish circles
			image = Image.createCircle(GC.ballRadius, 0x00FF00);
			image.x -= GC.ballRadius; image.y -= GC.ballRadius;
			addGraphic(image);
		}
		
		override public function update():void {
			super.update();

			updateSim();
		}

		public function updateSim():void {
			// Damp the velocity if needed
			vel[0] *= GC.ballDamp[0];
			vel[1] *= GC.ballDamp[1];

			// Avoid anoying pass by reference
			var remainingVel : Array = [vel[0],vel[1]];
			// If we are moving (sufficiently fast) move!
			while (remainingVel[0]*remainingVel[0] + remainingVel[1]*remainingVel[1] > 0.01) {
				var collisionData : Array = Level.CalculateCollideTimes([x,y], remainingVel, [left,right,top,bottom]);
				if (collisionData) {
					// We have collided so move to the colision point
					x += remainingVel[0]*collisionData[0]; y += remainingVel[1]*collisionData[0];
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
							// We have hit the top wall
							// bounce, remove the current movement and repeat
							remainingVel[0] *= (1 - collisionData[0]);
							remainingVel[1] *= GC.ballBounce[2] * (1 - collisionData[0]);
							// Set the velocity for the next frame
							vel[1] *= GC.ballBounce[2];
							break;
						case 3:
							// We have hit the bottom wall
							// bounce, remove the current movement and repeat
							//remainingVel[0] *= (1 - collisionData[0]);
							//remainingVel[1] *= GC.ballBounce[3] * (1 - collisionData[0]);
							// Set the velocity for the next frame
							//vel[1] *= GC.ballBounce[3];
							
							// Set vel to zero to avoid an infinite loop
							remainingVel[0]=0; remainingVel[1] = 0;
							hitBottom();
							break;
						default:
							// Ok this shouldn't have happened lets pretend it didn't and just update normally
							x += remainingVel[0]; y += remainingVel[1];
							remainingVel = [0,0];
							break;
					}
				} else {
					// We haven't collided
					x += remainingVel[0]; y += remainingVel[1];
					remainingVel = [0,0];
				}
			}
			// Resorting to terrible clampling
			// TODO: don't rely on something quite so terrible
			if (x < 0) {
				x = 0;
				vel[0] *= -1;
			} else if (x + GC.ballRadius*2 > GC.windowWidth) {
				x = GC.windowWidth - GC.playerWidth - 1;
				vel[0] *= -1;
			}
			if (y < 0) {
				y = 0;
				vel[1] *= -1;
			} else if (y + GC.ballRadius*2 > GC.windowHeight) {
				y = GC.windowHeight - GC.playerHeight - 1;
				vel[1] *= -1;
				hitBottom();
			}
		}

		public function hitEnemy(level:int):void {
			// If at some point I implement new balls level may become
			// necessery
			remove();
		}

		public function hitBottom():void {
			remove();
		}
		
		public function remove():void {
			if (world) world.remove(this);
		}
	}
}

// vim: foldmethod=indent:cindent
