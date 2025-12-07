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

entity tb_ula1bit is
end entity tb_ula1bit;

architecture test of tb_ula1bit is

    -- Componente a ser testado (UUT)
    component ula1bit is 
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
    end component;

    -- Sinais de interconexão
    signal s_a         : bit := '0';
    signal s_b         : bit := '0';
    signal s_cin       : bit := '0';
    signal s_ainvert   : bit := '0';
    signal s_binvert   : bit := '0';
    signal s_operation : bit_vector(1 downto 0) := "00";
    
    -- Sinais de saída
    signal s_result    : bit;
    signal s_cout      : bit;
    signal s_overflow  : bit;

    -- Constante de tempo para estabilização
    constant T_WAIT : time := 2 ns;

begin

    -- Instanciação da UUT
    uut: ula1bit
        port map (
            a         => s_a,
            b         => s_b,
            cin       => s_cin,
            ainvert   => s_ainvert,
            binvert   => s_binvert,
            operation => s_operation,
            result    => s_result,
            cout      => s_cout,
            overflow  => s_overflow
        );

    -- Processo de Estímulo e Verificação
    p_stimulus: process
    begin
        report ">>> INICIO DA SIMULACAO DA ULA DE 1 BIT <<<" severity note;

        ------------------------------------------------------------
        -- Cenario 1: Operacao AND (Operation = 00)
        ------------------------------------------------------------
        report "Cenario 1: Testando Operacao AND (00)..." severity note;
        s_operation <= "00"; s_ainvert <= '0'; s_binvert <= '0'; s_cin <= '0';

        -- 0 AND 0
        s_a <= '0'; s_b <= '0'; wait for T_WAIT;
        assert (s_result = '0') report "Falha: 0 AND 0 deve ser 0" severity error;

        -- 1 AND 0
        s_a <= '1'; s_b <= '0'; wait for T_WAIT;
        assert (s_result = '0') report "Falha: 1 AND 0 deve ser 0" severity error;

        -- 1 AND 1
        s_a <= '1'; s_b <= '1'; wait for T_WAIT;
        assert (s_result = '1') report "Falha: 1 AND 1 deve ser 1" severity error;

        report "-> Sucesso na Operacao AND." severity note;

        ------------------------------------------------------------
        -- Cenario 2: Operacao OR (Operation = 01)
        ------------------------------------------------------------
        report "Cenario 2: Testando Operacao OR (01)..." severity note;
        s_operation <= "01";

        -- 0 OR 0
        s_a <= '0'; s_b <= '0'; wait for T_WAIT;
        assert (s_result = '0') report "Falha: 0 OR 0 deve ser 0" severity error;

        -- 0 OR 1
        s_a <= '0'; s_b <= '1'; wait for T_WAIT;
        assert (s_result = '1') report "Falha: 0 OR 1 deve ser 1" severity error;

        -- 1 OR 1
        s_a <= '1'; s_b <= '1'; wait for T_WAIT;
        assert (s_result = '1') report "Falha: 1 OR 1 deve ser 1" severity error;

        report "-> Sucesso na Operacao OR." severity note;

        ------------------------------------------------------------
        -- Cenario 3: Operacao ADD (Operation = 10)
        ------------------------------------------------------------
        report "Cenario 3: Testando Operacao ADD (10)..." severity note;
        s_operation <= "10";

        -- 0 + 0 (Cin=0)
        s_a <= '0'; s_b <= '0'; s_cin <= '0'; wait for T_WAIT;
        assert (s_result = '0' and s_cout = '0') report "Falha Soma: 0+0+0" severity error;

        -- 1 + 0 (Cin=0)
        s_a <= '1'; s_b <= '0'; s_cin <= '0'; wait for T_WAIT;
        assert (s_result = '1' and s_cout = '0') report "Falha Soma: 1+0+0" severity error;

        -- 1 + 1 (Cin=0) -> Result 0, Cout 1
        s_a <= '1'; s_b <= '1'; s_cin <= '0'; wait for T_WAIT;
        assert (s_result = '0' and s_cout = '1') report "Falha Soma: 1+1+0 (gera carry)" severity error;

        -- 1 + 1 (Cin=1) -> Result 1, Cout 1
        s_a <= '1'; s_b <= '1'; s_cin <= '1'; wait for T_WAIT;
        assert (s_result = '1' and s_cout = '1') report "Falha Soma: 1+1+1" severity error;

        report "-> Sucesso na Operacao ADD." severity note;

        ------------------------------------------------------------
        -- Cenario 4: Teste dos Inversores (Ainvert e Binvert)
        ------------------------------------------------------------
        report "Cenario 4: Testando Inversores..." severity note;
        -- Usando AND para verificar: (NOT 0) AND 1 = 1 AND 1 = 1
        s_operation <= "00"; 
        
        -- Teste Ainvert
        s_ainvert <= '1'; s_binvert <= '0';
        s_a <= '0'; s_b <= '1'; wait for T_WAIT;
        assert (s_result = '1') report "Falha Ainvert: (NOT 0) AND 1 deveria ser 1" severity error;

        -- Teste Binvert
        s_ainvert <= '0'; s_binvert <= '1';
        s_a <= '1'; s_b <= '0'; wait for T_WAIT;
        assert (s_result = '1') report "Falha Binvert: 1 AND (NOT 0) deveria ser 1" severity error;

        report "-> Sucesso nos Inversores." severity note;

        ------------------------------------------------------------
        -- Cenario 5: Pass B (Operation = 11)
        ------------------------------------------------------------
        report "Cenario 5: Testando Pass B (11)..." severity note;
        s_operation <= "11"; s_ainvert <= '0'; s_binvert <= '0';

        s_b <= '1'; s_a <= '0'; wait for T_WAIT; -- A nao deve importar
        assert (s_result = '1') report "Falha Pass B: Entrada B=1" severity error;

        s_b <= '0'; wait for T_WAIT;
        assert (s_result = '0') report "Falha Pass B: Entrada B=0" severity error;

        report "-> Sucesso no Pass B." severity note;

        ------------------------------------------------------------
        -- Cenario 6: Detecçao de Overflow
        ------------------------------------------------------------
        report "Cenario 6: Testando Overflow (Cin XOR Cout)..." severity note;
        s_operation <= "10"; -- Modo Soma para gerar Cout interno
        s_ainvert <= '0'; s_binvert <= '0';

        -- Caso sem Overflow: Cin=0, Cout=0 (0+0)
        s_cin <= '0'; s_a <= '0'; s_b <= '0'; wait for T_WAIT;
        assert (s_overflow = '0') report "Erro: Overflow ativado indevidamente (0^0)" severity error;

        -- Caso com Overflow: Cin=1, Cout=0 (Ex: 0+0 com Cin=1 -> Soma=1, Cout=0)
        -- Overflow = 1 XOR 0 = 1
        s_cin <= '1'; s_a <= '0'; s_b <= '0'; wait for T_WAIT;
        assert (s_overflow = '1') report "Erro: Overflow nao detectado (Cin=1, Cout=0)" severity error;
        
        -- Caso com Overflow: Cin=0, Cout=1 (Ex: 1+1 com Cin=0 -> Soma=0, Cout=1)
        -- Overflow = 0 XOR 1 = 1
        s_cin <= '0'; s_a <= '1'; s_b <= '1'; wait for T_WAIT;
        assert (s_overflow = '1') report "Erro: Overflow nao detectado (Cin=0, Cout=1)" severity error;

        report "-> Sucesso na Deteccao de Overflow." severity note;

        report ">>> FIM DA SIMULACAO: TODOS OS TESTES PASSARAM <<<" severity note;
        wait;
    end process;

end architecture test;
