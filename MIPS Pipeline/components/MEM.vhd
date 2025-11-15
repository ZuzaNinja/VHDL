library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM is
  port (
    clk: in std_logic;
    MemWrite: in std_logic;
    en: in std_logic;
    addr: in std_logic_vector(31 downto 0);
    di: in std_logic_vector(31 downto 0);
    do: out std_logic_vector(31 downto 0);
    ALUResOut: out std_logic_vector(31 downto 0)
  );
end MEM;

architecture Behavioral of MEM is

type ram_type is array (0 to 63) of std_logic_vector(31 downto 0);
signal ram : ram_type := (
  0 => X"00000008",  -- A = 8
  1 => X"0000000A",  -- N = 10 (primele 10 elemente)
  others => X"00000000"
);


begin

  -- scriere sincrona
  process(clk)
  begin
    if rising_edge(clk) then
      if en = '1' and MemWrite = '1' then
        ram(conv_integer(addr(7 downto 2))) <= di;
      end if;
    end if;
  end process;

  -- citire asincrona
  do <= ram(conv_integer(addr(7 downto 2)));

  -- forward ALU result
  ALUResOut <= addr;

end Behavioral;
