package body array_memory is

    impure function InitRamFromFile(RamFileName : in string; RamDepth : in natural) return signed_array is

        FILE RamFile : text open read_mode is RamFileName;
    
        constant ram_width : natural := 16;
        variable RamFileLine : line;    
        variable RAM         : signed_array(0 to RamDepth-1);
        variable mem         : bit_vector(ram_width-1 downto 0);

        begin

            for i in 0 to RamDepth-1 loop
                readline(RamFile, RamFileLine);
                read(RamFileLine, mem);
                RAM(i) := signed(to_stdlogicvector(mem));
            end loop ;

        return RAM;

        end function;

end package body array_memory;

