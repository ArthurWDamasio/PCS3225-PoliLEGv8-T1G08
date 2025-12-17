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

entity tb_adder_n is
end entity tb_adder_n;

architecture testbench of tb_adder_n is
    -- Componente sob teste (UUT)
    component adder_n is
        generic (
            dataSize: natural := 64
        );
        port(
            ino  : in  bit_vector(dataSize-1 downto 0);
            in1  : in  bit_vector(dataSize-1 downto 0);
            sum  : out bit_vector(dataSize-1 downto 0);
            cout : out bit
        );
    end component;

    constant TIME_DELTA : time := 10 ns;
    constant N          : natural := 64;

    -- Constantes auxiliares
    constant C_ZERO     : bit_vector(N-1 downto 0) := (others => '0');
    constant C_MAX      : bit_vector(N-1 downto 0) := (others => '1');
    constant C_ALT_A    : bit_vector(N-1 downto 0) := x"AAAAAAAAAAAAAAAA";
    constant C_ALT_5    : bit_vector(N-1 downto 0) := x"5555555555555555";
    
    signal simulando : bit := '1';
    signal ino       : bit_vector(N-1 downto 0) := (others => '0');
    signal in1       : bit_vector(N-1 downto 0) := (others => '0');
    signal sum       : bit_vector(N-1 downto 0);
    signal cout      : bit;

begin
    -- Instancia do Somador
    UUT: adder_n
        generic map ( dataSize => N )
        port map (
            ino  => ino,
            in1  => in1,
            sum  => sum,
            cout => cout
        );

    processo_estimulo : process
        -- Variavel para criar o valor '1' em 64 bits
        variable v_one : bit_vector(N-1 downto 0);
    begin
        v_one := (others => '0');
        v_one(0) := '1';

        report ">>> INICIANDO TESTES DO SOMADOR (64 bits) <<<";
        
        -- =========================================================
        -- Cenario 1: Identidade (0+0 e X+0)
        -- =========================================================
        ino <= C_ZERO; in1 <= C_ZERO;
        wait for TIME_DELTA;
        assert sum = C_ZERO and cout = '0' 
            report "Falha Cenario 1.1: 0+0 falhou" severity error;

        ino <= C_ALT_A; in1 <= C_ZERO;
        wait for TIME_DELTA;
        assert sum = C_ALT_A and cout = '0'
            report "Falha Cenario 1.2: X+0 falhou" severity error;

        report "Cenario 1: Identidade -> SUCESSO" severity note;

        -- =========================================================
        -- Cenario 2: Incremento Unitario (X+1)
        -- =========================================================
        ino <= C_ZERO; in1 <= v_one;
        wait for TIME_DELTA;
        assert sum = v_one and cout = '0'
            report "Falha Cenario 2: 0+1 falhou" severity error;
            
        report "Cenario 2: Incremento -> SUCESSO" severity note;

        -- =========================================================
        -- Cenario 3: Padroes Complementares (Integridade)
        -- =========================================================
        ino <= C_ALT_A; in1 <= C_ALT_5;
        wait for TIME_DELTA;
        assert sum = C_MAX and cout = '0'
            report "Falha Cenario 3: Padroes alternados falhou" severity error;

        report "Cenario 3: Padroes Complementares -> SUCESSO" severity note;

        -- =========================================================
        -- Cenario 4: Overflow Global (Ripple Carry)
        -- (Max + 1) deve dar 0 com Cout=1
        -- =========================================================
        ino <= C_MAX; in1 <= v_one;
        wait for TIME_DELTA;
        
        -- Verifica se sum zerou
        assert sum = C_ZERO 
            report "Falha Cenario 4: Sum nao zerou no overflow" severity error;
        
        -- Verifica se cout subiu
        assert cout = '1'
            report "Falha Cenario 4: Cout nao ativou" severity error;

        report "Cenario 4: Overflow (Ripple) -> SUCESSO" severity note;

        -- =========================================================
        -- Cenario 5: Aritmetica Simples (10+20=30)
        -- =========================================================
        ino <= bit_vector(to_unsigned(10, N));
        in1 <= bit_vector(to_unsigned(20, N));
        wait for TIME_DELTA;
        
        assert sum = bit_vector(to_unsigned(30, N))
            report "Falha Cenario 5: 10+20!=30" severity error;

        report "Cenario 5: Aritmetica Simples -> SUCESSO" severity note;

        -- =========================================================
        -- Cenario 6: Transicao de Meio de Escala
        -- =========================================================
        ino <= x"000000000000FFFF"; in1 <= v_one;
        wait for TIME_DELTA;
        assert sum = x"0000000000010000"
            report "Falha Cenario 6: Carry de meio falhou" severity error;

        report "Cenario 6: Carry Intermediario -> SUCESSO" severity note;

        report ">>> FIM DOS TESTES: SOMADOR VALIDADO <<<";
        simulando <= '0';
        wait;
    end process;

end architecture testbench;