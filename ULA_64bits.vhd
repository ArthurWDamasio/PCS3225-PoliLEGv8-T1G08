library ieee;
use ieee.numeric_bit.all;

entity ula is
    port(
        A: in bit_vector(63 downto 0);
        B: in bit_vector(63 downto 0);
        S: in bit_vector(3 downto 0);
        F: out bit_vector(63 downto 0);
        Z: out bit;
        Ov: out bit;
        Co: out bit
    );
end entity ula;

architecture estrutura of ula is

    -- Componente ULA-1bit
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
    end component;

    -- Sinal de Carrys (65 bits, pro último ir pra flag sem mudar a lógica do generate)
    signal cin_carry : bit_vector(0 to 64); 
    
    -- Sinal de Overflows
    signal overflow_internal : bit_vector(0 to 63);
	-- Sinal interno para utilizar F na flag Z
    signal F_interno : bit_vector(63 downto 0);
begin

    -- O Carry-in de ALU0 é o sinal Binvert (S(2))
    cin_carry(0) <= S(2);

    -- Instanciação de 64 ULAs de 1 bit usando generate
    ULA_Generate: for i in 0 to 63 generate

        -- Conexões de ULA(i)
        ula_inst: ula1bit
            port map (
                a         => A(i),
                b         => B(i),
                cin       => cin_carry(i),
                ainvert   => S(3),
                binvert   => S(2),
                operation => S(1 downto 0),
                result    => F_interno(i),
                
                -- O carry-out desta fatia é o carry-in da próxima
                -- O Carry-out de ALU63 é a saída Co
                cout      => cin_carry(i+1),
                
                -- O overflow desta fatia é conectado à saída Ov.
                overflow  => overflow_internal(i) 
            );

    end generate ULA_Generate;
    -- Flag Co, Carry Out da ULA 63
    Co <= cin_carry(64); 

    -- Flag Ov, Overflow da ULA 63
    Ov <= overflow_internal(63); 

    -- Flag Z, em prática um NOR
    Z <= '1' when F_interno = "0000000000000000000000000000000000000000000000000000000000000000" else '0';
	
    F<= F_interno;
end architecture estrutura;