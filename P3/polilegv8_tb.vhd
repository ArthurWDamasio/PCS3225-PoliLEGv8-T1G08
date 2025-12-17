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

entity tb_polilegv8_debug is
end entity tb_polilegv8_debug;

architecture simulation of tb_polilegv8_debug is

    -- Componentes Originais (interface idêntica aos arquivos .vhd)
    component fluxoDados is
        port(
            clock: in bit;
            reset: in bit;
            extendMSB: in bit_vector (4 downto 0);
            extendLSB: in bit_vector (4 downto 0);
            reg2Loc: in bit;
            regWrite: in bit;
            aluSrc: in bit;
            alu_control: in bit_vector (3 downto 0);
            branch: in bit;
            uncondBranch: in bit;
            memRead: in bit;
            memWrite: in bit;
            memToReg: in bit;
            opcode: out bit_vector (10 downto 0)
        );
    end component;
    
    component unidadeControle is
        port(
            opcode: in bit_vector (10 downto 0);
            extendMSB: out bit_vector (4 downto 0);
            extendLSB: out bit_vector (4 downto 0);
            reg2Loc: out bit;
            regWrite: out bit;
            aluSrc: out bit;
            alu_control: out bit_vector (3 downto 0);
            branch: out bit;
            uncondBranch: out bit;
            memRead: out bit;
            memWrite: out bit;
            memToReg: out bit
        );
    end component;

    -- Sinais de Clock e Reset
    signal tb_clock : bit := '0';
    signal tb_reset : bit := '0';
    constant CLK_PERIOD : time := 10 ns; 

    -- Sinais Intermediários para Debug (White-Box)
    signal opcode_debug       : bit_vector (10 downto 0);
    signal extendMSB_debug    : bit_vector (4 downto 0);
    signal extendLSB_debug    : bit_vector (4 downto 0);
    signal reg2Loc_debug      : bit;
    signal regWrite_debug     : bit;
    signal aluSrc_debug       : bit;
    signal alu_control_debug  : bit_vector (3 downto 0);
    signal branch_debug       : bit;
    signal uncondBranch_debug : bit;
    signal memRead_debug      : bit;
    signal memWrite_debug     : bit;
    signal memToReg_debug     : bit;

    -- String para facilitar a leitura no Waveform
    signal debug_instr_str : string(1 to 4) := "...."; 

begin

    -- Geração do Clock (100 MHz)
    tb_clock <= not tb_clock after CLK_PERIOD / 2;

    -- Instância: Unidade de Controle
    UC_Inst : unidadeControle
        port map (
            opcode       => opcode_debug,
            extendMSB    => extendMSB_debug,
            extendLSB    => extendLSB_debug,
            reg2Loc      => reg2Loc_debug,
            regWrite     => regWrite_debug,
            aluSrc       => aluSrc_debug,
            alu_control  => alu_control_debug,
            branch       => branch_debug,
            uncondBranch => uncondBranch_debug,
            memRead      => memRead_debug,
            memWrite     => memWrite_debug,
            memToReg     => memToReg_debug
        );

    -- Instância: Fluxo de Dados
    FD_Inst : fluxoDados
        port map (
            clock        => tb_clock,
            reset        => tb_reset,
            extendMSB    => extendMSB_debug,
            extendLSB    => extendLSB_debug,
            reg2Loc      => reg2Loc_debug,
            regWrite     => regWrite_debug,
            aluSrc       => aluSrc_debug,
            alu_control  => alu_control_debug,
            branch       => branch_debug,
            uncondBranch => uncondBranch_debug,
            memRead      => memRead_debug,
            memWrite     => memWrite_debug,
            memToReg     => memToReg_debug,
            opcode       => opcode_debug
        );

    -- Processo de Estímulo e Controle de Fim de Simulação
    stim_proc: process
    begin
        -- 1. Reset inicial
        tb_reset <= '1';
        wait for CLK_PERIOD * 2; 
        tb_reset <= '0';
        
        -- 2. Aguarda a execução do programa
        -- O programa fornecido na imagem tem cerca de 14 instruções.
        -- Como termina em um loop infinito (B #0), não há sinal de "done" automático.
        -- Esperamos ciclos suficientes para rodar todas as instruções e entrar no loop.
        wait for 300 ns; -- 30 ciclos de clock (suficiente para o programa)
        
        -- 3. Encerra a simulação forçadamente
        report "Fim do programa (Timeout atingido para loop infinito)" severity note;
        assert false report "Simulation Finished Successfully" severity failure;
        wait;
    end process;

    -- Monitor de Instruções (Decodificador de Strings)
    -- Baseado estritamente na tabela da imagem fornecida
    monitor_proc: process(opcode_debug)
    begin
        -- Reset da string para evitar latch de valores antigos errados
        debug_instr_str <= "????";

        if opcode_debug = "11111000010" then
            debug_instr_str <= "LDUR"; --
            
        elsif opcode_debug = "11111000000" then
            debug_instr_str <= "STUR"; --
            
        elsif opcode_debug = "10001011000" then
            debug_instr_str <= "ADD "; --
            
        elsif opcode_debug = "11001011000" then
            debug_instr_str <= "SUB "; --
            
        elsif opcode_debug = "10001010000" then
            debug_instr_str <= "AND "; --
            
        elsif opcode_debug = "10101010000" then
            debug_instr_str <= "ORR "; --
            
        -- CBZ: 10110100XXX (Checa apenas os 8 bits superiores)
        elsif opcode_debug(10 downto 3) = "10110100" then
            debug_instr_str <= "CBZ "; --

        -- Branch Incondicional (B): 000101XXXXX (Padrão do LEGv8/Código UC)
        elsif opcode_debug(10 downto 5) = "000101" then
            debug_instr_str <= "B   ";
            
        else
            debug_instr_str <= "UNKN"; -- Unknown/Nop
        end if;
    end process;

end architecture simulation;