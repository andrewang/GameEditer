package net.protocl.file{	import net.protocl.MyByteArray;	import net.protocl.MessageBase;	import net.protocl.IMessage;	public class C_2_S_1V1_LOAD_COMPLETE extends MessageBase implements IMessage	{		public function C_2_S_1V1_LOAD_COMPLETE()		{			super(ProtoclId.C_2_S_1V1_LOAD_COMPLETE);		}		//打包函数		public function encode():MyByteArray		{			var bytes:MyByteArray = new MyByteArray();			return bytes;		}		//解包函数		public function decode(bytes:MyByteArray):void		{		}		//打印函数		override public function getString(func,p:String="")		{			func(p + "{");			p += "	";			p = p.slice(1,p.length);			func(p + "}");		}	}}