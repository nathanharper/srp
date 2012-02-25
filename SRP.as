package{
	import com.nathanharper.*;
	import flash.geom.Point;
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.utils.*;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None;
	//import fl.transitions.easing.Strong;
	
	public class SRP extends MovieClip{
		
		private var myText:TextField=new TextField(); //text field where level code is entered
		private var mySS:StartScreen=new StartScreen(); //the start screen object
		private var myGOS:GameOverScreen=new GameOverScreen(); //the game over screen object
		private var myLevel:EmptyLevel;
		private var myStick:Stick = new Stick();
		private var myCode:String; //the user entered level code
		private var alphabet:String="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		private var stageMode:String; //the mode of the entered level (has to do with switch dependencies)
		private var playMode:String = "menu"; //indicates the state of the game ("menu","play","pause","death")
		private var currInterface:HackInterface;
		
		//item arrays
		private var myArray:Array; //the complete level map
		private var lavaArray:Array=new Array(); //array of the lava squares
		private var robotArray:Array=new Array(); //array of robots
		private var swcArray:Array=new Array(); //array of switches
		private var turretArray:Array=new Array();
		private var forceFieldArray=new Array();
		
		private var hero:Hero;
		private var heroSpeed:int = 2;
		private var thrustTween:Tween;
		
		private var myWidth:int=20; //the width of the stage in squares
		private var myHeight:int=18; //height of the stage in squares
		private var blockWidth=28; //the width of an individual square (in pixels)
		
		//key press booleans (true if key is currently pressed)
		var left:Boolean=false;
		var right:Boolean=false;
		var up:Boolean=false;
		var down:Boolean=false;
		var space:Boolean = false;
		
		private var thrust:Boolean = false; // "thrust" variable is true if usb stick is being extended
		private var testingMode:Boolean = false; 
		
		public function SRP(){
			addChild(mySS);
			addChild(myGOS);
			
			myGOS.visible = false;
			//thrustTween = new Tween(myStick, "scaleY", None.easeNone, 1, 2, 12);
			//myStick.scaleY = 1;
			
			//format the input box
			myText.type=TextFieldType.INPUT;
			myText.background= true;
			myText.border=true;
			myText.backgroundColor=0xFFCCFF;
			//myText.text="Your level code \ngoes here."
			myText.x=350;
			myText.y=230;
			addChild(myText);
			
			//prepare the code reading button
			mySS.readcode.alpha=.4;
			mySS.readcode.addEventListener(MouseEvent.MOUSE_OVER,mouseOverFunc);
			mySS.readcode.addEventListener(MouseEvent.MOUSE_OUT,mouseOutFunc);
			mySS.readcode.addEventListener(MouseEvent.CLICK,readCode);
		}
		//ACCESSORS
		public function getMyHeight(){return myHeight;}
		public function getMyWidth(){return myWidth;}
		public function getBlockWidth(){return blockWidth;}
		public function getForceFieldArray():Array{return forceFieldArray;}
		public function getMyArray():Array { return myArray; }
		public function getMyHero():Hero { return hero;}
		
		//game loop, called after a level code is interpreted
		public function loop(e:Event){
			if (playMode == "play") {
				if(!thrust) moveHero();
				myStick.x = hero.x;
				myStick.y = hero.y;
				myStick.rotation = hero.rotation;
			}
			if(playMode=="play"||playMode=="death"){
				moveBots();
				checkTurretCollisions();
			}
			if(playMode=="play") {
				checkHeroCollisions();
				checkTurretSights();
			}
			if (thrust && hero.deathTween == null) {
				checkStickCollisions();
			}
		}
		
		//see if a robot has been "sticked"
		public function checkStickCollisions() {
			for (var i:int = 0; i < robotArray.length; i++) {
				if (myStick.hitTestObject(robotArray[i].hitbox)) {
					openProgrammingInterface(robotArray[i]);
					break;
				}
			}
		}
		
		//function called when myStick has made contact with a Robot
		public function openProgrammingInterface(robot:Robot) {
			removeEventListener(Event.ENTER_FRAME, loop);
			//stop all animations
			for (var i:int = 0; i < myLevel.numChildren; i++) {
				var poop:DisplayObject = myLevel.getChildAt(i);
				if (poop is Laser) (poop as Laser).pauseMotion();
				if (poop is Robot) {
					if ((poop as Robot).isDestroyed()) (poop as Robot).pauseDeath();
					else (poop as Robot).pauseBot();
				}
				if (poop is Turret && (poop as Turret).destroyed) (poop as Turret).pauseDeath();
				if (poop is Explosion) (poop as Explosion).stop();
			}
			
			var screen:HackInterface = new HackInterface(robot);
			currInterface = screen;
			currInterface.x = 5;
			currInterface.y = 5;
			//var boner:Lava = new Lava(new Point(hero.x, hero.y));
			//boner.x = hero.x;
			//boner.y = hero.y;
			myLevel.addChild(currInterface);
			currInterface.initiate();
		}
		
		public function closeProgrammingInterface() {
			currInterface.disableMouseEvents();
			myLevel.removeChild(currInterface);
			currInterface = null;
		}
		
		//see if a turret has spotted the hero
		public function checkTurretSights(){
			var heroPos:Point = getSquare(new Point(hero.x,hero.y));
			for(var i:int=0;i<turretArray.length;i++){
				if(turretArray[i].heroHit(heroPos)){
					//fire a missile
					//trace("heroHit is working");
					var lassP:Point = new Point(turretArray[i].x, turretArray[i].y);
					lassP = turretArray[i].globalToLocal(lassP);
					lassP.y -= 9;
					lassP = turretArray[i].localToGlobal(lassP);
					var lass:Laser=new Laser(myLevel,turretArray[i].rotation,10,lassP,turretArray[i]);
				}
			}
		}
		
		//moves the player avatar each frame
		public function moveHero(){
			var deltaX:int=0;
			var deltaY:int=0;
			
			var p1:Point;
			var p2:Point;
			var targ1:Object;
			var targ2:Object;

			if (up) {
				deltaY-=heroSpeed;
				p1=getSquare(new Point(hero.x-hero.width/2,(hero.y-hero.width/2)+deltaY));
				p2=getSquare(new Point(hero.x+hero.width/2,(hero.y-hero.width/2)+deltaY));
				hero.rotation=0;
				if(hero.y-hero.width/2+deltaY<=0){
					deltaY=0-(hero.y-hero.width/2);
				}
				else{
					targ1=myArray[p1.y][p1.x];
					targ2=myArray[p2.y][p2.x];
					if(targ1 is Wall || targ2 is Wall || targ1 is ForceField || targ2 is ForceField /*|| targ1 is Turret || targ2 is Turret*/){
						deltaY=(blockWidth*(myHeight-1-p1.y)+blockWidth)-(hero.y-hero.width/2);
					}
				}
			} else if (down) {
				deltaY+=heroSpeed;
				p1=getSquare(new Point(hero.x-hero.width/2,(hero.y+hero.width/2)+deltaY));
				p2=getSquare(new Point(hero.x+hero.width/2,(hero.y+hero.width/2)+deltaY));
				hero.rotation=180;
				if(hero.y+hero.width/2+deltaY>=blockWidth*myHeight){
					deltaY=blockWidth*myHeight-(hero.y+hero.width/2);
				}
				else{
					targ1=myArray[p1.y][p1.x];
					targ2=myArray[p2.y][p2.x];
					if(targ1 is Wall || targ2 is Wall || targ1 is ForceField || targ2 is ForceField /*|| targ1 is Turret || targ2 is Turret*/){
						deltaY=(blockWidth*(myHeight-1-p1.y))-(hero.y+hero.width/2);
					}
				}
			} else if (right) {
				deltaX+=heroSpeed;
				p1=getSquare(new Point((hero.x+hero.width/2)+deltaX,hero.y-hero.width/2));
				p2=getSquare(new Point((hero.x+hero.width/2)+deltaX,hero.y+hero.width/2));
				targ1=myArray[p1.y][p1.x];
				targ2=myArray[p2.y][p2.x];
				hero.rotation=90;
				if(hero.x+hero.width/2+deltaX>=blockWidth*myWidth){
					deltaX=blockWidth*myWidth-(hero.x+hero.width/2);
				}
				else if(targ1 is Wall || targ2 is Wall || targ1 is ForceField || targ2 is ForceField /*|| targ1 is Turret || targ2 is Turret*/){
					deltaX=p1.x*blockWidth-(hero.x+hero.width/2);
				}
			} else if (left) {
				deltaX-=heroSpeed;
				p1=getSquare(new Point((hero.x-hero.width/2)+deltaX,hero.y-hero.width/2));
				p2=getSquare(new Point((hero.x-hero.width/2)+deltaX,hero.y+hero.width/2));
				targ1=myArray[p1.y][p1.x];
				targ2=myArray[p2.y][p2.x];
				hero.rotation=270;
				if(hero.x-hero.width/2+deltaX<=0){
					deltaX=0-(hero.x-hero.width/2);
				}
				else if(targ1 is Wall || targ2 is Wall || targ1 is ForceField || targ2 is ForceField /*|| targ1 is Turret || targ2 is Turret*/){
					deltaX=p1.x*blockWidth+blockWidth-(hero.x-hero.width/2);
				}
			}
			
			hero.x+=deltaX;
			hero.y+=deltaY;
		}
		
		//hero death animation
		public function heroDeath(){
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			myLevel.removeChild(myStick);
			left=false;right=false;down=false;up=false;space=false;
			playMode="death";
			hero.killMe();
			hero.deathTween.addEventListener(TweenEvent.MOTION_FINISH,openGameOverScreen);
		}
		
		public function openGameOverScreen(e:Event){
			e.currentTarget.stop();
			e.currentTarget.removeEventListener(TweenEvent.MOTION_FINISH,openGameOverScreen);
			myGOS.x=0;myGOS.y=0;
			myGOS.visible=true;
			setChildIndex(myGOS,numChildren-1);
			myGOS.retry.addEventListener(MouseEvent.CLICK,retryLevel);
			myGOS.quit.addEventListener(MouseEvent.CLICK,quitLevel);
		}
		public function retryLevel(e:MouseEvent){
			myGOS.retry.removeEventListener(MouseEvent.CLICK,retryLevel);
			myGOS.visible=false;
			myGOS.quit.removeEventListener(MouseEvent.CLICK,quitLevel);
			
			stopTweens();
			removeChild(myLevel);
			clearVars();
			makeArray(myWidth,myHeight);
			generateLevel(StringCheese.trim(myText.text));
		}
		public function quitLevel(e:MouseEvent){
			myGOS.retry.removeEventListener(MouseEvent.CLICK,retryLevel);
			myGOS.visible=false;
			myGOS.quit.removeEventListener(MouseEvent.CLICK,quitLevel);
			
			stopTweens();
			removeChild(myLevel);
			clearVars();
			myCode="";
			playMode="menu";
			
			myText.text=""
			mySS.readcode.alpha=.4;
			mySS.readcode.addEventListener(MouseEvent.MOUSE_OVER,mouseOverFunc);
			mySS.readcode.addEventListener(MouseEvent.MOUSE_OUT,mouseOutFunc);
			mySS.readcode.addEventListener(MouseEvent.CLICK,readCode);
		}
		private function clearVars(){
			myLevel=null;
			myArray=null;
			hero=null;
			lavaArray=new Array();
			robotArray=new Array();
			swcArray=new Array();
			turretArray=new Array();
			forceFieldArray=new Array();
		}
		private function stopTweens(){
			for(var i:int=0;i<myLevel.numChildren;i++){
				var itm:DisplayObject=myLevel.getChildAt(i);
				if(itm is Robot){
					(itm as Robot).stopMyTween();
				}
			}
		}
		//checks to see if the hero has made a fatal collision
		public function checkHeroCollisions():Boolean{
			
			//check lava collisions
			var herobox:Point=hero.localToGlobal(new Point(hero.hitbox.x,hero.hitbox.y));
			var boxLength:Number=hero.hitbox.width/2;
			
			//calculate positions of the corners of the hero's hitbox
			var t1:Boolean=isType(getSquare(new Point(herobox.x+boxLength,herobox.y-boxLength)));
			var t2:Boolean=isType(getSquare(new Point(herobox.x+boxLength,herobox.y+boxLength)));
			var t3:Boolean=isType(getSquare(new Point(herobox.x-boxLength,herobox.y-boxLength)));
			var t4:Boolean=isType(getSquare(new Point(herobox.x-boxLength,herobox.y+boxLength)));
			
			if(t1||t2||t3||t4){
				heroDeath();
				return true;
			}
			
			//check robot and Force Field collisions
			for(var i:int=0;i<myLevel.numChildren;i++){
				var poop:DisplayObject=myLevel.getChildAt(i);
				//TURRET COLLISIONS HANDLED HERE
				/*if(poop is Laser||poop is Explosion){
					for(var j:int=0;j<turretArray.length;j++){
						if(turretArray[j].hitTestObject(poop)
					}
				}*/
				if((poop is Robot && hero.hitbox.hitTestObject((poop as Robot).hitbox)) || ((poop is FFchunk || poop is Explosion||poop is Turret) && hero.hitbox.hitTestObject(poop))||(poop is Laser && hero.hitTestObject(poop))){
					heroDeath();
					return true;
				}
			}
			
			return false;
		}
		private function isType(p:Point):Boolean{
			if(myArray[p.y][p.x] is Lava) return true;
			return false;
		}
		
		public function fullThrust(e:TweenEvent) {
			thrustTween.removeEventListener(TweenEvent.MOTION_FINISH, fullThrust);
			thrustTween.yoyo();
			thrustTween.addEventListener(TweenEvent.MOTION_FINISH, endThrust);
		}
		public function endThrust(e:TweenEvent) {
			thrustTween.removeEventListener(TweenEvent.MOTION_FINISH, endThrust);
			thrust = false;
		}
		
		//CHECK TURRET COLLISIONS
		public function checkTurretCollisions(){
			for(var i:int=0;i<myLevel.numChildren;i++){
				var itm:DisplayObject = myLevel.getChildAt(i);
				if(itm is Laser || itm is Explosion){
					for(var j:int=0;j<turretArray.length;j++){
						if (itm is Laser) {
							var itmOwner:StageItem = (itm as Laser).getOwner();
							if(!(turretArray[j].equals(itmOwner)) && itm.hitTestObject(turretArray[j])){
									turretArray[j].destroyTurret(myArray, turretArray);
									(itm as Laser).killLaser();
							}
						}
						else if(itm is Explosion && itm.hitTestObject(turretArray[j])){
							turretArray[j].destroyTurret(myArray,turretArray);
						}
					}
				}
			}
		}
		
		//loop thru robots and move them
		public function moveBots(){
			for(var i:int=0;i<robotArray.length;i++){
				robotArray[i].moveRobot(myArray,robotArray,myWidth,myHeight,blockWidth);
			}
		}
		
		//read & interpret code string
		public function readCode(e:MouseEvent){
			// clean up event listeners on code reading button
			mySS.readcode.removeEventListener(MouseEvent.MOUSE_OUT,mouseOutFunc);
			mySS.readcode.removeEventListener(MouseEvent.MOUSE_OVER,mouseOverFunc);
			mySS.readcode.removeEventListener(MouseEvent.CLICK,readCode);
			
			makeArray(myWidth,myHeight);
			generateLevel(StringCheese.trim(myText.text));
		}
		
		//interpret a level code and generate the stage
		public function generateLevel(myCode:String){
			stageMode=myCode.substr(0,3);
			var myCodeBuf:String=myCode.substr(3);
			
			while(myCodeBuf.length>6){
				placeItem(myCodeBuf.substr(0,7));
				if(myCodeBuf.length>7) myCodeBuf=myCodeBuf.substr(7);
				else myCodeBuf="";
			}
			
			myLevel=new EmptyLevel();
			
			//0=pink, 1=gren, 2=blue
			var swcArr:Array = new Array(new Array(), new Array(), new Array());
			var lastLava:int = 1;
			
			//iterate through the array and generate the level map
			for(var i:int=0; i<myArray.length;i++){
				for(var j:int=0;j<myArray[i].length;j++){
					if(myArray[i][j] is StageItem){
						var temp:StageItem=myArray[i][j];
						temp.y=blockWidth*(myArray.length-1-i)+blockWidth/2;
						temp.x=j*blockWidth+blockWidth/2;
						myLevel.addChild(temp);
						if(temp is Robot){
							robotArray.push(temp);
						}
						else if(temp is Lava){
							lavaArray.push(temp);
							myLevel.setChildIndex(temp, 1);
							lastLava++;
						}
						else if(temp is Turret){
							turretArray.push(temp);
						}
						else if(temp is ForceField){
							forceFieldArray.push(temp);
						}
						else if(temp is Switch){
							if(stageMode=="CLR") swcArr[temp.currentFrame-1].push(temp);
							swcArray.push(temp);
							myLevel.setChildIndex(temp,1);
							myArray[i][j]=null;
						}
					}
				}
			}
			//set up switch/force field relationships in CLR mode (and turret vision ranges)
			for(i=0;i<myArray.length;i++){
				for(j=0;j<myArray[i].length;j++){
					if(myArray[i][j] is ForceField){
						var mff:ForceField=myArray[i][j];
						//set up color dependent switches
						if(stageMode=="CLR"){
							var mnum:int=mff.currentFrame-1;
							if(mff.currentFrame>3) mnum-=3;
							for(var k:int=0;k<swcArr[mnum].length;k++){
								swcArr[mnum][k].assignFF(mff);
							}
						}
						else if (stageMode == "SWC") {
							for (var nut:int = 0; nut < swcArray.length; nut++) {
								if (mff.getSwitch().equals(swcArray[nut].getStartPos())) {
									swcArray[nut].assignFF(mff);
								}
							}
						}
						
						//generate field
						var r=mff.rotation;
						var deltaP:Point=new Point(0,0);
						
						if(r==0) deltaP.y+=1;
						else if(r==90) deltaP.x+=1;
						else if(r==180||r==-180) deltaP.y-=1;
						else if(r==270||r==-90) deltaP.x-=1;
						
						makeField(mff,deltaP.add(new Point(j,i)),deltaP);
						deltaP=null;
						if(mff.getState()) mff.turnOn(myLevel,myArray);
					}
					else if(myArray[i][j] is Turret){
						var mt:Turret=myArray[i][j];
						var rt=mt.rotation;
						var dP:Point=new Point(0,0);
						
						if(rt==0) dP.y+=1;
						else if(rt==90) dP.x+=1;
						else if(rt==180||rt==-180) dP.y-=1;
						else if(rt==270||rt==-90) dP.x-=1;
						
						makeSight(mt,dP.add(new Point(j,i)),dP);
						dP=null;
					}
				}
			}
			swcArr=null;
			
			//display the new level and enter the game loop
			hero.y=blockWidth*(myArray.length-1-hero.getStartPos().y)+blockWidth/2;
			hero.x=hero.getStartPos().x*blockWidth+blockWidth/2;
			myLevel.addChild(hero);
			myLevel.addChild(myStick);
			myLevel.setChildIndex(myStick, lastLava);
			//myStick.scaleY = 1;
			addChild(myLevel);
			addEventListener(Event.ENTER_FRAME,loop);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
			playMode="play";
		}
		
		//return an optimized StageItem given its hash representation
		public function placeItem(str:String){
			var itm:StageItem=getType(str.substr(2,2),str.substr(0,2),str.substr(4,2),str.substr(6,1));
			if(!(itm is Hero)) {
				var pos:Point=itm.getStartPos();
				myArray[pos.y][pos.x]=itm;
			}
		}
		//helper for placeItem
		public function getType(tp:String,pos:String,pt:String,dir:String){
			
			var p:Point=new Point(alphabet.indexOf(pos.substr(0,1)),alphabet.indexOf(pos.substr(1,1)));
			
			var nDir:int=0;
			if(dir=="R") nDir=90;
			if(dir=="D") nDir=180;
			if(dir=="L") nDir=270;
			
			var partner:Point=new Point(-1,-1);
			if(pt!="$$"){
				partner.x=alphabet.indexOf(pt.substr(0,1));
				partner.y=alphabet.indexOf(pt.substr(1,1));
			}
			
			if(tp=="A0") return new Lava(p);
			if(tp=="A1") return new Wall(p);
			if(tp=="A2") {
				hero=new Hero(p,nDir);
				return hero;
			}
			if(tp=="A3") return new Exit(p,nDir);
			if(tp=="A5") return new Turret(p,nDir);
			if(tp=="C0") return new Switch(p,"gren");
			if(tp=="C1") return new Switch(p,"blue");
			if(tp=="C2") return new Switch(p,"pink");
			if(tp=="B0") return new ForceField(p,nDir,true,partner,"gren");
			if(tp=="B2") return new ForceField(p,nDir,true,partner,"blue");
			if(tp=="B4") return new ForceField(p,nDir,true,partner,"pink");
			if(tp=="B1") return new ForceField(p,nDir,false,partner,"gren");
			if(tp=="B3") return new ForceField(p,nDir,false,partner,"blue");
			if(tp=="B5") return new ForceField(p,nDir,false,partner,"pink");
			if(tp=="D0") return new Robot(p,nDir,0,partner);
			if(tp=="D1") return new Robot(p,nDir,1,partner);
			if(tp=="E0") return new Robot(p,nDir,2,partner);
		}
		
		//intitialize stage array
		public function makeArray(w:int,h:int){
			myArray=new Array();
			for(var i:int=0;i<h;i++){
				myArray.push(new Array(w));
			}
		}
		
		//generates force fields given the emitter and the current location
		public function makeField(mff:ForceField,p:Point,dp:Point){
			if(p.x<myArray[0].length&&p.x>=0&&p.y>=0&&p.y<myArray.length&&(myArray[p.y][p.x]==null||myArray[p.y][p.x] is Number||(!mff.getState()&&(myArray[p.y][p.x] is Robot||myArray[p.y][p.x] is Hero)))){
				var ffc:FFchunk=new FFchunk(mff.rotation,p);
				ffc.y=blockWidth*(myArray.length-1-p.y)+blockWidth/2;
				ffc.x=p.x*blockWidth+blockWidth/2;
				mff.addChunk(ffc);
				
				//if a space is occupied by a forcefield, represent it with a number
				if(mff.getState()){
					if(!(myArray[p.y][p.x] is Number)) myArray[p.y][p.x]=new Number(0);
					if(!mff.getState()) myArray[p.y][p.x]+=1;
				}
				
				makeField(mff,p.add(dp),dp);
			}
		}
		
		//set up sight range for turrets
		public function makeSight(mt:Turret,p:Point,dp:Point){
			if(p.x<myArray[0].length&&p.x>=0&&p.y>=0&&p.y<myArray.length&&!(myArray[p.y][p.x] is StaticItem) && !(myArray[p.y][p.x] is ForceField)){
				mt.addSight(p);
				makeSight(mt,p.add(dp),dp);
			}
		}
		
		//change alpha transparency of the read code button
		public function mouseOverFunc(e:MouseEvent){
			e.currentTarget.alpha=1;
		}
		public function mouseOutFunc(e:MouseEvent){
			e.currentTarget.alpha=.4;
		}
		
		//convert exact pixel coordinates to coordinates of the stage grid
		public function getSquare(p:Point):Point{
			return new Point(Math.floor(p.x/blockWidth),myHeight-Math.ceil(p.y/blockWidth));
		}
		
		public function keyDownHandler(event:KeyboardEvent) {
			/*if (! interfaceUp) {*/
				if (event.keyCode==37) {//37 == left arrow key
					left=true;
				}
				if (event.keyCode==38) {//38 == up arrow key
					up=true;
				}
				if (event.keyCode==39) {//39 == right arrow key
					right=true;
				}
				if (event.keyCode==40) {//40 == down arrow key
					down=true;
				}
				if (event.keyCode==68) {//68 == d key: toggles testing mode for now
					//dee=true;
					//dispatchEvent(new Event("usbStart"));
					testingMode = !testingMode;
				}
			/*}*/
			if (event.keyCode==32) { //32 == space bar
				space=true;
				//var c:Point=getSquare(hero.localToGlobal(new Point(hero.hitbox.x,hero.hitbox.y)));
				if (playMode == "play" && !thrust) {
					
					// ACTIVATE HERO SWITCH-FLIPPING CAPABILITIES IN TESTING MODE!
					if (testingMode) {
						for(var i:int=0;i<swcArray.length;i++){
							if(hero.hitbox.hitTestObject(swcArray[i])){
								swcArray[i].flipSwitch(myLevel,myArray);
								break;
							}
						}
					}else {
						thrustTween = new Tween(myStick, "scaleY", None.easeNone, 1, 2.5, 12);
						thrust = true;
						//thrustTween.rewind();
						thrustTween.start();
						thrustTween.addEventListener(TweenEvent.MOTION_FINISH, fullThrust);
					}
				}
			}

		}
		public function keyUpHandler(event:KeyboardEvent) {
			if (event.keyCode==37) {
				left=false;
			}
			if (event.keyCode==38) {
				up=false;
			}
			if (event.keyCode==39) {
				right=false;
			}
			if (event.keyCode==40) {
				down=false;
			}
			if (event.keyCode==32) {
				space=false;
			}
			/*
			if (event.keyCode==68) {
				dee=false;
			}*/
		}
	}
}