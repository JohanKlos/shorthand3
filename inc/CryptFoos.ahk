b64Encode( ByRef buf, bufLen )
{
	DllCall( "crypt32\CryptBinaryToStringA", "ptr", &buf, "UInt", bufLen, "Uint", 1 | 0x40000000, "Ptr", 0, "UInt*", outLen )
	VarSetCapacity( outBuf, outLen, 0 )
	DllCall( "crypt32\CryptBinaryToStringA", "ptr", &buf, "UInt", bufLen, "Uint", 1 | 0x40000000, "Ptr", &outBuf, "UInt*", outLen )
	return strget( &outBuf, outLen, "CP0" )
}

b64Decode( b64str, ByRef outBuf )
{
	DllCall( "crypt32\CryptStringToBinaryW", "ptr", &b64str, "UInt", 0, "Uint", 1, "Ptr", 0, "UInt*", outLen, "ptr", 0, "ptr", 0 )
	VarSetCapacity( outBuf, outLen, 0 )
	DllCall( "crypt32\CryptStringToBinaryW", "ptr", &b64str, "UInt", 0, "Uint", 1, "Ptr", &outBuf, "UInt*", outLen, "ptr", 0, "ptr", 0 )
	return outLen
}

b2a_hex( ByRef buf, bufLen )
{
	DllCall( "crypt32\CryptBinaryToStringA", "ptr", &buf, "UInt", bufLen, "Uint", 12 | 0x40000000, "Ptr", 0, "UInt*", outLen )
	VarSetCapacity( outBuf, outLen, 0 )
	DllCall( "crypt32\CryptBinaryToStringA", "ptr", &buf, "UInt", bufLen, "Uint", 12 | 0x40000000, "Ptr", &outBuf, "UInt*", outLen )
	return strget( &outBuf, outLen, "CP0" )
}

a2b_hex( b64str, ByRef outBuf )
{
	DllCall( "crypt32\CryptStringToBinaryW", "ptr", &b64str, "UInt", 0, "Uint", 12, "Ptr", 0, "UInt*", outLen, "ptr", 0, "ptr", 0 )
	VarSetCapacity( outBuf, outLen, 0 )
	DllCall( "crypt32\CryptStringToBinaryW", "ptr", &b64str, "UInt", 0, "Uint", 12, "Ptr", &outBuf, "UInt*", outLen, "ptr", 0, "ptr", 0 )
	return outLen
}

Free(byRef var)
{
  VarSetCapacity(var,0)
  return
}