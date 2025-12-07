------------------------------------------------------------
-- Andre Saliba     NUSP: 15439911   Turma: 1 Grupo:T1G08 --
-- Arthur Damasio   NUSP: 15635138   Turma: 1 Grupo:T1G08 --
-- Joao Vitor Rocha NUSP: 15638465   Turma: 1 Grupo:T1G08 --
-- Henrique Falcao  NUSP: 15459010   Turma: 1 Grupo:T1G08 --
-- Pedro Beraldo    NUSP: 15484328   Turma: 1 Grupo:T1G08 --
-- Thiago Medeiros  NUSP: 15651404   Turma: 1 Grupo:T1G08 --
------------------------------------------------------------

library ieee;

entity tb_registrador_n is
end entity tb_registrador_n;

architecture testbench of tb_registrador_n is
    -- =================================================================
    -- SETOR 1: Declaracao do Componente (Interface Padrao)
    -- =================================================================
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

    -- Definicao do periodo do clock para simulacao
    constant CLK_PERIOD : time := 10 ns;
    
    -- Sinal de controle para o loop do clock
    signal simulando : bit := '1';
    
    -- Sinais globais de controle
    signal clock  : bit := '0';
    signal reset  : bit := '0';
    signal enable : bit := '0';
    
    -- =================================================================
    -- SETOR 2: Sinais para Instancias de Diferentes Tamanhos
    -- =================================================================
    -- Sinais para teste de 16 bits
    signal d_16 : bit_vector(15 downto 0);
    signal q_16 : bit_vector(15 downto 0);
    
    -- Sinais para teste de 32 bits
    signal d_32 : bit_vector(31 downto 0);
    signal q_32 : bit_vector(31 downto 0);
    
    -- Sinais para teste de 64 bits (Padrao PoliLEGv8)
    signal d_64 : bit_vector(63 downto 0);
    signal q_64 : bit_vector(63 downto 0);

begin

    -- =================================================================
    -- SETOR 3: Instanciacao das Unidades Sob Teste (UUT)
    -- =================================================================
    -- Instancia com 16 bits
    UUT_16: reg 
        generic map (dataSize => 16)
        port map (clock => clock, reset => reset, enable => enable, d => d_16, q => q_16);
    
    -- Instancia com 32 bits
    UUT_32: reg 
        generic map (dataSize => 32)
        port map (clock => clock, reset => reset, enable => enable, d => d_32, q => q_32);
    
    -- Instancia com 64 bits
    UUT_64: reg 
        generic map (dataSize => 64)
        port map (clock => clock, reset => reset, enable => enable, d => d_64, q => q_64);

    -- =================================================================
    -- SETOR 4: Gerador de Clock
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
    -- SETOR 5: Processo de Estimulos e Verificacao
    -- =================================================================
    processo_estimulo : process
    begin
        report ">> Inicio da Simulacao do Registrador";
        
        -- 5.1: Inicializacao (Garante estado conhecido)
        reset  <= '1'; -- Comeca resetado
        enable <= '0';
        d_16   <= (others => '0');
        d_32   <= (others => '0');
        d_64   <= (others => '0');
        wait for CLK_PERIOD; -- Espera um clock completo
        
        reset <= '0'; -- Libera reset
        wait for CLK_PERIOD;

        -- 5.2: Teste de Carga (Write Enable = 1) - Padrao All Ones
        report "Teste 1: Escrita com Enable=1 (Padrao FFFF...)";
        enable <= '1';
        d_16 <= (others => '1');
        d_32 <= (others => '1');
        d_64 <= (others => '1');
        
        wait until clock='1'; -- Aguarda borda de subida
        wait for 1 ns;        -- Pequeno delay para propagacao
        
        assert q_16 = X"FFFF" report "Falha: Reg 16 nao gravou 1s" severity error;
        assert q_32 = X"FFFFFFFF" report "Falha: Reg 32 nao gravou 1s" severity error;
        assert q_64 = X"FFFFFFFFFFFFFFFF" report "Falha: Reg 64 nao gravou 1s" severity error;

        -- 5.3: Teste de Retencao (Write Enable = 0)
        report "Teste 2: Retencao com Enable=0 (Protecao de escrita)";
        enable <= '0';          -- Desabilita escrita
        d_16 <= X"AAAA";        -- Tenta mudar entrada para padrao alternado
        d_32 <= X"AAAAAAAA";
        d_64 <= X"AAAAAAAAAAAAAAAA";
        
        wait until clock='1';   -- Borda de subida
        wait for 1 ns;
        
        -- Saida deve continuar sendo "FFFF..."
        assert q_16 = X"FFFF" report "Falha: Reg 16 alterou valor com enable=0" severity error;
        assert q_32 = X"FFFFFFFF" report "Falha: Reg 32 alterou valor com enable=0" severity error;
        
        -- 5.4: Teste de Padrao Alternado (Bit Toggling)
        report "Teste 3: Escrita de Padrao Alternado (AAAA...)";
        enable <= '1';
        
        wait until clock='1';
        wait for 1 ns;
        
        assert q_16 = X"AAAA" report "Falha: Reg 16 padrao alternado" severity error;
        assert q_64 = X"AAAAAAAAAAAAAAAA" report "Falha: Reg 64 padrao alternado" severity error;

        -- 5.5: Teste Reset Assincrono
        report "Teste 4: Reset Assincrono (Prioridade sobre Enable e Clock)";
        enable <= '1';          -- Enable continua alto (tentando escrever)
        d_16 <= X"FFFF";        -- Dado na entrada e 1
        wait for 1 ns;          -- Logo apos a borda do teste anterior
        
        reset <= '1';           -- Ativa reset NO MEIO do ciclo
        wait for 1 ns;          -- Delay minimo de propagacao 
        
        -- Deve zerar IMEDIATAMENTE
        assert q_16 = X"0000" report "Falha: Reset assincrono nao zerou imediatamente" severity error;
        assert q_64 = X"0000000000000000" report "Falha: Reset assincrono 64 bits" severity error;

        -- Finalizacao
        report ">> Sucesso: Todos os testes passaram!";
        simulando <= '0';
        wait;
    end process;

end architecture testbench;