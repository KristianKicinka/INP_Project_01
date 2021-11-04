-- cpu.vhd: Simple 8-bit CPU (BrainLove interpreter)
-- Copyright (C) 2021 Brno University of Technology,
--                    Faculty of Information Technology
-- Author(s): Kristián Kičinka (xkicin02)
--


---------------------------------------------------------
--                  CPU Program Counter                --

library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity CPU_PC is
  port(
     CLK : in std_logic;
     RST : in std_logic;
     PC_INC : in std_logic;
     PC_DEC : in std_logic;
     PC_CLR : in std_logic;
     PC_OUT : out std_logic_vector (11 downto 0)
     );
  end entity CPU_PC;
  
  -------------------------------------------------
  architecture behavioral of CPU_PC is

    signal pc_val : std_logic_vector (11 downto 0); 
     
  begin
  
   cpu_pc : process (CLK,RST,PC_INC,PC_DEC,PC_CLR) 
    begin
       if RST = '1' then
        pc_val <= "000000000000";
       elsif CLK'event and CLK = '1' then

        if PC_INC = '1' then
          pc_val <= pc_val + 1;
        elsif PC_DEC = '1' then
          pc_val <= pc_val - 1;
        elsif PC_CLR = '1' then
          pc_val <= "000000000000";
        end if;
       end if;
    end process;
 
    PC_OUT <= pc_val;
     
  end behavioral;
 
---------------------------------------------------------
--                  CPU Counter While                  --


library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity CPU_CNT is
  port(
     CLK : in std_logic;
     RST : in std_logic;
     CNT_INC : in std_logic;
     CNT_DEC : in std_logic;
     CNT_CLR : in std_logic;
     CNT_OUT : out std_logic_vector (11 downto 0)
     );
  end entity CPU_CNT;
  
  -------------------------------------------------
  architecture behavioral of CPU_CNT is

    signal cnt_val : std_logic_vector (11 downto 0); 
     
  begin
  
   cpu_cnt : process (CLK,RST,CNT_INC,CNT_DEC,CNT_CLR) 
    begin
       if RST = '1' then
        cnt_val <= "000000000000";
       elsif CLK'event and CLK = '1' then

        if CNT_INC = '1' then
          cnt_val <= cnt_val + 1;
        elsif CNT_DEC = '1' then
          cnt_val <= cnt_val - 1;
        elsif CNT_CLR = '1' then
          cnt_val <= "000000000000";
        end if;
       end if;
    end process;

    CNT_OUT <= cnt_val;
  
  end behavioral;

---------------------------------------------------------
--             CPU Pointer address recieve             --


library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity CPU_PTR is
  port(
     CLK : in std_logic;
     RST : in std_logic;
     PTR_INC : in std_logic;
     PTR_DEC : in std_logic;
     PTR_CLR : in std_logic;
     PTR_OUT : out std_logic_vector (9 downto 0)
     );
  end entity CPU_PTR;
  
  -------------------------------------------------
  architecture behavioral of CPU_PTR is

    signal ptr_val : std_logic_vector (9 downto 0); 
     
  begin
  
   cpu_ptr : process (CLK,RST,PTR_INC,PTR_DEC,PTR_CLR) 
    begin
       if RST = '1' then
        ptr_val <= "0000000000";
       elsif CLK'event and CLK = '1' then

        if PTR_INC = '1' then
          ptr_val <= ptr_val + 1;
        elsif PTR_DEC = '1' then
          ptr_val <= ptr_val - 1;
        elsif PTR_CLR = '1' then
          ptr_val <= "0000000000";
        end if;
       end if;
    end process;

    PTR_OUT <= ptr_val;
         
  end behavioral;

---------------------------------------------------------
--       MUX Multiplexor to select value to save       --

library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity CPU_MUX is
  port(
     CLK : in std_logic;
     RST : in std_logic;
     DATA_IN_00 : in std_logic_vector (7 downto 0);
     DATA_IN_01: in std_logic_vector (7 downto 0);
     MUX_SEL : in std_logic_vector (1 downto 0);
     MUX_OUT : out std_logic_vector (7 downto 0)
     );
  end entity CPU_MUX;
  
  -------------------------------------------------
  architecture behavioral of CPU_MUX is

    signal mux_val : std_logic_vector (7 downto 0); 
     
  begin
  
   cpu_mux : process (CLK,RST,DATA_IN_00,DATA_IN_01,MUX_SEL) 
    begin
       if (RST = '1') then
        mux_val <= "00000000";
       elsif CLK'event and CLK = '1' then
          case MUX_SEL is
            when "00" =>  mux_val <= DATA_IN_00;
            when "01" =>  mux_val <= DATA_IN_01 - 1;
            when "10" =>  mux_val <= DATA_IN_01 + 1;
            when others => mux_val <= "00000000";
          end case;
       end if;
    end process;

    MUX_OUT <= mux_val;
     
  end behavioral;


