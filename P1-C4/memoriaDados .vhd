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

entity memoriaDados is
    generic (
        addressSize : natural := 8;
        dataSize    : natural := 64;
        datFileName : string  := "memDados_conteudo_inicial.dat"
    );
    port (
        clock  : in  bit;
        wr     : in  bit;
        addr   : in  bit_vector(addressSize-1 downto 0);
        data_i : in  bit_vector(dataSize-1 downto 0);
        data_o : out bit_vector(dataSize-1 downto 0)
    );
end entity memoriaDados;

architecture arch_memoriaDados of memoriaDados is

    type mem_t is array (0 to (2**addressSize)-1) of bit_vector(dataSize-1 downto 0);

    impure function inicializa(nome_do_arquivo : in string) return mem_t is
        file     arquivo  : text open read_mode is nome_do_arquivo;
        variable linha    : line;
        variable temp_byte: bit_vector(7 downto 0); -- Variable to read 8 bits at a time
        variable temp_mem : mem_t;
    begin
        -- Clear memory
        temp_mem := (others => (others => '0'));
        
        for i in temp_mem'range loop
            -- We need to read 8 lines to build 1 64-bit word
            -- Byte 7 (MSB)
            if not endfile(arquivo) then readline(arquivo, linha); read(linha, temp_byte); temp_mem(i)(63 downto 56) := temp_byte; end if;
            -- Byte 6
            if not endfile(arquivo) then readline(arquivo, linha); read(linha, temp_byte); temp_mem(i)(55 downto 48) := temp_byte; end if;
            -- Byte 5
            if not endfile(arquivo) then readline(arquivo, linha); read(linha, temp_byte); temp_mem(i)(47 downto 40) := temp_byte; end if;
            -- Byte 4
            if not endfile(arquivo) then readline(arquivo, linha); read(linha, temp_byte); temp_mem(i)(39 downto 32) := temp_byte; end if;
            -- Byte 3
            if not endfile(arquivo) then readline(arquivo, linha); read(linha, temp_byte); temp_mem(i)(31 downto 24) := temp_byte; end if;
            -- Byte 2
            if not endfile(arquivo) then readline(arquivo, linha); read(linha, temp_byte); temp_mem(i)(23 downto 16) := temp_byte; end if;
            -- Byte 1
            if not endfile(arquivo) then readline(arquivo, linha); read(linha, temp_byte); temp_mem(i)(15 downto 8)  := temp_byte; end if;
            -- Byte 0 (LSB)
            if not endfile(arquivo) then readline(arquivo, linha); read(linha, temp_byte); temp_mem(i)(7 downto 0)   := temp_byte; end if;
        end loop;
        return temp_mem;
    end function;

    -- Sinais internos
    signal mem      : mem_t := inicializa(datFileName); 
    signal addr_int : natural;

begin 

    -- Conversão do endereço (bit_vector -> integer)
    addr_int <= to_integer(unsigned(addr));

    wrt: process(clock)
    begin
        if (clock='1' and clock'event) then 
            if (wr='1') then                
                mem(addr_int) <= data_i;
            end if;
        end if;
    end process;

    data_o <= mem(addr_int);

end architecture arch_memoriaDados;