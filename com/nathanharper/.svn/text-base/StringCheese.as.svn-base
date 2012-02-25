/*
This is just a class I've made to help format Strings,
because for some reason ActionScript 3 has no "trim" function.
I may add to it in the future.
*/
package com.nathanharper{
	public class StringCheese{
		public function StringCheese(){
		}
		
		//trims the string (gets rid of spaces at beginning and end
		static public function trim(str:String){
			return trimBack(trimFront(str));
		}
		
		//trim the front spaces
		static public function trimFront(str:String){
			if(str.charAt(0)==" ") return trimFront(str.substr(1));
			else return str;
		}
		
		//trim the end spaces
		static public function trimBack(str:String){
			if(str.charAt(str.length-1)==" ") return trimBack(str.substr(0,str.length-1));
			else return str;
		}
		
		//remove ALL spaces from string
		static public function removeSpaces(str:String) {
			if (str.length == 1) {
				if (str.charAt(0) == " ") return "";
				return str;
			}else {
				if (str.charAt(0) == " ") return removeSpaces(str.substr(1));
				return str.charAt(0).concat(removeSpaces(str.substr(1)));
			}
		}
	}
}