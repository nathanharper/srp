//a mobile object that can be reprogrammed by the hero.
//If the robot circles another stage item by default, it will contain a reference
//to the stage position of that object.
package com.nathanharper{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	import flash.geom.*;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	//import flash.utils.*;
	
	public class Robot extends Rotatable{
		//0,1,2
		private var myType:int;
		private var currPos:Point;
		private var nextPos:Point;
		private var myPartner:Point;
		private var myTween:Tween;
		private var returnTween:Tween;
		private var myColorTween:Tween;
		private var myAlphaTween:Tween;
		private var myColor:ColorTransform = new ColorTransform();
		private var myState:String = "normal";
		private var destroyed:Boolean = false;
		private var mayFire:Boolean = true;
		private var myTime:Timer = new Timer(150, 1);
		private var myBMP:Bitmap=new Bitmap();
		private var savedAngle:Number; //position to return to when robot sees hero
		
		public function Robot(pos:Point,dir:int,t:int,partner:Point){
			myType=t;
			setStartPos(pos);
			currPos=pos;
			setStartDir(dir);
			rotation=dir;
			myPartner = partner;
			myBMP.bitmapData = new BitmapData(28, 28, true, 0x00000000);
			myBMP.bitmapData.draw(new RoboVector());
			myBMP.x = -14;
			myBMP.y = -14;
			addChild(myBMP);
			savedAngle = this.rotation;
		}
		public function getPartner(){
			return myPartner;
		}
		public function getType(){
			return myType;
		}
		public function setPos(p:Point){
			currPos=p;
		}
		public function getCurrPos(){
			return currPos;
		}
		public override function resetMe(){
			super.resetMe();
			setPos(getStartPos());
		}
		public function destroyBot(arr:Array, ra:Array, p:Point, sh:int, bw:int) {
			destroyed = true;
			myTween.stop();
			
			if(arr[currPos.y][currPos.x] is Robot) arr[currPos.y][currPos.x]=null;
			if(nextPos!=null && arr[nextPos.y][nextPos.x] is Robot) arr[nextPos.y][nextPos.x]=null;
			currPos=p;
			for(var i:int=0;i<ra.length;i++){
				if(ra[i]===this) ra.splice(i,1);
			}
			myColorTween=new Tween(myColor,"redOffset",None.easeNone,0,255,24);
			myAlphaTween = new Tween(myColor, "alphaOffset", None.easeNone, 0, -100, 24);
			//myAlphaTween=new Tween(this,"alpha",None.easeNone,1,.5,24);
			myColorTween.addEventListener(TweenEvent.MOTION_CHANGE,updateColor);
			myColorTween.addEventListener(TweenEvent.MOTION_FINISH,explodeBot);
			myAlphaTween.start();
			myColorTween.start();
		}
		public function explodeBot(e:TweenEvent){
			myColorTween.removeEventListener(TweenEvent.MOTION_FINISH,explodeBot);
			myColorTween.removeEventListener(TweenEvent.MOTION_CHANGE,updateColor);
			if(this.parent.parent is SRP){
				var myLevel:Object=this.parent;
				var mySRP:SRP=myLevel.parent as SRP;
				myLevel.removeChild(this);
				myBMP.bitmapData.dispose();
				for(var x2:int=-1;x2<2;x2++){
					for(var y2:int=-1;y2<2;y2++){
						makeSplode(myLevel,(currPos.x+x2)*mySRP.getBlockWidth(),(mySRP.getMyHeight()-1-currPos.y+y2)*mySRP.getBlockWidth());
					}
				}
			}
		}
		public static function makeSplode(lvl:Object,x:int,y:int){
			var s:Explosion = new Explosion();
			s.x=x;
			s.y=y;
			lvl.addChild(s);
		}
		public function updateColor(e:TweenEvent){
			this.transform.colorTransform=myColor;
		}
		
		public function moveRobot(arr:Array, ra:Array, sw:int, sh:int, bw:int):Boolean {
			
			//1st, destroy the robot if it has collided with a force field beam, explosion, or laser
			for(var u:int=0;u<this.parent.numChildren;u++){
				var cld:DisplayObject=this.parent.getChildAt(u);
				if((cld is FFchunk && this.hitbox.hitTestObject(cld))||(cld is Explosion && this.hitbox.hitTestObject((cld as Explosion).hitbox))||(cld is Laser && this.hitbox2.hitTestObject(cld)&&(!((cld as Laser).getOwner() is Robot)||!(cld as Laser).getOwner().equals(this)))){
					destroyBot(arr, ra, new Point(Math.floor(x / bw), sh - Math.ceil(y / bw)), sh, bw);
					if (cld is Laser) (cld as Laser).killLaser();
					return false;
				}
			}
			
			//2nd, check robot's sights for Hero
			checkRobotSights();
			
			//3rd, either 'pursue' the hero...
			if (myState == "paused") {
				var hero:Hero = (this.parent.parent as SRP).getMyHero();
				var xbuf:int = hero.x - this.x;
				var ybuf:int = hero.y - this.y;
				var angle = Math.atan(ybuf / xbuf) / (Math.PI / 180);
				
				if (xbuf<0) {
					angle+=180;
				}
				if (xbuf>=0&&ybuf<0) {
					angle+=360;
				}
				
				this.rotation = angle+90;
			}
			//...or go about your usual business.
			else if (myTween == null || (!myTween.isPlaying && myState != "return")) {
				
				//variable for next square in motion path
				var np:Point=currPos.clone();
				//coordinate change value
				var cc:int = bw;
				
				savedAngle = this.rotation;
				
				if(rotation==0){
					np.y+=1;
					cc=-cc;
				}
				else if(rotation==90) np.x+=1;
				else if(rotation==180||rotation==-180) np.y-=1;
				else if(rotation==270||rotation==-90){
					np.x-=1;
					cc=-cc;
				}
				
				//move LINEAR and RANDOM robots
				if(myType==0||myType==1){
					if(np.x<arr[0].length&&np.x>=0&&np.y>=0&&np.y<arr.length){
						//var itm:Object=arr[np.y][np.x];
						if(areEmpty(arr,np.y,np.x)){
							if ((rotation / 90) % 2 != 0) {
								myTween=new Tween(this,"x",None.easeNone,this.x,this.x+cc,48);
							}
							else {
								myTween = new Tween(this, "y", None.easeNone, this.y, this.y + cc, 48);
							}
							
							//update robot position in array
							arr[np.y][np.x]=this;
							nextPos = np;
							//halfway = true;
							myTween.addEventListener(TweenEvent.MOTION_CHANGE,halfWayCheck);
							myTween.addEventListener(TweenEvent.MOTION_STOP,tweenStop);
						}else {
							if (myType == 0) {
								myTween=new Tween(this,"rotation",None.easeNone,rotation,rotation+180,48);
								//trace(getTimer());
							}
							else myTween=new Tween(this,"rotation",None.easeNone,rotation,rotation+rTwo()*90,24);
						}
					}else {
						if(myType==0) myTween=new Tween(this,"rotation",None.easeNone,rotation,rotation+180,48);
						else myTween=new Tween(this,"rotation",None.easeNone,rotation,rotation+rTwo()*90,24);
					}
					myTween.start();
				}//end LINEAR/RANDOM
				
				//move CYCLE robots
				else if(myType==2){
					if(rotation==0 && currPos.y>myPartner.y){
						if(currPos.x>myPartner.x && areEmpty(arr,currPos.y,currPos.x-1)){
							myTween=new Tween(this,"rotation",None.easeNone,rotation,rotation-90,24);
							myTween.start();
						}
						else if(currPos.x<myPartner.x && areEmpty(arr,currPos.y,currPos.x+1)){
							myTween=new Tween(this,"rotation",None.easeNone,rotation,rotation+90,24);
							myTween.start();
						}
					}
					else if((rotation==180||rotation==-180) && currPos.y<myPartner.y){
						if(currPos.x>myPartner.x && areEmpty(arr,currPos.y,currPos.x-1)){
							myTween=new Tween(this,"rotation",None.easeNone,rotation,rotation+90,24);
							myTween.start();
						}
						else if(currPos.x<myPartner.x && areEmpty(arr,currPos.y,currPos.x+1)){
							myTween=new Tween(this,"rotation",None.easeNone,rotation,rotation-90,24);
							myTween.start();
						}
					}
					else if(rotation==90 && currPos.x>myPartner.x){
						if(currPos.y>myPartner.y && areEmpty(arr,currPos.y-1,currPos.x)){
							myTween=new Tween(this,"rotation",None.easeNone,rotation,rotation+90,24);
							myTween.start();
						}
						else if(currPos.y<myPartner.y && areEmpty(arr,currPos.y+1,currPos.x)){
							myTween=new Tween(this,"rotation",None.easeNone,rotation,rotation-90,24);
							myTween.start();
						}
					}
					else if((rotation==-90||rotation==270) && currPos.x<myPartner.x){
						if(currPos.y>myPartner.y && areEmpty(arr,currPos.y-1,currPos.x)){
							myTween=new Tween(this,"rotation",None.easeNone,rotation,rotation-90,24);
							myTween.start();
						}
						else if(currPos.y<myPartner.y && areEmpty(arr,currPos.y+1,currPos.x)){
							myTween=new Tween(this,"rotation",None.easeNone,rotation,rotation+90,24);
							myTween.start();
						}
					}
					
					//default to straight
					if((myTween==null||!myTween.isPlaying)){
						if(areEmpty(arr,np.y,np.x)){
							if((rotation/90)%2!=0) myTween=new Tween(this,"x",None.easeNone,this.x,this.x+cc,48);
							else myTween=new Tween(this,"y",None.easeNone,this.y,this.y+cc,48);
							myTween.start();
							
							arr[np.y][np.x]=this;
							nextPos = np;
							//halfway = true;
							myTween.addEventListener(TweenEvent.MOTION_CHANGE,halfWayCheck);
							myTween.addEventListener(TweenEvent.MOTION_STOP,tweenStop);
						}
						else if(!(arr[np.y][np.x] is Robot)&&!(arr[np.y][np.x] is Number)){
							if((currPos.x<myPartner.x&&rotation==0)||(currPos.x>myPartner.x&&(rotation==180||rotation==-180))||(currPos.y>myPartner.y&&rotation==90)||(currPos.y<myPartner.y&&(rotation==-90||rotation==270))){
								myTween=new Tween(this,"rotation",None.easeNone,rotation,rotation-90,24);
								myTween.start();
							}else{
								myTween=new Tween(this,"rotation",None.easeNone,rotation,rotation+90,24);
								myTween.start();
							}
							myPartner=np;
						}
					}
				}//end CYCLE
			}
			return true;
		}//end move robots
		
		public function checkRobotSights():Boolean {
			if (myTween!=null&&this.parent.parent is SRP) {
				var hero:Hero = (this.parent.parent as SRP).getMyHero();
				if (hero.alpha>0&&this.sight.hitTestPoint(hero.x, hero.y,true)&&checkObstructions()) {
					if (myTween.isPlaying) myTween.stop();
					if (returnTween != null) {
						returnTween.removeEventListener(TweenEvent.MOTION_FINISH, endReturnState);
						returnTween = null;
					}
					myState = "paused";
					
					//fire missiles
					if(mayFire){
						var lassP:Point = new Point(this.x,this.y);
						lassP = this.globalToLocal(lassP);
						lassP.y -= 14;
						lassP = this.localToGlobal(lassP);
						var lass:Laser = new Laser(this.parent as EmptyLevel, this.rotation, 10, lassP, this);
						
						mayFire = false;
						myTime.start();
						myTime.addEventListener(TimerEvent.TIMER_COMPLETE, stopTimer);
					}
					
					return true;
				}
				// After robot has eliminated or lost sight of the hero, start return to initial position
				else if (myState == "paused") {
					myState = "return";
					var newAngle:Number;
					
					if (myTween.prop == "rotation") {
						newAngle = myTween.finish;
					} else {
						newAngle = savedAngle;
					}
					
					if (Math.abs(newAngle) > 180) newAngle = -1 * (360 - Math.abs(newAngle));
					var returnTime:Number = Math.round(Math.abs(Math.abs(newAngle) - Math.abs(this.rotation)) * (48 / 180));
					if (returnTime < 10) returnTime = 10;
					if (this.rotation < 0 && newAngle == 180) newAngle = -180;
					returnTween = new Tween(this, "rotation", None.easeNone, this.rotation, newAngle, returnTime);
					returnTween.start();
					returnTween.addEventListener(TweenEvent.MOTION_FINISH, endReturnState);
				}
				else if (myTween!=null&&myTween.time != myTween.duration && myState != "return") {
					myTween.resume();
					myState = "normal";
					return true;
				}
				if(myState != "return") myState = "normal";
			}
			
			return false;
		}
		
		public function endReturnState(e:TweenEvent) {
			myState = "normal";
			returnTween.removeEventListener(TweenEvent.MOTION_FINISH, endReturnState);
			returnTween = null;
			if (myTween.prop == "rotation") {
				myTween.fforward();
			}
		}
		
		// when player is in sight, check for obstructions
		public function checkObstructions():Boolean {
			var mySRP:SRP = this.parent.parent as SRP;
			var hero:Hero = mySRP.getMyHero();
			var heroP:Point = new Point(hero.x, hero.y);
			var robotP:Point = new Point(this.sight.x, this.sight.y);
			var sightPL:Point = new Point(robotP.x - 1, robotP.y - 1);
			var sightPR:Point = new Point(robotP.x + 1, robotP.y - 1);
			robotP = this.localToGlobal(robotP);
			
			var hgt:int = mySRP.getMyHeight();
			var wdt:int = mySRP.getMyWidth();
			var bwd:int = mySRP.getBlockWidth();
			var arf:Array = mySRP.getMyArray();
			
			
			while (Point.distance(robotP, this.localToGlobal(sightPL)) < Point.distance(robotP, heroP) /*&& sightPL.y > sight.y - sight.width*/) {
				var rprGlobal = this.localToGlobal(sightPR);
				var rplGlobal = this.localToGlobal(sightPL);
				
				rprGlobal= new Point(Math.floor(rprGlobal.x / bwd), hgt - Math.ceil(rprGlobal.y / bwd));
				rplGlobal = new Point(Math.floor(rplGlobal.x / bwd), hgt - Math.ceil(rplGlobal.y / bwd));
				if(rprGlobal.x>=0&&rprGlobal.x<wdt&&rplGlobal.y>=0&&rplGlobal.y<hgt){
					var lSpot:Object = arf[rplGlobal.y][rplGlobal.x];
					var rSpot:Object = arf[rprGlobal.y][rprGlobal.x];
					if (!rprGlobal.equals(currPos) && (nextPos==null || !rprGlobal.equals(nextPos))) {
						if (rSpot is Wall || rSpot is Robot || rSpot is ForceField) return false;
					}
					else if (!(rplGlobal.equals(currPos)) && (nextPos==null || !rplGlobal.equals(nextPos))) {
						if (lSpot is Wall || lSpot is Robot || lSpot is ForceField) return false;
					}
				}
				//return new Point(Math.floor(p.x/blockWidth),myHeight-Math.ceil(p.y/bwd));
				sightPL.y -= 1;
				sightPR.y -= 1;
			}
			return true;
		}
		
		public function stopTimer(e:TimerEvent) {
			myTime.reset();
			myTime.removeEventListener(TimerEvent.TIMER_COMPLETE, stopTimer);
			mayFire = true;
		}
		//this tween stop method is called by SRP.as
		public function stopMyTween(){
			if(myTween!=null)myTween.stop();
			if(myAlphaTween!=null)myAlphaTween.stop();
			if (myColorTween != null) myColorTween.stop();
			if(returnTween!=null)returnTween.stop();
		}
		public function halfWayCheck(e:TweenEvent){
			if (e.time >= 24) {
				myTween.removeEventListener(TweenEvent.MOTION_CHANGE,halfWayCheck);
				myTween.removeEventListener(TweenEvent.MOTION_STOP, tweenStop);
				//halfway = false;
				var arr:Array=(parent.parent as SRP).getMyArray();
				if(!(arr[currPos.y][currPos.x] is Number)) arr[currPos.y][currPos.x]=null;
				setPos(nextPos);
				nextPos=null;
			}
		}
		public function tweenStop(e:TweenEvent){
			if (destroyed) {
				myTween.removeEventListener(TweenEvent.MOTION_CHANGE,halfWayCheck);
				myTween.removeEventListener(TweenEvent.MOTION_STOP, tweenStop);
			}
		}
		
		private function areEmpty(arr:Array,yi:int,xi:int):Boolean{
			var itm:Object=arr[yi][xi];
			return !(itm is Switch)&&!(itm is StaticItem)&&!(itm is Turret)&&!(itm is Exit)&&!(itm is Number)&&!(itm is Robot)&&!(itm is ForceField);
		}
		private function rTwo(){
			var rando:Array=new Array(-1,1);
			return rando[Math.floor(Math.random()*2)];
		}

		public function isDestroyed() {
			return destroyed;
		}
		public function pauseDeath() {
			myColorTween.stop();
			myAlphaTween.stop();
		}
		public function pauseBot() {
			if (myTween.isPlaying) myTween.stop();
		}
	}
}