------------------------------------------------------------
-- Andre Saliba     NUSP: 15439911   Turma: 1 Grupo:T1G08 --
-- Arthur Damasio   NUSP: 15635138   Turma: 1 Grupo:T1G08 --
-- Joao Vitor Rocha NUSP: 15638465   Turma: 1 Grupo:T1G08 --
-- Henrique Falcao  NUSP: 15459010   Turma: 1 Grupo:T1G08 --
-- Pedro Beraldo    NUSP: 15484328   Turma: 1 Grupo:T1G08 --
-- Thiago Medeiros  NUSP: 15651404   Turma: 1 Grupo:T1G08 --
------------------------------------------------------------

entity tb_mux_n is
end entity tb_mux_n;

architecture testbench of tb_mux_n is
    component mux_n is 
        generic (dataSize: natural := 64);
        port(
            ino  : in bit_vector(dataSize-1 downto 0);
            in1  : in bit_vector(dataSize-1 downto 0);
            sel  : in bit;
            dOut : out bit_vector(dataSize-1 downto 0)
        );
    end component;

    constant TIME_DELTA : time := 10 ns;
    
    signal simulando : bit := '1';
    signal sel : bit := '0';
    
    -- Sinais para instancia de 16 bits
    signal ino_16, in1_16, dOut_16 : bit_vector(15 downto 0);
    
    -- Sinais para instancia de 32 bits
    signal ino_32, in1_32, dOut_32 : bit_vector(31 downto 0);
    
    -- Sinais para instancia de 64 bits
    signal ino_64, in1_64, dOut_64 : bit_vector(63 downto 0);

begin
    -- Instanciacao das UUTs (Unit Under Test)
    UUT_16: mux_n generic map (dataSize => 16)
        port map (ino => ino_16, in1 => in1_16, sel => sel, dOut => dOut_16);
    
    UUT_32: mux_n generic map (dataSize => 32)
        port map (ino => ino_32, in1 => in1_32, sel => sel, dOut => dOut_32);
    
    UUT_64: mux_n generic map (dataSize => 64)
        port map (ino => ino_64, in1 => in1_64, sel => sel, dOut => dOut_64);

    processo_estimulo : process
    begin
        report ">>> INICIANDO TESTES DO MULTIPLEXADOR <<<";

        -- =========================================================
        -- Cenario 1: Selecao do Canal 0 e Isolamento do Canal 1
        -- =========================================================
        sel <= '0';
        
        -- Padrao A (1010) no canal selecionado
        ino_16 <= X"AAAA"; 
        ino_32 <= X"AAAAAAAA";
        ino_64 <= X"AAAAAAAAAAAAAAAA";
        
        -- Padrao 5 (0101) no canal ignorado (ruido)
        in1_16 <= X"5555";
        in1_32 <= X"55555555";
        in1_64 <= X"5555555555555555";
        
        wait for TIME_DELTA;
        
        assert dOut_16 = X"AAAA" report "Falha (16b): Canal 0 nao selecionado" severity error;
        assert dOut_32 = X"AAAAAAAA" report "Falha (32b): Canal 0 nao selecionado" severity error;
        assert dOut_64 = X"AAAAAAAAAAAAAAAA" report "Falha (64b): Canal 0 nao selecionado" severity error;
        
        report "Cenario 1: Selecao do Canal 0 -> SUCESSO" severity note;

        -- =========================================================
        -- Cenario 2: Comutacao para Canal 1
        -- =========================================================
        sel <= '1';
        wait for TIME_DELTA;
        
        -- A saida deve virar 5555... imediatamente
        assert dOut_16 = X"5555" report "Falha (16b): Canal 1 nao selecionado" severity error;
        assert dOut_32 = X"55555555" report "Falha (32b): Canal 1 nao selecionado" severity error;
        assert dOut_64 = X"5555555555555555" report "Falha (64b): Canal 1 nao selecionado" severity error;

        report "Cenario 2: Comutacao para Canal 1 -> SUCESSO" severity note;

        -- =========================================================
        -- Cenario 3: Propagacao Combinacional (Mudanca Dinamica)
        -- =========================================================
        -- Mantemos sel='1', mas zeramos a entrada in1
        in1_16 <= (others => '0');
        in1_32 <= (others => '0');
        in1_64 <= (others => '0');
        
        wait for TIME_DELTA;
        
        -- A saida deve zerar acompanhando a entrada
        assert dOut_16 = X"0000" report "Falha (16b): Propagacao dinamica incorreta" severity error;
        assert dOut_32 = X"00000000" report "Falha (32b): Propagacao dinamica incorreta" severity error;
        assert dOut_64 = X"0000000000000000" report "Falha (64b): Propagacao dinamica incorreta" severity error;

        report "Cenario 3: Propagacao Dinamica -> SUCESSO" severity note;

        report ">>> FIM DOS TESTES: TODOS OS CASOS APROVADOS <<<";
        simulando <= '0';
        wait;
    end process;

end architecture testbench;