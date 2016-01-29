package egret.utils.maxRects
{
	/**
	 * 二维装箱算法 
	 * featherJ 改
	 */
	public class MaxRectsCore
	{      
		public var binWidth:int = 0;
		public var binHeight:int = 0;
		public var allowRotations:Boolean = false;
		
		public var usedRectangles:Vector.<IMaxRectangle> = new Vector.<IMaxRectangle>();
		public var freeRectangles:Vector.<IMaxRectangle> = new Vector.<IMaxRectangle>();
		/**
		 *工厂类实例 用来实例化内部新对象 
		 */		
		public var factory:IMaxRectangle=new MaxRectangle();
		
		private var score1:int = 0; // Unused in this function. We don't need to know the score after finding the position.
		private var score2:int = 0;
		private var bestShortSideFit:int;
		private var bestLongSideFit:int;
		
		public function MaxRectsCore() 
		{
			
		}
		
		/**
		 * 是否可以旋转 
		 * @param rotations
		 * 
		 */		
		public function setCanRotate(rotations:Boolean):void
		{
			allowRotations = rotations;
		}
		
		/**
		 *初始化一个用来填充的矩形区域 
		 * @param width 宽度
		 * @param height 高度
		 * @param rotations 是否允许旋转
		 * 
		 */
		public function init(width:int, height:int):void
		{
			if( count(width) % 1 != 0 ||count(height) % 1 != 0)
				throw new Error("Must be 2,4,8,16,32,...512,1024,...");
			binWidth = width;
			binHeight = height;
			
			
			var n:IMaxRectangle = factory.newOne();
			n.x = 0;
			n.y = 0;
			n.width = width;
			n.height = height;
			
			usedRectangles.length = 0;
			freeRectangles.length = 0;
			freeRectangles.push( n );
		}
		
		private function count(n:Number):Number
		{
			if( n >= 2 )
				return count(n / 2);
			return n;
		}
		
		/**
		 * 插入一个矩形，并布局该矩形
		 * @param width 宽度
		 * @param height 高度
		 * @param data 附加参数
		 * @param method 布局方式
		 * @return 布局完毕的矩形对象
		 * 
		 */    
		public function insert(width:int, height:int,data:Object,method:int):IMaxRectangle
		{
			var newNode:IMaxRectangle  = factory.newOne();
			score1 = 0;
			score2 = 0;
			switch(method)
			{
				case FreeRectangleChoiceHeuristic.BestShortSideFit: 
					newNode = findPositionForNewNodeBestShortSideFit(width, height,data); 
					break;
				case FreeRectangleChoiceHeuristic.BottomLeftRule: 
					newNode = findPositionForNewNodeBottomLeft(width, height, score1, score2,data); 
					break;
				case FreeRectangleChoiceHeuristic.ContactPointRule: 
					newNode = findPositionForNewNodeContactPoint(width, height, score1,data); 
					break;
				case FreeRectangleChoiceHeuristic.BestLongSideFit: 
					newNode = findPositionForNewNodeBestLongSideFit(width, height, score2, score1,data); 
					break;
				case FreeRectangleChoiceHeuristic.BestAreaFit: 
					newNode = findPositionForNewNodeBestAreaFit(width, height, score1, score2,data); 
					break;
			}
			
			if (newNode.height == 0)
				return newNode;
			
			placeRectangle(newNode);
			return newNode;
		}
		/**
		 * 插入一个矩形，并布局该矩形
		 * @param width 宽度
		 * @param height 高度
		 * @param method 布局方式
		 * @return 布局完毕的矩形对象
		 * 
		 */ 
		public function insertGroup( rectangles:Vector.<IMaxRectangle>, method:int):void
		{	
			while(rectangles.length > 0)
			{
				var bestScore1:int = int.MAX_VALUE;
				var bestScore2:int = int.MAX_VALUE;
				var bestRectangleIndex:int = -1;
				var bestNode:IMaxRectangle;
				
				for(var i:int = 0; i < rectangles.length; ++i)
				{
					var score1:int = 0;
					var score2:int = 0;
					var newNode:IMaxRectangle = scoreRectangle(rectangles[i].width, rectangles[i].height, method, score1, score2,rectangles[i].data);
					
					if (score1 < bestScore1 || (score1 == bestScore1 && score2 < bestScore2))
					{
						bestScore1 = score1;
						bestScore2 = score2;
						bestNode = newNode;
						bestRectangleIndex = i;
					}
				}
				
				if (bestRectangleIndex == -1)
					return;
				
				placeRectangle(bestNode);
				rectangles.splice(bestRectangleIndex,1);
			}
		}
		
		private function placeRectangle(node:IMaxRectangle):void
		{
			var numRectanglesToProcess:int = freeRectangles.length;
			for(var i:int = 0; i < numRectanglesToProcess; i++)
			{
				if (splitFreeNode(freeRectangles[i], node))
				{
					freeRectangles.splice(i,1);
					--i;
					--numRectanglesToProcess;
				}
			}
			pruneFreeList();
			usedRectangles.push(node);
		}
		
		private function scoreRectangle( width:int,  height:int,  method:int, 
										 score1:int, score2:int,data:Object):IMaxRectangle
		{
			var newNode:IMaxRectangle = factory.newOne();
			score1 = int.MAX_VALUE;
			score2 = int.MAX_VALUE;
			switch(method)
			{
				case FreeRectangleChoiceHeuristic.BestShortSideFit: 
					newNode = findPositionForNewNodeBestShortSideFit(width, height,data); 
					break;
				case FreeRectangleChoiceHeuristic.BottomLeftRule: 
					newNode = findPositionForNewNodeBottomLeft(width, height, score1,score2,data); 
					break;
				case FreeRectangleChoiceHeuristic.ContactPointRule: 
					newNode = findPositionForNewNodeContactPoint(width, height, score1,data); 
					// todo: reverse
					score1 = -score1; // Reverse since we are minimizing, but for contact point score bigger is better.
					break;
				case FreeRectangleChoiceHeuristic.BestLongSideFit: 
					newNode = findPositionForNewNodeBestLongSideFit(width, height, score2, score1,data); 
					break;
				case FreeRectangleChoiceHeuristic.BestAreaFit: 
					newNode = findPositionForNewNodeBestAreaFit(width, height, score1, score2,data); 
					break;
			}
			
			// Cannot fit the current Rectangle.
			if (newNode.height == 0)
			{
				score1 = int.MAX_VALUE;
				score2 = int.MAX_VALUE;
			}
			
			return newNode;
		}
		
		/// Computes the ratio of used surface area.
		private function occupancy():Number
		{
			var usedSurfaceArea:Number = 0;
			for(var i:int = 0; i < usedRectangles.length; i++)
				usedSurfaceArea += usedRectangles[i].width * usedRectangles[i].height;
			
			return usedSurfaceArea / (binWidth * binHeight);
		}
		
		private function findPositionForNewNodeBottomLeft(width:int, height:int, 
														  bestY:int, bestX:int,data:Object):IMaxRectangle
		{
			var bestNode:IMaxRectangle = factory.newOne();
			//memset(bestNode, 0, sizeof(Rectangle));
			bestY = int.MAX_VALUE;
			var rect:IMaxRectangle;
			var topSideY:int;
			for(var i:int = 0; i < freeRectangles.length; i++)
			{
				rect = freeRectangles[i];
				// Try to place the Rectangle in upright (non-flipped) orientation.
				if (rect.width >= width && rect.height >= height)
				{
					topSideY = rect.y + height;
					if (topSideY < bestY || (topSideY == bestY && rect.x < bestX))
					{
						bestNode.x = rect.x;
						bestNode.y = rect.y;
						bestNode.width = width;
						bestNode.height = height;
						bestNode.data = data;
						bestY = topSideY;
						bestX = rect.x;
						bestNode.isRotated = false;
					}
				}else
				if (allowRotations && rect.width >= height && rect.height >= width)
				{
					topSideY = rect.y + width;
					if (topSideY < bestY || (topSideY == bestY && rect.x < bestX))
					{
						bestNode.x = rect.x;
						bestNode.y = rect.y;
						bestNode.width = height;
						bestNode.height = width;
						bestNode.data = data;
						bestY = topSideY;
						bestX = rect.x;
						bestNode.isRotated = true;
					}
				}
			}
			return bestNode;
		}
		
		private function findPositionForNewNodeBestShortSideFit(width:int, height:int,data:Object):IMaxRectangle
		{
			var bestNode:IMaxRectangle = factory.newOne();
			//memset(&bestNode, 0, sizeof(Rectangle));
			bestShortSideFit = int.MAX_VALUE;
			bestLongSideFit = score2;
			var rect:IMaxRectangle;
			var leftoverHoriz:int;
			var leftoverVert:int;
			var shortSideFit:int;
			var longSideFit:int;
			
			for(var i:int = 0; i < freeRectangles.length; i++)
			{
				rect = freeRectangles[i];
				// Try to place the Rectangle in upright (non-flipped) orientation.
				if (rect.width >= width && rect.height >= height)
				{
					leftoverHoriz = Math.abs(rect.width - width);
					leftoverVert = Math.abs(rect.height - height);
					shortSideFit = Math.min(leftoverHoriz, leftoverVert);
					longSideFit = Math.max(leftoverHoriz, leftoverVert);
					
					if (shortSideFit < bestShortSideFit || (shortSideFit == bestShortSideFit && longSideFit < bestLongSideFit))
					{
						bestNode.x = rect.x;
						bestNode.y = rect.y;
						bestNode.width = width;
						bestNode.height = height;
						bestNode.data = data;
						bestNode.isRotated = false;
						bestShortSideFit = shortSideFit;
						bestLongSideFit = longSideFit;
					}
				}
				var flippedLeftoverHoriz:Number;
				var flippedLeftoverVert:Number;
				var flippedShortSideFit:Number;
				var flippedLongSideFit:Number;
				if (allowRotations && rect.width >= height && rect.height >= width)
				{
					flippedLeftoverHoriz = Math.abs(rect.width - height);
					flippedLeftoverVert = Math.abs(rect.height - width);
					flippedShortSideFit = Math.min(flippedLeftoverHoriz, flippedLeftoverVert);
					flippedLongSideFit = Math.max(flippedLeftoverHoriz, flippedLeftoverVert);
					
					if (flippedShortSideFit < bestShortSideFit || (flippedShortSideFit == bestShortSideFit && flippedLongSideFit < bestLongSideFit))
					{
						bestNode.x = rect.x;
						bestNode.y = rect.y;
						bestNode.width = height;
						bestNode.height = width;
						bestNode.data = data;
						bestNode.isRotated = true;
						bestShortSideFit = flippedShortSideFit;
						bestLongSideFit = flippedLongSideFit;
					}
				}
			}
			return bestNode;
		}
		
		private function findPositionForNewNodeBestLongSideFit(width:int, height:int, bestShortSideFit:int, bestLongSideFit:int,data:Object):IMaxRectangle
		{
			var bestNode:IMaxRectangle = factory.newOne();
			//memset(&bestNode, 0, sizeof(Rectangle));
			bestLongSideFit = int.MAX_VALUE;
			var rect:IMaxRectangle;
			var leftoverHoriz:int;
			var leftoverVert:int;
			var shortSideFit:int;
			var longSideFit:int;
			for(var i:int = 0; i < freeRectangles.length; i++) {
				rect = freeRectangles[i];
				// Try to place the Rectangle in upright (non-flipped) orientation.
				if (rect.width >= width && rect.height >= height) {
					leftoverHoriz = Math.abs(rect.width - width);
					leftoverVert = Math.abs(rect.height - height);
					shortSideFit = Math.min(leftoverHoriz, leftoverVert);
					longSideFit = Math.max(leftoverHoriz, leftoverVert);
					
					if (longSideFit < bestLongSideFit || (longSideFit == bestLongSideFit && shortSideFit < bestShortSideFit)) {
						bestNode.x = rect.x;
						bestNode.y = rect.y;
						bestNode.width = width;
						bestNode.height = height;
						bestNode.data = data;
						bestNode.isRotated = false;
						bestShortSideFit = shortSideFit;
						bestLongSideFit = longSideFit;
					}
				}
				
				if (allowRotations && rect.width >= height && rect.height >= width) {
					leftoverHoriz = Math.abs(rect.width - height);
					leftoverVert = Math.abs(rect.height - width);
					shortSideFit = Math.min(leftoverHoriz, leftoverVert);
					longSideFit = Math.max(leftoverHoriz, leftoverVert);
					
					if (longSideFit < bestLongSideFit || (longSideFit == bestLongSideFit && shortSideFit < bestShortSideFit)) {
						bestNode.x = rect.x;
						bestNode.y = rect.y;
						bestNode.width = height;
						bestNode.height = width;
						bestNode.data = data;
						bestNode.isRotated = true;
						bestShortSideFit = shortSideFit;
						bestLongSideFit = longSideFit;
					}
				}
			}
			return bestNode;
		}
		
		private function findPositionForNewNodeBestAreaFit(width:int, height:int, bestAreaFit:int, bestShortSideFit:int,data:Object):IMaxRectangle
		{
			var bestNode:IMaxRectangle = factory.newOne();
			//memset(&bestNode, 0, sizeof(Rectangle));
			
			bestAreaFit = int.MAX_VALUE;
			
			var rect:IMaxRectangle;
			var leftoverHoriz:int;
			var leftoverVert:int;
			var shortSideFit:int;
			var areaFit:int;
			
			for(var i:int = 0; i < freeRectangles.length; i++) 
			{
				rect = freeRectangles[i];
				areaFit = rect.width * rect.height - width * height;
				
				// Try to place the Rectangle in upright (non-flipped) orientation.
				if (rect.width >= width && rect.height >= height) 
				{
					leftoverHoriz = Math.abs(rect.width - width);
					leftoverVert = Math.abs(rect.height - height);
					shortSideFit = Math.min(leftoverHoriz, leftoverVert);
					
					if (areaFit < bestAreaFit || (areaFit == bestAreaFit && shortSideFit < bestShortSideFit))
					{
						bestNode.x = rect.x;
						bestNode.y = rect.y;
						bestNode.width = width;
						bestNode.height = height;
						bestNode.data = data;
						bestNode.isRotated = false;
						bestShortSideFit = shortSideFit;
						bestAreaFit = areaFit;
					}
				}
				
				if (allowRotations && rect.width >= height && rect.height >= width) 
				{
					leftoverHoriz = Math.abs(rect.width - height);
					leftoverVert = Math.abs(rect.height - width);
					shortSideFit = Math.min(leftoverHoriz, leftoverVert);
					
					if (areaFit < bestAreaFit || (areaFit == bestAreaFit && shortSideFit < bestShortSideFit))
					{
						bestNode.x = rect.x;
						bestNode.y = rect.y;
						bestNode.width = height;
						bestNode.height = width;
						bestNode.data = data;
						bestNode.isRotated = true;
						bestShortSideFit = shortSideFit;
						bestAreaFit = areaFit;
					}
				}
			}
			return bestNode;
		}
		
		/// Returns 0 if the two intervals i1 and i2 are disjoint, or the length of their overlap otherwise.
		private function commonIntervalLength(i1start:int, i1end:int, i2start:int, i2end:int):int 
		{
			if (i1end < i2start || i2end < i1start)
				return 0;
			return Math.min(i1end, i2end) - Math.max(i1start, i2start);
		}
		
		private function contactPointScoreNode(x:int, y:int, width:int, height:int):int
		{
			var score:int = 0;
			
			if (x == 0 || x + width == binWidth)
				score += height;
			if (y == 0 || y + height == binHeight)
				score += width;
			var rect:IMaxRectangle;
			for(var i:int = 0; i < usedRectangles.length; i++) 
			{
				rect = usedRectangles[i];
				if (rect.x == x + width || rect.x + rect.width == x)
					score += commonIntervalLength(rect.y, rect.y + rect.height, y, y + height);
				if (rect.y == y + height || rect.y + rect.height == y)
					score += commonIntervalLength(rect.x, rect.x + rect.width, x, x + width);
			}
			return score;
		}
		
		private function findPositionForNewNodeContactPoint(width:int, height:int, bestContactScore:int,data:Object):IMaxRectangle 
		{
			var bestNode:IMaxRectangle = factory.newOne();
			//memset(&bestNode, 0, sizeof(Rectangle));
			
			bestContactScore = -1;
			var rect:IMaxRectangle;
			var score:int;
			for(var i:int = 0; i < freeRectangles.length; i++) 
			{
				rect = freeRectangles[i];
				// Try to place the Rectangle in upright (non-flipped) orientation.
				if (rect.width >= width && rect.height >= height) 
				{
					score = contactPointScoreNode(rect.x, rect.y, width, height);
					if (score > bestContactScore) {
						bestNode.x = rect.x;
						bestNode.y = rect.y;
						bestNode.width = width;
						bestNode.height = height;
						bestNode.data = data;
						bestNode.isRotated = false;
						bestContactScore = score;
					}
				}
				if (allowRotations && rect.width >= height && rect.height >= width) 
				{
					score = contactPointScoreNode(rect.x, rect.y, height, width);
					if (score > bestContactScore) 
					{
						bestNode.x = rect.x;
						bestNode.y = rect.y;
						bestNode.width = height;
						bestNode.height = width;
						bestNode.data = data;
						bestNode.isRotated = true;
						bestContactScore = score;
					}
				}
			}
			return bestNode;
		}
		
		private function splitFreeNode(freeNode:IMaxRectangle, usedNode:IMaxRectangle):Boolean 
		{
			// Test with SAT if the Rectangles even intersect.
			if (usedNode.x >= freeNode.x + freeNode.width || usedNode.x + usedNode.width <= freeNode.x ||
				usedNode.y >= freeNode.y + freeNode.height || usedNode.y + usedNode.height <= freeNode.y)
				return false;
			var newNode:IMaxRectangle;
			if (usedNode.x < freeNode.x + freeNode.width && usedNode.x + usedNode.width > freeNode.x)
			{
				// New node at the top side of the used node.
				if (usedNode.y > freeNode.y && usedNode.y < freeNode.y + freeNode.height)
				{
					newNode = freeNode.cloneOne() as IMaxRectangle;
					newNode.height = usedNode.y - newNode.y;
					freeRectangles.push(newNode);
				}
				
				// New node at the bottom side of the used node.
				if (usedNode.y + usedNode.height < freeNode.y + freeNode.height)
				{
					newNode = freeNode.cloneOne() as IMaxRectangle;
					newNode.y = usedNode.y + usedNode.height;
					newNode.height = freeNode.y + freeNode.height - (usedNode.y + usedNode.height);
					freeRectangles.push(newNode);
				}
			}
			
			if (usedNode.y < freeNode.y + freeNode.height && usedNode.y + usedNode.height > freeNode.y) 
			{
				// New node at the left side of the used node.
				if (usedNode.x > freeNode.x && usedNode.x < freeNode.x + freeNode.width)
				{
					newNode = freeNode.cloneOne() as IMaxRectangle;
					newNode.width = usedNode.x - newNode.x;
					freeRectangles.push(newNode);
				}
				
				// New node at the right side of the used node.
				if (usedNode.x + usedNode.width < freeNode.x + freeNode.width)
				{
					newNode = freeNode.cloneOne() as IMaxRectangle;
					newNode.x = usedNode.x + usedNode.width;
					newNode.width = freeNode.x + freeNode.width - (usedNode.x + usedNode.width);
					freeRectangles.push(newNode);
				}
			}
			
			return true;
		}
		
		private function pruneFreeList():void 
		{
			for(var i:int = 0; i < freeRectangles.length; i++)
				for(var j:int = i+1; j < freeRectangles.length; j++) 
				{
					if (isContainedIn(freeRectangles[i], freeRectangles[j]))
					{
						freeRectangles.splice(i,1);
						break;
					}
					if (isContainedIn(freeRectangles[j], freeRectangles[i])) 
					{
						freeRectangles.splice(j,1);
					}
				}
		}
		
		private function isContainedIn(a:IMaxRectangle, b:IMaxRectangle):Boolean 
		{
			return a.x >= b.x && a.y >= b.y 
				&& a.x+a.width <= b.x+b.width 
				&& a.y+a.height <= b.y+b.height;
		}
	}
	
}