---------------------------------------------------------
--       FSM Final state machine as well in VUT        --

library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity CPU_FSM is
  port(
    -- Inputs
    CLK : in std_logic;
    RST : in std_logic;
    EN : in std_logic;
    CODE_DATA : in std_logic_vector (7 downto 0);
    IN_VLD : in std_logic;
    OUT_BUSY : in std_logic;
    DATA_RDATA : in std_logic_vector (7 downto 0);
    CNT_OUT : in std_logic_vector (11 downto 0);

    -- Outputs
    PTR_INC : out std_logic := '0';
    PTR_DEC : out std_logic := '0';
    PTR_CLEAR : out std_logic := '0';

    CNT_INC : out std_logic := '0';
    CNT_DEC : out std_logic := '0';
    CNT_CLEAR : out std_logic := '0';

    PC_INC : out std_logic := '0';
    PC_DEC : out std_logic := '0';
    PC_CLEAR : out std_logic := '0';

    DATA_WREN : out std_logic := '0';
    DATA_EN : out std_logic := '0';

    MUX_SEL : out std_logic_vector (1 downto 0) := "00";
    CODE_EN : out std_logic := '0';

    IN_REQ : out std_logic := '0';
    OUT_WREN : out std_logic := '0'  
    );
end entity CPU_FSM;
  
  -------------------------------------------------
  architecture behavioral of CPU_FSM is

    type cpu_fsm_state is (
        
        -- Service states
        state_idle,
        state_load_instruction,
        state_decode_instruction,

        -- Ptr states
        state_inc_val_ptr,
        state_dec_val_ptr,

        -- Inc cell states
        state_inc_cell_start,
        state_mux_sel_01,
        state_inc_cell_end,

        -- Dec cell states
        state_dec_cell_start,
        state_mux_sel_10,
        state_dec_cell_end,

        -- Set char states
        state_set_char_start,
        state_set_char_end,

        -- Get char states
        state_get_char_start,
        state_get_char_end,

        -- While end states
        state_while_end,
        state_while_end_ram_ptr,
        state_while_end_cnt_loop,
        state_while_end_cnt_check,
        state_while_end_rom_en,

        -- While start states
        state_while_start,
        state_while_start_ram_ptr,
        state_while_start_cnt_check,
        state_while_start_rom_en,

        -- break states
        state_break,
        state_break_cnt_loop,
        state_break_rom_en,

        state_return,
        state_other
    );

    signal current_state : cpu_fsm_state := state_idle;
    signal next_state : cpu_fsm_state;
    begin

    -- Logika spracovania aktuálneho stavu
    cpu_fsm_current_state_proc : process (CLK, RST)
    begin
        if RST = '1' then
			current_state <= state_idle;
		elsif CLK'event and CLK = '1' and EN = '1' then
            current_state <= next_state; 
		end if;
    end process;
    
    -- Logika spracovania následujúceho stavu
    cpu_fsm_next_state_proc : process (CODE_DATA, IN_VLD, OUT_BUSY, DATA_RDATA, CNT_OUT ,current_state)
    begin
        case current_state is
            when state_idle =>  
                next_state <= state_load_instruction;

            when state_load_instruction =>
                next_state <= state_decode_instruction;

            when state_decode_instruction =>
                case CODE_DATA is
                    when X"3E" => next_state <= state_inc_val_ptr;          -- { > }
                    when X"3C" => next_state <= state_dec_val_ptr;          -- { < }
                    when X"2B" => next_state <= state_inc_cell_start;       -- { + }
                    when X"2D" => next_state <= state_dec_cell_start;       -- { - }
                    when X"5B" => next_state <= state_while_start;          -- { [ }
                    when X"5D" => next_state <= state_while_end;            -- { ] }
                    when X"2E" => next_state <= state_set_char_start;       -- { . }
                    when X"2C" => next_state <= state_get_char_start;       -- { , }
                    when X"7E" => next_state <= state_break;                -- { ~ }
                    when X"00" => next_state <= state_return;               -- { null }
                    when others => next_state <= state_other;               -- { undef }
                end case;
            
            when state_inc_val_ptr => 
                next_state <= state_load_instruction;
    
            when state_dec_val_ptr => 
                next_state <= state_load_instruction;
    
            when state_inc_cell_start =>
                next_state <= state_mux_sel_10;
    
            when state_mux_sel_10 =>
                next_state <= state_inc_cell_end;
    
            when state_inc_cell_end => 
                next_state <= state_load_instruction;
    
            when state_dec_cell_start => 
                next_state <= state_mux_sel_01;
    
            when state_mux_sel_01 => 
                next_state <= state_dec_cell_end;
    
            when state_dec_cell_end => 
                next_state <= state_load_instruction;
    
            -- Set char states

            when state_set_char_start => 
                next_state <= state_set_char_end;
    
            when state_set_char_end =>
                if OUT_BUSY = '0' then
                    next_state <= state_load_instruction;
                else
                    next_state <= state_set_char_end;
                end if;
            
            -- Get char states

            when state_get_char_start =>
                next_state <= state_get_char_end;
    
            when state_get_char_end =>
                if IN_VLD /= '1' then
                    next_state <= state_get_char_end;
                else
                    next_state <= state_load_instruction;
                end if;
            
            -- While Start states

            when state_while_start =>
                next_state <= state_while_start_ram_ptr;
            
            when state_while_start_ram_ptr =>
                if DATA_RDATA = "00000000" then
                    next_state <= state_while_start_cnt_check;
                else
                    next_state <= state_load_instruction;
                end if;

            when state_while_start_cnt_check =>
                if CNT_OUT /= "000000000000" then
                    next_state <= state_while_start_rom_en;
                else
                    next_state <= state_load_instruction;
                end if;
            
            when state_while_start_rom_en =>
                next_state <= state_while_start_cnt_check;
            
            -- While End states

            when state_while_end =>
                next_state <= state_while_end_ram_ptr;

            when state_while_end_ram_ptr =>
                if DATA_RDATA = "00000000" then
                    next_state <= state_load_instruction;
                else
                    next_state <= state_while_end_rom_en;
                end if;
            
            when state_while_end_cnt_loop =>
                if CNT_OUT /= "000000000000" then
                    next_state <= state_while_end_cnt_check;
                else
                    next_state <= state_load_instruction;
                end if;
            
            when state_while_end_cnt_check =>
                next_state <= state_while_end_rom_en;

            when state_while_end_rom_en =>
                next_state <= state_while_end_cnt_loop;
            
            -- Break command
            
            when state_break =>
                next_state <= state_break_rom_en;
            
            when state_break_rom_en =>
                next_state <= state_break_cnt_loop;

            when state_break_cnt_loop =>
                if CNT_OUT /= "000000000000" then
                    next_state <= state_break_rom_en;
                else
                    next_state <= state_load_instruction;
                end if;

            -- Other state

            when state_other =>
                next_state <= state_load_instruction;

            -- Halt state

            when state_return =>
                next_state <= state_return;

        end case;
    end process;


   -- Logika výpočtu výstupných hodnôt
   cpu_fsm_output_logic : process (CODE_DATA, IN_VLD, OUT_BUSY, DATA_RDATA, CNT_OUT ,current_state)
    begin
       
       -- Preset output
       PC_INC <= '0';
       PC_DEC <= '0';
       PC_CLEAR <= '0';
       PTR_DEC <= '0';
       PTR_INC <= '0';
       PTR_CLEAR <= '0';
       CNT_DEC <= '0';
       CNT_CLEAR <= '0';
       CNT_INC <= '0';
       DATA_WREN <= '0';
       IN_REQ <= '0';
       MUX_SEL <= "00";
       CODE_EN <= '0';
       DATA_EN <= '0';
       OUT_WREN <= '0';
      
        case current_state is
            when state_idle =>
                PC_CLEAR <= '1';
                CNT_CLEAR <= '1';
                PTR_CLEAR <= '1';

            when state_load_instruction =>
                CODE_EN <= '1';

            when state_inc_val_ptr =>
                PC_INC <= '1';
                PTR_INC <= '1';

            when state_dec_val_ptr =>
                PC_INC <= '1';
                PTR_DEC <= '1';

            when state_inc_cell_start =>
                DATA_EN <= '1';
                DATA_WREN <= '0';

            when state_mux_sel_10 =>
                MUX_SEL <= "10";

            when state_inc_cell_end =>
                DATA_EN <= '1';
                DATA_WREN <= '1';
                PC_INC <= '1';

            when state_dec_cell_start =>
                DATA_EN <= '1';
                DATA_WREN <= '0';

            when state_mux_sel_01 =>
                MUX_SEL <= "01";

            when state_dec_cell_end =>
                DATA_EN <= '1';
                DATA_WREN <= '1';
                PC_INC <= '1';

            -- Set char states
            when state_set_char_start =>
                DATA_EN <= '1';
                DATA_WREN <= '0';

            when state_set_char_end =>
                if OUT_BUSY = '0' then
                    OUT_WREN <= '1';
                    PC_INC <= '1';
                else
                    DATA_EN <= '1';
                    DATA_WREN <= '0';
                end if;

            -- Get char states
            when state_get_char_start =>
                IN_REQ <= '1';
                MUX_SEL <= "00";

            when state_get_char_end =>
                if IN_VLD /= '1' then
                    IN_REQ <= '1';
                    MUX_SEL <= "00";
                else
                    DATA_EN <= '1';
                    DATA_WREN <= '1';
                    PC_INC <= '1';
                end if;
            
            -- While start states
            
            when state_while_start =>
                PC_INC <= '1';
                DATA_EN <= '1';
                DATA_WREN <= '0';
                
            when state_while_start_ram_ptr =>
                if DATA_RDATA = "00000000" then
                    CNT_INC <= '1';
                    CODE_EN <= '1';
                end if;

            when state_while_start_cnt_check =>
                if CNT_OUT /= "000000000000" then
                    if CODE_DATA = x"5B" then
                        CNT_INC <= '1';
                    elsif CODE_DATA = x"5D" then
                        CNT_DEC <= '1';
                    end if;
                    PC_INC <= '1';
                end if;
                
            when state_while_start_rom_en =>
                CODE_EN <= '1';

            -- While End states
            
            when state_while_end =>
                DATA_EN <= '1';
                DATA_WREN <= '0';

            when state_while_end_ram_ptr =>
                if DATA_RDATA = "00000000" then
                    PC_INC <= '1';
                else
                    CNT_INC <= '1';
                    PC_DEC <= '1';
                end if;
                
            when state_while_end_cnt_loop =>
                if CNT_OUT /= "000000000000" then
                    if CODE_DATA = x"5D" then
                        CNT_INC <= '1';
                    elsif CODE_DATA = x"5B" then
                        CNT_DEC <= '1';
                    end if;
                end if;
                
            when state_while_end_cnt_check =>
                if CNT_OUT = "000000000000" then
                    PC_INC <= '1';
                else
                    PC_DEC <= '1';
                end if;

            when state_while_end_rom_en =>
                CODE_EN <= '1';

            -- Break load states    
            when state_break =>
                CNT_INC <= '1';
                PC_INC <= '1';
            
            when state_break_rom_en =>
                CODE_EN <= '1';

            when state_break_cnt_loop =>

                if CNT_OUT /= "000000000000" then

                    if CODE_DATA = x"5B" then 
                        CNT_INC <= '1';
                    elsif CODE_DATA = x"5D" then
                        CNT_DEC <= '1';
                    end if;
                    PC_INC <= '1';
                end if;

            when state_other =>
                PC_INC <= '1';

            when others => null;
        end case;
    end process;
  end behavioral;


