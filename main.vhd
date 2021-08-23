----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Marco Montorsi 
-- 
-- Create Date: 22.04.2020 11:05:14
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is  port (   
  i_clk          : in  std_logic;   
  i_start        : in  std_logic;   
  i_rst          : in  std_logic;   
  i_data         : in  std_logic_vector(7 downto 0);    
  o_address      : out std_logic_vector(15 downto 0);   
  o_done         : out std_logic;   
  o_en           : out std_logic;   
  o_we           : out std_logic;   
  o_data         : out std_logic_vector (7 downto 0)  );
 end project_reti_logiche; 

architecture Behavioral of project_reti_logiche is
 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                     States of the FSM                                                                                   --                                                     
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 type state is ( 
  START,           --Initial state, in which the FSM will wait until the signal of start becomes 1
  ADDR_READ_ASK,   --State where the FSM requests to RAM the address to encode
  ADDR_READ_WAIT,  --State where the FSM waits the response of RAM
  ADDR_READ_GET,   --State where the FSM save the address to encode
  CHECK_ADDR,      --State where the FSM checks the 8 WZs, if the address doesn't belong to any of the WZs, it will reach the DONE state to write the address as it is
  READ_MEM_ASK,    --State where the FSM requests to RAM the address of one of the eight WZs, based on the count value
  READ_MEM_WAIT,   --State where the FSM waits the response of RAM
  READ_MEM_GET,    --State where the FSM saves the value of the chosen WZ
  VALUE_SET,       --State where the FSM saves the difference_values based on the chosen WZ, this integer will be needed in the next state
  CHECK_DWZ,       --State where the FSM checks if my address belongs to the chosen WZ, using difference_values, if it belongs to the chosen WZ,
                   --the FSM will go to DWZ_FOUND, otherwise it will increase the counter by going to COUNT_UPDATE and it will continue to search
  DWZ_FOUND,       --State where the FSM calculates the number of WZ corrispondent to the address and the one-hot code, then it will go to DONE, to send the address
  COUNT_UPDATE,    --State where the FSM will update the counter, needed to decide the next address of the WZ
  DONE,            --State where the FSM send to ram the address encoded
  WRITE_MEM_RESULT --State where the FSM waits the signal start to become 0 then it will be ready to be resetted to START and start again
               );
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                              Variables used in the process                                                                              --                                                     
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
 signal next_state        : state;                       -- next state of the FSM
 signal one_hot           : std_logic_vector(3 downto 0);-- vector of 4 bits where it will be encoded the one-hot,if the address belongs to a WZ
 signal address           : std_logic_vector(7 downto 0);-- vector of 8 bits where the address to encode will be saved
 signal prov_addr         : std_logic_vector(7 downto 0);-- vector of 8 bits where it will be saved the address for every WZ to check
 signal my_value          : integer;                     -- the value in integer of my address to encode
 signal his_value         : integer;                     -- value in integer of a checked WZ
 signal difference_values : integer;                     -- substraction between my_value and his_value, value useful for checking if the address belong to a WZ
 signal count             : integer;                     -- counter useful to request the right address of a WZ and check if the FSM already checked the 8 WZs
 signal found_dwz         : boolean;                     -- boolean used in state DONE, needed to understand which address encoded send to RAM

