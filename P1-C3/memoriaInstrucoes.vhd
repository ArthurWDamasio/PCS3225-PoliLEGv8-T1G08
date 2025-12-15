library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity memoriaInstrucoes is
    generic (
        addressSize : natural := 8;
        dataSize    : natural := 32; -- Output is 32 bits
        datFileName : string  := "memInstr_conteudo.dat" 
    );
    port (
        addr : in  bit_vector(addressSize-1 downto 0);
        data : out bit_vector(dataSize-1 downto 0)
    );
end entity memoriaInstrucoes;

architecture mem_instru of memoriaInstrucoes is
    -- Memory array is 32-bit wide
    type mem_type is array (0 to (2**addressSize)-1) of bit_vector(dataSize-1 downto 0);
    
    impure function init_mem(filename : string) return mem_type is
        file mif_file : text open read_mode is filename;
        variable mif_line : line;
        variable temp_byte : bit_vector(7 downto 0); -- Read 8 bits at a time
        variable temp_word : bit_vector(31 downto 0);
        variable temp_mem : mem_type;
    begin
        temp_mem := (others => (others => '0'));
        for i in temp_mem'range loop
            -- Reconstruct 32-bit word from 4 lines (bytes)
            if not endfile(mif_file) then 
                readline(mif_file, mif_line); read(mif_line, temp_byte); 
                temp_word(31 downto 24) := temp_byte; 
            end if;
            if not endfile(mif_file) then 
                readline(mif_file, mif_line); read(mif_line, temp_byte); 
                temp_word(23 downto 16) := temp_byte; 
            end if;
            if not endfile(mif_file) then 
                readline(mif_file, mif_line); read(mif_line, temp_byte); 
                temp_word(15 downto 8) := temp_byte; 
            end if;
            if not endfile(mif_file) then 
                readline(mif_file, mif_line); read(mif_line, temp_byte); 
                temp_word(7 downto 0) := temp_byte; 
            end if;
            
            temp_mem(i) := temp_word;
        end loop;
        return temp_mem;
    end function;

    constant mem : mem_type := init_mem(datFileName);
begin
    -- Convert address (bit_vector) to integer for array indexing
    data <= mem(to_integer(unsigned(addr)));
end architecture mem_instru;