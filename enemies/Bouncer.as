package enemies
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	
	public class Bouncer extends Enemy
	{
		public function Bouncer(ident:int, pos:Array, muted:Boolean) {
			super(ident, pos, muted);
		}
		
		override public function queryAI():void {
			var a : Number = FP.random * 2 * Math.PI;
			vel[0] = Math.cos(a) * speed;
			vel[1] = Math.sin(a) * speed;
		}
	}
}

// vim: foldmethod=indent:cindent
