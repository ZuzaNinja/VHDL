library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
use IEEE.NUMERIC_STD.ALL;

entity EX is
  Port (
  rd1: in std_logic_vector(31 downto 0);
  rt: in std_logic_vector(4 downto 0);
  rd: in std_logic_vector(4 downto 0);
  RegDst: in std_logic;
  ALUSrc: in std_logic;
  rd2: in std_logic_vector(31 downto 0);
  Ext_Imm: in std_logic_vector(31 downto 0);
  sa: in std_logic_vector(4 downto 0);
  func: in std_logic_vector(5 downto 0);
  ALUOp: in std_logic_vector(1 downto 0);
  PC: in std_logic_vector(31 downto 0);
  Zero: out std_logic;
  ALURes: out std_logic_vector(31 downto 0);
  BranchAddress: out std_logic_vector(31 downto 0);
  rWa: out std_logic_vector(4 downto 0));
end EX;

architecture Behavioral of EX is

signal mux_out: std_logic_vector(31 downto 0);
signal ALUCtrl: std_logic_vector(2 downto 0);
signal ext_shift_left: std_logic_vector(31 downto 0);
signal A, B, C: std_logic_vector(31 downto 0);
begin

MUX: process(ALUSrc)
begin
if ALUSrc = '0' then
mux_out <= rd2;
else
mux_out <= Ext_Imm;
end if;
end process;

AluControl: process(ALUOp, func)
begin
case ALUOp is 
    when "10"=> -- R type
        case func is
            when "100000"=>ALUCtrl<="000"; -- add
            when "000000"=>ALUCtrl<="010"; -- sll 
            when "000010"=>ALUCtrl<="011"; -- srl
            when others => ALUCtrl <= (others => 'X');
        end case;
    when "00"=>ALUCtrl<="000"; -- addi, lw, sw
    when "01"=>ALUCtrl<="100"; -- beq
    when "11"=>ALUCtrl<="111"; --slti
    when others=>ALUCtrl<=(others=>'X');
 end case;
 end process;

A<=rd1;
B<=mux_out; 

ALU: process(ALUCtrl)
begin
case ALUCtrl is
    when "000"=> C <= A + B; -- add, addi, lw, sw
    when "100"=> C <= A - B; -- beq
    when "010"=> C <= to_stdlogicvector(to_bitvector(B) sll conv_integer(sa)); -- sll
    when "011"=> C <= to_stdlogicvector(to_bitvector(B) srl conv_integer(sa)); -- srl
    when "111"=> -- slti
        if signed(A) < signed(B) then C <= X"00000001";
                                 else C <= X"00000000";
        end if;
    when others => C <= (others=>'X');    
    end case;
end process;

Zero <= '1' when C = X"00000000" else '0';

ext_shift_left <= Ext_Imm(29 downto 0) & "00";
BranchAddress <= ext_shift_left + PC;

mux_process: process(RegDst)
begin
if RegDst = '0' then
rWA <= rt;
else 
rWA <= rd;
end if;
end process;


end Behavioral;
