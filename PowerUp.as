package
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.Sfx;
	import flash.utils.getQualifiedClassName;
	
	public class PowerUp extends Entity
	{
		public var vel : Array;
		public var muted : Boolean;

		private var image:Image;
		private var colTypes : Array;

		public function PowerUp(pos:Array, vel:Array, muted:Boolean) {
			// Set the initial velocity of the ball
			this.vel = [vel[0],vel[1]];
			// Add collision with players
			colTypes = [];
			for (var i:int = 0; i < GC.noPlayers; i++) {
				colTypes.push("player" + i);
			}
			// set collide type
			type = "powerUp";
			this.muted = muted;
			// set possition
			super(pos[0], pos[1]);
			// Set the hitbox
			setHitbox(GC.powerUpWidth, GC.powerUpHeight);
			// Add sprites
			// TODO: make that are not rubish rectangle
			image = Image.createRect(GC.powerUpWidth, GC.powerUpHeight, 0x00FF00);
			addGraphic(image);
		}
		
		override public function update():void {
			super.update();

			updateSim();
			checkCollisions();
		}

		public function updateSim():void {
			// Avoid anoying pass by reference
			var remainingVel : Array = [vel[0],vel[1]];
			// If we are moving (sufficiently fast) move!
			while (remainingVel[0]*remainingVel[0] + remainingVel[1]*remainingVel[1] > 0.01) {
				var collisionData : Array = Level.CalculateCollideTimes([0,0], remainingVel, [left,right,top,bottom]);
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
							remainingVel[0] *= (1 - collisionData[0]);
							remainingVel[1] *= GC.ballBounce[3] * (1 - collisionData[0]);
							// Set the velocity for the next frame
							vel[1] *= GC.ballBounce[3];
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
			if (left < 0) {
				x = originX;
				vel[0] *= -1;
			} else if (right > GC.windowWidth) {
				x = GC.windowWidth + originX - width;
				vel[0] *= -1;
			}
			if (top < 0) {
				y = originY;
				vel[1] *= -1;
			} else if (bottom > GC.windowHeight) {
				y = GC.windowHeight + originY - height;
				vel[1] *= -1;
			}
		}

		public function checkCollisions():void {
			var p : Player = collideTypes(colTypes, x, y) as Player;
			if (p) {
				hitPlayer(p);
			}
		}

		public function hitPlayer(p:Player):void {
			removeThis();
		}
		
		public function removeThis():void {
			if (world) world.remove(this);
		}

		public static function createPowerUp(pos:Array, vel:Array, muted:Boolean):PowerUp {
			return new PowerUp(pos, vel, muted);
		}
	}
}

// vim: foldmethod=indent:cindent
