package
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Text;
	
	public class ScoreBox extends Entity
	{
		public var textBox:Text;
		public var id : int;

		public function ScoreBox(pos:Array, score:int, id:int) {
			this.id = id;
			textBox = new Text("Player " + (id + 1) + ": " + score);
			super(pos[0], pos[1], textBox);
		}

		public function set Score(s:int):void {
			textBox.text = "Player " + (id + 1) + ": " + s;
		}
	}
}

// vim: foldmethod=indent:cindent
