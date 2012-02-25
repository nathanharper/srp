/*
a static object that emits a force field.
can be either on or off
holds a refernce to the stage position of its governing switch
*/
package com.nathanharper{
	import flash.geom.Point;
	public class ForceField extends Rotatable{
		//true==on, false==off
		private var defaultState:Boolean;
		private var currState:Boolean;
		private var mySwitch:Point;
		private var myColor:String;
		private var chunkArr:Array=new Array();
		
		public function ForceField(pos:Point,dir:int,onOff:Boolean,switchy:Point,clr:String){
			hitbox.alpha=0;
			hitbox2.alpha=0;
			setStartPos(pos);
			setStartDir(dir);
			defaultState=onOff;
			currState=onOff;
			mySwitch=switchy;
			myColor=clr;
			gotoAndStop(myColor);
			if(!currState) gotoAndStop(currentFrame+3);
		}
		public override function resetMe(){
			super.resetMe();
			currState=defaultState;
			//fix this!!!
		}
		public function getColor(){
			return myColor;
		}
		public function toggleMe(s:EmptyLevel,arr:Array){
			//trace("yes");
			currState=!currState;
			if(currState){
				gotoAndStop(currentFrame-3);
				this.turnOn(s,arr);
			}
			else{ 
				gotoAndStop(currentFrame+3);
				this.turnOff(s,arr);
			}
		}
		public function getState(){
			return currState;
		}
		public function getSwitch(){
			return mySwitch;
		}
		
		public function addChunk(ffc:FFchunk){
			chunkArr.push(ffc);
		}
		public function turnOn(p:EmptyLevel,arr:Array){
			for(var i:int=0;i<chunkArr.length;i++){
				p.addChild(chunkArr[i]);
				var cp:Point=chunkArr[i].getPoint();
				
				if(!(arr[cp.y][cp.x] is Number)) arr[cp.y][cp.x]=new Number(0);
				arr[cp.y][cp.x]+=1;
			}
		}
		public function turnOff(p:EmptyLevel,arr:Array){
			for(var i:int=0;i<chunkArr.length;i++){
				p.removeChild(chunkArr[i]);
				var cp:Point=chunkArr[i].getPoint();
				arr[cp.y][cp.x]-=1;
				if(arr[cp.y][cp.x]==0) {
					//trace(arr[cp.y][cp.x]);
					arr[cp.y][cp.x]=null;
					//trace(arr[cp.y][cp.x]);
				}
			}
		}
		public function getChunkArray(){return chunkArr;}
	}
}