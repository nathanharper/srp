//A static object that allows the hero to exit the stage
package com.nathanharper{
	import flash.geom.Point;
	public class Exit extends Rotatable{
		public function Exit(pos:Point,dir:int){
			setStartDir(dir);
			setStartPos(pos);
		}
	}
}