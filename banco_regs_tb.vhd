
------------------------------------------------------------
-- Andre Saliba     NUSP: 15439911   Turma: 1 Grupo:T1G08 --
-- Arthur Damasio   NUSP: 15635138   Turma: 1 Grupo:T1G08 --
-- Joao Vitor Rocha NUSP: 15638465   Turma: 1 Grupo:T1G08 --
-- Henrique Falcao  NUSP: 15459010   Turma: 1 Grupo:T1G08 --
-- Pedro Beraldo    NUSP: 15484328   Turma: 1 Grupo:T1G08 --
-- Thiago Medeiros  NUSP: 15651404   Turma: 1 Grupo:T1G08 --
------------------------------------------------------------

entity tb_regfile is
end entity tb_regfile;

architecture test of tb_regfile is

    -- Declaração do componente sob teste (DUT)
    component regfile is
        port(
            clock:    in bit;
            reset:    in bit;
            regWrite: in bit;
            rr1:      in bit_vector(4 downto 0);
            rr2:      in bit_vector(4 downto 0);
            wr:       in bit_vector(4 downto 0);
            d:        in bit_vector(63 downto 0);
            q1:       out bit_vector(63 downto 0);
            q2:       out bit_vector(63 downto 0)
        );
    end component;

    -- Sinais de interconexão
    signal clock_tb:    bit := '0';
    signal reset_tb:    bit := '0';
    signal regWrite_tb: bit := '0';
    signal rr1_tb:      bit_vector(4 downto 0) := (others => '0');
    signal rr2_tb:      bit_vector(4 downto 0) := (others => '0');
    signal wr_tb:       bit_vector(4 downto 0) := (others => '0');
    signal d_tb:        bit_vector(63 downto 0) := (others => '0');
    signal q1_tb:       bit_vector(63 downto 0);
    signal q2_tb:       bit_vector(63 downto 0);

    -- Sinal de controle para parar o clock (nao parava de dar runtime)
    signal sim_finished : boolean := false;

    -- Constantes
    constant CLK_PERIOD: time := 10 ns;
    constant ZERO64: bit_vector(63 downto 0) := (others => '0');
    constant ONES64: bit_vector(63 downto 0) := (others => '1');
    constant PATT_A: bit_vector(63 downto 0) := x"AAAAAAAAAAAAAAAA"; 
    constant PATT_5: bit_vector(63 downto 0) := x"5555555555555555"; 

begin

    -- Instanciação do DUT
    DUT: regfile port map (
        clock    => clock_tb,
        reset    => reset_tb,
        regWrite => regWrite_tb,
        rr1      => rr1_tb,
        rr2      => rr2_tb,
        wr       => wr_tb,
        d        => d_tb,
        q1       => q1_tb,
        q2       => q2_tb
    );

    -- Clock
    clock_process: process
    begin
        while not sim_finished loop
            clock_tb <= '0';
            wait for CLK_PERIOD/2;
            clock_tb <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait; -- Suspende o processo indefinidamente ao sair do loop
    end process;

    stimulus: process
    begin
        report "INICIO DA SIMULACAO" severity note;

        -- Inicialização
        reset_tb <= '1';
        wait for CLK_PERIOD * 2;
        reset_tb <= '0';
        wait for CLK_PERIOD;

        -- Caso 1: Reset Assíncrono
        rr1_tb <= "00001"; 
        rr2_tb <= "11110"; 
        wait for 1 ns; 
        assert (q1_tb = ZERO64) report "Erro C1: Reg 1 nao zerou" severity error;
        assert (q2_tb = ZERO64) report "Erro C1: Reg 30 nao zerou" severity error;

        -- Caso 2: Escrita e Leitura Básica (X1)
        regWrite_tb <= '1';
        wr_tb       <= "00001"; 
        d_tb        <= PATT_A;
        wait for CLK_PERIOD;
        
        regWrite_tb <= '0'; 
        rr1_tb      <= "00001";
        wait for 1 ns; 
        assert (q1_tb = PATT_A) report "Erro C2: Falha escrita X1" severity error;

        -- Caso 3: Múltiplos Registradores (X2, X3)
        regWrite_tb <= '1';
        wr_tb <= "00010"; d_tb <= PATT_5; wait for CLK_PERIOD;
        wr_tb <= "00011"; d_tb <= ONES64; wait for CLK_PERIOD;
        regWrite_tb <= '0';
        
        rr1_tb <= "00010"; rr2_tb <= "00011"; wait for 1 ns;
        assert (q1_tb = PATT_5) report "Erro C3: X2 incorreto" severity error;
        assert (q2_tb = ONES64) report "Erro C3: X3 incorreto" severity error;

        -- Caso 4: Teste XZR (X31)
        regWrite_tb <= '1';
        wr_tb       <= "11111"; 
        d_tb        <= ONES64;  
        wait for CLK_PERIOD;
        
        regWrite_tb <= '0';
        rr1_tb      <= "11111"; 
        wait for 1 ns;
        assert (q1_tb = ZERO64) report "Erro C4: X31 foi escrito" severity error;

        -- Caso 5: RegWrite em '0'
        regWrite_tb <= '0';     
        wr_tb       <= "00100"; -- X4
        d_tb        <= ONES64;
        wait for CLK_PERIOD;
        rr1_tb <= "00100"; wait for 1 ns;
        assert (q1_tb = ZERO64) report "Erro C5: Escrita com enable 0" severity error;

        -- Caso 6: Leitura e Escrita Simultanea
        rr1_tb      <= "00010"; -- Monitorando X2
        regWrite_tb <= '1';
        wr_tb       <= "00010"; -- Escrevendo X2
        d_tb        <= PATT_A;  -- Novo valor
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert (q1_tb = PATT_A) report "Erro C6: Saida nao atualizou" severity error;

        -- Caso 7: Reset durante operacao
        regWrite_tb <= '1';
        wr_tb       <= "01010"; -- X10
        d_tb        <= ONES64;
        wait for CLK_PERIOD;
        
        reset_tb <= '1'; -- Reset imediato
        wait for 1 ns;
        assert (q1_tb = ZERO64) report "Erro C7: Reset falhou" severity error;
        reset_tb <= '0';

        ------------------------------------------------------------------------
        -- FINALIZACAO
        ------------------------------------------------------------------------
        report "FIM DOS TESTES. SUCESSO." severity note;
        
        -- Sinaliza para o clock parar
        sim_finished <= true;
        wait; -- Para o processo de estímulos
    end process;

end architecture test;