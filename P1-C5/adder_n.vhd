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

entity adder_n is
    generic (
        dataSize: natural := 64
    );
    port(
        ino  : in  bit_vector(dataSize-1 downto 0);
        in1  : in  bit_vector(dataSize-1 downto 0);
        sum  : out bit_vector(dataSize-1 downto 0);
        cout : out bit
    );
end entity adder_n;

architecture structural of adder_n is

    component fullAdder is
        port (
            a, b, cin : in bit;
            s, cout   : out bit
        );
    end component fullAdder;

    signal c : bit_vector(dataSize downto 0);

begin

    c(0) <= '0';

    gen_adder: for i in 0 to dataSize-1 generate
        inst_fulladder: fullAdder
            port map (
                a    => ino(i),
                b    => in1(i),
                cin  => c(i),
                s    => sum(i),
                cout => c(i+1)
            );
    end generate;

    cout <= c(dataSize);

end architecture structural;
