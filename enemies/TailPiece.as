package enemies
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	
	public class TailPiece extends Enemy
	{
		public function TailPiece(ident:int, pos:Array, muted:Boolean) {
			super(ident, pos, muted);
		}
		
		override public function queryAI():void {
			// No ai here!
		}

		override public function updateSim():void {
			// We will do all this in tail head
		}

		public function set Pos(pos:Array):void {
			x = pos[0];
			y = pos[1];
			Angle = pos[2];
		}

		override public function hitByBall(b:Ball):void {
			b.hitEnemy(level);
		}
	}
}

// vim: foldmethod=indent:cindent
