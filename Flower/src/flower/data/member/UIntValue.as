package flower.data.member
{
	public class UIntValue extends Value
	{
		private var _events:Array;
		private var _value:* = 0;
		
		public function UIntValue(initValue:*=0)
		{
			if(initValue) {
				initValue = +initValue&~0;
				initValue = initValue<0?0:initValue;
				_value = initValue;
			}
		}
		
		override public function set value(val:*):void {
			val = +val&~0;
			val = val<0?0:val;
			if(_value == val) {
				return;
			}
			var old:* = _value;
			_value = val;
			if(!_events) {
				_events = [];
			}
			var list:Array = _events;
			for(var i:int = 0,len:int = list.length; i < len; i++) {
				if(list[i].del == false) {
					var listener:Function = list[i].listener;
					var thisObj:* = list[i].thisObject;
					if(list[i].once) {
						list[i].listener = null;
						list[i].thisObject = null;
						list[i].del = true;
					}
					listener.call(thisObj,_value,old);
				}
			}
			for(i = 0; i < list.length; i++) {
				if(list[i].del == true) {
					list.splice(i,1);
					i--;
				}
			}
		}
		
		override public function get value():* {
			return _value;
		}
		
		public function once(listener:Function,thisObject:*):void {
			this._addListener(listener,thisObject,true);
		}
		
		public function addListener(listener:Function,thisObject:*):void {
			this._addListener(listener,thisObject,false);
		}
		
		private function _addListener(listener:Function, thisObject:*,once:Boolean):void {
			if(!_events) {
				_events = [];
			}
			var list:Array = _events;
			for(var i:int = 0,len:int = list.length; i < len; i++) {
				if(list[i].listener == listener && list[i].thisObject == thisObject && list[i].del == false) {
					return;
				}
			}
			list.push({
				"listener":listener,
				"thisObject":thisObject,
				"once":once,
				"del":false
			});
		}
		
		public function removeListener(listener:Function,thisObject:*):void {
			if(!_events) {
				return;
			}
			var list:Array = _events;
			for(var i:int = 0,len:int = list.length; i < len; i++) {
				if(list[i].listener == listener && list[i].thisObject == thisObject && list[i].del == false) {
					list[i].listener = null;
					list[i].thisObject = null;
					list[i].del = true;
					break;
				}
			}
		}
		
		public function removeAllListener():void {
			_events = [];
		}
		
		public function dispose():void {
			_events = null;
		}
		
		
		private static var pool:Vector.<UIntValue> = new Vector.<UIntValue>();
		public static function create(initValue:*=null):UIntValue {
			var value:UIntValue;
			if(pool.length) {
				value = pool.pop();
				value._events = [];
				initValue = +initValue&~0;
				initValue = initValue<0?0:initValue;
				value._value = initValue;
			} else {
				value = new UIntValue(initValue);
			}
			return value;
		}
		
		public static function release(value:UIntValue):void {
			value.dispose();
			pool.push(value);
		}
	}
}