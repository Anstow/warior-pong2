package
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.FP;
	
	public class Enemy extends Entity
	{
		public var vel : Vector.<Number>;
		public var id : int;
		public var muted : Boolean;
		public var speed : Number;
		public var aiRepeat : int;
		public var aiCounter : int;

		private var colTypes:Array;

		public function Enemy(ident:int, pos:Array, muted:Boolean) {
			// Set up the velocity vector
			vel = new Vector.<Number>(2, true);
			vel[0] = 0;
			vel[1] = 0;
			// set the id of the player
			id  = ident;
			// I can't think of anything to collide with at the moment.
			colTypes = [];
			// set collide type
			type = GC.enemies[id].aiType;
			speed = GC.enemies[id].speed;
			aiRepeat = GC.enemies[id].ai_repeat;
			this.muted = muted;
			// set possition
			super(pos[0], pos[1]);
			// Set the hitbox
			setHitbox(GC.enemies[id].hitbox[0], GC.enemies[id].hitbox[1]);
			// Add sprites
			// TODO: make these not rubish boxes
			addGraphic(Image.createRect(GC.enemies[id].hitbox[0], GC.enemies[id].hitbox[1], 0xFF0000));
			aiCounter = 0;
			// Set the initial velocity
			queryAI();
		}
		
		override public function update():void {
			super.update();

			runAI();
			updateSim();
			checkCollisions(); // this may be a misnomer updateSim also does a fair bit of collision checking.
		}

		public function queryAI():void {
			switch (type) {
				case "bouncer":
					var a : Number = FP.random * 2 * Math.PI;
					vel[0] = Math.cos(a) * speed;
					vel[1] = Math.sin(a) * speed;
					break;
			}
		}

		public function runAI():void {
			aiCounter++;
			if (aiCounter == aiRepeat) {
				aiCounter = 0;
				queryAI();
			}
		}

		public function updateSim():void {
			// Avoid anoying pass by reference
			var remainingVel : Array = [vel[0],vel[1]];
			// If we are moving (sufficiently fast) move!
			while (remainingVel[0]*remainingVel[0] + remainingVel[1]*remainingVel[1] > 0.01) {
				var collisionData : Array = Level.CalculateCollideTimes([x,y], remainingVel, [0,GC.playerWidth,0, GC.playerHeight]);
				if (collisionData) {
					// We have collided so move to the colision point
					x += remainingVel[0]*collisionData[0]; y += remainingVel[1]*collisionData[0];
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

		public function checkCollisions():void {
			var b :Ball = collide("ball", x, y) as Ball;
			if (b) {
				// Increase score or relevant player
				// b.playerShot;
				if (world) world.remove(this); // I like these belts and braces
			}
		}
	}
}

// vim: foldmethod=indent:cindent
