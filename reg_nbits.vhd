library ieee;

entity reg is 
	generic (dataSize: natural := 64);
	port (
		clock: in bit;
		reset: in bit;
		enable: in bit;
		d: in bit_vector(dataSize-1 downto 0);
		q: out bit_vector(dataSize-1 downto 0)
	);
end entity reg;

architecture arch_reg of reg is 
	signal data : bit_vector(dataSize - 1 downto 0);
	begin 
		process(clock, reset)
		begin
		if reset = '1' then 
			data <= (others => '0');
		elsif (clock'event and clock='1') then 
			if enable = '1' then
				data <= d;
			end if;
		end if;
		end process;
	q <= data;
end architecture; 

-- Para a implementacao deste registrador nos inspiramos nos registradores da AF0 