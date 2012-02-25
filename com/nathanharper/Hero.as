//the player avatar
package com.nathanharper{
	import flash.geom.Point;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.Strong;
	public class Hero extends Rotatable{
		public var deathTween:Tween;
		public function Hero(pos:Point,dir:int){
			setStartPos(pos);
			setStartDir(dir);
			rotation=dir;
		}
		public function killMe(){
			deathTween=new Tween(this,"alpha",Strong.easeOut,this.alpha,0,24);
			deathTween.start();
		}
	}
}