begin
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                    Process of the FSM                                                                                   --                                                     
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
process(i_clk,i_rst)
begin
    
    
    if(rising_edge(i_clk))then                              -- if clock is 1 the FSM will do the operation of the specific state in which the FSM is at
        
        
    case next_state is                                      -- cases of states of the FSM
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------  
      when START =>                                         -- in START the FSM waits until the i_start becomes 1, initialating the needed variables 
                     count <= 0;                            -- and then proceed to the next state ADDR_READ_ASK
                     o_done <= '0';
                     o_en <= '0';
                     o_we <= '0';
                     o_address <= "0000000000000000";
                     o_data <= "00000000";
                     my_value <= 0;
                     his_value <= 0;
                     difference_values <= 0;
                     address <= "00000000";
                     prov_addr <= "00000000";
                     if(i_start = '1')then
                       next_state <= ADDR_READ_ASK;
                     else 
                       next_state <= START;
                     end if;
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------ 
      when ADDR_READ_ASK =>  
      if( i_rst = '1' )then                              -- when i_rst is 1 the FSM must go back to the initial state START
            next_state <= START;
            else                                         -- in ADDR_READ_ASK the FSM asks to RAM the address to encode, which is in position 8           
                     o_en <= '1';                        -- then it goes to ADDR_READ_WAIT
                     o_we <= '0';
                     o_address <= "0000000000001000";
                     next_state <= ADDR_READ_WAIT;
                     end if;
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------ 
      when ADDR_READ_WAIT =>       
      if( i_rst = '1' )then                              -- when i_rst is 1 the FSM must go back to the initial state START
            next_state <= START;
            else                                         -- in ADDR_READ_WAIT the FSM waits the response from RAM, doing nothing, then it proceeds to ADDR_READ_GET
                     o_en <= '0';
                     next_state <= ADDR_READ_GET;       
                     end if;        
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------
      when ADDR_READ_GET =>  
      if( i_rst = '1' )then                               -- when i_rst is 1 the FSM must go back to the initial state START
            next_state <= START;
            else                                          -- in ADDR_READ_GET tbe FSM saves in the vecotr address, the address to encode, then it saves the value in 
                     address <= i_data;                   -- integer in my_value, then it proceeds to CHECK_ADDR 
                     my_value <= to_integer(unsigned(i_data));
                     next_state <= CHECK_ADDR;
                     end if;
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------ 
      when CHECK_ADDR =>   
      if( i_rst = '1' )then                               -- when i_rst is 1 the FSM must go back to the initial state START
            next_state <= START;
            else                                          -- in CHECK_ADDR the FSM checks with count if it has to check more WZs or not, if it has then it proceeds to
                     if(count<=7) then                    -- READ_MEM_ASK, otherwise it goes to DONE, setting found_dwz to false, because the address doesn't belong to any WZs
                       prov_addr <= std_logic_vector(to_unsigned(count,8));
                       next_state <= READ_MEM_ASK;
                     else                      
                       found_dwz <= false;
                       next_state <= DONE;
                     end if;
                     end if;
     -------------------------------------------------------------------------------------------------------------------------------------------------------------------
      when READ_MEM_ASK =>       
      if( i_rst = '1' )then                              -- when i_rst is 1 the FSM must go back to the initial state START
            next_state <= START;
            else                                         -- in READ_MEM_ASK the FSM requests the address of one WZ based on the value of count, then it will wait in
                     o_en <= '1';                        -- the state READ_MEM_WAIT
                     o_we <= '0';
                     o_address <= "00000000" & prov_addr;
                     next_state <= READ_MEM_WAIT;
                     end if;
     ------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
      when READ_MEM_WAIT =>     
      if( i_rst = '1' )then                              -- when i_rst is 1 the FSM must go back to the initial state START
            next_state <= START;
            else                                         -- in READ_MEM_WAIT the FSM does nothing but waits, then it proceeds to READ_MEM_GET
                     o_en <= '0';
                     next_state <= READ_MEM_GET;
                     end if;
     -------------------------------------------------------------------------------------------------------------------------------------------------------------------                
      when READ_MEM_GET =>  
      if( i_rst = '1' )then                              -- when i_rst is 1 the FSM must go back to the initial state START
            next_state <= START;
            else                                         -- in READ_MEM_GET the FSM saves the value of the WZ chosen in his_value then it proceeds to VALUE_SET
                     his_value <= to_integer(unsigned(i_data));
                     next_state <= VALUE_SET; 
                     end if;                  
     ------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
      when VALUE_SET =>   
      if( i_rst = '1' )then                               -- when i_rst is 1 the FSM must go back to the initial state START
            next_state <= START;
            else                                          -- in VALUE_SET the FSM sets the value difference_values, variables used in the next state CHECK_DWZ
                     difference_values <= my_value - his_value;
                     next_state <= CHECK_DWZ;
                     end if;
     -------------------------------------------------------------------------------------------------------------------------------------------------------------------
      when CHECK_DWZ =>   
      if( i_rst = '1' )then                                -- when i_rst is 1 the FSM must go back to the initial state START
            next_state <= START;
            else                                           -- in CHECK_DWZ the FSM verify if the address does belong to the chosen WZ, first of all if difference_values
                     if(difference_values < 0) then        -- is lower than 0, the address surely doesn't belong to the WZ, so it proceeds to COUNT_UPDATE, if it isn't lower
                       next_state <= COUNT_UPDATE;         -- than 0 it checks if difference_values is lower than 4, in this case the address belongs to a DWZ , so
                     else                                  -- the FSM proceeds to DWZ_FOUND, otherwise the address doesn't belong to a DWZ and the FSM goes to COUNT_UPDATE
                       if(difference_values < 4) then 
                         next_state <= DWZ_FOUND;
                       else
                         next_state <= COUNT_UPDATE;
                       end if;
                     end if;  
                     end if;
     -------------------------------------------------------------------------------------------------------------------------------------------------------------------                                  
      when COUNT_UPDATE =>   
      if( i_rst = '1' )then                                -- when i_rst is 1 the FSM must go back to the initial state START
            next_state <= START;
            else                                           -- in COUNT_UPDATE the FSM increase count by 1, variable necessary in the check states, then the FSM returns 
                     count <= count+1;                     -- to CHECK_ADDR
                     next_state <= CHECK_ADDR;
                     end if;
     ------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
      when DWZ_FOUND=>      
      if( i_rst = '1' )then                                -- when i_rst is 1 the FSM must go back to the initial state START
            next_state <= START;
            else                                           -- in this state the FSM calculates the one-hot code based on difference_values, then it sets found_dwz to true
                     if(difference_values = 0)then         -- and it proceeds to DONE to write the correct address ecnoded
                       one_hot <= "0001";
                     elsif(difference_values = 1)then
                       one_hot <= "0010";
                     elsif(difference_values = 2)then
                       one_hot <= "0100";
                     else
                       one_hot <= "1000";
                     end if;
                     found_dwz <= true;
                     next_state <= DONE;
                     end if;
      ------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
       when DONE =>     
       if( i_rst = '1' )then                               -- when i_rst is 1 the FSM must go back to the initial state START
             next_state <= START;
             else                                          -- in DONE the FSM sends the address encoded at the address 9 of RAM, to check which address send it uses the
                     o_en <= '1';                          -- variable found_dwz, based on his value it will send the correct address encoded and then it 
                     o_we <= '1';                          -- proceeds to WRITE_MEM_RESULT
                     o_address <= "0000000000001001"; 
                     if(found_dwz = true) then  
                       o_data <= '1' & std_logic_vector(to_unsigned(count,3)) & one_hot;
                     else 
                       o_data <= address;
                     end if; 
                     next_state <= WRITE_MEM_RESULT;
                     end if;
      ------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
       when WRITE_MEM_RESULT =>     
       if( i_rst = '1' )then                               -- when i_rst is 1 the FSM must go back to the initial state START
             next_state <= START;
             else                                          -- in WRITE_MEM_RESULT the FSM sets o_done to 1 and waits until i_start goes to 0,  
                     o_en <= '0';                          -- meaning the RAM has received the address, and the FSM is ready to restart
                     o_we <= '0'; 
                     o_done <= '1';                    
                     if(i_start = '0')then
                       next_state <= START;
                     else
                       next_state <= WRITE_MEM_RESULT;
                     end if;     
                     end if;           
      -------------------------------------------------------------------------------------------------------------------------------------------------------------------        
       end case;
    end if;
end process;
end Behavioral;