package com.nathanharper{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.events.*;
	
	public class Laser extends MovieClip{
		public var stageArray:Array;
		private var speed:Number;
		private var myOwner:StageItem;
		private var deltaX:Number;
		private var deltaY:Number;
		
		public function Laser(lvl:EmptyLevel,dir:int,s:Number,p:Point,mo:StageItem){
			alpha = .5;
			myOwner=mo;
			this.x=p.x;
			this.y=p.y;
			lvl.addChild(this);
			stageArray=(this.parent.parent as SRP).getMyArray();
			this.rotation=dir;
			speed=s;
			addEventListener(Event.ENTER_FRAME, moveLaser);
			
			var absRotationX:Number = rotation;
			if (absRotationX < 0) absRotationX += 360;
			var absRotationY:Number = 90 - absRotationX;
			absRotationX *= (Math.PI / 180);
			absRotationY *= (Math.PI / 180);
			
			deltaX = 10 * (Math.sin(absRotationX));
			deltaY = -10 * (Math.sin(absRotationY));
		}
		public function moveLaser(e:Event):Boolean{
			var mother:SRP=parent.parent as SRP;
			stageArray=mother.getMyArray();
			
			this.x += deltaX;
			this.y += deltaY;
			
			//remove Laser if it is off stage
			if(this.x<0||this.x>mother.getMyWidth()*mother.getBlockWidth()||this.y<0||this.y>mother.getMyHeight()*mother.getBlockWidth()){
				killLaser();
			}
			else{
				//remove laser if it hits a wall, lava, forcefield, or ffchunk
				var p:Point=new Point(Math.floor(this.x/mother.getBlockWidth()),mother.getMyHeight()-Math.ceil(this.y/mother.getBlockWidth()));
				if(stageArray[p.y][p.x] is Wall ||stageArray[p.y][p.x] is ForceField) killLaser();
				else{
					var ffArray:Array=mother.getForceFieldArray();
					for(var i:int=0;i<ffArray.length;i++){
						if(ffArray[i].getState()){
							var cArray:Array=ffArray[i].getChunkArray();
							for(var j:int=0;j<cArray.length;j++){
								if (this.hitTestObject(cArray[j])) {
									killLaser();
									return false;
								}
							}
						}
					}
				}
			}
			return true;
		}
		
		public function killLaser(){
			removeEventListener(Event.ENTER_FRAME,moveLaser);
			parent.removeChild(this);
		}
		public function getOwner(){
			return myOwner;
		}
		public function pauseMotion() {
			removeEventListener(Event.ENTER_FRAME, moveLaser);
		}
		public function resumeMotion() {
			addEventListener(Event.ENTER_FRAME, moveLaser);
		}
	}
}