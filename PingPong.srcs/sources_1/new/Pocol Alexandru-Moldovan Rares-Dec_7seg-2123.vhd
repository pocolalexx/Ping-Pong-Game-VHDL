----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/11/2026 07:44:17 PM
-- Design Name: 
-- Module Name: Dec_7seg - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Dec_7seg is
    Port ( cifra : in integer range 0 to 9;
           seg : out STD_LOGIC_VECTOR (6 downto 0));
end Dec_7seg;

architecture Behavioral of Dec_7seg is

begin

process(cifra) -- se activeaza cand se schimba cifra
    begin
        case cifra is
        -- aprindem segmentele
            when 0 => seg <= "1000000";
            when 1 => seg <= "1111001";
            when 2 => seg <= "0100100";
            when 3 => seg <= "0110000";
            when 4 => seg <= "0011001";
            when 5 => seg <= "0010010";
            when 6 => seg <= "0000010";
            when 7 => seg <= "1111000";
            when 8 => seg <= "0000000";
            when 9 => seg <= "0010000";
            when others => seg <= "1111111"; -- alta valoare, stingem tot
        end case;
    end process;

end Behavioral;
