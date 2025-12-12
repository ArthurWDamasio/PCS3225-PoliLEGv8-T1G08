------------------------------------------------------------
-- Andre Saliba     NUSP: 15439911   Turma: 1 Grupo:T1G08 --
-- Arthur Damasio   NUSP: 15635138   Turma: 1 Grupo:T1G08 --
-- Joao Vitor Rocha NUSP: 15638465   Turma: 1 Grupo:T1G08 --
-- Henrique Falcao  NUSP: 15459010   Turma: 1 Grupo:T1G08 --
-- Pedro Beraldo    NUSP: 15484328   Turma: 1 Grupo:T1G08 --
-- Thiago Medeiros  NUSP: 15651404   Turma: 1 Grupo:T1G08 --
------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_polilegv8 is
end entity tb_polilegv8;

architecture behavioral of tb_polilegv8 is

    -- Componente do processador
    component polilegv8 is
        port (
            clock : in  bit;
            reset : in  bit
        );
    end component;

    -- Sinais de teste
    signal clk_tb   : bit := '0';
    signal rst_tb   : bit := '1';

    -- Constante do período do clock
    constant PERIODO_CLK : time := 20 ns; -- 50 MHz

begin

    -- Instância do processador
    DUT: polilegv8
        port map (
            clock => clk_tb,
            reset => rst_tb
        );

    -- Geração do clock
    process
    begin
        while now < 1000 ns loop
            clk_tb <= not clk_tb;
            wait for PERIODO_CLK / 2;
        end loop;
        wait;
    end process;

    process
    begin
        rst_tb <= '1';
        wait for 2 * PERIODO_CLK;
        rst_tb <= '0';
        wait;
    end process;

    -- Monitoramento de sinais internos 
    process (clk_tb)
    begin
        if falling_edge(clk_tb) then
            report "Tempo: " & time'image(now);
        end if;
    end process;

end architecture behavioral;