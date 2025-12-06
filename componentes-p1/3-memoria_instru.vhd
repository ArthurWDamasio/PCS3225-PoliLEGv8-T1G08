library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity memoriaInstrucoes is
    generic (
        addressSize : natural := 8; -- Corrigido: removido espaço em ": ="
        dataSize    : natural := 8; -- Corrigido: removido espaço em ": ="
        datFileName : string  := "memInstr_conteudo.dat" -- Corrigido: removido espaço em ": ="
    );
    port (
        addr : in  bit_vector(addressSize-1 downto 0);
        data : out bit_vector(dataSize-1 downto 0)
    );
end entity memoriaInstrucoes; -- Corrigido: nome deve bater com a declaração

architecture mem_instru of memoriaInstrucoes is
    
    -- 1. Definição do Tipo deve vir ANTES da função
    -- O tamanho agora é calculado com base no addressSize (2^N - 1)
    type mem_t is array (0 to (2**addressSize)-1) of bit_vector(dataSize-1 downto 0);

    -- 2. Função de Inicialização
    impure function inicializa(nome_do_arquivo : in string) return mem_t is
        file     arquivo  : text open read_mode is nome_do_arquivo;
        variable linha    : line;
        variable temp_bv  : bit_vector(dataSize-1 downto 0);
        variable temp_mem : mem_t;
    begin
        -- Inicializa a memória com zeros (boa prática)
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

    -- 3. Declaração dos Sinais
    signal mem      : mem_t := inicializa(datFileName);
    signal addr_int : natural; -- 'natural' é mais simples que integer range aqui

begin 
    -- 4. Conversão correta usando numeric_bit
    -- bit_vector -> unsigned -> integer
    addr_int <= to_integer(unsigned(addr));
    
    -- Acesso à memória
    data <= mem(addr_int);

end architecture mem_instru;