// A stage object.
// All items in the level are subclasses of this.
package com.nathanharper{
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class StageItem extends MovieClip{
		private var startPos:Point;
		
		public function StageItem(){}
		
		//set the starting grid position of this stage item
		public function setStartPos(point:Point){
			startPos=point;
		}
		
		public function getStartPos(){
			return startPos;
		}
		
		//check StageItem equality
		public function equals(stageItem:StageItem):Boolean {
			return this.getStartPos().equals(stageItem.getStartPos());
		}
	}
}