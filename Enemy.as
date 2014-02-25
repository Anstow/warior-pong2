package
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	
	import enemies.*;
	
	public class Enemy extends Entity
	{
		public var vel : Vector.<Number>;
		public var id : int;
		public var muted : Boolean;

		public var speed : Number;
		public var level : int;

		public var aiRepeat : Number;
		public var aiCounter : Number;
		private var image : MyPreRotation;
		private var angle : Number;
		private var imgAngle : Number = 0;
		public var value:int = 0;
		public var killedBy:int = -1;

		public function Enemy(ident:int, pos:Array, muted:Boolean) {
			// Set up the velocity vector
			vel = new Vector.<Number>(2, true);
			vel[0] = 0;
			vel[1] = 0;
			// set the id of the player
			id  = ident;
			// set collide type
			type = GC.enemies[id].aiType;
			speed = GC.enemies[id].speed;
			level = GC.enemies[id].level;
			aiRepeat = GC.enemies[id].ai_repeat;
			value = GC.enemies[id].value;
			this.muted = muted;
			// set possition
			super(pos[0], pos[1]);
			// Set the hitbox
			setHitbox(GC.enemies[id].hitbox[0], GC.enemies[id].hitbox[1], GC.enemies[id].hitbox[0]/2, GC.enemies[id].hitbox[1]/2);
			aiCounter = 0;
			// Set the initial velocity
			queryAI();
			// Sprites are added
			setSprite();
			Angle = 0;
		}

		public function setSprite():void {
			image = GC.getClippedImg(GC.enemies[id].graphic_box);
			//image.smooth = true;
			image.centerOrigin();
			addGraphic(image);
			imgAngle += GC.enemies[id].graphic_box[4];
			angle = 0;
		}
		
		override public function update():void {
			super.update();

			runAI();
			updateSim();
			checkCollisions(); // this may be a misnomer updateSim also does a fair bit of collision checking.
		}

		public function queryAI():void {
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
				var collisionData : Array = Level.CalculateCollideTimes([0,0], remainingVel, [left,right,top,bottom]);
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
							bounceX(GC.playerBounce[0]);
							break;
						case 1:
							// We have hit the right wall
							// bounce, remove the current movement and repeat
							remainingVel[0] *= GC.playerBounce[1] * (1 - collisionData[0]);
							remainingVel[1] *= (1 - collisionData[0]);
							// Set the velocity for the next frame
							bounceX(GC.playerBounce[1]);
							break;
						case 2:
							// We have hit the bottom wall
							// bounce, remove the current movement and repeat
							remainingVel[0] *= (1 - collisionData[0]);
							remainingVel[1] *= GC.playerBounce[2] * (1 - collisionData[0]);
							// Set the velocity for the next frame
							bounceY(GC.playerBounce[2]);
							break;
						case 3:
							// We have hit the bottom wall
							// bounce, remove the current movement and repeat
							remainingVel[0] *= (1 - collisionData[0]);
							remainingVel[1] *= GC.playerBounce[3] * (1 - collisionData[0]);
							// Set the velocity for the next frame
							bounceY(GC.playerBounce[3]);
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
			// TODO: don't rely on, something quite so terrible
			if (left < 0) {
				x = originX;
				bounceX(-1);
			} else if (right > GC.windowWidth) {
				x = GC.windowWidth + originX - width;
				bounceX(-1);
			}
			if (top < 0) {
				y = originY;
				bounceY(-1);
			} else if (bottom > GC.windowHeight) {
				y = GC.windowHeight + originY - height;
				bounceY(-1);
			}
		}

		/*!
		 * \brief We may want to overload this for complicated AIs
		 *
		 * \param bounce:Number The bounce factor.
		 */
		public function bounceX(bounce:Number):void {
			vel[0] *= bounce;
		}

		/*!
		 * \brief We may want to overload this for complicated AIs
		 *
		 * \param bounce:Number The bounce factor.
		 */
		public function bounceY(bounce:Number):void {
			vel[1] *= bounce;
		}

		public function checkCollisions():void {
			var b :Ball = collide("ball", x, y) as Ball;
			if (b) {
				hitByBall(b);
			}
		}

		public function hitByBall(b:Ball):void {
			// Increase score or relevant player
			// b.playerShot;
			removeThis(b);
			b.hitEnemy(level);
		}

		public function removeThis(b:Ball):void {
			// Don't do this the other way around otherwise the score won't be added
			if (b) killedBy = b.playerShot;
			if (world) world.remove(this); // I like these belts and braces
		}

		public function set Angle(a:Number):void {
			angle = a;

			if (image) image.frameAngle = (imgAngle + angle) * 180 / Math.PI;
		}
		
		public function get Angle():Number {
			return angle;
		}

		public static function createEnemy(ident:int, pos:Array, muted:Boolean):Enemy {
			switch (GC.enemies[ident].aiType) {
				case "bouncer":
					return new Bouncer(ident, pos, muted);
				case "tail_head":
					return new TailHead(ident, pos, muted);
				default:
					return null;
			}
		}
	}
}

// vim: foldmethod=indent:cindent
