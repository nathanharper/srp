package com.nathanharper
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Nathan Harper
	 */
	public class HackInterface extends MovieClip 
	{
		private var robot:Robot;
		private var data:Array;
		private var loops:Array;
		
		//private var loop1:WhileModule;
		//private var loop2:WhileModule;
		//private var loop3:WhileModule;
		
		private var right:ActionButton;
		private var left:ActionButton;
		private var up:ActionButton;
		private var down:ActionButton;
		private var clockwise:ActionButton;
		private var counterclockwise:ActionButton;
		private var fire:ActionButton;
		private var flip:ActionButton;
		
		private var alert:AlertMessage;
		private var finish:FinishButton;
		private var viewstage:ViewStageButton;
		private var selected:WhileSlot;
		
		public function HackInterface(r:Robot) {
			this.robot = r;
		}
		
		public function initiate() {
			this.right = new ActionButton();
			this.right.x = 10.7;
			this.right.y = 280.75;
			addChild(this.right);

			this.left = new ActionButton();
			this.left.x = 99.45;
			this.left.y = 280.75;
			addChild(this.left);

			this.up = new ActionButton();
			this.up.x = 10.7;
			this.up.y = 325.15;
			addChild(this.up);

			this.down = new ActionButton();
			this.down.x = 99.45;
			this.down.y = 325.15;
			addChild(this.down);

			this.fire = new ActionButton();
			this.fire.x = 10.7;
			this.fire.y = 370.45;
			addChild(this.fire);

			this.flip = new ActionButton();
			this.flip.x = 99.45;
			this.flip.y = 370.45;
			addChild(this.flip);
			
			this.clockwise = new ActionButton();
			this.clockwise.x = 10.7;
			this.clockwise.y = 416.7;
			addChild(this.clockwise);
			
			this.counterclockwise = new ActionButton();
			this.counterclockwise.x = 99.45;
			this.counterclockwise.y = 416.7;
			addChild(this.counterclockwise);
			
			loop1 = this.loops.push(new WhileModule(1));
			loop1.x = 30.9;
			loop1.y = 22.5;
			addChild(loop1);
			
			loop2 = this.loops.push(new WhileModule(2));
			loop2.x = 191.8;
			loop2.y = 22.5;
			addChild(loop2);
			
			loop3 = this.loops.push(new WhileModule(3));
			loop3.x = 360.45;
			loop3.y = 22.5;
			addChild(loop3);
			
			this.viewstage = new ViewStageButton();
			this.viewstage.x = 398.65;
			this.viewstage.y = 423.65;
			addChild(this.viewstage);
			
			this.finish = new FinishButton();
			this.finish.x = 394.95;
			this.finish.y = 371.4;
			addChild(this.finish);
			
			this.alert = new AlertMessage();
			this.alert.x = 194.2;
			this.alert.y = 332.9;
			addChild(this.alert);
			
			this.right.gotoAndStop('right');
			this.left.gotoAndStop('left');
			this.up.gotoAndStop('up');
			this.down.gotoAndStop('down');
			this.fire.gotoAndStop('fire');
			this.flip.gotoAndStop('flip');
			this.clockwise.gotoAndStop('clockwise');
			this.counterclockwise.gotoAndStop('counterclockwise');
			
			this.left.buttonMode = true;
			this.right.buttonMode = true;
			this.up.buttonMode = true;
			this.down.buttonMode = true;
			this.clockwise.buttonMode = true;
			this.counterclockwise.buttonMode = true;
			this.flip.buttonMode = true;
			this.fire.buttonMode = true;
			this.viewstage.buttonMode = true;
			
			this.alert.visible = false;
			
			enableMouseEvents();
			return true;
		}
			
		// Fade the programming interface so the user can see the level.
		public function showLevel(e:MouseEvent) {
			if (this.viewstage.currentLabel == "view") {
				this.alpha = .2;
				this.viewstage.alpha = 10;
				this.viewstage.gotoAndStop("back");
				disableMouseEvents(false);
			}
			else {
				this.alpha = 1;
				this.viewstage.gotoAndStop("view");
				enableMouseEvents(false);
			}
		}
	
		public function disableMouseEvents(viewButton:Boolean = true) {
			this.finish.removeEventListener(MouseEvent.CLICK, finishProgramming);
			
			for (var i:int = 0; i < this.loops.length; i++ ) {
				var loop:WhileModule = WhileModule(this.loops[i]);
				removeSlotEvents(loop);
				if (loop.currentLabel.indexOf("closed") >= 0) {
					loop.removeEventListener(MouseEvent.CLICK, openLoop);
				}
			}
			
			if (viewButton) {
				this.viewstage.removeEventListener(MouseEvent.CLICK, showLevel);
			}
			return true;
		}
	
		public function enableMouseEvents(viewButton:Boolean = true) {
			this.finish.addEventListener(MouseEvent.CLICK, finishProgramming);
			for (var i:int = 0; i < this.loops.length; i++ ) {
				var loop:WhileModule = WhileModule(this.loops[i]);
				addSlotEvents(loop);
				if (loop.currentLabel.indexOf("closed") >= 0) {
					loop.addEventListener(MouseEvent.CLICK, openLoop);
				}
			}
			
			if (viewButton) {
				this.viewstage.addEventListener(MouseEvent.CLICK,showLevel);
			}
			return true;
		}
	
		public function openLoop(e:MouseEvent) {
			var loop:WhileModule = WhileModule(e.currentTarget);
			loop.open();
			loop.removeEventListener(MouseEvent.CLICK, openLoop);
			addSlotEvents(loop);
		}
	
		public function finishProgramming(e:MouseEvent) {
			// Close the programming interface 
			// Save code and transfer to robot object
		}
	
		public function addSlotEvents(w:WhileModule) {
			if (w.currentLabel == ("loop" + w.currentLabel.substr(4, 1) + "open")) {
				w.slot1.addEventListener(MouseEvent.CLICK, selectSlot);
				w.slot2.addEventListener(MouseEvent.CLICK, selectSlot);
				w.slot3.addEventListener(MouseEvent.CLICK, selectSlot);
			}
			return true;
		}
	
		public function removeSlotEvents(w:WhileModule) {
			if (w.currentLabel == ("loop" + w.currentLabel.substr(4, 1) + "open")) {
				w.slot1.removeEventListener(MouseEvent.CLICK, selectSlot);
				w.slot2.removeEventListener(MouseEvent.CLICK, selectSlot);
				w.slot3.removeEventListener(MouseEvent.CLICK, selectSlot);
				w.slot1.gotoAndStop("green");
				w.slot2.gotoAndStop("green");
				w.slot3.gotoAndStop("green");
			}
			return true;
		}
	
		public function selectSlot(e:MouseEvent) {
			this.alert.visible = true;
			this.selected = e.currentTarget;
			for (var i:int = 0; i < this.loops.length; i++) {
				removeSlotEvents(this.loops[i]);
			}
			this.selected.gotoAndStop("pink");
		}
	}
}