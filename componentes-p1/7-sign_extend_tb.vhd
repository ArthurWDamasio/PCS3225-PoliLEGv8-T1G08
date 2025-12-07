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

entity sign_extend_tb is
end entity sign_extend_tb;

architecture testbench of sign_extend_tb is

    -- Definição do Componente (Deve corresponder exatamente à entity do projeto)
    component sign_extend is
        generic (
            dataISize       : natural := 32;
            dataOSize       : natural := 64;
            dataMaxPosition : natural := 5
        );
        port(
            inData      : in bit_vector(dataISize-1 downto 0);
            inDataStart : in bit_vector(dataMaxPosition-1 downto 0);
            inDataEnd   : in bit_vector(dataMaxPosition-1 downto 0);
            outData     : out bit_vector(dataOSize-1 downto 0)
        );
    end component;

    -- Constantes
    constant c_dataISize : natural := 32;
    constant c_dataOSize : natural := 64;
    constant c_posSize   : natural := 5;

    -- Sinais
    signal s_inData      : bit_vector(c_dataISize-1 downto 0) := (others => '0');
    signal s_inDataStart : bit_vector(c_posSize-1 downto 0)   := (others => '0');
    signal s_inDataEnd   : bit_vector(c_posSize-1 downto 0)   := (others => '0');
    signal s_outData     : bit_vector(c_dataOSize-1 downto 0);

