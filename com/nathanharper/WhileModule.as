package com.nathanharper
{
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author ...
	 */
	public class WhileModule extends MovieClip
	{
		private var loopnum:int;
		private var slot1val:int;
		private var slot2val:int;
		private var slot3val:int;
		
		public function WhileModule(num:int) {
			this.loopnum = num;
			this.buttonMode = true;
			this.gotoAndStop('loop' + num + 'closed');
		}
		
		public function open() {
			this.gotoAndStop("loop" + this.loopnum + "open");
			this.slot1.buttonMode = true;
			this.slot2.buttonMode = true;
			this.slot3.buttonMode = true;
			
			//var loop:WhileModule = WhileModule(e.currentTarget);
			
			this.buttonMode = false;
			this.slot1.buttonMode = true;
			this.slot2.buttonMode = true;
			this.slot3.buttonMode = true;
			
			//addSlotEvents();
		}
		
		public function getNum() {
			return this.loopnum;
		}
	}
	
}