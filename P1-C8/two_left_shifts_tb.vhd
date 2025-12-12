------------------------------------------------------------
-- Andre Saliba     NUSP: 15439911   Turma: 1 Grupo:T1G08 --
-- Arthur Damasio   NUSP: 15635138   Turma: 1 Grupo:T1G08 --
-- Joao Vitor Rocha NUSP: 15638465   Turma: 1 Grupo:T1G08 --
-- Henrique Falcao  NUSP: 15459010   Turma: 1 Grupo:T1G08 --
-- Pedro Beraldo    NUSP: 15484328   Turma: 1 Grupo:T1G08 --
-- Thiago Medeiros  NUSP: 15651404   Turma: 1 Grupo:T1G08 --
------------------------------------------------------------

library ieee;

entity tb_two_left_shifts is
end entity tb_two_left_shifts;

architecture test of tb_two_left_shifts is

    -- Definição do Componente (DUT)
    component two_left_shifts is 
        generic(
            dataSize: natural := 64
        );
        port(
            input: in bit_vector(dataSize-1 downto 0);
            output: out bit_vector(dataSize-1 downto 0)
        );
    end component;

    -- Sinais de interconexão
    constant DATA_WIDTH : natural := 64;
    signal s_input      : bit_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal s_output     : bit_vector(DATA_WIDTH-1 downto 0);

begin

    -- Instanciação do DUT (Device Under Test)
    DUT: two_left_shifts
        generic map (
            dataSize => DATA_WIDTH
        )
        port map (
            input  => s_input,
            output => s_output
        );

    -- Processo de Estímulo e Verificação
    stimulus_process: process
    begin
        report "------------------------------------------------------------";
        report "INICIANDO TESTBENCH: two_left_shifts (Deslocador << 2)";
        report "------------------------------------------------------------";

        -- CASO DE TESTE 1: Entrada Zero
        -- Objetivo: Verificar se 0 deslocado continua 0.
        s_input <= (others => '0');
        wait for 10 ns;
        assert s_output = (s_output'range => '0')
            report "FALHA NO TESTE 1: Entrada Zero gerou saida nao nula."
            severity error;
        
        -- CASO DE TESTE 2: Valor Unitário (1)
        -- Objetivo: Verificar se 1 (0...01) vira 4 (0...100).
        s_input <= (0 => '1', others => '0'); -- Decimal 1
        wait for 10 ns;
        assert s_output(2) = '1' and s_output(1 downto 0) = "00"
            report "FALHA NO TESTE 2: Deslocamento de valor unitario incorreto."
            severity error;

        -- CASO DE TESTE 3: Saturação (Todos '1')
        -- Objetivo: Verificar truncamento dos MSBs e preenchimento dos LSBs.
        -- Entrada: FFFFFFFFFFFFFFFF
        -- Esperado: FFFFFFFFFFFFFFFC (Os dois ultimos bits '0' e os dois primeiros perdidos)
        s_input <= (others => '1');
        wait for 10 ns;
        assert s_output(1 downto 0) = "00" 
            report "FALHA NO TESTE 3: LSBs nao sao zero." severity error;
        assert s_output(DATA_WIDTH-1 downto 2) = (DATA_WIDTH-1 downto 2 => '1')
            report "FALHA NO TESTE 3: Bits superiores incorretos." severity error;

        -- CASO DE TESTE 4: Padrão Alternado (0x5555...)
        -- Padrão binário input: ...01010101
        -- Esperado output:      ...01010100
        -- Verifica integridade dos bits internos.
        s_input <= X"5555555555555555"; 
        wait for 10 ns;
        -- O resultado esperado é o padrão deslocado. 
        -- 0x5...5 (bin 0101) << 2 -> vira 0x5...4 (bin ...010100)
        assert s_output = X"5555555555555554"
            report "FALHA NO TESTE 4: Padrao alternado corrompido."
            severity error;

        -- CASO DE TESTE 5: Teste de Borda Superior
        -- Colocar '1' apenas nos dois bits mais significativos para garantir que somem.
        -- Input: 1100...0000 (Bits 63 e 62 setados)
        -- Output esperado: 0000...0000
        s_input <= (others => '0');
        s_input(DATA_WIDTH-1) <= '1';
        s_input(DATA_WIDTH-2) <= '1';
        wait for 10 ns;
        assert s_output = (s_output'range => '0')
            report "FALHA NO TESTE 5: MSBs nao foram descartados corretamente."
            severity error;

        report "------------------------------------------------------------";
        report "TESTBENCH FINALIZADO: Verificacao concluida.";
        report "------------------------------------------------------------";
        wait; -- Para a simulação
    end process;

end architecture test;