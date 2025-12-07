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

entity ula1bit is 
    port(
        a         : in bit;
        b         : in bit;
        cin       : in bit;
        ainvert   : in bit;
        binvert   : in bit;
        operation : in bit_vector(1 downto 0);
        result    : out bit;
        cout      : out bit;
        overflow  : out bit 
    );
end entity ula1bit;

entity fulladder is
  port (
    a, b, cin : in bit;
    s, cout   : out bit
  );
end entity fulladder;

architecture structural of fulladder is
  signal axorb: bit;
begin
  axorb <= a xor b;
  s     <= axorb xor cin;
  cout  <= (axorb and cin) or (a and b);
end architecture;

-------------------------------------------------------
-- Arquitetura da ULA de 1 Bit
-------------------------------------------------------
architecture structural of ula1bit is 

    -- Declaração do componente somador
    component fulladder is
        port (
            a, b, cin : in bit;
            s, cout   : out bit
        );
    end component;

    -- Sinais internos para os dados invertidos (ou não)
    signal a_mux : bit;
    signal b_mux : bit;

    -- Sinais para os resultados das operações
    signal res_and : bit;
    signal res_or  : bit;
    signal res_add : bit;
    
    -- Sinal interno para o carry out
    signal cout_internal : bit;

begin

    a_mux <= not a when ainvert = '1' else a;
    b_mux <= not b when binvert = '1' else b;

    res_and <= a_mux and b_mux;
    res_or  <= a_mux or b_mux;


    inst_adder: fulladder
        port map (
            a    => a_mux,
            b    => b_mux,
            cin  => cin,
            s    => res_add,
            cout => cout_internal
        );

    -- Multiplexador de Saída (Seleciona o resultado baseado em 'operation')
    -- 00: AND 
    -- 01: OR  
    -- 10: ADD (Soma) 
    -- 11: Pass B (Passagem direta de B invertido ou não) 
    with operation select 
        result <= res_and when "00",
                  res_or  when "01",
                  res_add when "10",
                  b_mux   when "11";

    -- Saídas de Controle
    cout <= cout_internal;
    
    -- Detecção de Overflow
    -- Para uma fatia de 1 bit (considerando que seja o MSB), overflow é Cin XOR Cout.
    overflow <= cin xor cout_internal;

end architecture structural;
