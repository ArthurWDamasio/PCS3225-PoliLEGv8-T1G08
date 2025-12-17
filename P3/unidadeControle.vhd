------------------------------------------------------------
-- Andre Saliba     NUSP: 15439911   Turma: 1 Grupo:T1G08 --
-- Arthur Damasio   NUSP: 15635138   Turma: 1 Grupo:T1G08 --
-- Joao Vitor Rocha NUSP: 15638465   Turma: 1 Grupo:T1G08 --
-- Henrique Falcao  NUSP: 15459010   Turma: 1 Grupo:T1G08 --
-- Pedro Beraldo    NUSP: 15484328   Turma: 1 Grupo:T1G08 --
-- Thiago Medeiros  NUSP: 15651404   Turma: 1 Grupo:T1G08 --
------------------------------------------------------------

entity unidadeControle is
    port(
        opcode : in bit_vector (10 downto 0); -- sinal de condição código da instrução
        extendMSB : out bit_vector (4 downto 0); -- sinal de controle sign-extend
        extendLSB : out bit_vector (4 downto 0); -- sinal de controle sign-extend
        reg2Loc : out bit; -- sinal de controle MUX Read Register 2
        regWrite : out bit; -- sinal de controle Write Register
        aluSrc : out bit; -- sinal de controle MUX entrada B ULA
        alu_control : out bit_vector (3 downto 0); -- sinal de controle da ULA
        branch : out bit; -- sinal de controle desvio condicional
        uncondBranch : out bit; -- sinal de controle desvio incondicional
        memRead : out bit; -- sinal de controle leitura RAM dados
        memWrite : out bit; -- sinal de controle escrita RAM dados
        memToReg : out bit -- sinal de controle MUX Write Data
    );
end entity unidadeControle;

architecture arch_unidadeControle of unidadeControle is

    constant C_ADD: bit_vector(10 downto 0) := "10001011000";
    constant C_SUB: bit_vector(10 downto 0) := "11001011000";
    constant C_AND: bit_vector(10 downto 0) := "10001010000";
    constant C_ORR: bit_vector(10 downto 0) := "10101010000";
    constant C_LDUR: bit_vector(10 downto 0) := "11111000010";
    constant C_STUR: bit_vector(10 downto 0) := "11111000000";
    constant C_CBZ: bit_vector(7 downto 0) := "10110100"; -- Opcode de 8 bits 10110100XXX
    constant C_B: bit_vector(5 downto 0) := "000101";  -- Opcode de 6 bits 000101XXXXX

begin

    process(opcode)
        variable reg2Loc_aux : bit;
        variable aluSrc_aux : bit;
        variable memToReg_aux : bit;
        variable regWrite_aux : bit;
        variable memRead_aux : bit;
        variable memWrite_aux : bit;
        variable branch_aux : bit;
        variable uncondBranch_aux : bit;
        variable alu_control_aux : bit_vector(3 downto 0);
        variable extendMSB_aux : bit_vector(4 downto 0);
        variable extendLSB_aux : bit_vector(4 downto 0);

    begin
        
        reg2Loc_aux := '0';
        aluSrc_aux := '0';
        memToReg_aux := '0';
        regWrite_aux := '0';
        memRead_aux := '0';
        memWrite_aux := '0';
        branch_aux := '0';
        uncondBranch_aux := '0';
        alu_control_aux := "0000";
        extendMSB_aux := "00000"; 
        extendLSB_aux := "00000";
        
        if opcode = ADD then 
            regWrite_aux := '1';
            alu_control_aux := "0010"; -- ADD

        elsif opcode = C_SUB then
            regWrite_aux := '1';
            alu_control_aux := "0110"; -- SUB

        elsif opcode = C_AND then
            regWrite_aux := '1';
            alu_control_aux := "0000"; -- AND

        elsif opcode = C_ORR then
            regWrite_aux := '1';
            alu_control_aux := "0001"; -- OR

        elsif opcode = C_LDUR then
            aluSrc_aux := '1';    -- Usa o imediato
            memToReg_aux := '1';    -- Vem da memória
            regWrite_aux := '1';    -- Escreve no registrador
            memRead_aux := '1';    -- Lê da memória
            alu_control_aux := "0010"; -- Soma (Base + Offset)
            extendMSB_aux := "10100";
            extendLSB_aux := "01100";

        elsif opcode = C_STUR then
            reg2Loc_aux     := '1';    -- O dado a gravar vem de Rt 
            aluSrc_aux      := '1';    -- Usa imediato (offset)
            memWrite_aux    := '1';    -- Escreve na memória
            alu_control_aux := "0010"; -- Soma (Base + Offset)
            extendMSB_aux   := "10100";
            extendLSB_aux   := "01100";

        elsif opcode(10 downto 3) = C_CBZ then
            reg2Loc_aux := '1';    -- Verifica o registrador Rt
            branch_aux := '1';    -- Ativa branch condicional
            alu_control_aux := "0011"; -- Pass B / Lógica para checar zero
            extendMSB_aux := "10111";
            extendLSB_aux := "00101";

        elsif opcode(10 downto 5) = C_B then
            uncondBranch_aux := '1';   -- Ativa branch incondicional
            extendMSB_aux := "11001";
            extendLSB_aux := "00000"; 

        else
            null;
        end if;

        reg2Loc      <= reg2Loc_aux;
        aluSrc       <= aluSrc_aux;
        memToReg     <= memToReg_aux;
        regWrite     <= regWrite_aux;
        memRead      <= memRead_aux;
        memWrite     <= memWrite_aux;
        branch       <= branch_aux;
        uncondBranch <= uncondBranch_aux;
        alu_control  <= alu_control_aux;
        extendMSB    <= extendMSB_aux;
        extendLSB    <= extendLSB_aux;
        
    end process;
end architecture arch_unidadeControle;