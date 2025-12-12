------------------------------------------------------------
-- Andre Saliba     NUSP: 15439911   Turma: 1 Grupo:T1G08 --
-- Arthur Damasio   NUSP: 15635138   Turma: 1 Grupo:T1G08 --
-- Joao Vitor Rocha NUSP: 15638465   Turma: 1 Grupo:T1G08 --
-- Henrique Falcao  NUSP: 15459010   Turma: 1 Grupo:T1G08 --
-- Pedro Beraldo    NUSP: 15484328   Turma: 1 Grupo:T1G08 --
-- Thiago Medeiros  NUSP: 15651404   Turma: 1 Grupo:T1G08 --
------------------------------------------------------------

entity polilegv8 is
    port (
        clock : in bit;
        reset : in bit
    );
end entity polilegv8;

architecture structure of polilegv8 is

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
    
    -- FluxoDados -> UnidadeControle
    signal opcode_aux: bit_vector (10 downto 0); 
    signal extendMSB_aux: bit_vector (4 downto 0);
    signal extendLSB_aux: bit_vector (4 downto 0);
    signal reg2Loc_aux: bit;
    signal regWrite_aux: bit;
    signal aluSrc_aux: bit;
    signal alu_control_aux: bit_vector (3 downto 0);
    signal branch_aux: bit;
    signal uncondBranch_aux: bit;
    signal memRead_aux: bit;
    signal memWrite_aux: bit;
    signal memToReg_aux: bit;

begin

    UC : unidadeControle
        port map (
            opcode => opcode_aux,
            extendMSB => extendMSB_aux,
            extendLSB => extendLSB_aux,
            reg2Loc => reg2Loc_aux,
            regWrite => regWrite_aux,
            aluSrc => aluSrc_aux,
            alu_control => alu_control_aux,
            branch => branch_aux,
            uncondBranch => uncondBranch_aux,
            memRead => memRead_aux,
            memWrite => memWrite_aux,
            memToReg => memToReg_aux
        );

    FD : fluxoDados
        port map (
            clock => clock,
            reset => reset,
            extendMSB => extendMSB_aux,
            extendLSB => extendLSB_aux,
            reg2Loc => reg2Loc_aux,
            regWrite => regWrite_aux,
            aluSrc => aluSrc_aux,
            alu_control => alu_control_aux,
            branch => branch_aux,
            uncondBranch => uncondBranch_aux,
            memRead => memRead_aux,
            memWrite => memWrite_aux,
            memToReg => memToReg_aux,
            opcode => opcode_aux
        );

end architecture structure;