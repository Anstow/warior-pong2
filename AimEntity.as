package
{
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Image;

	public class AimEntity extends Entity
	{
		public var targets : Vector.<Graphic>;
		private var image : Image;

		public function AimEntity(pos:Array) {
			super();
			setPos(pos);
			targets = new Vector.<Graphic>();
			for (var i : int = 0; i < GC.targettingNo; i++) {
				image = new Image(GC.getClippedImg(GC.targetingGraphicsBoxes[i])); 
				image.alpha = 1/Math.pow(3,i);
				targets.push(image);
				addGraphic(targets[i]);
			}
			setAngle(0);
			targets[0].x = - GC.targettingSizes[0];
			targets[0].y = - GC.targettingSizes[0];
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
