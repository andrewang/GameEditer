package egret.effects.animation
{
	/**
	 * RepeatBehavior 类定义用于与 Animate 和 Animation 类的 repeatBehavior 属性一起使用的常量。
	 */
	public class RepeatBehavior
	{
		/**
		 * 指定在每个迭代上重复的动画在前进方向上的进度。
		 */
		public static const LOOP:String = "loop";
		
		/**
		 * 指定重复动画应该在每个迭代上倒转方向。
		 * 例如，反向动画在偶数迭代上向前播放，而在奇数迭代上反向播放。
		 */
		public static const REVERSE:String = "reverse";
	}
}