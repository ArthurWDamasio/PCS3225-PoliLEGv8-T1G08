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

entity tb_memoriaInstrucoes is
end entity tb_memoriaInstrucoes;

architecture testbench of tb_memoriaInstrucoes is
    component memoriaInstrucoes is
        generic (
            addressSize : natural := 8;
            dataSize    : natural := 8; 
            datFileName : string  := "memInstr_conteudo.dat" 
        );
        port (
            addr : in  bit_vector(addressSize-1 downto 0);
            data : out bit_vector(dataSize-1 downto 0)
        );
    end component;

    constant TIME_DELTA : time := 10 ns;
    constant ADDR_WIDTH : natural := 8;
    constant DATA_WIDTH : natural := 8;
    
    signal simulando : bit := '1';
    signal addr : bit_vector(ADDR_WIDTH-1 downto 0);
    signal data : bit_vector(DATA_WIDTH-1 downto 0);

begin
    -- Instancia com o arquivo especifico fornecido
    UUT: memoriaInstrucoes
        generic map (
            addressSize => ADDR_WIDTH,
            dataSize    => DATA_WIDTH,
            datFileName => "memInstr_conteudo.dat"
        )
        port map (
            addr => addr,
            data => data
        );

    processo_estimulo : process
    begin
        report ">>> INICIANDO TESTES DA MEMORIA DE INSTRUCOES <<<";

        -- =========================================================
        -- Cenario 1: Endereco 0 (Primeira linha do arquivo)
        -- Valor esperado: 11111000
        -- =========================================================
        addr <= (others => '0'); 
        wait for TIME_DELTA;
        
        assert data = "11111000" 
            report "Falha Cenario 1: Endereco 0 incorreto. Esperado 11111000" 
            severity error;
            
        report "Cenario 1: Leitura do Endereco Base -> SUCESSO" severity note;

        -- =========================================================
        -- Cenario 2: Endereco 1 (Segunda linha do arquivo)
        -- Valor esperado: 01000000
        -- =========================================================
        addr <= bit_vector(to_unsigned(1, ADDR_WIDTH));
        wait for TIME_DELTA;
        
        assert data = "01000000" 
            report "Falha Cenario 2: Endereco 1 incorreto. Esperado 01000000" 
            severity error;

        report "Cenario 2: Leitura Sequencial -> SUCESSO" severity note;

        -- =========================================================
        -- Cenario 3: Endereco 33 (Linha 34 do arquivo - Padrao de uns)
        -- Valor esperado: 11111111
        -- =========================================================
        addr <= bit_vector(to_unsigned(33, ADDR_WIDTH));
        wait for TIME_DELTA;
        
        assert data = "11111111" 
            report "Falha Cenario 3: Endereco 33 incorreto. Esperado 11111111" 
            severity error;

        report "Cenario 3: Leitura Intermediaria -> SUCESSO" severity note;

        -- =========================================================
        -- Cenario 4: Endereco 63 (Ultima linha do arquivo)
        -- Valor esperado: 00000000
        -- =========================================================
        addr <= bit_vector(to_unsigned(63, ADDR_WIDTH));
        wait for TIME_DELTA;
        
        assert data = "00000000" 
            report "Falha Cenario 4: Endereco 63 incorreto. Esperado 00000000" 
            severity error;

        report "Cenario 4: Leitura de Limite -> SUCESSO" severity note;

        report ">>> FIM DOS TESTES: CONTEUDO DA MEMORIA VALIDADO <<<";
        simulando <= '0';
        wait;
    end process;

end architecture testbench;