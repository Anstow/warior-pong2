package
{
	import net.flashpunk.Entity;
	import net.flashpunk.utils.Draw;
	
	public class Grid extends Entity
	{
		public var poss : Vector.<Vector.<Vector.<Number>>>
		public var vels : Vector.<Vector.<Vector.<Number>>>;
		public var accels : Vector.<Vector.<Vector.<Number>>>;

		public var gridWidth : int = GC.gridWidth;
		public var gridHeight : int = GC.gridHeight;
		public var xPartition : Number;
		public var yPartition : Number;

		public function Grid() {
			poss = new Vector.<Vector.<Vector.<Number>>>(gridWidth + 1, true);
			vels = new Vector.<Vector.<Vector.<Number>>>(gridWidth + 1, true);
			accels = new Vector.<Vector.<Vector.<Number>>>(gridWidth + 1, true);

			for (var i : int = 0; i <= gridWidth; ++i) {
				poss[i] = new Vector.<Vector.<Number>>(gridHeight + 1, true);
				vels[i] = new Vector.<Vector.<Number>>(gridHeight + 1, true);
				accels[i] = new Vector.<Vector.<Number>>(gridHeight + 1, true);
				xPartition = (GC.windowWidth - 2 * GC.gridOffsetX) / gridWidth;
				yPartition = (GC.windowHeight - 2 * GC.gridOffsetY) / gridHeight;
				for (var j : int = 0; j <= gridHeight; ++j) {
					poss[i][j] = new <Number>[
					   	GC.gridOffsetX + i * xPartition,
					   	GC.gridOffsetY + j * yPartition ];
					vels[i][j] = new <Number>[0, 0];
					accels[i][j] = new <Number>[0, 0];
				}
			}
		}
		
		public function circularPush(origin:Vector.<Number>, radius:Number, force:Number):void {
		}
		
		public function updateGridPoints():void {
			for (var i : int = 0; i <= gridWidth; ++i) {
				for (var j : int = 0; j <= gridHeight; ++j) {
					// Update positions
					poss[i][j][0] += vels[i][j][0] + accels[i][j][0]/2;
					poss[i][j][1] += vels[i][j][1] + accels[i][j][1]/2;
					// TODO: May need extra code to prevent grid shuddering?

					// Update velocites
					poss[i][j][0] += accels[i][j][0];
					poss[i][j][1] += accels[i][j][1];
					
					// Calculate returning forces
					accels[i][j][0] = GC.gridRigidity * (GC.gridOffsetX + i * xPartition - poss[i][j][0]);
					accels[i][j][1] = GC.gridRigidity * (GC.gridOffsetY + j * yPartition - poss[i][j][1]);
				}
			}
		}

		public function drawGrid():void {
			for (var i : int = 0; i < gridWidth; ++i) {
				for (var j : int = 0; j < gridHeight; ++j) {
					// Horzontal lines
					Draw.line(poss[i][j][0],poss[i][j][1],poss[i + 1][j][0],poss[i + 1][j][1]);
					// Vertical lines
					Draw.line(poss[i][j][0],poss[i][j][1],poss[i][j + 1][0],poss[i][j + 1][1]);
				}
			}

			// Now draw the right edge
			for (j = 0; j < gridHeight; ++j) {
				Draw.line(poss[gridWidth][j][0],poss[gridWidth][j][1],poss[gridWidth][j + 1][0],poss[gridWidth][j + 1][1]);
			}

			// Now the bottom edge
			for (i = 0; i < gridWidth; ++i) {
				Draw.line(poss[i][gridHeight][0],poss[i][gridHeight][1],poss[i + 1][gridHeight][0],poss[i + 1][gridHeight][1]);
			}
		}
		
		override public function update():void {
			super.update();
			updateGridPoints();
		}

		override public function render():void {
			//super.render();
			drawGrid();
		}

		override public function added():void {
			super.added();
		}

		override public function removed():void {
			super.removed();
		}
	}
}

// vim: foldmethod=indent:cindent
