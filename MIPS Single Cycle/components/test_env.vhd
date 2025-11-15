library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port (
        clk : in STD_LOGIC;
        btn : in STD_LOGIC_VECTOR (4 downto 0);
        sw : in STD_LOGIC_VECTOR (15 downto 0);
        led : out STD_LOGIC_VECTOR (15 downto 0); 
        an : out STD_LOGIC_VECTOR (7 downto 0);
        cat : out STD_LOGIC_VECTOR (6 downto 0)
    );
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port (
        input : in STD_LOGIC;
        clock : in STD_LOGIC;
        en : out STD_LOGIC
    );
end component;

component SSD is
    Port (
        clk : in STD_LOGIC;
        digits : in STD_LOGIC_VECTOR(31 downto 0);
        an : out STD_LOGIC_VECTOR(7 downto 0);
        cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component InstrFetch is
Port(
clk, en, rst: in std_logic;
branchAdress: in std_logic_vector(31 downto 0);
jumpAdress: in std_logic_vector(31 downto 0);
Jump: in std_logic;
PSCrc: in std_logic;
Instruction: out std_logic_vector(31 downto 0);
PC: out std_logic_vector(31 downto 0)
);
end component;

component ID is
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
end component;

component UC is 
Port(
opcode: in std_logic_vector(5 downto 0);
ALUop: out std_logic_vector(1 downto 0);
RegDst, ExtOp, ALUsrc, Branch, Jump, MemWrite, MemtoReg, RegWrite: out std_logic
);
end component;

component EX is
  Port (
  rd1: in std_logic_vector(31 downto 0);
  ALUSrc: in std_logic;
  rd2: in std_logic_vector(31 downto 0);
  Ext_Imm: in std_logic_vector(31 downto 0);
  sa: in std_logic_vector(4 downto 0);
  func: in std_logic_vector(5 downto 0);
  ALUOp: in std_logic_vector(1 downto 0);
  PC: in std_logic_vector(31 downto 0);
  Zero: out std_logic;
  ALURes: out std_logic_vector(31 downto 0);
  BranchAddress: out std_logic_vector(31 downto 0));
end component;

component MEM is
  port (
    clk: in std_logic;
    MemWrite: in std_logic;
    en: in std_logic;
    addr: in std_logic_vector(31 downto 0);
    di: in std_logic_vector(31 downto 0);
    do: out std_logic_vector(31 downto 0);
    ALUResOut: out std_logic_vector(31 downto 0)
  );
end component;

signal en, rst: std_logic;
signal Instruction, PCinc: std_logic_vector(31 downto 0);
signal digits: std_logic_vector(31 downto 0);
signal rd1, rd2, sum, ext_imm: std_logic_vector(31 downto 0);
signal func: std_logic_vector(5 downto 0);
signal sa: std_logic_vector(10 downto 6);
signal RegDst, RegWr, ExtOp: std_logic;
signal sel: std_logic_vector(2 downto 0);
signal ALUSrc, zero: std_logic;
signal ALUOp: std_logic_vector(1 downto 0);
signal BranchAddress, ALURes: std_logic_vector(31 downto 0);
signal MemWrite: std_logic;
signal MemData, ALUResOut: std_logic_vector(31 downto 0);
signal MemtoReg: std_logic;
signal wb_out: std_logic_vector(31 downto 0);
signal JumpAddress: std_logic_vector(31 downto 0);
signal PCSrc: std_logic;
signal branch,jump: std_logic ;
begin

monopulse1: MPG port map(btn(0), clk, en);

JumpAddress <= PCinc(31 downto 28) & (Instruction(25 downto 0) & "00");
PCSrc <= branch and zero;

instruction_fetch: InstrFetch port map(clk, en, rst, BranchAddress, JumpAddress, jump, PCSrc, Instruction, PCinc);
instruction_decoder: ID port map(clk, en, RegDst, RegWr, ExtOp, Instruction(25 downto 0), wb_out, rd1, rd2, ext_imm, func, sa);
unit_control: UC port map(Instruction(31 downto 26), ALUOp, RegDst, ExtOp, ALUSrc, branch, jump, MemWrite, MemtoReg, RegWr);
execution_unity: EX port map (rd1, ALUSrc, rd2, ext_imm, sa, func, ALUOp, PCinc, zero, ALURes, BranchAddress);
data_memory: MEM port map(clk, MemWrite, en, ALURes, rd2, MemData, ALUResOut);

WB: process(MemtoReg)
   begin
   if MemtoReg = '0'
   then wb_out <= ALUResOut;
   else
   wb_out <= MemData;
   end if;
end process;    

sel <= sw(7 downto 5);

--MUX process
process(sel)
begin
    case sel is 
    when "000" => digits <= Instruction;
    when "001" => digits <= PCinc;
    when "010" => digits <= rd1;
    when "011" => digits <= rd2;
    when "100" => digits <= ext_imm;
    when "101" => digits <= AluRes;
    when "110" => digits <= MemData;
    when others => digits <= wb_out;
end case;
end process;

led(9 downto 8) <= ALUOp;
led(7) <= RegDst;
led(6) <= ExtOp;
led(5) <= ALUSrc;
led(4) <= branch;
led(3) <= jump;
led(2) <= MemWrite;
led(1) <= MemtoReg;
led(0) <= RegWr;

-- SSD Output
SSD_display: SSD port map(clk, digits, an, cat);

end Behavioral;
