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
        regwr : in std_logic;
        wa: in std_logic_vector(4 downto 0);
        extop: in std_logic;
        instr: in std_logic_vector(25 downto 0);
        wd : in std_logic_vector(31 downto 0);        
        rd1 : out std_logic_vector(31 downto 0);
        rd2 : out std_logic_vector(31 downto 0);
        ext_imm: out std_logic_vector(31 downto 0);
        func: out std_logic_vector(5 downto 0);
        sa: out std_logic_vector(10 downto 6);
        rt: out std_logic_vector (4 downto 0);
        rd: out std_logic_vector(4 downto 0)
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
signal rd, rt: std_logic_vector (4 downto 0);
signal rWA: std_logic_vector (4 downto 0);
signal Instruction_IF_ID, PCinc_IF_ID, RD1_ID_EX, RD2_ID_EX, Ext_Imm_ID_EX, PCinc_ID_EX, BrAddr_EX_MEM, ALURes_EX_MEM, RD2_EX_MEM, ALURes_MEM_WB, MemData_MEM_WB: std_logic_vector(31 downto 0);
signal func_ID_EX: std_logic_vector(5 downto 0);
signal sa_ID_EX, rd_ID_EX, rt_ID_EX, WA_EX_MEM, WA_MEM_WB: std_logic_vector(4 downto 0);
signal ALUOp_ID_EX: std_logic_vector(1 downto 0);
signal RegDst_ID_EX, ALUSrc_ID_EX, Branch_ID_EX, MemWrite_ID_EX, MemtoReg_ID_EX, RegWr_ID_EX, Branch_EX_MEM, MemWrite_EX_MEM, MemtoReg_EX_MEM, RegWr_EX_MEM, Zero_EX_MEM, RegWr_MEM_WB, MemtoReg_MEM_WB: std_logic;
begin

monopulse1: MPG port map(btn(0), clk, en);

JumpAddress <= PCinc_IF_ID(31 downto 28) & (Instruction_IF_ID(25 downto 0) & "00");
PCSrc <= Branch_EX_MEM and Zero_EX_MEM;

instruction_fetch: InstrFetch port map(clk, en, rst, BrAddr_EX_MEM, JumpAddress, jump, PCSrc, Instruction, PCinc);
instruction_decoder: ID port map(clk, en, RegWr_MEM_WB, WA_MEM_WB, ExtOp, Instruction_IF_ID(25 downto 0), wb_out, rd1, rd2, ext_imm, func, sa, rt, rd);
unit_control: UC port map(Instruction_IF_ID(31 downto 26), ALUOp, RegDst, ExtOp, ALUSrc, branch, jump, MemWrite, MemtoReg, RegWr);
execution_unity: EX port map (RD1_ID_EX, rt_ID_EX, rd_ID_EX, RegDst_ID_EX, ALUSrc_ID_EX, RD2_ID_EX, Ext_Imm_ID_EX, sa_ID_EX, func_ID_EX, ALUOp_ID_EX, PCinc_ID_EX, zero, ALURes, BranchAddress, rWA);
data_memory: MEM port map(clk, MemWrite_EX_MEM, en, ALURes_EX_MEM, RD2_EX_MEM, MemData, ALUResOut);

--pipeline
delay_pipeline: process(clk)
begin
    if rising_edge(clk) then
        if en = '1' then
            -- IF_ID
            PCinc_IF_ID <= PCinc;
            Instruction_IF_ID <= Instruction;
            -- ID_EX 
            RegDst_ID_EX <= RegDst;
            ALUSrc_ID_EX <=  ALUSrc;
            Branch_ID_EX <= branch;
            ALUOp_ID_EX <= ALUOp;
            MemWrite_ID_EX <= MemWrite;
            MemtoReg_ID_EX <= MemtoReg;
            RegWr_ID_EX <= RegWr;
            RD1_ID_EX <= rd1;
            RD2_ID_EX <= rd2;
            Ext_Imm_ID_EX <= ext_imm;
            func_ID_EX <= func;
            sa_ID_EX <= sa;
            rd_ID_EX <= rd;
            rt_ID_EX <= rt;
            PCinc_ID_EX <= PCinc_IF_ID;
            --  EX_MEM
            Branch_EX_MEM <= Branch_ID_EX;
            MemWrite_EX_MEM <= MemWrite_ID_EX;
            MemtoReg_EX_MEM <= MemtoReg_ID_EX;
            RegWr_EX_MEM <= RegWr_ID_EX;
            Zero_EX_MEM <= zero;
            BrAddr_EX_MEM <= BranchAddress;
            ALURes_EX_MEM <= ALURes;
            WA_EX_MEM <= rWA;
            RD2_EX_MEM <= RD2_ID_EX;
            -- MEM_WB
            RegWr_MEM_WB <= RegWr_EX_MEM;
            MemtoReg_MEM_WB <= MemtoReg_EX_MEM;
            ALURes_MEM_WB <= ALUResOut;
            MemData_MEM_WB <= MemData;
            WA_MEM_WB <= WA_EX_MEM;
        end if;
    end if;        
end process;

WB: process(MemtoReg_MEM_WB)
   begin
   if MemtoReg_MEM_WB = '0'
   then wb_out <= ALURes_MEM_WB;
   else
   wb_out <= MemData_MEM_WB;
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
