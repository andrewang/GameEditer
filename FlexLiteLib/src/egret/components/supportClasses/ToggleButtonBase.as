package egret.components.supportClasses
{
	
	import flash.events.Event;
	
	import egret.core.ns_egret;
	import egret.events.UIEvent;
	
	use namespace ns_egret;
	
	[Event(name="change", type="flash.events.Event")]
	
	[EXML(show="false")]
	
	[SkinState("up")]
	[SkinState("over")]
	[SkinState("down")]
	[SkinState("disabled")]
	[SkinState("upAndSelected")]
	[SkinState("overAndSelected")]
	[SkinState("downAndSelected")]
	[SkinState("disabledAndSelected")]
	
	/**
	 * 切换按钮组件基类
	 * @author dom
	 */	
	public class ToggleButtonBase extends ButtonBase
	{
		public function ToggleButtonBase()
		{
			super();
		}
		
		private var _selected:Boolean;
		/**
		 * 按钮处于按下状态时为 true，而按钮处于弹起状态时为 false。
		 */		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function set selected(value:Boolean):void
		{
			if (value == _selected)
				return;
			
			_selected = value;            
			dispatchEvent(new UIEvent(UIEvent.VALUE_COMMIT));
			invalidateSkinState();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function getCurrentSkinState():String
		{
			if (!selected)
				return super.getCurrentSkinState();
			else
				return super.getCurrentSkinState() + "AndSelected";
		}
		/**
		 * 是否根据鼠标事件自动变换选中状态,默认true。
		 */		
		ns_egret var autoSelected:Boolean = true;
		/**
		 * @inheritDoc
		 */
		override protected function buttonReleased():void
		{
			super.buttonReleased();
			if(!autoSelected||!enabled)
				return;
			selected = !selected;
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
	
}
