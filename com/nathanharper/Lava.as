//a static object that kills the hero and robots on contact
package com.nathanharper{
	import flash.geom.Point;
	public class Lava extends StaticItem{
		public function Lava(point:Point){
			this.setStartPos(point);
		}
	}
}