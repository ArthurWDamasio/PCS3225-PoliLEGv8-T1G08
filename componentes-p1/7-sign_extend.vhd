
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

entity sign_extend is
    generic (
        dataISize       : natural := 32; -- Tamanho do dado de entrada [cite: 226]
        dataOSize       : natural := 64; -- Tamanho do dado de saida [cite: 227]
        dataMaxPosition : natural := 5   -- Bits para definir as posicoes (log2(dataISize)) [cite: 229]
    );
    port(
        inData      : in bit_vector(dataISize-1 downto 0);       -- Vetor de entrada
        inDataStart : in bit_vector(dataMaxPosition-1 downto 0); -- Posicao do bit mais significativo (sinal) [cite: 238]
        inDataEnd   : in bit_vector(dataMaxPosition-1 downto 0); -- Posicao do bit menos significativo [cite: 242]
        outData     : out bit_vector(dataOSize-1 downto 0)       -- Vetor de saida estendido [cite: 246]
    );
end entity sign_extend;

architecture behavioral of sign_extend is
begin
    process(inData, inDataStart, inDataEnd)
        -- Variaveis auxiliares para manipulacao dos indices como inteiros
        variable idx_start : integer;
        variable idx_end   : integer;
        variable sign_bit  : bit;
        variable v_out     : bit_vector(dataOSize-1 downto 0);
        variable width     : integer;
    begin
        -- Conversao dos vetores de posicao para inteiros
        idx_start := to_integer(unsigned(inDataStart));
        idx_end   := to_integer(unsigned(inDataEnd));
        
        -- Identificacao do bit de sinal na posicao indicada por inDataStart
        sign_bit := inData(idx_start);

        -- Calculo da largura do dado util a ser copiado
        width := idx_start - idx_end + 1;

        -- Loop para construcao do vetor de saida
        for i in 0 to dataOSize-1 loop
            if i < width then
                -- Copia os bits uteis do intervalo [inDataEnd, inDataStart] para os LSBs da saida
                v_out(i) := inData(idx_end + i);
            else
                -- Preenche o restante dos bits superiores com o bit de sinal (extensao)
                v_out(i) := sign_bit;
            end if;
        end loop;

        -- Atribuicao do resultado a porta de saida
        outData <= v_out;
        
    end process;
end architecture behavioral;