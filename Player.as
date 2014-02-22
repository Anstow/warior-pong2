package
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	
	public class Player extends Entity
	{
		public var vel : Vector.<Number>;
		public var id : int;
		public var muted : Boolean;

		private var colTypes:Array;
		public var input : GameInput;

		public var aimEntity : AimEntity;
		public var angle : Number = 0;
		public var fireCounter : Number = 0;

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
			type = "player" + id;
			this.muted = muted;
			// set possition
			super(pos[0], pos[1]);
			// Set the hitbox
			setHitbox(GC.playerWidth, GC.playerHeight);
			// Add sprites
			// TODO: make these not rubish boxes
			addGraphic(Image.createRect(GC.playerWidth, GC.playerHeight, 0xFF0000));

			aimEntity = new AimEntity([x,y]);
			if (world) world.add(aimEntity);
		}
		
		override public function update():void {
			super.update();

			checkInput();
			shooting();
			updateSim();
			checkCollisions(); // this may be a misnomer updateSim also does a fair bit of collision checking.
		}

		override public function added():void {
			super.added();
			if (aimEntity) world.add(aimEntity);
		}

		override public function removed():void {
			if (aimEntity) world.remove(aimEntity);
		}

		public function checkInput():void {
			// Check for input
			if (input.check("left_target"+id)) {
				// Target left
				angle += GC.targettingAngleChange;
				// clamp the angle to the region
				if (angle > GC.targettingAngleClamp) angle = GC.targettingAngleClamp;
				aimEntity.setAngle(angle);
			}
			if (input.check("right_target"+id)) {
				// Target right
				angle -= GC.targettingAngleChange;
				if (angle < -GC.targettingAngleClamp) angle = -GC.targettingAngleClamp;
				aimEntity.setAngle(angle);
			}
			if (input.check("left"+id)) {
				vel[0] -= GC.moveSpeed;
			}
			if (input.check("right"+id)) {
				vel[0] += GC.moveSpeed;
			}
		}

		public function updateSim():void {
			// Damp the velocity to get smoother movement
			vel[0] *= GC.playerDamp[0];
			vel[1] *= GC.playerDamp[1];

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

			if (aimEntity) {
				aimEntity.setPos([x,y]);
			}
		}

		public function shooting():void {
			fireCounter++;
			if (fireCounter == GC.invFireRate) {
				fireCounter = 0;
				shoot();
			}
		}

		public function shoot():void {
			if (world) {
				world.add(new Ball(aimEntity.getPos(), [-Math.sin(angle)*GC.ballSpeed, -Math.cos(angle)*GC.ballSpeed], muted, id));
			}
		}

		public function checkCollisions():void {
		}
	}
}

// vim: foldmethod=indent:cindent
