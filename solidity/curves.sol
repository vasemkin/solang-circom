@program_id("GiM4xoMCQSCZNioTiALPSYHfhNGCEnKX16gKTK51JbXN")
interface curves {
	@selector([0xfb,0xde,0xc5,0x5f,0x02,0xf5,0x90,0x6a])
	function addition(bytes input) view external returns (bytes);
	@selector([0x03,0xad,0xbc,0x04,0x7b,0x3b,0x51,0x84])
	function multiplication(bytes input) view external returns (bytes);
	@selector([0xe6,0xa1,0xba,0x09,0x7c,0x24,0xf2,0xba])
	function pairing(bytes input) view external returns (bytes);
}
