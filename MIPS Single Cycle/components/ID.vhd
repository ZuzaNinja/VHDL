library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
entity ID is
    port (
        clk : in std_logic;
        en: in std_logic;
        regdst: in std_logic;
        regwr : in std_logic;
        extop: in std_logic;
        instr: in std_logic_vector(25 downto 0);
        wd : in std_logic_vector(31 downto 0);        
        rd1 : out std_logic_vector(31 downto 0);
        rd2 : out std_logic_vector(31 downto 0);
        ext_imm: out std_logic_vector(31 downto 0);
        func: out std_logic_vector(5 downto 0);
        sa: out std_logic_vector(10 downto 6)
    );
end ID;

architecture Behavioral of ID is
    type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);
    signal reg_file : reg_array := (
        --x"00000001", x"00000005", x"0000000A", x"00000F09", x"0000FF10",
        others => x"00000000"
    );
signal ra1, ra2: std_logic_vector(4 downto 0); 
signal wa: std_logic_vector(4 downto 0);
begin

ra1 <= instr(25 downto 21);
ra2 <= instr(20 downto 16);
wa <= instr(20 downto 16) when  regdst = '0' else instr(15 downto 11);

register_file:process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' and regwr = '1' then
                reg_file(conv_integer(wa)) <= wd;
            end if;
        end if;
    end process;

rd1 <= reg_file(conv_integer(ra1));
rd2 <= reg_file(conv_integer(ra2));
    
func <= instr(5  downto 0);
sa   <= instr(10 downto 6);
ext_imm(15 downto 0)  <= instr(15 downto 0);
ext_imm(31 downto 16) <= (others => instr(15)) when extop = '1' else (others => '0');

end Behavioral;
