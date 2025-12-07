
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
        dataSize    : natural := 8;
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

    -- Definição do tamanho da memória com base no addressSize
    type mem_t is array (0 to (2**addressSize)-1) of bit_vector(dataSize-1 downto 0);

    impure function inicializa(nome_do_arquivo : in string) return mem_t is
        file     arquivo  : text open read_mode is nome_do_arquivo;
        variable linha    : line;
        variable temp_bv  : bit_vector(dataSize-1 downto 0);
        variable temp_mem : mem_t;
    begin
        -- Limpa a memória antes de carregar
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

    -- Sinais internos
    signal mem      : mem_t := inicializa(datFileName); -- Inicialização via arquivo
    signal addr_int : natural;

begin 

    -- Conversão do endereço (bit_vector -> integer)
    addr_int <= to_integer(unsigned(addr));

    wrt: process(clock)
    begin
        if (clock='1' and clock'event) then -- Borda de subida
            if (wr='1') then                -- Enable de escrita
                mem(addr_int) <= data_i;
            end if;
        end if;
    end process;

    data_o <= mem(addr_int);

end architecture arch_memoriaDados;