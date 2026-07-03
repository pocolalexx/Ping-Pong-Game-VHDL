----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/11/2026 07:38:50 PM
-- Design Name: 
-- Module Name: PingPongGame - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL; -- operatii matematice
use IEEE.STD_LOGIC_UNSIGNED.ALL; -- numere fara semn

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PingPongGame is
    Port ( clk : in STD_LOGIC;
           btnC : in STD_LOGIC;  -- reset joc   
           btnL : in STD_LOGIC;  -- paleta stanga
           btnR : in STD_LOGIC;  -- paleta dreapta
           led : out STD_LOGIC_VECTOR (15 downto 0); -- 16 led-uri
           seg : out STD_LOGIC_VECTOR (6 downto 0); -- seg cifrei afisate
           an : out STD_LOGIC_VECTOR (3 downto 0)); -- 4 pozitii ale afisajului
end PingPongGame;

architecture Behavioral of PingPongGame is

component Dec_7seg is -- declararea componentei
    Port ( cifra : in integer range 0 to 9;
           seg : out STD_LOGIC_VECTOR (6 downto 0));
end component Dec_7seg;

    signal numara_clk : std_logic_vector(25 downto 0) := (others => '0'); -- contor timp
    signal clk_joc : std_logic; -- semnalul pentru minge
    signal mux_cnt : std_logic_vector(1 downto 0); -- semnal pentru multiplexare
    
    --FSM
    type stari_joc is (asteapta_l, asteapta_r, la_dreapta, la_stanga, final_joc);
    signal stare : stari_joc := asteapta_l; -- starea initiala
    
    signal pozitie : integer range 0 to 15 := 0; -- unde se afla led-ul aprins
    signal puncte_l : integer range 0 to 99 := 0; -- scorul jucatorului din stanga
    signal puncte_r : integer range 0 to 99 := 0; -- scorul jucatorului dreapta
    signal cifra_lcd : integer range 0 to 9; -- cifra trimisa spre dec_7seg
begin

    -- numarator pentru divizarea ceasului
    process(clk)
    begin
        if rising_edge(clk) then -- la fiecare impuls ded 100MHz
            numara_clk <= numara_clk + 1; -- +contor
        end if;
    end process;
    
    clk_joc <= numara_clk(22); -- viteza cu care se misca mingea
    mux_cnt <= numara_clk(18 downto 17); -- viteza de schimbare a anozilor

    process(clk_joc, btnc)
    begin
        if btnc = '1' then -- butonul reset apasat
            stare <= asteapta_l; -- merge la inceput
            pozitie <= 0; -- resetare pozitie minge
            puncte_l <= 0; -- reset scor stanga
            puncte_r <= 0;  -- reset scor dreapta
        elsif rising_edge(clk_joc) then -- la fiecare pas al mingii
            case stare is
                when asteapta_l =>
                    pozitie <= 0;
                    if btnr = '1' then
                        stare <= la_dreapta; -- mingea se deplaseaza spre dreapta
                    end if;
                when asteapta_r =>
                    pozitie <= 15;
                    if btnl = '1' then
                        stare <= la_stanga; -- mingea se deplaseaza spre stanga
                    end if;
                when la_dreapta =>
                    if pozitie = 15 then -- mingea ajunge la jucatorul din dreapta
                        if btnl = '1' then -- apasarea butonului la timp
                            stare <= la_stanga; -- mingea merge spre stanga
                        else
                            -- punct pentru jucatorul din stanga
                            if puncte_l >= 10 and (puncte_l + 1 - puncte_r >= 2) then
                                puncte_l <= puncte_l + 1; -- scor final
                                stare <= final_joc; -- setul s-a terminat
                            else
                                puncte_l <= puncte_l + 1; -- incrementam scorul
                                stare <= asteapta_l; -- serveste cel din stanga (castigare punct)
                            end if;
                        end if;
                    else
                        pozitie <= pozitie + 1; -- mutam bila spre dreapta
                    end if;
                -- aceeasi chestie dar pentru deplasarea mingii la stanga
                when la_stanga =>
                    if pozitie = 0 then
                        if btnr = '1' then
                            stare <= la_dreapta;
                        else
                            -- Punct pentru dreapta
                            if puncte_r >= 10 and (puncte_r + 1 - puncte_l >= 2) then
                                puncte_r <= puncte_r + 1;
                                stare <= final_joc;
                            else
                                puncte_r <= puncte_r + 1;
                                stare <= asteapta_r; -- serveste cel din dreapta (castigare punct)
                            end if;
                        end if;
                    else
                        pozitie <= pozitie - 1;
                    end if;

                when final_joc => -- asteptare pentru resetare
                    if btnc = '1' then stare <= asteapta_l; end if;
            end case;
        end if;
    end process;

    -- afisare led-uri
process(pozitie, stare, numara_clk)
begin
    led <= (others => '0');
        case stare is
            when final_joc =>
                led <= (others => numara_clk(23)); -- palpaie tot la final
            when asteapta_l | asteapta_r =>
                led(pozitie) <= numara_clk(22); -- palpaie doar ledul de servire (bitul 22 e mai rapid)
            when others =>
                led(pozitie) <= '1'; -- led-ul sta aprins in timpul miscarii
        end case;
 end process;

    -- multiplexare display: scor stanga (primele 2 cifre) si scor sreapta (ultimele 2)
    process(mux_cnt, puncte_l, puncte_r)
    begin
        case mux_cnt is
            when "00" => -- prima cifra din stanga
                an <= "1110"; cifra_lcd <= puncte_l rem 10; -- unitati stanga
            when "01" => -- a doua cifra stanga
                an <= "1101"; cifra_lcd <= (puncte_l / 10) rem 10; -- zeci stanga
            when "10" => -- prima cifra dreapta
                an <= "1011"; cifra_lcd <= puncte_r rem 10; -- unitati dreapta
            when "11" => -- a doua cifra dreapta
                an <= "0111"; cifra_lcd <= (puncte_r / 10) rem 10; -- zeci dreapta
        end case;
    end process;
    -- instantiere dec
    afisaj: Dec_7seg port map (
        cifra => cifra_lcd, -- trimitem cifra calculata de multiplexor
        seg   => seg -- semnale pentru seg de pe placa
    );

end Behavioral;
