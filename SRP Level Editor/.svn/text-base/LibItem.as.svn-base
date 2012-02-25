//an item in the level editor window
package{
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.geom.Point;
	
	public class LibItem extends MovieClip{
		
		private var myType:String;
		private var myDirection:String="U";
		private var myPoint:Point=null;
		private var partner:Point=null;
		
		public function LibItem(type:String){
			myType=type;
			gotoAndStop(myType);
			selector.visible=false;
		}
		
		//set the direction of the LibItem
		public function rotate(){
			if(myDirection=="U"){
				myDirection="R";
			}
			else if(myDirection=="R"){
				myDirection="D";
			}
			else if(myDirection=="D"){
				myDirection="L"
			}else{
				myDirection="U";
			}
			
			rotation+=90;
			if(rotation>270) rotation-=360;
		}
		
		//get the direction of the LibItem
		public function getDirection(){
			return myDirection;
		}
		
		//set the current slot of the LibItem
		public function setSlot(point:Point){
			myPoint=point;
		}
		
		//get the current slot of the LibItem
		public function getSlot(){
			return myPoint;
		}
		
		//get the partner coordinates of the LibItem
		public function getPartner(){
			return partner;
		}
		
		// set the partner coordinates
		public function setPartner(point:Point){
			partner=point;
		}
	}
}