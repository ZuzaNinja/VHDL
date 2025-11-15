library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MPG is
    Port ( input : in STD_LOGIC;
           clock : in STD_LOGIC;
           en : out STD_LOGIC);
end MPG;

architecture Behavioral of MPG is
    signal cnt_out: std_logic_vector(15 downto 0):=x"0000";
    signal Q1: std_logic;
    signal Q2: std_logic;
    signal Q3: std_logic;
begin
       
    --proces counter
    counter: process(clock)
    begin
        if rising_edge(clock) then
            cnt_out<=cnt_out + 1;
        end if;
    end process;
    
    --proces D flip flop 1
    delayReg1: process(clock)
    begin
        if rising_edge(clock) then
            if cnt_out(15 downto 0) = x"FFFF" then
                Q1<=input;
            end if;
        end if;
    end process;
    
    --process D flip flop 2
    delayReg2: process(clock)
    begin
        if rising_edge(clock) then
            Q2<=Q1;
        end if;
    end process;
    
    --process D flip flop 3
    delayReg3: process(clock)
    begin
        if rising_edge(clock) then
           Q3<=Q2;
        end if;
    end process;
    
      en<=Q2 and(not Q3);

end Behavioral;
