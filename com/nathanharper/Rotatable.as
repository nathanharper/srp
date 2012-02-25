// A stage item for which direction is relevant
package com.nathanharper{
	class Rotatable extends StageItem{
		
		private var startDir:int;
		
		public function Rotatable(){}

		//set the starting direction of this Rotatable
		public function setStartDir(dir:int){
			startDir=dir;
			rotation=startDir;
		}
		
		//set the object to its starting direction
		public function resetMe(){
			rotation=startDir;
		}
	}
}