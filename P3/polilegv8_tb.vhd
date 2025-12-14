------------------------------------------------------------
-- Andre Saliba     NUSP: 15439911   Turma: 1 Grupo:T1G08 --
-- Arthur Damasio   NUSP: 15635138   Turma: 1 Grupo:T1G08 --
-- Joao Vitor Rocha NUSP: 15638465   Turma: 1 Grupo:T1G08 --
-- Henrique Falcao  NUSP: 15459010   Turma: 1 Grupo:T1G08 --
-- Pedro Beraldo    NUSP: 15484328   Turma: 1 Grupo:T1G08 --
-- Thiago Medeiros  NUSP: 15651404   Turma: 1 Grupo:T1G08 --
------------------------------------------------------------

entity tb_polilegv8 is
end entity tb_polilegv8;

architecture arch_tb_polilegv8 of tb_polilegv8 is

    component polilegv8 is
        port (
            clock : in bit;
            reset : in bit
        );
    end component;

    -- Sinais de teste
    signal clock_tb : bit := '0';
    signal reset_tb : bit := '1';
    
    constant PERIODO_CLK : time := 20 ns; -- 50 MHz
    constant TEMPO_SIMULACAO : time := 500 ns; 
    
    -- para depuração
    function bit_vector_to_hex(bv : bit_vector) return string is
        constant HEX_DIGITS : string(1 to 16) := "0123456789ABCDEF";
        variable result : string(1 to (bv'length+3)/4);
        variable temp : bit_vector(3 downto 0);
        variable index : natural;
    begin
        for i in result'range loop
            index := (result'length - i) * 4;
            if index + 3 < bv'length then
                temp := bv(index+3 downto index);
            else
                temp := (others => '0');
                for j in 0 to 3 loop
                    if index + j < bv'length then
                        temp(j) := bv(index + j);
                    end if;
                end loop;
            end if;
            case temp is
                when "0000" => result(i) := HEX_DIGITS(1);
                when "0001" => result(i) := HEX_DIGITS(2);
                when "0010" => result(i) := HEX_DIGITS(3);
                when "0011" => result(i) := HEX_DIGITS(4);
                when "0100" => result(i) := HEX_DIGITS(5);
                when "0101" => result(i) := HEX_DIGITS(6);
                when "0110" => result(i) := HEX_DIGITS(7);
                when "0111" => result(i) := HEX_DIGITS(8);
                when "1000" => result(i) := HEX_DIGITS(9);
                when "1001" => result(i) := HEX_DIGITS(10);
                when "1010" => result(i) := HEX_DIGITS(11);
                when "1011" => result(i) := HEX_DIGITS(12);
                when "1100" => result(i) := HEX_DIGITS(13);
                when "1101" => result(i) := HEX_DIGITS(14);
                when "1110" => result(i) := HEX_DIGITS(15);
                when "1111" => result(i) := HEX_DIGITS(16);
                when others => result(i) := 'X';
            end case;
        end loop;
        return result;
    end function;
    
    function to_string(b : bit) return string is
    begin
        if b = '1' then
            return "1";
        else
            return "0";
        end if;
    end function;
    
    function to_string(bv : bit_vector) return string is
        variable result : string(1 to bv'length);
    begin
        for i in bv'range loop
            if bv(i) = '1' then
                result(bv'length - i) := '1';
            else
                result(bv'length - i) := '0';
            end if;
        end loop;
        return result;
    end function;

begin

    DUT: polilegv8
        port map (
            clock => clock_tb,
            reset => reset_tb
        );

    process -- geração do clock
    begin
        while now < TEMPO_SIMULACAO loop
            clock_tb <= '0';
            wait for PERIODO_CLK / 2;
            clock_tb <= '1';
            wait for PERIODO_CLK / 2;
        end loop;
        report "Simulação finalizada após " & time'image(now);
        wait;
    end process;

    process -- Processo de sequência de reset
    begin
        reset_tb <= '1'; -- Reset inicial
        wait for PERIODO_CLK * 2;
        reset_tb <= '0';
        wait for TEMPO_SIMULACAO - PERIODO_CLK * 2; -- Aguarda execução do programa completo
        wait;  -- Finaliza simulação
    end process;

    process -- geracao de logs
        variable ciclo : integer := 0;
        variable ultimo_pc : bit_vector(63 downto 0) := (others => '0');
    begin

        wait until reset_tb = '0'; -- Aguarda fim do reset
        while now < TEMPO_SIMULACAO loop -- Monitora a cada ciclo de clock
            wait until rising_edge(clock_tb);
            ciclo := ciclo + 1;
            
            if ciclo mod 5 = 0 then  -- Report a cada 5 ciclos
                report "Ciclo " & integer'image(ciclo) & " - Tempo: " & time'image(now);
            end if;
            
            if ciclo > 100 then
                report "Execução do programa completa ou em loop infinito" severity note;
                exit;
            end if;
        end loop;
        wait;
    end process;

end architecture arch_tb_polilegv8;