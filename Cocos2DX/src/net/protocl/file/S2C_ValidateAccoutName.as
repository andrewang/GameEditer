package net.protocl.file{	import net.protocl.MyByteArray;	import net.protocl.MessageBase;	import net.protocl.IMessage;	public class S2C_ValidateAccoutName extends MessageBase implements IMessage	{		public var result:int = 0;		public function S2C_ValidateAccoutName()		{			super(ProtoclId.S2C_ValidateAccoutName);		}		//打包函数		public function encode():MyByteArray		{			var bytes:MyByteArray = new MyByteArray();			encodeInt32(bytes,result);			return bytes;		}		//解包函数		public function decode(bytes:MyByteArray):void		{			result = decodeInt32(bytes);		}		//打印函数		override public function getString(func,p:String="")		{			func(p + "{");			p += "	";			func(p + "result:" + result);			p = p.slice(1,p.length);			func(p + "}");		}	}}