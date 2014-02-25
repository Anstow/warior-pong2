package
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Text;
	
	public class ScoreBox extends Entity
	{
		public var textBox:Text;
		public var id : int;
		public var score : int;

		public function ScoreBox(pos:Array, score:int, id:int = -1) {
			this.id = id;
			textBox = new Text("");
			Score = score;
			super(pos[0], pos[1], textBox);
		}

		public function set Score(s:int):void {
			score = s;
			if (id == -1)
				textBox.text = "Combined Score: " + s;
			else 
				textBox.text = "Player " + (id + 1) + ": " + s;
		}

		public function get Score():int {
			return score;
		}
	}
}

// vim: foldmethod=indent:cindent
