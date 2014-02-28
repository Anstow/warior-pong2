package powerups
{
	import net.flashpunk.Entity;
	
	public class ExtraBall extends PowerUp
	{
		public function ExtraBall(id:int, pos:Array, vel:Array, muted:Boolean) {
			super(id, pos, vel, muted);
		}
		
		override public function hitPlayer(p:Player):void {
			p.NoBallsFired++;
			super.hitPlayer(p);
		}
	}
}

// vim: foldmethod=indent:cindent
