------------------------------------------------------------
-- Andre Saliba     NUSP: 15439911   Turma: 1 Grupo:T1G08 --
-- Arthur Damasio   NUSP: 15635138   Turma: 1 Grupo:T1G08 --
-- Joao Vitor Rocha NUSP: 15638465   Turma: 1 Grupo:T1G08 --
-- Henrique Falcao  NUSP: 15459010   Turma: 1 Grupo:T1G08 --
-- Pedro Beraldo    NUSP: 15484328   Turma: 1 Grupo:T1G08 --
-- Thiago Medeiros  NUSP: 15651404   Turma: 1 Grupo:T1G08 --
------------------------------------------------------------
library ieee;
library std;
use ieee.numeric_bit.all;
use std.all;


entity fluxoDados is
    port(
        clock : in bit; -- entrada de clock
        reset : in bit; -- clear assincrono
        extendMSB : in bit_vector (4 downto 0); -- sinal de controle sign-extend
        extendLSB : in bit_vector (4 downto 0); -- sinal de controle sign-extend
        reg2Loc : in bit; -- sinal de controle MUX Read Register 2
        regWrite : in bit; -- sinal de controle Write Register
        aluSrc : in bit; -- sinal de controle MUX entrada B ULA
        alu_control : in bit_vector (3 downto 0); -- sinal de controle da ULA
        branch : in bit; -- sinal de controle desvio condicional
        uncondBranch : in bit; -- sinal de controle desvio incondicional
        memRead : in bit; -- sinal de controle leitura RAM dados
        memWrite : in bit; -- sinal de controle escrita RAM dados
        memToReg : in bit; -- sinal de controle MUX Write Data
        opcode : out bit_vector (10 downto 0) -- sinal de condição código da instrução
    );
end entity fluxoDados;

