------------------------------------------------------------
-- Andre Saliba     NUSP: 15439911   Turma: 1 Grupo:T1G08 --
-- Arthur Damasio   NUSP: 15635138   Turma: 1 Grupo:T1G08 --
-- Joao Vitor Rocha NUSP: 15638465   Turma: 1 Grupo:T1G08 --
-- Henrique Falcao  NUSP: 15459010   Turma: 1 Grupo:T1G08 --
-- Pedro Beraldo    NUSP: 15484328   Turma: 1 Grupo:T1G08 --
-- Thiago Medeiros  NUSP: 15651404   Turma: 1 Grupo:T1G08 --
------------------------------------------------------------

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
