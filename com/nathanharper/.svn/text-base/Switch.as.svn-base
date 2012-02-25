/*
A switch that toggles the state of force fields.
Contains an array of indices for force fields that it gpverns.
*/
package com.nathanharper{
	import flash.geom.Point;
	public class Switch extends StageItem{
		
		private var ctrlArr:Array;
		private var myColor:String;
		
		public function Switch(position:Point,clr:String){
			setStartPos(position);
			ctrlArr=new Array();
			myColor=clr;
			gotoAndStop(myColor);
		}
		public function getColor(){
			return myColor;
		}
		
		//assign a force field for this switch to control
		public function assignFF(mff:ForceField){
			ctrlArr.push(mff);
		}
		
		public function flipSwitch(el:EmptyLevel,arr:Array){
			this.scaleX*=-1;
			for(var i:int=0;i<ctrlArr.length;i++){
				ctrlArr[i].toggleMe(el,arr);
			}
		}
	}
}