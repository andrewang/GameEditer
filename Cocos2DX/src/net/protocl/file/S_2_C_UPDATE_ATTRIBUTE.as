package net.protocl.file{	import net.protocl.MyByteArray;	import net.protocl.MessageBase;	import net.protocl.IMessage;	public class S_2_C_UPDATE_ATTRIBUTE extends MessageBase implements IMessage	{		public var forceValue:int = 0;		public var atrrTypeInfos:Vector.<S_2_C_UPDATE_ATTRIBUTEInfo> = new Vector.<S_2_C_UPDATE_ATTRIBUTEInfo>;		public function S_2_C_UPDATE_ATTRIBUTE()		{			super(ProtoclId.S_2_C_UPDATE_ATTRIBUTE);		}		//打包函数		public function encode():MyByteArray		{			var bytes:MyByteArray = new MyByteArray();			encodeInt32(bytes,forceValue);			encodeRepeatMessage(bytes,atrrTypeInfos);			return bytes;		}		//解包函数		public function decode(bytes:MyByteArray):void		{			forceValue = decodeInt32(bytes);			decodeRepeatMessage(bytes,S_2_C_UPDATE_ATTRIBUTEInfo,atrrTypeInfos);		}		//打印函数		override public function getString(func,p:String="")		{			func(p + "{");			p += "	";			func(p + "forceValue:" + forceValue);			func(p + "[");			for(var i:int = 0; i < atrrTypeInfos.length; i++)			{				this.atrrTypeInfos[i].getString(func,p + "	");			}			func(p + "]");			p = p.slice(1,p.length);			func(p + "}");		}	}}