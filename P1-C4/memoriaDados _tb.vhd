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

entity tb_memoriaDados is
end entity tb_memoriaDados;

architecture testbench of tb_memoriaDados is
    component memoriaDados is
        generic (
            addressSize : natural := 8;
            dataSize    : natural := 8;
            datFileName : string  := "memDados_conteudo_inicial.dat"
        );
        port (
            clock  : in  bit;
            wr     : in  bit;
            addr   : in  bit_vector(addressSize-1 downto 0);
            data_i : in  bit_vector(dataSize-1 downto 0);
            data_o : out bit_vector(dataSize-1 downto 0)
        );
    end component;

    constant TIME_DELTA : time := 10 ns;
    constant CLK_PERIOD : time := 20 ns;
    constant ADDR_WIDTH : natural := 8;
    constant DATA_WIDTH : natural := 8;

    signal simulando : bit := '1';
    signal clock     : bit := '0';
    signal wr        : bit := '0';
    signal addr      : bit_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal data_i    : bit_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal data_o    : bit_vector(DATA_WIDTH-1 downto 0);

begin
    -- Instancia da Memoria de Dados (RAM)
    -- Aponta para o arquivo fornecido no enunciado
    UUT: memoriaDados
        generic map (
            addressSize => ADDR_WIDTH,
            dataSize    => DATA_WIDTH,
            datFileName => "memDados_conteudo_inicial.dat"
        )
        port map (
            clock  => clock,
            wr     => wr,
            addr   => addr,
            data_i => data_i,
            data_o => data_o
        );

    -- Processo de geracao de Clock
    processo_clock : process
    begin
        while simulando = '1' loop
            clock <= '0';
            wait for CLK_PERIOD / 2;
            clock <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    processo_estimulo : process
    begin
        report ">>> INICIANDO TESTES DA MEMORIA DE DADOS <<<";

        -- Espera inicial para estabilizacao
        wait for CLK_PERIOD;

        -- =========================================================
        -- Cenario 1: Validacao da Carga Inicial (Arquivo .dat)
        -- Verifica linhas especificas conhecidas do arquivo fornecido
        -- =========================================================
        
        -- Teste 1.1: Endereco 0 (Linha 1: 10000000)
        addr <= bit_vector(to_unsigned(0, ADDR_WIDTH));
        wait for TIME_DELTA;
        assert data_o = "10000000"
            report "Falha Cenario 1.1: Endereco 0. Esperado 10000000 (x80)" severity error;
        
        -- Teste 1.2: Endereco 15 (Linha 16: 00001001)
        addr <= bit_vector(to_unsigned(15, ADDR_WIDTH));
        wait for TIME_DELTA;
        assert data_o = "00001001"
            report "Falha Cenario 1.2: Endereco 15. Esperado 00001001 (x09)" severity error;

        -- Teste 1.3: Endereco 23 (Linha 24: 00001111)
        addr <= bit_vector(to_unsigned(23, ADDR_WIDTH));
        wait for TIME_DELTA;
        assert data_o = "00001111"
            report "Falha Cenario 1.3: Endereco 23. Esperado 00001111 (x0F)" severity error;

        report "Cenario 1: Validacao da Carga Inicial -> SUCESSO" severity note;

        -- =========================================================
        -- Cenario 2: Escrita Sincrona
        -- Escrever o valor AA (10101010) no endereco 30 (vazio)
        -- =========================================================
        wait until clock = '0'; 
        addr   <= bit_vector(to_unsigned(30, ADDR_WIDTH));
        data_i <= "10101010"; -- Hex AA
        wr     <= '1';        -- Habilita escrita
        
        wait until clock = '1'; -- Borda de subida (Momento da escrita)
        wait for TIME_DELTA;    
        
        wr <= '0'; -- Desabilita escrita para o proximo ciclo

        assert data_o = "10101010"
            report "Falha Cenario 2: Escrita Sincrona. Esperado AA" severity error;
            
        report "Cenario 2: Escrita Sincrona -> SUCESSO" severity note;

        -- =========================================================
        -- Cenario 3: Protecao de Escrita (Write Disable)
        -- Tentar escrever 55 (01010101) no mesmo endereco 30 com WR=0
        -- =========================================================
        wait until clock = '0';
        addr   <= bit_vector(to_unsigned(30, ADDR_WIDTH));
        data_i <= "01010101"; -- Hex 55
        wr     <= '0';        -- DESABILITA escrita
        
        wait until clock = '1'; 
        wait for TIME_DELTA;

        assert data_o = "10101010" -- Deve manter o valor antigo (AA)
            report "Falha Cenario 3: Protecao de escrita violada. Valor alterado incorretamente." severity error;

        report "Cenario 3: Protecao de Escrita -> SUCESSO" severity note;

        -- =========================================================
        -- Cenario 4: Leitura Assincrona e Persistencia
        -- Ler outro endereco e voltar para confirmar o dado gravado
        -- =========================================================
        
        -- Passo A: Ler endereco 0 (deve ser 10000000 do arquivo)
        addr <= bit_vector(to_unsigned(0, ADDR_WIDTH));
        wait for TIME_DELTA; -- Apenas atraso combinacional, sem clock
        
        assert data_o = "10000000" 
            report "Falha Cenario 4A: Leitura assincrona do endereco 0 falhou." severity error;

        -- Passo B: Voltar para endereco 30 (deve ter mantido AA da escrita anterior)
        addr <= bit_vector(to_unsigned(30, ADDR_WIDTH));
        wait for TIME_DELTA;

        assert data_o = "10101010"
            report "Falha Cenario 4B: Persistencia do dado gravado falhou." severity error;

        report "Cenario 4: Leitura Assincrona e Persistencia -> SUCESSO" severity note;

        report ">>> FIM DOS TESTES: MEMORIA DE DADOS VALIDADA <<<";
        simulando <= '0';
        wait;
    end process;

end architecture testbench;