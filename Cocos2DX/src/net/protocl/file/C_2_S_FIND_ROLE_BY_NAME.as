package net.protocl.file{	import net.protocl.MyByteArray;	import net.protocl.MessageBase;	import net.protocl.IMessage;	public class C_2_S_FIND_ROLE_BY_NAME extends MessageBase implements IMessage	{		public var name:String = "";		public function C_2_S_FIND_ROLE_BY_NAME()		{			super(ProtoclId.C_2_S_FIND_ROLE_BY_NAME);		}		//打包函数		public function encode():MyByteArray		{			var bytes:MyByteArray = new MyByteArray();			encodeStringLength(bytes,name,32);			return bytes;		}		//解包函数		public function decode(bytes:MyByteArray):void		{			name = decodeStringLength(bytes,32);		}		//打印函数		override public function getString(func,p:String="")		{			func(p + "{");			p += "	";			func(p + "name:" + name);			p = p.slice(1,p.length);			func(p + "}");		}	}}