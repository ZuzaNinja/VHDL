library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstrFetch is
Port(
clk, en, rst: in std_logic;
branchAdress: in std_logic_vector(31 downto 0);
jumpAdress: in std_logic_vector(31 downto 0);
Jump: in std_logic;
PSCrc: in std_logic;
Instruction: out std_logic_vector(31 downto 0);
PC: out std_logic_vector(31 downto 0)
);
end entity;

architecture behavioral of InstrFetch is

signal PC_out: std_logic_vector(31 downto 0);
signal MUX2_out: std_logic_vector(31 downto 0);
signal sum: std_logic_vector(31 downto 0);
signal MUX1_out: std_logic_vector(31 downto 0);
signal Adress: std_logic_vector(31 downto 0) := (others => '0'); 
type ROM is array(0 to 255) of std_logic_vector(31 downto 0);
signal romInst: ROM := (
    0  => B"100011_00000_00010_0000000000000000",  -- X"8C020000"  -- lw   $2, 0($0) -- incarca un cuvant din adresa $0 in $2
    1  => B"100011_00000_00100_0000000000000100",  -- X"8C040004"  -- lw   $4, 4($0) --incarca un cuvant din adresa $0 + 4 in $4
    2  => B"001000_00000_00101_0000000000000001",  -- X"20050001"  -- addi $5, $0, 1 -- $5 = 1
    3  => B"001000_00000_00110_0000000000000001",  -- X"20060001"  -- addi $6, $0, 1 -- $6 = 1
    4  => B"000000_00000_00000_00001_00000_100000",-- X"00000820"  -- add  $1, $0, $0 -- $1 = $0 + $0 -- am initializat contorul

    5  => B"000100_00001_00100_0000000000001101",  -- X"1024000D"  -- beq  $1, $4, 13 -- daca $1 = $4, sare la adresa 13
    6  => B"001010_00001_01001_0000000000000010",  -- X"28290002"  -- slti $9, $1, 2 -- daca $1 < 2 atunci $9 <= 1 altfel $9 <= 0
    7  => B"000100_01001_00000_0000000000000011",  -- X"11200003"  -- beq  $9, $0, 3 -- daca $9 = 0 sare peste instructiuni

    8  => B"001000_00000_00111_0000000000000001",  -- X"20070001"  -- addi $7, $0, 1 -- $7 = 1
    9  => B"000010_00000000000000000000010010",    -- X"08000012"  -- j 18 -- sare la adresa 18

    10 => B"000000_00101_00110_00111_00000_100000",-- X"00A63820"  -- add  $7, $5, $6 -- $7 = $5 + $6
    11 => B"000000_00110_00000_00101_00000_100000",-- X"00C02820"  -- add  $5, $6, $0 -- $5 = $6 + 0
    12 => B"000000_00111_00000_00110_00000_100000",-- X"00E03020"  -- add  $6, $7, $0 -- $6 = $7 + 0

    13 => B"000000_00000_00111_01010_00011_000000",-- X"000750C0"  -- sll  $10, $7, 3 -- $10 = $7 << 3 -- inmultesc cu 8
    14 => B"000000_00001_00000_01000_00000_100000",-- X"00204020"  -- add  $8, $1, $0 -- $8 = $1 + 0
    15 => B"000000_00000_01000_01000_00010_000000",-- X"00084100"  -- sll  $8, $8, 2 -- $8 = $8 << 2 -- inmultesc cu 4
    16 => B"000000_00010_01000_01000_00000_100000",-- X"00484020"  -- add  $8, $2, $8 -- $8 = $2 + $8 -- calculeaza adresa de memorie
    17 => B"101011_01000_01010_0000000000000000",  -- X"AD0A0000"  -- sw   $10, 0($8) -- stocheaza $10 la adresa $8

    18 => B"001000_00001_00001_0000000000000001",  -- X"20210001"  -- addi $1, $1, 1 -- $1 = $1 + 1 -- se incr contorul 
    19 => B"000010_00000000000000000000000101",    -- X"08000005"  -- j 5 -- sare inapoi la adresa 5

    20 => B"000000_00000_00000_00000_00000_000000",-- X"00000000"  -- noop

    others => X"00000000"
);


begin

PC_C: process(clk, rst, en)
begin
    if rst = '1' then
      PC_out <= (others => '0');
    elsif rising_edge(clk) then
    if en = '1' then
      PC_out <= MUX2_out;
    end if;
    end if;
  end process;

sum <= PC_out + 4;

MUX1: process(PSCrc)
begin
    if PSCrc = '0' then
      MUX1_out <= sum;
    else
      MUX1_out <= branchAdress;
    end if;
  end process;
  
MUX2: process(Jump)
begin
    if Jump = '0' then
      MUX2_out <= MUX1_out;
    else
      MUX2_out <= jumpAdress;
    end if;
  end process;
  
  Instruction <= romInst(CONV_INTEGER(PC_out(6 downto 2)));
  PC <= sum;

end architecture;