begin

    -- Instanciação do DUT (Device Under Test)
    DUT: sign_extend
        generic map (
            dataISize       => c_dataISize,
            dataOSize       => c_dataOSize,
            dataMaxPosition => c_posSize
        )
        port map (
            inData      => s_inData,
            inDataStart => s_inDataStart,
            inDataEnd   => s_inDataEnd,
            outData     => s_outData
        );

    -- Processo de Teste Principal
    p_test: process
        -- Variável auxiliar para construir o vetor de entrada de forma segura
        variable v_data_build : bit_vector(c_dataISize-1 downto 0);
    begin
        report "============================================================";
        report "   INICIANDO TESTBENCH: SIGN_EXTEND (Grupo T1G08)";
        report "============================================================";

        ------------------------------------------------------------
        -- CASO 1: Extensão Simples POSITIVA (Bit de sinal '0')
        -- Cenário: Extrair bits 4 até 0. Valor "01011" (11 decimal).
        ------------------------------------------------------------
        v_data_build := (others => '0');          -- Limpa variável
        v_data_build(4 downto 0) := "01011";      -- Define valor
        s_inData <= v_data_build;                 -- Atribui ao sinal
        
        -- Configura indices: Start=4, End=0
        s_inDataStart <= bit_vector(to_unsigned(4, c_posSize));
        s_inDataEnd   <= bit_vector(to_unsigned(0, c_posSize));
        
        wait for 10 ns; -- Aguarda propagação

        -- Verificação:
        -- Esperado: 59 zeros seguidos de "01011"
        assert s_outData(63 downto 5) = (63 downto 5 => '0')
            report "FALHA Caso 1: Extensão de zeros incorreta." severity error;
        
        assert s_outData(4 downto 0) = "01011"
            report "FALHA Caso 1: Dados LSB incorretos." severity error;
            
        report "Caso 1 (Positivo Simples): Verificado.";

        ------------------------------------------------------------
        -- CASO 2: Extensão Simples NEGATIVA (Bit de sinal '1')
        -- Cenário: Extrair bits 4 até 0. Valor "10101". Bit 4 é '1'.
        ------------------------------------------------------------
        v_data_build := (others => '0');
        v_data_build(4 downto 0) := "10101";
        s_inData <= v_data_build;
        
        s_inDataStart <= bit_vector(to_unsigned(4, c_posSize));
        s_inDataEnd   <= bit_vector(to_unsigned(0, c_posSize));
        
        wait for 10 ns;

        -- Verificação:
        -- Esperado: 59 uns seguidos de "10101"
        assert s_outData(63 downto 5) = (63 downto 5 => '1')
            report "FALHA Caso 2: Extensão de uns (sinal) incorreta." severity error;
            
        assert s_outData(4 downto 0) = "10101"
            report "FALHA Caso 2: Dados LSB incorretos." severity error;

        report "Caso 2 (Negativo Simples): Verificado.";

        ------------------------------------------------------------
        -- CASO 3: Janela Deslocada (Offset de LDUR/STUR)
        -- Cenário: Extrair bits 20 até 12. Tamanho 9 bits.
        -- Valor: "100000001" (MSB '1' -> Negativo)
        ------------------------------------------------------------
        v_data_build := (others => '0');
        v_data_build(20 downto 12) := "100000001";
        s_inData <= v_data_build;
        
        s_inDataStart <= bit_vector(to_unsigned(20, c_posSize));
        s_inDataEnd   <= bit_vector(to_unsigned(12, c_posSize));
        
        wait for 10 ns;

        -- Verificação:
        -- Width = 20 - 12 + 1 = 9 bits.
        -- Saída deve ter (64-9)=55 bits '1' no topo e "100000001" na base.
        assert s_outData(63 downto 9) = (63 downto 9 => '1')
            report "FALHA Caso 3: Extensão superior LDUR falhou." severity error;

        assert s_outData(8 downto 0) = "100000001"
            report "FALHA Caso 3: Cópia dos dados LDUR falhou." severity error;

        report "Caso 3 (Janela Deslocada Negativa): Verificado.";

        ------------------------------------------------------------
        -- CASO 4: Teste de Borda - Janela de 1 Bit
        -- Cenário: Apenas bit 31. Valor '1'.
        ------------------------------------------------------------
        v_data_build := (others => '0');
        v_data_build(31) := '1';
        s_inData <= v_data_build;
        
        s_inDataStart <= bit_vector(to_unsigned(31, c_posSize));
        s_inDataEnd   <= bit_vector(to_unsigned(31, c_posSize));
        
        wait for 10 ns;

        -- Se o bit selecionado é 1 e é o único, a saída deve ser TODA 1 (sinal estendido desde o bit 0).
        assert s_outData = (c_dataOSize-1 downto 0 => '1')
            report "FALHA Caso 4: Extensão de 1 bit (MSB) falhou." severity error;

        report "Caso 4 (Borda 1 Bit): Verificado.";

        ------------------------------------------------------------
        -- CASO 5: Teste de Integridade - Janela Grande Positiva
        -- Cenário: Bits 25 a 2. Bit 25='0'. Padrão misto no meio.
        ------------------------------------------------------------
        v_data_build := (others => '0');
        -- Preenche com padrão alternado para garantir que não houve shift
        v_data_build(25 downto 2) := x"A5A5A5"; -- Hex A5... binário 10100101...
        -- Garante que o MSB da janela (bit 25) seja '0' para ser positivo
        v_data_build(25) := '0'; 
        
        s_inData <= v_data_build;
        
        s_inDataStart <= bit_vector(to_unsigned(25, c_posSize));
        s_inDataEnd   <= bit_vector(to_unsigned(2, c_posSize));
        
        wait for 10 ns;

        -- Width = 25 - 2 + 1 = 24 bits.
        -- Bits 63 downto 24 devem ser '0'.
        -- Bits 23 downto 0 devem ser iguais a v_data_build(25 downto 2).
        
        assert s_outData(63 downto 24) = (63 downto 24 => '0')
            report "FALHA Caso 5: Extensão positiva janela grande." severity error;
            
        assert s_outData(23 downto 0) = v_data_build(25 downto 2)
            report "FALHA Caso 5: Integridade dos dados corrompida." severity error;

        report "Caso 5 (Integridade Janela Grande): Verificado.";

        report "============================================================";
        report "   FIM DO TESTBENCH - SUCESSO";
        report "============================================================";
        wait;
    end process;

end architecture testbench;