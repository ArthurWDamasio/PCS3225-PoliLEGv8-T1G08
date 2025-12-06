library ieee;
entity two_left_shifts is 
	generic(
		dataSize: natural := 64
	);
	port(
		input: in bit_vector(dataSize-1 downto 0);
		output: out bit_vector(dataSize-1 downto 0)
	);
end entity two_left_shifts;

architecture arch_two_left_shift of two_left_shifts is 
	signal data  : bit_vector(dataSize-1 downto 0);
	begin
	data <= input sll 2;
	output <= data;
end architecture arch_two_left_shift;