library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

  
-- ----------------------------------------------------------------------------
--                        Entity declaration
-- ----------------------------------------------------------------------------
entity cpu is
 port (
   CLK   : in std_logic;  -- hodinovy signal
   RESET : in std_logic;  -- asynchronni reset procesoru
   EN    : in std_logic;  -- povoleni cinnosti procesoru
 
   -- synchronni pamet ROM
   CODE_ADDR : out std_logic_vector(11 downto 0); -- adresa do pameti
   CODE_DATA : in std_logic_vector(7 downto 0);   -- CODE_DATA <- rom[CODE_ADDR] pokud CODE_EN='1'
   CODE_EN   : out std_logic;                     -- povoleni cinnosti
   
   -- synchronni pamet RAM
   DATA_ADDR  : out std_logic_vector(9 downto 0); -- adresa do pameti
   DATA_WDATA : out std_logic_vector(7 downto 0); -- ram[DATA_ADDR] <- DATA_WDATA pokud DATA_EN='1'
   DATA_RDATA : in std_logic_vector(7 downto 0);  -- DATA_RDATA <- ram[DATA_ADDR] pokud DATA_EN='1'
   DATA_WREN  : out std_logic;                    -- cteni z pameti (DATA_WREN='0') / zapis do pameti (DATA_WREN='1')
   DATA_EN    : out std_logic;                    -- povoleni cinnosti
   
   -- vstupni port
   IN_DATA   : in std_logic_vector(7 downto 0);   -- IN_DATA obsahuje stisknuty znak klavesnice pokud IN_VLD='1' a IN_REQ='1'
   IN_VLD    : in std_logic;                      -- data platna pokud IN_VLD='1'
   IN_REQ    : out std_logic;                     -- pozadavek na vstup dat z klavesnice
   
   -- vystupni port
   OUT_DATA : out  std_logic_vector(7 downto 0);  -- zapisovana data
   OUT_BUSY : in std_logic;                       -- pokud OUT_BUSY='1', LCD je zaneprazdnen, nelze zapisovat,  OUT_WREN musi byt '0'
   OUT_WREN : out std_logic                       -- LCD <- OUT_DATA pokud OUT_WE='1' a OUT_BUSY='0'
 );
