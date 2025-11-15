library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UC is 
Port(
opcode: in std_logic_vector(5 downto 0);
ALUop: out std_logic_vector(1 downto 0);
RegDst, ExtOp, ALUsrc, Branch, Jump, MemWrite, MemtoReg, RegWrite: out std_logic
);
end entity;

architecture behavioral of UC is
begin

process(opcode)
begin
        RegDst <= '0'; ExtOp <= '0'; ALUSrc <= '0'; 
        Branch <= '0'; Jump <= '0'; MemWrite <= '0';
        MemtoReg <= '0'; RegWrite <= '0';
        ALUOp <= "00";
        case (opcode) is 
            when "000000" => -- R type
                RegDst <= '1';
                RegWrite <= '1';
                ALUOp <= "10";
            when "001000" => -- ADDI
                ExtOp <= '1';
                ALUSrc <= '1';
                RegWrite <= '1';
            when "001101" => -- ORI
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "11";
            when "001010" => -- SLTI
                ExtOp <= '1';
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "11";
            when "100011" => -- LW
                ExtOp <= '1';
                ALUSrc <= '1';
                MemtoReg <= '1';
                RegWrite <= '1';
            when "101011" => -- SW
                ExtOp <= '1';
                ALUSrc <= '1';
                MemWrite <= '1';
            when "000100" => -- BEQ
                ExtOp <= '1';
                Branch <= '1';
                ALUOp <= "01";          
            when "000010" => -- J
                Jump <= '1';
            when others => 
                RegDst <= '0'; ExtOp <= '0'; ALUSrc <= '0'; 
                Branch <= '0'; Jump <= '0'; MemWrite <= '0';
                MemtoReg <= '0'; RegWrite <= '0';
                ALUOp <= "00";
        end case;
    end process;		

end architecture;