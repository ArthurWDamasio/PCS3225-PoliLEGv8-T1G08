library ieee;
use std.textio.all;

entity memoriaInstrucoes is
	generic (
		addressSize : natural : = 8 ;
		dataSize : natural : = 8 ;
		datFileName : string : = "memInstr_conteudo.dat"
	);
	port (
		addr : in bit_vector ( addressSize-1 downto 0 ) ;
		data : out bit_vector ( dataSize-1 downto 0 )
	);
end entity rom_arquivo_generica;

