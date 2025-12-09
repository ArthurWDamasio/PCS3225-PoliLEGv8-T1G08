
------------------------------------------------------------
-- Andre Saliba     NUSP: 15439911   Turma: 1 Grupo:T1G08 --
-- Arthur Damasio   NUSP: 15635138   Turma: 1 Grupo:T1G08 --
-- Joao Vitor Rocha NUSP: 15638465   Turma: 1 Grupo:T1G08 --
-- Henrique Falcao  NUSP: 15459010   Turma: 1 Grupo:T1G08 --
-- Pedro Beraldo    NUSP: 15484328   Turma: 1 Grupo:T1G08 --
-- Thiago Medeiros  NUSP: 15651404   Turma: 1 Grupo:T1G08 --
------------------------------------------------------------


entity regfile is
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
end entity regfile;

architecture estrutural of regfile is

    -- Instanciacao do componente reg
    component reg is 
        generic (dataSize: natural := 64);
        port (
            clock:  in bit;
            reset:  in bit;
            enable: in bit;
            d:      in bit_vector(dataSize-1 downto 0);
            q:      out bit_vector(dataSize-1 downto 0)
        );
    end component;
    
    -- TIPO INTERNO
    type reg_array_type is array (0 to 31) of bit_vector(63 downto 0);
    
    -- SINAIS
    signal reg_outputs : reg_array_type;          -- Banco dos registradores
    signal write_enables : bit_vector(31 downto 0); -- Sinais de enable pro generate

    -- Conversor
    function bv_to_int(bv : bit_vector(4 downto 0)) return integer is
        variable result : integer := 0;
    begin
        for i in 0 to 4 loop
            if bv(i) = '1' then
                result := result + 2**i;
            end if;
        end loop;
        return result;
    end function;

begin
    -- Write Decoder
    process(regWrite, wr)
        variable write_index : integer;
    begin
        write_enables <= (others => '0');
        
        -- Converte o endereço de escrita
        write_index := bv_to_int(wr);
        
        if (regWrite = '1') and (write_index < 31) then
            write_enables(write_index) <= '1';
        end if;
    end process;
	
    -- Instanciacao dos regs X0 a X30 com generate
    GEN_REGS: for i in 0 to 30 generate 
        REG_INST: reg
            generic map (dataSize => 64)
            port map (
                clock  => clock,
                reset  => reset,
                enable => write_enables(i), -- Enable vindo do decodificador
                d      => d,                -- Dado de entrada comum a todos
                q      => reg_outputs(i)    -- Saída conectada ao array
            );
    end generate GEN_REGS;
   
    reg_outputs(31) <= (others => '0'); -- X31 sempre zerado

    -- Mux 1
    q1 <= reg_outputs(bv_to_int(rr1));
    
    -- Mux 2
    q2 <= reg_outputs(bv_to_int(rr2));

end architecture estrutural;