end cpu;


-- ----------------------------------------------------------------------------
--                      Architecture declaration
-- ----------------------------------------------------------------------------
architecture behavioral of cpu is

 -- zde dopiste potrebne deklarace signalu

  -- PTR Signals
  signal ptr_out : std_logic_vector (9 downto 0) := "0000000000";
  signal ptr_inc : std_logic := '0';
  signal ptr_dec : std_logic := '0';
  signal ptr_clear : std_logic := '0';

  -- CNT Signals
  signal cnt_out : std_logic_vector (11 downto 0) := "000000000000";
  signal cnt_inc : std_logic := '0';
  signal cnt_dec : std_logic := '0';
  signal cnt_clear : std_logic := '0';

  -- PC Signals
  signal pc_out : std_logic_vector (11 downto 0) := "000000000000";
  signal pc_inc : std_logic := '0';
  signal pc_dec : std_logic := '0';
  signal pc_clear : std_logic := '0';

  -- MUX Signals
  signal mux_sel : std_logic_vector (1 downto 0 ) := "00";
  signal mux_out : std_logic_vector (7 downto 0)  := "00000000";

begin

 -- CPU FSM entity
 CPU_FSM : entity work.CPU_FSM (behavioral)
 port map (
    CLK => CLK,
    RST => RESET,
    EN => EN,
    CODE_DATA => CODE_DATA,
    IN_VLD => IN_VLD,
    OUT_BUSY => OUT_BUSY,
    DATA_RDATA => DATA_RDATA,
    CNT_OUT => cnt_out,
    PTR_INC => ptr_inc,
    PTR_DEC => ptr_dec,
    PTR_CLEAR => ptr_clear,
    CNT_INC => cnt_inc,
    CNT_DEC => cnt_dec,
    CNT_CLEAR => cnt_clear,
    PC_INC => pc_inc,
    PC_DEC => pc_dec,
    PC_CLEAR => pc_clear,
    DATA_WREN => DATA_WREN,
    DATA_EN => DATA_EN,
    MUX_SEL => mux_sel,
    CODE_EN => CODE_EN,
    IN_REQ => IN_REQ,
    OUT_WREN => OUT_WREN

  );

 -- CPU PC entity
 CPU_PC : entity work.CPU_PC (behavioral)
 port map (
   CLK => CLK,
   RST => RESET,
   PC_INC => pc_inc,
   PC_DEC => pc_dec,
   PC_CLR => pc_clear,
   PC_OUT => pc_out
 );

 -- CPU CNT entity
 CPU_CNT : entity work.CPU_CNT (behavioral)
 port map (
  CLK => CLK,
  RST => RESET,
  CNT_INC => cnt_inc,
  CNT_DEC => cnt_dec,
  CNT_CLR => cnt_clear,
  CNT_OUT => cnt_out
 );

 -- CPU PTR entity
 CPU_PTR : entity work.CPU_PTR (behavioral)
 port map (
  CLK => CLK,
  RST => RESET,
  PTR_INC => ptr_inc,
  PTR_DEC => ptr_dec,
  PTR_CLR => ptr_clear,
  PTR_OUT => ptr_out
 );
 
 -- CPU MUX entity
 CPU_MUX : entity work.CPU_MUX (behavioral)
 port map(
  CLK => CLK,
  RST => RESET,
  DATA_IN_00 => IN_DATA,
  DATA_IN_01 => DATA_RDATA,
  MUX_SEL => mux_sel,
  MUX_OUT => mux_out
 );


 -- Priradenie výstupov 

 DATA_WDATA <= mux_out;
 DATA_ADDR <= ptr_out;
 CODE_ADDR <= pc_out;
 OUT_DATA <= DATA_RDATA;

end behavioral;

