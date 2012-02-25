//an immobile, rotating and shooting enemy
package com.nathanharper{
	import flash.geom.*;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	public class Turret extends Rotatable{
		private var sightArr:Array=new Array();
		private var myTime:Timer=new Timer(150,1);
		private var mayFire:Boolean=true;
		private var myColor:ColorTransform=new ColorTransform();
		private var myColorTween:Tween;
		private var myAlphaTween:Tween;
		public var destroyed:Boolean = false;
		
		public function Turret(pos:Point,dir:int){
			setStartPos(pos);
			setStartDir(dir);
			rotation=dir;
			//myTime.addEventListener(TimerEvent.TIMER_COMPLETE,stopTimer);
			//myTime.addEventListener(TimerEvent.TIMER_COMPLETE,stopTimer,false);
		}
		public function addSight(p:Point){
			sightArr.push(p);
		}
		public function heroHit(p:Point):Boolean{
			if(mayFire){
				for(var i:int=0;i<sightArr.length;i++){
					//trace(myTime.running);
					if(p.x==sightArr[i].x&&p.y==sightArr[i].y){
						myTime.reset();
						myTime.start();
						//myTime.addEventListener(TimerEvent.,stopTimer,true);
						myTime.addEventListener(TimerEvent.TIMER_COMPLETE,stopTimer);
						mayFire=false;
						//trace("fired");
						return true;
					}
				}
			}
			return false;
		}
		public function stopTimer(e:TimerEvent){
			myTime.removeEventListener(TimerEvent.TIMER_COMPLETE,stopTimer);
			//myTime.removeEventListener(TimerEvent.TIMER_COMPLETE,stopTimer,false);
			myTime.stop();
			mayFire=true;
			//trace("boop");
		}
		public function destroyTurret(arr:Array, ta:Array) {
			destroyed = true;
			var myPos:Point=this.getStartPos();
			arr[myPos.y][myPos.x]=null;
			
			for(var i:int=0;i<ta.length;i++){
				if(ta[i]===this) ta.splice(i,1);
			}
			
			myColorTween=new Tween(myColor,"redOffset",None.easeNone,0,255,24);
			myAlphaTween = new Tween(myColor, "alphaOffset", None.easeNone, 0, -100, 24);
			//myAlphaTween = new Tween(this, "alpha", None.easeNone, 1, .5, 24);
			myColorTween.addEventListener(TweenEvent.MOTION_CHANGE,updateTurretColor);
			myColorTween.addEventListener(TweenEvent.MOTION_FINISH,explodeTurret);
			myAlphaTween.start();
			myColorTween.start();
		}
		public function updateTurretColor(e:TweenEvent){
			this.transform.colorTransform=myColor;
		}
		public function explodeTurret(e:TweenEvent){
			myColorTween.removeEventListener(TweenEvent.MOTION_FINISH,explodeTurret);
			myColorTween.removeEventListener(TweenEvent.MOTION_CHANGE,updateTurretColor);
			
			if(this.parent.parent is SRP){
				var myLevel:Object=this.parent;
				var mySRP:SRP=myLevel.parent as SRP;
				myLevel.removeChild(this);
				
				var myPos:Point=this.getStartPos();
	
				for(var x2:int=-1;x2<2;x2++){
					for(var y2:int=-1;y2<2;y2++){
						Robot.makeSplode(myLevel,(myPos.x+x2)*mySRP.getBlockWidth(),(mySRP.getMyHeight()-1-myPos.y+y2)*mySRP.getBlockWidth());
					}
				}
			}
		}

		public function pauseDeath() {
			myColorTween.stop();
			myAlphaTween.stop();
		}
	}
}