architecture arch_fluxoDados of fluxoDados is
    component reg is
        generic (dataSize : natural := 64);
        port (
            clock, reset : in bit;
            enable       : in bit;
            d            : in bit_vector (dataSize-1 downto 0);
            q            : out bit_vector (dataSize-1 downto 0)
        );
    end component;

    component mux_n is 
        generic (dataSize: natural := 64);
        port(
            ino  : in bit_vector(dataSize-1 downto 0);
            in1  : in bit_vector(dataSize-1 downto 0);
            sel  : in bit;
            dOut : out bit_vector(dataSize-1 downto 0)
        );
    end component mux_n;

    component memoriaInstrucoes is
        generic (
            addressSize : natural ;
            dataSize    : natural ; 
            datFileName : string   
        );
        port (
            addr : in  bit_vector(addressSize-1 downto 0);
            data : out bit_vector(dataSize-1 downto 0)
        );
    end component memoriaInstrucoes;

    component memoriaDados is
        generic (
            addressSize : natural ;
            dataSize    : natural ;
            datFileName : string  
        );
        port (
            clock  : in  bit;
            wr     : in  bit;
            addr   : in  bit_vector(addressSize-1 downto 0);
            data_i : in  bit_vector(dataSize-1 downto 0);
            data_o : out bit_vector(dataSize-1 downto 0)
        );
    end component memoriaDados;

    component fulladder is
        port (
            a, b, cin: in bit;
            s, cout: out bit
        );
    end component;

    component adder_n is
        generic (
            dataSize: natural := 64
        );
        port(
            ino  : in  bit_vector(dataSize-1 downto 0);
            in1  : in  bit_vector(dataSize-1 downto 0);
            sum  : out bit_vector(dataSize-1 downto 0);
            cout : out bit
        );
    end component adder_n;

    component ula1bit is 
        port(
            a         : in bit;
            b         : in bit;
            cin       : in bit;
            ainvert   : in bit;
            binvert   : in bit;
            operation : in bit_vector(1 downto 0);
            result    : out bit;
            cout      : out bit;
            overflow  : out bit 
        );
    end component ula1bit;

    component sign_extend is
        generic (
            dataISize       : natural := 32; -- Tamanho do dado de entrada 
            dataOSize       : natural := 64; -- Tamanho do dado de saida 
            dataMaxPosition : natural := 5   -- Bits para definir as posicoes (log2(dataISize)) 
        );
        port(
            inData      : in bit_vector(dataISize-1 downto 0);       -- Vetor de entrada
            inDataStart : in bit_vector(dataMaxPosition-1 downto 0); -- Posicao do bit mais significativo (sinal) 
            inDataEnd   : in bit_vector(dataMaxPosition-1 downto 0); -- Posicao do bit menos significativo 
            outData     : out bit_vector(dataOSize-1 downto 0)       -- Vetor de saida estendido 
        );
    end component sign_extend;

    component two_left_shifts is 
        generic(
            dataSize: natural := 64
        );
        port(
            input: in bit_vector(dataSize-1 downto 0);
            output: out bit_vector(dataSize-1 downto 0)
        );
    end component two_left_shifts;

    component regfile is
        port(
            clock:    in bit;
            reset:    in bit;
            regWrite: in bit;                       -- Write enable
            rr1:      in bit_vector(4 downto 0);    -- Read reg 1
            rr2:      in bit_vector(4 downto 0);    -- Read reg 2
            wr:       in bit_vector(4 downto 0);    -- Write reg
            d:        in bit_vector(63 downto 0);   -- Write data
            q1:       out bit_vector(63 downto 0);  -- Reg Data 1
            q2:       out bit_vector(63 downto 0)   -- Reg Data 2
        );
    end component regfile;

    component ula is
        port(
            A: in bit_vector(63 downto 0);
            B: in bit_vector(63 downto 0);
            S: in bit_vector(3 downto 0);
            F: out bit_vector(63 downto 0);
            Z: out bit;
            Ov: out bit;
            Co: out bit
        );
    end component ula;

   -- Sinais Internos
    signal pc_in, pc_plus_4, branch_target : bit_vector(6 downto 0); -- próximo valor do PC e PC + 4
    signal instruction : bit_vector(31 downto 0); --Armazena a instrução de 32 bits

    signal instruction8 : bit_vector(7 downto 0);
    signal instruction16 : bit_vector(7 downto 0);
    signal instruction24 : bit_vector(7 downto 0);
    signal instruction32 : bit_vector(7 downto 0);
    
    signal pc_out0 : bit_vector(6 downto 0);
    signal pc_out1 : bit_vector(6 downto 0);
    signal pc_out2 : bit_vector(6 downto 0);
    signal pc_out3 : bit_vector(6 downto 0);

    -- Sinais do Banco de Registradores
    signal read_reg2_addr : bit_vector(4 downto 0); -- Armazena o endereço do segundo registrador que precisa ser lido.
    signal write_data, read_data1, read_data2 : bit_vector(63 downto 0); -- leitura ou escrita do dado de 64 bits que sera gravado no registrador de destino
    
    -- Sinais de Extensão e Deslocamento
    signal imm_extended, imm_shifted : bit_vector(63 downto 0);
    
    -- Sinais da ULA
    signal alu_b, alu_result : bit_vector(63 downto 0); --segunda entrada da ULA, resultado do multiplexador entre o valor imediato do read_data2 e o valor extendido
    signal zero_flag : bit; -- fica em '1' se o resultado da ULA for zero (cbz)
    
    -- Interface com a memória RAM para utilizar o memRead e memWrite
    signal mem_read_data : bit_vector(63 downto 0);
    signal mem_data_aux  : bit_vector(63 downto 0);
    
    -- sinal de seleção do multiplexador do PC
    signal pc_src : bit;
    
    -- Constante 4 para incremento do PC (7 bits)
    constant C_FOUR : bit_vector(6 downto 0) := (2 => '1', others => '0'); -- Valor 4

