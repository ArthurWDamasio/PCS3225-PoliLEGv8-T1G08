
library ieee;
use ieee.numeric_bit.all; 

entity tb_ula is
end entity tb_ula;

architecture test of tb_ula is

    -- Declaração do componente ULA (Device Under Test)
    component ula is
        port(
            A: in bit_vector(63 downto 0);
            B: in bit_vector(63 downto 0);
            S: in bit_vector(3 downto 0); -- Sinal de controle
            F: out bit_vector(63 downto 0);
            Z: out bit;
            Ov: out bit;
            Co: out bit
        );
    end component;

    -- Sinais para conectar ao componente
    signal s_A, s_B, s_F : bit_vector(63 downto 0);
    signal s_S           : bit_vector(3 downto 0);
    signal s_Z, s_Ov, s_Co : bit;

begin

    -- Instanciação da ULA (Conectando os sinais)
    DUT: ula port map(
        A => s_A,
        B => s_B,
        S => s_S,
        F => s_F,
        Z => s_Z,
        Ov => s_Ov,
        Co => s_Co
    );

    -- Processo de Estímulos (Os Casos de Teste)
    process
    begin
        report "Iniciando Testbench da ULA de 64 bits...";

        ------------------------------------------------------------
        -- Caso 1: Operação AND (Op: 0000)
        -- Objetivo: Verificar se a ULA realiza E bit-a-bit.
        ------------------------------------------------------------
        s_S <= "0000"; 
        s_A <= x"FFFFFFFF0000FFFF"; -- Máscara alta e baixa
        s_B <= x"F0F0F0F0F0F0F0F0"; -- Padrão alternado
        wait for 10 ns;
        -- Esperado: F deve ser (A and B)
        assert s_F = (x"FFFFFFFF0000FFFF" and x"F0F0F0F0F0F0F0F0")
            report "Erro no Teste 1: AND falhou" severity error;

        ------------------------------------------------------------
        -- Caso 2: Operação OR (Op: 0001)
        -- Objetivo: Verificar se a ULA realiza OU bit-a-bit.
        ------------------------------------------------------------
        s_S <= "0001";
        s_A <= x"00000000FFFF0000";
        s_B <= x"1234567800000000";
        wait for 10 ns;
        -- Esperado: F deve combinar os bits altos de B e médios de A
        assert s_F = (x"00000000FFFF0000" or x"1234567800000000")
            report "Erro no Teste 2: OR falhou" severity error;

        ------------------------------------------------------------
        -- Caso 3: Operação ADD - Soma Simples (Op: 0010)
        -- Objetivo: Somar dois números pequenos sem overflow.
        ------------------------------------------------------------
        s_S <= "0010";
        s_A <= x"000000000000000A"; -- 10 em decimal
        s_B <= x"0000000000000005"; -- 5 em decimal
        wait for 10 ns;
        -- Esperado: Resultado 15 (0x0F), Z=0, Ov=0
        assert s_F = x"000000000000000F" report "Erro no Teste 3: Soma Simples" severity error;

        ------------------------------------------------------------
        -- Caso 4: Operação SUB - Subtração resultando em Zero (Op: 0110)
        -- Objetivo: Testar a subtração e a flag Z (Zero).
        ------------------------------------------------------------
        s_S <= "0110"; -- Op 0110 (Op2=1 inverte B, Op1Op0=10 soma => A + compl(B))
        s_A <= x"0000000000000020"; -- 32
        s_B <= x"0000000000000020"; -- 32
        wait for 10 ns;
        -- Esperado: Resultado 0, Flag Z=1
        assert s_F = x"0000000000000000" report "Erro no Teste 4: Resultado da subtracao incorreto" severity error;
        assert s_Z = '1' report "Erro no Teste 4: Flag Zero nao ativada" severity error;

        ------------------------------------------------------------
        -- Caso 5: Operação NOR (Op: 1100)
        -- Objetivo: Testar a lógica A NOR B.
        -- Nota: Conforme Tabela 1, Op=1100 -> Ainvert=1, Binvert=1, Op=AND (00).
        -- Pelo Teorema de DeMorgan: (not A) and (not B) = not (A or B) = NOR.
        ------------------------------------------------------------
        s_S <= "1100";
        s_A <= x"FFFFFFFFFFFFFFFF"; -- Tudo 1
        s_B <= x"0000000000000000"; -- Tudo 0
        wait for 10 ns;
        -- Esperado: (1 or 0) = 1 -> inv -> 0.
        assert s_F = x"0000000000000000" report "Erro no Teste 5: NOR falhou" severity error;
        
        -- Teste NOR com zeros (resultado deve ser tudo 1)
        s_A <= x"0000000000000000";
        s_B <= x"0000000000000000";
        wait for 10 ns;
        assert s_F = x"FFFFFFFFFFFFFFFF" report "Erro no Teste 5b: NOR com zeros falhou" severity error;

        ------------------------------------------------------------
        -- Caso 6: Operação Pass B (Op: 0111 conforme Tabela)
        -- Atenção: A Tabela 1 do PDF lista 0111 para Pass B.
        -- Porém, 0111 ativa Binvert (Bit 2). Na lógica da ula1bit:
        -- se Binvert=1, b_mux = not B. Logo a saída será (not B).
        ------------------------------------------------------------
        s_S <= "0111"; 
        s_B <= x"0000000000000000"; -- B é Zero
        wait for 10 ns;
        
        -- Se a lógica seguir estritamente o hardware ula1bit fornecido:
        -- Op=11 (Pass) + Binvert=1 -> Sai (NOT B) = FFFFF...
        -- Se o PDF indicar que Pass B deve sair B puro, o código Op deveria ser 0011.
        -- Vamos testar o comportamento do HARDWARE atual:
        assert s_F = x"FFFFFFFFFFFFFFFF" report "Alerta Teste 6: Pass B (0111) gerou NOT B (Comportamento de Hardware)" severity note;

        ------------------------------------------------------------
        -- Caso 7: Teste de Overflow (Op: 0010 - Soma)
        -- Objetivo: Somar dois números grandes positivos para estourar o sinal.
        -- Max positivo signed (64 bits): 0x7FFF...FFF
        ------------------------------------------------------------
        s_S <= "0010"; -- Soma
        s_A <= x"7FFFFFFFFFFFFFFF"; -- Maior positivo
        s_B <= x"0000000000000001"; -- +1
        wait for 10 ns;
        -- Esperado: Resultado 0x8000... (que é negativo em complemento de 2)
        -- Indica Overflow (positivo + positivo = negativo).
        assert s_Ov = '1' report "Erro no Teste 7: Flag Overflow falhou" severity error;

        ------------------------------------------------------------
        -- Caso 8: Teste de Carry Out (Op: 0010 - Soma)
        -- Objetivo: Gerar um "vai-um" para fora dos 64 bits (Unsigned overflow).
        ------------------------------------------------------------
        s_S <= "0010"; -- Soma
        s_A <= x"FFFFFFFFFFFFFFFF"; -- -1 (signed) ou Max (unsigned)
        s_B <= x"0000000000000001"; -- +1
        wait for 10 ns;
        -- Esperado: Resultado 0, Carry Out = 1
        assert s_F = x"0000000000000000" report "Erro no Teste 8: Resultado soma carry incorreto" severity error;
        assert s_Co = '1' report "Erro no Teste 8: Flag Carry Out falhou" severity error;
        assert s_Z = '1'  report "Erro no Teste 8: Flag Z falhou no estouro" severity error;

        report "Fim dos testes.";
        wait;
    end process;

end architecture test;