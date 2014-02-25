package enemies
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	
	public class TailHead extends Enemy
	{
		public var turn_angle_cap : Number;
		public var turnAngle : Number;

		public var turnFreq: int;
		public var turnFreqCounter : int;

		public var tailPieces: Vector.<TailPiece>;
		public var tailPiecePath:Vector.<Array>;
		public var tailLength: int;
		
		public var tailSeparation : int;

		public function TailHead(ident:int, pos:Array, muted:Boolean) {
			super(ident, pos, muted);
			turn_angle_cap = GC.enemies[ident].turn_angle_cap;
			turnFreq = GC.enemies[ident].turn_frequency;
			turnFreqCounter = turnFreq;

			tailLength = GC.enemies[ident].tailLength;
			tailPieces = new Vector.<TailPiece>();
			tailPiecePath = new Vector.<Array>();
			tailSeparation = GC.enemies[ident].tailSeparation;

			// Add the tail positions
			for (var i : int = 0; i < tailLength * tailSeparation; i++) {
				tailPiecePath.push([x,y,Angle]);
			}
			
			// Add the tail elements
			for (i = 0; i < tailLength; i++) {
				tailPieces.push(new TailPiece(GC.enemies[ident].tailPiece, tailPiecePath[(i+1)*tailSeparation - 1], muted));
			}
			Angle = Math.PI/2;
		}

		override public function added():void {
			super.added();
			// Add the tail pieces
			for (var i:int = 0; i < tailPieces.length; i++) {
				if (tailPieces[i]) world.add(tailPieces[i]);
			}
		}

		override public function removed():void {
			super.removed();
			// remove the tail pieces
			for (var i:int = 0; i < tailPieces.length; i++) {
				if (tailPieces[i]) world.remove(tailPieces[i]);
				tailPieces[i] = null;
			}
		}
		
		override public function updateSim():void {
			super.updateSim();

			// remove the last coordinate
			tailPiecePath.pop();

			// And a new point to the beginning of the queue
			tailPiecePath.reverse();
			tailPiecePath.push([x,y,Angle]);
			tailPiecePath.reverse();

			// Set tail positions
			for (var i:int = 0; i < tailPieces.length; i++) {
				tailPieces[i].Pos= tailPiecePath[(i+1)*tailSeparation - 1];
			}
		}

		override public function queryAI():void {
			if (turnFreqCounter == turnFreq) {
				turnFreqCounter=0;

				// create an angle to change at
				turnAngle = FP.random * 2 * turn_angle_cap - turn_angle_cap;
			}

			Angle += turnAngle;

			vel[0] = Math.sin(Angle) * speed;
			vel[1] = -Math.cos(Angle) * speed;
			
			turnFreqCounter++;
		}
		
		override public function bounceX(bounce:Number):void {
			super.bounceX(bounce);
			Angle = -Angle
		}

		override public function bounceY(bounce:Number):void {
			super.bounceY(bounce);
			Angle = Math.PI-Angle
		}
	}
}

// vim: foldmethod=indent:cindent
