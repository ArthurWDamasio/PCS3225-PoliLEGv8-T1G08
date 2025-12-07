 
-----------------Sistemas Digitais II-------------------------------------
-- Arquivo   : reg_nbits_tb.vhd
-- Projeto   : AF12 Parte 1 SDII 2025 - Biblioteca de Componentes
-------------------------------------------------------------------------
-- Descricao : Testbench para o registrador parametrizavel (reg)
--             Valida generics, enable, retencao e reset assincrono.
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     06/12/2025  1.2     T1G08             Expansao dos casos de teste
-------------------------------------------------------------------------

entity tb_registrador_n is
end entity tb_registrador_n;

architecture testbench of tb_registrador_n is
    -- Declaracao do componente (Interface conforme reg_nbits.vhd)
    component reg is
        generic (dataSize: natural := 64);
        port (
            clock  : in  bit;
            reset  : in  bit;
            enable : in  bit;
            d      : in  bit_vector (dataSize-1 downto 0);
            q      : out bit_vector (dataSize-1 downto 0) 
        );
    end component;

    constant CLK_PERIOD : time := 10 ns;
    
    signal simulando : bit := '1';
    
    -- Sinais de controle globais (compartilhados entre as UUTs)
    signal clock  : bit := '0';
    signal reset  : bit := '0';
    signal enable : bit := '0';
    
    -- Sinais independentes para a instancia de 16 bits
    signal d_16 : bit_vector(15 downto 0);
    signal q_16 : bit_vector(15 downto 0);
    
    -- Sinais independentes para a instancia de 32 bits
    signal d_32 : bit_vector(31 downto 0);
    signal q_32 : bit_vector(31 downto 0);
    
    -- Sinais independentes para a instancia de 64 bits
    signal d_64 : bit_vector(63 downto 0);
    signal q_64 : bit_vector(63 downto 0);

begin
    -- =================================================================
    -- Instanciacao das Unidades Sob Teste (UUTs)
    -- Testa a capacidade de parametrizacao (Generic map)
    -- =================================================================
    
    UUT_16: reg 
        generic map (dataSize => 16)
        port map (
            clock  => clock, reset => reset, enable => enable,
            d => d_16, q => q_16
        );
    
    UUT_32: reg 
        generic map (dataSize => 32)
        port map (
            clock  => clock, reset => reset, enable => enable,
            d => d_32, q => q_32
        );
    
    UUT_64: reg 
        generic map (dataSize => 64)
        port map (
            clock  => clock, reset => reset, enable => enable,
            d => d_64, q => q_64
        );

    -- =================================================================
    -- Processo de Geracao de Clock
    -- =================================================================
    processo_clock : process
    begin
        while simulando = '1' loop
            clock <= '0';
            wait for CLK_PERIOD/2;
            clock <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- =================================================================
    -- Processo de Estimulos (Sequencia de Testes)
    -- =================================================================
    processo_estimulo : process
    begin
        -- Cenario 1: Inicializacao e Estado Conhecido
        report "Cenario 1: Inicializacao";
        reset  <= '1'; 
        enable <= '0';
        d_16   <= (others => '0');
        d_32   <= (others => '0');
        d_64   <= (others => '0');
        wait for CLK_PERIOD; 
        
        reset <= '0'; -- Libera o reset para operacao normal
        wait for CLK_PERIOD;

        -- Cenario 2: Teste de Escrita de Nivel Alto (Stress de 1s)
        report "Cenario 2: Escrita de Todos os Bits em '1'";
        enable <= '1'; -- Habilita escrita
        d_16 <= (others => '1');
        d_32 <= (others => '1');
        d_64 <= (others => '1');
        wait for CLK_PERIOD; -- Aguarda borda de subida
        
        -- Verificacao automatica
        assert q_16 = X"FFFF" report "Falha: Escrita de 1s (16 bits)" severity error;
        assert q_32 = X"FFFFFFFF" report "Falha: Escrita de 1s (32 bits)" severity error;
        assert q_64 = X"FFFFFFFFFFFFFFFF" report "Falha: Escrita de 1s (64 bits)" severity error;
        
        -- Cenario 3: Teste de Escrita de Nivel Baixo (Stress de 0s)
        report "Cenario 3: Escrita de Todos os Bits em '0'";
        d_16 <= (others => '0');
        d_32 <= (others => '0');
        d_64 <= (others => '0');
        wait for CLK_PERIOD;
        
        assert q_16 = X"0000" report "Falha: Escrita de 0s (16 bits)" severity error;
        assert q_32 = X"00000000" report "Falha: Escrita de 0s (32 bits)" severity error;
        assert q_64 = X"0000000000000000" report "Falha: Escrita de 0s (64 bits)" severity error;

        -- Prepara dado para o proximo teste (Padrao Alternado AAAA...)
        d_16 <= X"AAAA";
        d_32 <= X"AAAAAAAA";
        d_64 <= X"AAAAAAAAAAAAAAAA";
        wait for CLK_PERIOD; -- Grava o padrao AAAA...
        
        -- Cenario 4: Teste de Retencao de Dados (Enable = 0)
        report "Cenario 4: Teste de Retencao (Disable)";
        enable <= '0';           -- Desabilita escrita
        d_16 <= (others => '1'); -- Muda a entrada para FFFF... (ruido/dado novo)
        d_32 <= (others => '1');
        d_64 <= (others => '1');
        wait for CLK_PERIOD;     -- Aguarda borda de clock
        
        -- A saida deve IGNORAR a entrada FFFF e manter o valor antigo AAAA
        assert q_16 = X"AAAA" report "Falha: Enable=0 nao reteve dado (16 bits)" severity error;
        assert q_32 = X"AAAAAAAA" report "Falha: Enable=0 nao reteve dado (32 bits)" severity error;
        assert q_64 = X"AAAAAAAAAAAAAAAA" report "Falha: Enable=0 nao reteve dado (64 bits)" severity error;
        
        -- Cenario 5: Validacao da Assincronicidade do Reset
        report "Cenario 5: Teste de Reset Assincrono";
        enable <= '1'; -- Habilita, pronto para escrever FFFF...
        wait for CLK_PERIOD/4; -- Avanca 2.5ns (clock estavel, longe da borda)
        
        reset <= '1';          -- Dispara o reset AGORA
        wait for 1 ns;         -- Espera minima apenas para propagacao (nao espera clock)
        
        -- O registrador deve ter zerado IMEDIATAMENTE, sem esperar a borda subir
        assert q_16 = X"0000" report "Falha: Reset assincrono (16 bits)" severity error;
        assert q_32 = X"00000000" report "Falha: Reset assincrono (32 bits)" severity error;
        assert q_64 = X"0000000000000000" report "Falha: Reset assincrono (64 bits)" severity error;
        
        report "Fim da bateria de testes com sucesso.";
        
        simulando <= '0';
        wait;
    end process;

end architecture testbench;
