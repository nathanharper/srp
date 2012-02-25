/*
Here be the level editor for Stealth Robot Programmer!

Item Key:

A0 = Lava
A1 = Wall
A2 = Hero
A3 = Exit
A5 = Turret

C0 = Green Switch
C1 = Blue Switch
C2 = Pink Switch

B0 = Green Force Field
B2 = Blue Force Field
B4 = Pink Force Field
B1 = Green FF OFF
B3 = Blue FF OFF
B5 = Pink FF OFF

D0 = Robot (Line-Walker)
D1 = Robot (Random-Walker)
E0 = Robot (Cycle-Walker)

Directions: U,R,D,L

Hash Format:
XXX Mode Code

for each item on the map...
XX Map Index
XX LibItem ID
XX Partner Index
X Direction
*/
package{
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.geom.Point;
	
	public class SRPEditor extends MovieClip{
		
		private var currItem:LibItem=null;
		private var myArray:Array=new Array();
		
		private var alphabet:String="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		
		//the size variables for the map
		private var levelWidth=20;
		private var levelHeight=18;
		private var blockWidth=20;
		
		//start positions for all LibItems
		private var lavaStart:Point=new Point(475,45);
		private var wallStart:Point=new Point(505,45);
		private var heroStart:Point=new Point(475,70);
		private var exitStart:Point=new Point(505,70);
		private var robotStart:Point=new Point(475,95);
		private var turretStart:Point=new Point(505,95);
		private var ff0Start:Point=new Point(475,120);
		private var swc0Start:Point=new Point(505,120);
		private var ff1Start:Point=new Point(475,145);
		private var swc1Start:Point=new Point(505,145);
		private var ff2Start:Point=new Point(475,170);
		private var swc2Start:Point=new Point(505,170);
		
		public function SRPEditor(){
			makeArray();
			makeIcons();
			
			prompter.visible=false;
			roboswitch.buttonMode=true;
			rotator.buttonMode=true;
			getcode.buttonMode=true;
			onoff.buttonMode=true;
			modeButton.buttonMode=true;
			roboswitch.addEventListener(MouseEvent.CLICK,roboMode);
			modeButton.addEventListener(MouseEvent.CLICK,switchMode);
			rotator.addEventListener(MouseEvent.CLICK,rotateItem);
			getcode.addEventListener(MouseEvent.CLICK,getCode);
			onoff.addEventListener(MouseEvent.CLICK,onOff);
		}
		
		//initialize the array storing lib items placed on the map
		public function makeArray(){
			for(var i:int=0;i<levelHeight;i++){
				myArray.push(new Array(levelWidth));
			}
		}
		
		//set up the LibItem icons
		public function makeIcons(){
			makeIconsHelper("A0");
			makeIconsHelper("A1");
			makeIconsHelper("A2");
			makeIconsHelper("A3");
			makeIconsHelper("D0");
			makeIconsHelper("A5");
			makeIconsHelper("B0");
			makeIconsHelper("C0");
			makeIconsHelper("B2");
			makeIconsHelper("C1");
			makeIconsHelper("B4");
			makeIconsHelper("C2");
		}
		public function makeIconsHelper(type:String){
			var itm:LibItem=new LibItem(type);
			var point:Point;
			
			if(type=="A0") point=lavaStart;
			if(type=="A1") point=wallStart;
			if(type=="A2") point=heroStart;
			if(type=="A3") point=exitStart;
			if(type=="D0") point=robotStart;
			if(type=="A5") point=turretStart;
			if(type=="B0") point=ff0Start;
			if(type=="C0") point=swc0Start;
			if(type=="B2") point=ff1Start;
			if(type=="C1") point=swc1Start;
			if(type=="B4") point=ff2Start;
			if(type=="C2") point=swc2Start;
			
			itm.x=point.x;
			itm.y=point.y;
			addChild(itm);
			itm.addEventListener(MouseEvent.MOUSE_DOWN,clickEvent);
		}
		
		//handle clicking on LibItems
		public function clickEvent(event:MouseEvent){
			if(!prompter.visible){
				event.currentTarget.removeEventListener(MouseEvent.MOUSE_DOWN,clickEvent);
				
				//set currItem to the LibItem just clicked
				if(currItem!=null) currItem.selector.visible=false;
				event.currentTarget.selector.visible=true;
				currItem=event.currentTarget as LibItem;
	
				var index:Point=currItem.getSlot();
				if(index!=null){
					myArray[index.y][index.x]=null;
				}else{
					//do not make more heroes.
					if(currItem.currentLabel!="A2"){
						makeIconsHelper(currItem.currentLabel);
					}
				}
				
				setChildIndex(currItem,numChildren-1);
				currItem.startDrag();
				currItem.addEventListener(MouseEvent.MOUSE_UP, releaseEvent);
			}else if(event.currentTarget.getSlot()!=null){
				if(prompter.currentLabel=="selectItem"||(prompter.currentLabel=="selectSwitch"&&event.currentTarget.currentLabel.charAt(0)=="C")){
					currItem.setPartner(event.currentTarget.getSlot());
					prompter.visible=false;
				}
			}
		}
		
		//handle release of mouse from a LibItem
		public function releaseEvent(event:MouseEvent){
			var itm:LibItem=event.currentTarget as LibItem;
			itm.stopDrag();
			itm.removeEventListener(MouseEvent.MOUSE_UP, releaseEvent);
			
			if(itm.x>blockWidth&&itm.x<blockWidth+levelWidth*blockWidth&&itm.y>blockWidth&&itm.y<blockWidth+levelHeight*blockWidth){
				var arrIndex:Point=new Point(Math.floor((itm.x-blockWidth)/blockWidth),levelHeight-1-Math.floor((itm.y-blockWidth)/blockWidth));
				itm.setSlot(arrIndex);
				itm.x=blockWidth+(blockWidth/2)+(arrIndex.x*blockWidth);
				itm.y=blockWidth*(levelHeight-arrIndex.y)+(blockWidth/2);
				if(myArray[arrIndex.y][arrIndex.x] is LibItem) {
					if((removeChild(myArray[arrIndex.y][arrIndex.x]) as LibItem).currentLabel=="A2"){
						makeIconsHelper("A2");
					}
				}
				myArray[arrIndex.y][arrIndex.x]=itm;
				itm.addEventListener(MouseEvent.MOUSE_DOWN,clickEvent);
				
				var myFirst:String=itm.currentLabel.charAt(0);
				if((myFirst=="B"&&modeButton.currentLabel=="SWC")||myFirst=="E"){
					if(itm.currentLabel=="E0") prompter.gotoAndStop("selectItem");
					else if(myFirst=="B") prompter.gotoAndStop("selectSwitch");
					prompter.visible=true;
				}
			} else{
				//make a new hero
				if(itm.currentLabel=="A2"){
					makeIconsHelper("A2");
				}
				currItem=null;
				removeChild(itm);
			}
		}
		
		//function called when "rotator" is clicked. rotates currItem clockwise.
		public function rotateItem(event:MouseEvent){
			if(currItem!=null){
				currItem.rotate();
			}
		}
		
		//switch game modes when modeButton is clicked
		public function switchMode(event:MouseEvent){
			if(modeButton.currentLabel=="CLR") modeButton.gotoAndStop("SWC");
			else {
				modeButton.gotoAndStop("CLR");
				if(prompter.visible&&prompter.currentLabel=="selectSwitch") prompter.visible=false;
			}
		}
		
		//turns force field emitters on or off
		public function onOff(event:MouseEvent){
			if(currItem!=null){
				if(currItem.currentLabel.charAt(0)=="B"){
					var temp:int=parseInt(currItem.currentLabel.charAt(1));
					if(temp%2==0) temp+=1;
					else temp-=1;
					currItem.gotoAndStop("B".concat(temp));
				}
			}
		}
		
		//cycles between types of robots
		public function roboMode(event:MouseEvent){
			if(currItem!=null){
				var myType:String=currItem.currentLabel.charAt(0);
				if(myType=="D"||myType=="E"){
					if(currItem.currentLabel=="D0") currItem.gotoAndStop("D1");
					else if(currItem.currentLabel=="D1"){
						currItem.gotoAndStop("E0");
						prompter.gotoAndStop("selectItem");
						prompter.visible=true;
					}
					else if(currItem.currentLabel=="E0"){
						currItem.gotoAndStop("D0");
						prompter.visible=false;
					}
				}
			}
		}
		
		//function called when "getcode" is clicked. Opens a window containing level hash
		public function getCode(event:MouseEvent){
			
			//first, create the hash string.
			var hash:String=modeButton.currentLabel;
			for(var i:int=0;i<levelHeight;i++){
				for(var j:int=0;j<levelWidth;j++){
					var itm:LibItem;
					if(myArray[i][j] is LibItem){
						itm=myArray[i][j];
						var partner:String="$$";
						if(itm.getPartner()!=null) partner=alphabet.charAt(itm.getPartner().x).concat(alphabet.charAt(itm.getPartner().y));
						//coordinates are stored XY
						hash=hash.concat(alphabet.charAt(j),alphabet.charAt(i),itm.currentLabel,partner,itm.getDirection());
					}
				}
			}
			
			//display the Hash
			var myHash:HashDisplay=new HashDisplay();
			var hashText:TextField=new TextField();
			hashText.text=hash;
			hashText.selectable=true;
			hashText.x=300;
			hashText.y=150;
			myHash.addChild(hashText);
			myHash.x=0;
			myHash.y=0;
			addChild(myHash);
			myHash.returner.addEventListener(MouseEvent.CLICK,returnFunc);
		}
		
		//return from hash display screen
		public function returnFunc(event:MouseEvent){
			event.currentTarget.removeEventListener(MouseEvent.CLICK,returnFunc);
			removeChild(event.currentTarget.parent);
		}
	}
}