begin
    instruction <= instruction8 & instruction16 & instruction24 & instruction32; -- 0000 0000 0000 0000
    opcode <= instruction(31 downto 21);
    pc_out1 <= bit_vector(unsigned(pc_out0) +  "0000001"); 
    pc_out2 <= bit_vector(unsigned(pc_out0) +  "0000010"); 
    pc_out3 <= bit_vector(unsigned(pc_out0) +  "0000011"); 

    PC: reg 
        generic map (dataSize => 7)
        port map (
            clock => clock, 
            reset => reset, 
            enable => '1', 
            d => pc_in, 
            q => pc_out0
        );

    InstMem1: memoriaInstrucoes 
        generic map (
            addressSize => 7, 
            dataSize => 8, 
            datFileName => "memInstrPolilegv8.dat"
        )
        port map (
            addr => pc_out0, 
            data => instruction8
        );

    InstMem2: memoriaInstrucoes 
        generic map (
            addressSize => 7, 
            dataSize => 8, 
            datFileName => "memInstrPolilegv8.dat"
        )
        port map (
            addr => pc_out1, 
            data => instruction16
        );
    
    InstMem3: memoriaInstrucoes 
        generic map (
            addressSize => 7, 
            dataSize => 8, 
            datFileName => "./memInstrPolilegv8.dat"
        )
        port map (
            addr => pc_out2, 
            data => instruction24
        );
    
    InstMem4: memoriaInstrucoes 
        generic map (
            addressSize => 7, 
            dataSize => 8, 
            datFileName => "./memInstrPolilegv8.dat"
        )
        port map (
            addr => pc_out3, 
            data => instruction32
        );

	--Seleciona o endereço de leitura do registrador 2
    Mux_Reg2: mux_n 
        generic map (dataSize => 5) -- pdf pede 64 mas as entradas tem so 5 bits ?
        port map (
            ino  => instruction(20 downto 16), -- Rm
            in1  => instruction(4 downto 0),   -- Rt/Rd
            sel  => reg2Loc,
            dOut => read_reg2_addr
        );

    --Banco de Registradores
    RegistersBank: regfile 
        port map (
            clock    => clock,
            reset    => reset,
            regWrite => regWrite,
            rr1      => instruction(9 downto 5), -- Rn
            rr2      => read_reg2_addr,
            wr       => instruction(4 downto 0), -- Rd
            d        => write_data,
            q1       => read_data1,
            q2       => read_data2
        );

    --Extensor de Sinal de 32 para 64 bits
    SignExtend: sign_extend 
        generic map (
            dataISize => 32, 
            dataOSize => 64, 
            dataMaxPosition => 5)
        port map (
            inData      => instruction,
            inDataStart => extendMSB,
            inDataEnd   => extendLSB,
            outData     => imm_extended
        );
    
    -- Seleciona a segunda entrada da ULA
    Mux_ALU: mux_n 
        generic map (dataSize => 64)
        port map (
            ino  => read_data2,
            in1  => imm_extended,
            sel  => aluSrc,
            dOut => alu_b
        );

    ULA_P3: ula
        port map (
            A  => read_data1,
            B  => alu_b,
            S  => alu_control,
            F  => alu_result,
            Z  => zero_flag,
            Ov => open,
            Co => open
        );
    
    DataMem: memoriaDados
        generic map (
            addressSize => 7, --endereço recebido pela ULA
            dataSize => 64, -- pdf cita 8 bits, mas o dado é de 64 bits ???
            datFileName => "memDadosInicialPolilegv8.dat")
        port map (
            clock  => clock,
            wr     => memWrite,
            addr   => alu_result(6 downto 0), -- Endereço calculado pela ULA
            data_i => read_data2,             -- Dado para escrita vem do Reg2
            data_o => mem_data_aux
        );

    -- passa o dado se a leitura estiver habilitada 
    mem_read_data <= mem_data_aux when memRead = '1' else (others => '0');

    --Seleciona o dado a ser escrito no banco de registradores
    Mux_WriteBank: mux_n 
        generic map (dataSize => 64)
        port map (
            ino  => alu_result,
            in1  => mem_read_data,
            sel  => memToReg,
            dOut => write_data
        );
    
    -- Incremento do PC +4
    PC_4: adder_n  
        generic map (dataSize => 7)
        port map (
            ino => pc_out0,
            in1 => C_FOUR, 
            sum => pc_plus_4,
            cout => open
        );

    -- Deslocamento do offset da branch 
    ShiftBranch: two_left_shifts 
        generic map (dataSize => 64)
        port map (
            input => imm_extended, -- a entrada é o valor extendido
            output => imm_shifted -- a saída é o valor deslocado
        );

    -- PC + Offset deslocado
    PC_Branch: adder_n
        generic map (dataSize => 7)
        port map (
            ino => pc_out0, -- PC atual
            in1 => imm_shifted(6 downto 0), -- offset deslocado
            sum => branch_target, -- novo endereço de branch
            cout => open
        );
    
    pc_src <= (branch and zero_flag) or uncondBranch; --seleção do próximo PC

    Mux_PC: mux_n
        generic map (dataSize => 7)
        port map (
            ino  => pc_plus_4, -- próxima instrução sequencial
            in1  => branch_target, -- endereço de desvio
            sel  => pc_src, -- seleção do desvio
            dOut => pc_in -- próximo valor do PC
        );

end architecture arch_fluxoDados;
   