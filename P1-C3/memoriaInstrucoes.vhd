------------------------------------------------------------
-- Andre Saliba     NUSP: 15439911   Turma: 1 Grupo:T1G08 --
-- Arthur Damasio   NUSP: 15635138   Turma: 1 Grupo:T1G08 --
-- Joao Vitor Rocha NUSP: 15638465   Turma: 1 Grupo:T1G08 --
-- Henrique Falcao  NUSP: 15459010   Turma: 1 Grupo:T1G08 --
-- Pedro Beraldo    NUSP: 15484328   Turma: 1 Grupo:T1G08 --
-- Thiago Medeiros  NUSP: 15651404   Turma: 1 Grupo:T1G08 --
------------------------------------------------------------

library ieee;

use ieee.numeric_bit.all;
use std.textio.all;

entity memoriaInstrucoes is
    generic (
        addressSize : natural := 8;
        dataSize    : natural := 8; 
        datFileName : string  := "memInstr_conteudo.dat" 
    );
    port (
        addr : in  bit_vector(addressSize-1 downto 0);
        data : out bit_vector(dataSize-1 downto 0)
    );
end entity memoriaInstrucoes;

architecture mem_instru of memoriaInstrucoes is
    
    type mem_t is array (0 to 63) of bit_vector(dataSize-1 downto 0);

    impure function inicializa(nome_do_arquivo : in string) return mem_t is
        file     arquivo  : text open read_mode is nome_do_arquivo;
        variable linha    : line;
        variable temp_bv  : bit_vector(dataSize-1 downto 0);
        variable temp_mem : mem_t;
    begin
        temp_mem := (others => (others => '0'));
        
        for i in temp_mem'range loop
            if not endfile(arquivo) then
                readline(arquivo, linha);
                read(linha, temp_bv);
                temp_mem(i) := temp_bv;
            end if;
        end loop;
        return temp_mem;
    end function;

    signal mem      : mem_t := inicializa(datFileName);
    signal addr_int : natural; 

begin 
    addr_int <= to_integer(unsigned(addr));
    
    -- Acesso à memória
    data <= mem(addr_int);

end architecture mem_instru;