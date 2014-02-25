package
{
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;

	public class AimEntity extends Entity
	{
		public var targets : Vector.<Graphic>;
		private var selectorImage : MyPreRotation;

		public function AimEntity(pos:Array, ident:int) {
			super();
			setPos(pos);

			selectorImage = GC.getClippedImg(GC.selectorGraphicsBoxes[ident]);
			selectorImage.centerOrigin();
			addGraphic(selectorImage);

			targets = new Vector.<Graphic>();
			for (var i : int = 0; i < GC.targettingNo; i++) {
				var image : MyPreRotation = GC.getClippedImg(GC.targetingGraphicsBoxes[i], 1); 
				image.alpha = 1/Math.pow(3,i);
				targets.push(image);
				addGraphic(targets[i]);
			}
			setAngle(0);
			targets[0].x = - GC.targettingSizes[0];
			targets[0].y = - GC.targettingSizes[0];
		}

		public override function update():void {
			// Rotate the selector image
			selectorImage.frameAngle += GC.selectorRotateSpeed;
		}

		public function setPos(pos:Array):void {
			x = pos[0] + GC.playerWidth/2 - GC.targettingCenter[0];
			y = pos[1] - GC.targettingCenter[1];
		}

		public function getPos():Array {
			return [x,y];
		}

		public function setAngle(angle:Number):void {
			for (var i:int = 1; i < GC.targettingNo; i++) {
				targets[i].x = -Math.sin(angle)*GC.targettingOffsets[i-1] - GC.targettingSizes[i];
				targets[i].y = -Math.cos(angle)*GC.targettingOffsets[i-1] - GC.targettingSizes[i];
			}
		}
	}
}

// vim: foldmethod=indent:cindent
