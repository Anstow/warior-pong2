package
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.Sfx;
	import flash.utils.getQualifiedClassName;
	
	public class Player extends Entity
	{
		public var vel : Vector.<Number> = Vector.<Number>(2, true); 

		public function Player(ident:int, pos:Array, inp:GameInput, muted:Boolean) {
			vel[0] = 0;
			vel[1] = 0;
		}
		
		override public function update():void {
			super.update();

			//Horizontal
			if (input.check("left"+ident)) {
				vel[0] -= GC.moveSpeed;
			}
			if (input.check("right"+ident)) {
				vel[0] += GC.moveSpeed;
			}
		}

		public function blink():void {
			if (blinked)
			{
				eyes.setAnimFrame("anim", 0);
				FP.alarm(Math.pow(Math.random() * 12.1,3), blink);
			}
			else
			{
				winked = false;

				eyes.setAnimFrame("anim", 1);
				FP.alarm(10,blink);
			}

			blinked = !blinked;
		}

		public function wink():void {
			if (winked)
			{
				eyes.setAnimFrame("anim",0);
			}
			else
			{
				blinked = false;

				eyes.setAnimFrame("anim", FP.rand(2));
				FP.alarm(0.5,blink);
			}

			winked = !winked;
		}
	}
}

// vim: foldmethod=indent:cindent
