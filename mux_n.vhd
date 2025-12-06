library ieee;

entity mux_n is 
	generic (dataSize: natural := 64);
	port(
		ino  : in bit_vector(dataSize-1 downto 0);
		in1  : in bit_vector(dataSize-1 downto 0);
		sel  : in bit;
		dOut : out bit_vector(dataSize-1 downto 0)
	);
end entity mux_n;

architecture arch_mux_n of mux_n is
	begin 
	with sel select 
		dOut <= ino when '0',
		        in1 when '1',
		        (others => '0') when others;
end architecture arch_mux_n;

