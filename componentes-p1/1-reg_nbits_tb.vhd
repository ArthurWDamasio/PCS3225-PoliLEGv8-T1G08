------------------------------------------------------------
-- Andre Saliba     NUSP: 15439911   Turma: 1 Grupo:T1G08 --
-- Arthur Damasio   NUSP: 15635138   Turma: 1 Grupo:T1G08 --
-- Joao Vitor Rocha NUSP: 15638465   Turma: 1 Grupo:T1G08 --
-- Henrique Falcao  NUSP: 15459010   Turma: 1 Grupo:T1G08 --
-- Pedro Beraldo    NUSP: 15484328   Turma: 1 Grupo:T1G08 --
-- Thiago Medeiros  NUSP: 15651404   Turma: 1 Grupo:T1G08 --
------------------------------------------------------------

entity tb_registrador_n is
end entity tb_registrador_n;

architecture testbench of tb_registrador_n is
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
    
    signal clock  : bit := '0';
    signal reset  : bit := '0';
    signal enable : bit := '0';
    
    signal d_16 : bit_vector(15 downto 0);
    signal q_16 : bit_vector(15 downto 0);
    
    signal d_32 : bit_vector(31 downto 0);
    signal q_32 : bit_vector(31 downto 0);
    
    signal d_64 : bit_vector(63 downto 0);
    signal q_64 : bit_vector(63 downto 0);

begin
    UUT_16: reg 
        generic map (dataSize => 16)
        port map (
            clock => clock, reset => reset, enable => enable,
            d => d_16, q => q_16
        );
    
    UUT_32: reg 
        generic map (dataSize => 32)
        port map (
            clock => clock, reset => reset, enable => enable,
            d => d_32, q => q_32
        );
    
    UUT_64: reg 
        generic map (dataSize => 64)
        port map (
            clock => clock, reset => reset, enable => enable,
            d => d_64, q => q_64
        );

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

    processo_estimulo : process
    begin
        -- Inicializacao
        reset  <= '0';
        enable <= '0';
        d_16   <= (others => '0');
        d_32   <= (others => '0');
        d_64   <= (others => '0');
        wait for CLK_PERIOD;

        report "Iniciando bateria de testes";

        -- Teste 1: Escrita habilitada (Enable = 1)
        enable <= '1';
        
        -- Padrao 1: Todos uns
        d_16 <= (others => '1');
        d_32 <= (others => '1');
        d_64 <= (others => '1');
        wait for CLK_PERIOD;
        
        assert q_16 = X"FFFF" report "Erro: Escrita de 1s (16 bits)" severity error;
        assert q_32 = X"FFFFFFFF" report "Erro: Escrita de 1s (32 bits)" severity error;
        assert q_64 = X"FFFFFFFFFFFFFFFF" report "Erro: Escrita de 1s (64 bits)" severity error;
        
        -- Padrao 2: Todos zeros
        d_16 <= (others => '0');
        d_32 <= (others => '0');
        d_64 <= (others => '0');
        wait for CLK_PERIOD;
        
        assert q_16 = X"0000" report "Erro: Escrita de 0s (16 bits)" severity error;
        assert q_32 = X"00000000" report "Erro: Escrita de 0s (32 bits)" severity error;
        assert q_64 = X"0000000000000000" report "Erro: Escrita de 0s (64 bits)" severity error;

        -- Padrao 3: Bits alternados (AAAA)
        d_16 <= X"AAAA";
        d_32 <= X"AAAAAAAA";
        d_64 <= X"AAAAAAAAAAAAAAAA";
        wait for CLK_PERIOD;
        
        assert q_16 = X"AAAA" report "Erro: Padrao alternado (16 bits)" severity error;
        assert q_32 = X"AAAAAAAA" report "Erro: Padrao alternado (32 bits)" severity error;
        assert q_64 = X"AAAAAAAAAAAAAAAA" report "Erro: Padrao alternado (64 bits)" severity error;

        -- Teste 2: Retencao de dados (Enable = 0)
        enable <= '0';
        d_16 <= (others => '1'); -- Muda entrada para FFFF
        d_32 <= (others => '1');
        d_64 <= (others => '1');
        wait for CLK_PERIOD;
        
        -- Saida deve manter AAAA (valor anterior)
        assert q_16 = X"AAAA" report "Erro: Disable falhou (16 bits)" severity error;
        assert q_32 = X"AAAAAAAA" report "Erro: Disable falhou (32 bits)" severity error;
        assert q_64 = X"AAAAAAAAAAAAAAAA" report "Erro: Disable falhou (64 bits)" severity error;
        
        -- Teste 3: Re-habilitar escrita
        enable <= '1';
        wait for CLK_PERIOD;
        
        assert q_16 = X"FFFF" report "Erro: Re-enable falhou (16 bits)" severity error;
        assert q_32 = X"FFFFFFFF" report "Erro: Re-enable falhou (32 bits)" severity error;
        assert q_64 = X"FFFFFFFFFFFFFFFF" report "Erro: Re-enable falhou (64 bits)" severity error;
        
        -- Teste 4: Reset
        reset <= '1';
        wait for CLK_PERIOD;
        
        assert q_16 = X"0000" report "Erro: Reset falhou (16 bits)" severity error;
        assert q_32 = X"00000000" report "Erro: Reset falhou (32 bits)" severity error;
        assert q_64 = X"0000000000000000" report "Erro: Reset falhou (64 bits)" severity error;
        
        report "Testes finalizados!";
        simulando <= '0';
        wait;
    end process;

end architecture testbench;