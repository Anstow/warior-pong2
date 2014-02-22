package
{
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	import net.flashpunk.World;

	[SWF(width = '960', height = '540')]
	public class Main extends Engine
	{
		public function Main():void
		{
			super(GC.windowWidth, GC.windowHeight, GC.FPS, true);
			FP.console.enable();
			//FP.world = new TitleScreen();
			FP.world = new Level(changeWorld);
		}
		
		public function changeWorld(world : World) : void {
			trace(world);
			FP.world = world;
		}
	}
}

// vim: foldmethod=indent:cindent
