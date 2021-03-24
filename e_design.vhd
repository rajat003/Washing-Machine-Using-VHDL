
-- ENGI-9865 - ADS
-- PROject : Automated Washing machine
-- Project Implementation
-- Group Members:
--	Disha Bodiwala - 201991118
-- Rajat Acharya - 201990852  

-- Main source code --

-- Code for counter -- (Data path)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  --library for unsigned--
			
										----counter entity----
entity time_counter is 
port(
		clock,reset: in std_logic;
		Q : out std_logic_vector(4 downto 0)--till 32 sec counter
);
end time_counter;
	
										---- counter architecture ----
architecture a_counter of time_counter is
signal cntr: unsigned (4 downto 0) :="00000"; --temporary signal to save counter value--and initialization to 0
	begin 
	process(clock)
	begin
		if(clock'event and clock='1') then
			if(reset='1') then --if reset is 1 then set every bit to zero
				cntr<="00000";
			else 					 --otherwise, increment counter value by 1
				cntr<=cntr+1;
			end if;	
		end if;
	end process;
Q<=std_logic_vector(cntr);	-- assign value of signal-cntr to output Q

end a_counter;


-- code  for main system -- (Controller)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

							-- Controller entity --
entity e_design is
	port(clock,coin,lid_closed,stop,start: in std_logic;
			mode :in std_logic_vector(1 downto 0);
			coin_return,water,water_temp10,water_temp20,water_temp30,detergent,drain,spin,blower: out std_logic);
end e_design;
				
					-- controller architecture --
architecture a_design of e_design is
	
	-- component of counter --
component time_counter
	port(clock,reset: in std_logic;
		Q : out std_logic_vector(4 downto 0));
	end component;

signal start_timer,time_10m,time_20m,time_30m : std_logic;


signal q_out: std_logic_vector(4 downto 0);

type state is (idle,check_mode,ready,
					soak_delicate,soak_dirty,
					wash_delicate,wash_casual,wash_dirty,
					rinse_simple,rinse_delicate,rinse_casual,rinse_dirty,
					spin_simple,spin_delicate,spin_casual,spin_dirty,
					dry_simple,dry_delicate,dry_casual,dry_dirty);


signal present_state , next_state : state := idle;

begin

counter_map : time_counter port map(clock,start_timer,Q_out);
time_10m <=Q_out(3) and Q_out(1) and not Q_out(4) and not Q_out(2) and not Q_out(0) ;
time_20m <=Q_out(4) and Q_out(2) and not Q_out(3) and not Q_out(3) and not Q_out(0);
time_30m <=Q_out(4) and Q_out(3) and Q_out(2) and Q_out(1) and not Q_out(0);

process1: process(clock)
begin
		if(clock'event and clock='1') then
				present_state<=next_state;
		end if;
end process;

process2: process(present_state)
begin
	
	case (present_state) is
	
		when idle=> --in idle condition, if token is inserted then only will move to next state else will stay idle only
			--output
			coin_return<='0';
			water<='0';
			water_temp10<='0';
			water_temp20<='0';
			water_temp30<='0';
				detergent<='0';
			spin<='0';
			drain<='0';
			blower<='0';
			if(coin='1') then 
				next_state<=ready;
			else 
				next_state<=idle;
			end if;
			
			-- Ready state --
						
		when Ready=>

			if ((stop='1' or lid_closed='0') and start='0') then
						next_state<=idle;
						coin_return<='1'; ---returning to idle and return coin
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
								
			elsif ((stop='0' and lid_closed='1') and start='0') then
						next_state<=Ready; 
						coin_return<='0'; --remain in Ready and DON'T return coin
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';	
						
			elsif ((stop='0' and lid_closed='1') and start='1') then
						next_state<=check_mode; 				
						coin_return<='0'; -- go to check_mode state and Don't return coin
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
			else 
				next_state <=idle;
				coin_return<='0';
				water<='0';
				water_temp10<='0';
				water_temp20<='0';
				water_temp30<='0';
				detergent<='0';
				spin<='0';
				drain<='0';
				blower<='0';
				end if;
			
	----CHOOSING MODE----	
				
		when check_mode=>
		if(lid_closed='1')then
			if(stop='0') then
					coin_return<='0'; --every output is zero in check_mode state--
					water<='0';
					water_temp10<='0';
					water_temp20<='0';
					water_temp30<='0';
					detergent<='0';
					spin<='0';
					drain<='0';
					blower<='0';
			 case mode is
			   when "00" =>
					next_state<=rinse_simple;-- Direct Rinse cycle
					
				when "01" =>
					next_state<=soak_delicate;-- DELICATES cycyle
									
				when "10" =>
					next_state<=wash_casual; -- CASUAL Cycyle
									
				when "11" =>
					next_state<=soak_dirty;-- DIRTY cycle
				end case;
				
			elsif(stop='1' or lid_closed='0') then
				next_state<=idle;
				coin_return<='0';
				water<='0';
				water_temp10<='0';
				water_temp20<='0';
				water_temp30<='0';
				detergent<='0';
				spin<='0';
				drain<='0';
				blower<='0';
			else
				next_state<=idle;
				coin_return<='0';
				water<='0';
				water_temp10<='0';
				water_temp20<='0';
				water_temp30<='0';
				detergent<='0';
				spin<='0';
				drain<='0';
				blower<='0';
			
			end if;
			
			else
				next_state<=idle;
				coin_return<='0';
				water<='0';
				water_temp10<='0';
				water_temp20<='0';
				water_temp30<='0';
				detergent<='0';
				spin<='0';
				drain<='0';
				blower<='0';
			
			end if;

			
--SOAK cycles--			
	
			when soak_delicate=>
			if(lid_closed='1')then
				if( time_10m = '0') then
					if(stop='0') then
						next_state<=soak_delicate;
						coin_return<='0'; -- coin can be returned only in idle and ready state
						water<='1';			-- water intake is ON
						water_temp10<='1';-- water temp is 10 deg for delicates
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';			-- drain is OFF while soaking
						blower<='0';	
					elsif(stop='1' or lid_closed='0') then 
						next_state<=idle; 
							coin_return<='0';
							water<='0';
							water_temp10<='0';
							water_temp20<='0';
							water_temp30<='0';
							detergent<='0';
							spin<='0';
							drain<='0';
							blower<='0';
							else
							next_state<=idle;
							coin_return<='0';
							water<='0';
							water_temp10<='0';
							water_temp20<='0';
							water_temp30<='0';
							detergent<='0';
							spin<='0';
							drain<='0';
							blower<='0';
			
						end if;
					else
					next_state<=wash_delicate;  
				end if;
				else
				next_state<=idle;
				coin_return<='0';
							water<='0';
							water_temp10<='0';
							water_temp20<='0';
							water_temp30<='0';
							detergent<='0';
							spin<='0';
							drain<='0';
							blower<='0';
					end if;
			
			when soak_dirty=>
			
			if(lid_closed='1')then
			
			   if(time_10m='0') then
					 if(stop='0') then
						next_state<=soak_dirty;
						coin_return<='0'; -- coin can be returned only in idle and ready state
						water<='1';			-- water intake is ON
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='1';-- water temp is 30 deg for Dirty cycle
						detergent<='0';
						spin<='0';
						drain<='0';			-- drain is OFF while soaking
						blower<='0';
					 
					 elsif(stop='1' or lid_closed='0') then  --lid opened or stop pressed
						next_state<=idle;  
						coin_return<='0';
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
						else
							next_state<=idle;
							coin_return<='0';
							water<='0';
							water_temp10<='0';
							water_temp20<='0';
							water_temp30<='0';
							detergent<='0';
							spin<='0';
							drain<='0';
							blower<='0';
			
						end if;
				else --10mins are over
					next_state<=wash_dirty; 
				end if;	
				
				else
					next_state<=idle;
					coin_return<='0';
					water<='0';
					water_temp10<='0';
					water_temp20<='0';
					water_temp30<='0';
					detergent<='0';
					spin<='0';
					drain<='0';
					blower<='0';
				
						end if;
		
--WASH cycles

			when wash_delicate=>
			if(lid_closed='1') then
				if(time_30m='0') then
					if(stop='0') then
						next_state<=wash_delicate;
						coin_return<='0'; -- coin can be returned only in idle and ready state
						water<='1';			-- water intake is ON
						water_temp10<='1';-- water temp is 10 deg for DELICATES
						water_temp20<='0';
						water_temp30<='0';
						detergent<='1';	--add detergent while washing
						spin<='0';
						drain<='0';			-- drain is OFF while washing
						blower<='0';
					elsif(stop='1' or lid_closed='0') then --lid opened or stop pressed
						next_state<=idle;
						coin_return<='0';
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
					else
						next_state<=idle;
						coin_return<='0';
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
					end if;
			
				else
					next_state<=rinse_delicate;
				end if;	
				else
						next_state<=idle;
						coin_return<='0';
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
					end if;

			when wash_casual=>
			if(lid_closed='1') then
				if(time_30m='0') then
					if(stop='0') then
						next_state<=wash_casual;
						coin_return<='0'; -- coin can be returned only in idle and ready state
						water<='1';			-- water intake is ON
						water_temp10<='0';
						water_temp20<='1';-- water temp is 20 deg for CASUALs
						water_temp30<='0';
						detergent<='1';	--add detergent while washing
						spin<='0';
						drain<='0';			-- drain is OFF while washing
						blower<='0';	
					elsif(stop='1' or lid_closed='0') then --lid opened or stop pressed
						next_state<=idle;
						coin_return<='0';
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
						else
						next_state<=idle;
						coin_return<='0';
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
			
					end if;
				else
					next_state<=rinse_casual;
				end if;
				
				else
				next_state<=idle;
				coin_return<='0';
				water<='0';
				water_temp10<='0';
				water_temp20<='0';
				water_temp30<='0';
				detergent<='0';
				spin<='0';
				drain<='0';
				blower<='0';
					end if;
			
			when wash_dirty=>
			if(lid_closed='1') then

				if(time_30m='0') then
					if(stop='0') then
						next_state<=wash_dirty;
						coin_return<='0'; -- coin can be returned only in idle and ready state
						water<='1';			-- water intake is ON
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='1';-- water temp is 30 deg for DIRTY
						detergent<='1';	--add detergent while washing
						spin<='0';
						drain<='0';			-- drain is OFF while washing
						blower<='0';
					elsif(stop='1' or lid_closed='0') then --lid opened or stop pressed
						next_state<=idle;
						coin_return<='0';
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
						else
							next_state<=idle;
							coin_return<='0';
							water<='0';
							water_temp10<='0';
							water_temp20<='0';
							water_temp30<='0';
							detergent<='0';
							spin<='0';
							drain<='0';
							blower<='0';
			
					end if;	
				else
					next_state<=rinse_dirty;
				end if;	
				
				

				else
				next_state<=idle;
				coin_return<='0';
				water<='0';
				water_temp10<='0';
				water_temp20<='0';
				water_temp30<='0';
				detergent<='0';
				spin<='0';
				drain<='0';
				blower<='0';
					end if;

--Rinse cycles--					
				
		when rinse_simple=>
		if(lid_closed='1') then
				if(time_20m='0') then
					if(stop='0' ) then
						next_state<=rinse_simple;
						coin_return<='0'; -- coin can be returned only in idle and ready state
						water<='1';			-- water intake is ON
						water_temp10<='1';-- water temp is 10 deg for  Rinse directcycle
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='1';  -- drain is ON for rinsing
						blower<='0';
					elsif(stop='1' or lid_closed='0') then --lid opened or stop pressed
						next_state<=idle;
						coin_return<='0';
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
						else
							next_state<=idle;
							coin_return<='0';
							water<='0';
							water_temp10<='0';
							water_temp20<='0';
							water_temp30<='0';
							detergent<='0';
							spin<='0';
							drain<='0';
							blower<='0';
			
					end if;		
				else
					next_state<=spin_simple;
				end if;
				
				else
				next_state<=idle;
				coin_return<='0';
				water<='0';
				water_temp10<='0';
				water_temp20<='0';
				water_temp30<='0';
				detergent<='0';
				spin<='0';
				drain<='0';
				blower<='0';
			
					end if;		
				
		when rinse_delicate=>
		if(lid_closed='1') then
				if(time_20m='0') then
					if(stop='0') then
						next_state<=rinse_delicate;
						coin_return<='0'; -- coin can be returned only in idle and ready state
						water<='1';			-- water intake is ON
						water_temp10<='1';-- water temp is 10 deg for  DELICATES cycle
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';	--Detergent is OFF for rinse
						spin<='0';
						drain<='1';  -- drain is ON for rinsing
						blower<='0';
					elsif(stop='1' or lid_closed='0') then --lid opened or stop pressed
						next_state<=idle;
						coin_return<='0';
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
						else
							next_state<=idle;
							coin_return<='0';
							water<='0';
							water_temp10<='0';
							water_temp20<='0';
							water_temp30<='0';
							detergent<='0';
							spin<='0';
							drain<='0';
							blower<='0';
			
					end if;	
				else
					next_state<=spin_delicate;
				end if;	
				
				else
				next_state<=idle;
				coin_return<='0';
				water<='0';
				water_temp10<='0';
				water_temp20<='0';
				water_temp30<='0';
				detergent<='0';
				spin<='0';
				drain<='0';
				blower<='0';
			
					end if;	
			
		when rinse_casual=>
		if(lid_closed='1') then
				if(time_20m='0') then
					if(stop='0' ) then
						next_state<=rinse_casual;
						coin_return<='0'; -- coin can be returned only in idle and ready state
						water<='1';			-- water intake is ON
						water_temp10<='0';
						water_temp20<='1';-- water temp is 20 deg for CASUALs
						water_temp30<='0';
						detergent<='0';	--Detergent is OFF for rinse
						spin<='0';
						drain<='1';  -- drain is ON for rinsing
						blower<='0';
					elsif(stop='1' or lid_closed='0') then --lid opened or stop pressed
						next_state<=idle;
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						else
				next_state<=idle;
				coin_return<='0';
				water<='0';
				water_temp10<='0';
				water_temp20<='0';
				water_temp30<='0';
				detergent<='0';
				spin<='0';
				drain<='0';
				blower<='0';
			
					end if;	
				else
					next_state<=spin_casual;
				end if;
					else
						next_state<=idle;
						coin_return<='0';
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
				end if;
			
		when rinse_dirty=>
		if(lid_closed='1') then
				if(time_20m='0') then
					if(stop='0' ) then
						next_state<=rinse_dirty;
						coin_return<='0'; -- coin can be returned only in idle and ready state
						water<='1';			-- water intake is ON
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='1';-- water temp is 30 deg for DIRTY
						detergent<='0';	--Detergent is OFF for rinse
						spin<='0';
						drain<='1';  -- drain is ON for rinsing
						blower<='0';
					elsif(stop='1' or lid_closed='0') then --lid opened or stop pressed
							next_state<=idle;
							water<='0';
							water_temp10<='0';
							water_temp20<='0';
							water_temp30<='0';
							detergent<='0';
							spin<='0';
							drain<='0';
						else
							next_state<=idle;
							coin_return<='0';
							water<='0';
							water_temp10<='0';
							water_temp20<='0';
							water_temp30<='0';
							detergent<='0';
							spin<='0';
							drain<='0';
							blower<='0';
			
						end if;
				else
					next_state<=spin_dirty;
				end if;
	
			else
				next_state<=idle;
				coin_return<='0';
				water<='0';
				water_temp10<='0';
				water_temp20<='0';
				water_temp30<='0';
				detergent<='0';
				spin<='0';
				drain<='0';
				blower<='0';
			
						end if;	

--SPINNing cycle--			
		
			when spin_simple=>
			if(lid_closed='1') then
				if(time_10m='0') then
					if(stop='0') then
						next_state<=spin_simple;
						water<='0';			-- water intake is OFF
						water_temp10<='0';-- water temp is also OFF
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='1';		-- spin is ON
						drain<='1';  -- drain is ON for spinning
						blower<='0';					
					elsif(stop='1' or lid_closed='0') then --lid opened or stop pressed
						next_state<=idle;
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						else
							next_state<=idle;
							coin_return<='0';
							water<='0';
							water_temp10<='0';
							water_temp20<='0';
							water_temp30<='0';
							detergent<='0';
							spin<='0';
							drain<='0';
							blower<='0';
			
					end if;
				else
					next_state<=dry_simple;
				end if;
			
			else
				next_state<=idle;
				coin_return<='0';
				water<='0';
				water_temp10<='0';
				water_temp20<='0';
				water_temp30<='0';
				detergent<='0';
				spin<='0';
				drain<='0';
				blower<='0';
			
					end if;
					
			when spin_delicate=>
			if(lid_closed='1') then
				if(time_10m='0') then
					if(stop='0') then
						next_state<=spin_delicate;
						coin_return<='0'; -- coin can be returned only in idle and ready state
						water<='0';			-- water intake is OFF
						water_temp10<='0';-- water temp is also OFF
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='1';		-- spin is ON
						drain<='1';  -- drain is ON for spinning
						blower<='0';					
					elsif(stop='1' or lid_closed='0') then --lid opened or stop pressed
						next_state<=idle;
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						else
							next_state<=idle;
							coin_return<='0';
							water<='0';
							water_temp10<='0';
							water_temp20<='0';
							water_temp30<='0';
							detergent<='0';
							spin<='0';
							drain<='0';
							blower<='0';
			
					end if;
				else
					next_state<=dry_delicate;
				end if;
				
				else
					next_state<=idle;
					coin_return<='0';
					water<='0';
					water_temp10<='0';
					water_temp20<='0';
					water_temp30<='0';
					detergent<='0';
					spin<='0';
					drain<='0';
					blower<='0';
			
					end if;
				
			when spin_casual=>
			if(lid_closed='1') then
				if(time_10m='0') then
					if(stop='0') then
						next_state<=spin_casual;
						coin_return<='0'; -- coin can be returned only in idle and ready state
						water<='0';			-- water intake is ON
						water_temp10<='0';-- water temp is is also OFF
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='1';		-- spin is ON
						drain<='1';  -- drain is ON for spinning
						blower<='0';
					elsif(stop='1' or lid_closed='0') then --lid opened or stop pressed
						next_state<=idle;
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
					else
						next_state<=idle;
						coin_return<='0';
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
			
					end if;
				else
					next_state<=dry_casual;
				end if;
				
			else
				next_state<=idle;
				coin_return<='0';
				water<='0';
				water_temp10<='0';
				water_temp20<='0';
				water_temp30<='0';
				detergent<='0';
				spin<='0';
				drain<='0';
				blower<='0';
				end if;
	
			when spin_dirty=>
			if(lid_closed='1') then
				if(time_10m='0') then
					if(stop='0') then
						next_state<=spin_dirty;
						coin_return<='0'; -- coin can be returned only in idle and ready state
						water<='0';			-- water intake is ON
						water_temp10<='0';-- water temp is is also OFF
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='1';	 -- spin is ON
						drain<='1';  -- drain is ON for spinning
						blower<='0';
					elsif(stop='1' or lid_closed='0') then --lid opened or stop pressed
						next_state<=idle;
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
					else
						next_state<=idle;
						coin_return<='0';
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
			
					end if;
				else
					next_state<=dry_dirty;
				end if;
				
				else
					next_state<=idle;
					coin_return<='0';
					water<='0';
					water_temp10<='0';
					water_temp20<='0';
					water_temp30<='0';
					detergent<='0';
					spin<='0';
					drain<='0';
					blower<='0';
				
					end if;
	
--DRYing cycle--	
			when dry_simple=>
			if(lid_closed='1') then
				if(time_30m='0') then
					if(stop='0')	then
						next_state<=dry_simple;
						coin_return<='0'; -- coin can be returned only in idle and ready state
						water<='0';			-- water intake is OFF
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';  
						blower<='1';-- Drying blower is ON for DRYing cycle 
					elsif(stop='1' or lid_closed='0') then --lid opened or stop pressed
						next_state<=idle;
						coin_return<='0'; -- coin can be returned only in idle and ready stat
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
					else
						next_state<=idle;
						coin_return<='0';
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
			
					end if;
				else
					next_state<=idle;
					coin_return<='0'; -- coin can be returned only in idle and ready stat
					water<='0';
					water_temp10<='0';
					water_temp20<='0';
					water_temp30<='0';
					detergent<='0';
					spin<='0';
					drain<='0';
				end if;
					
			else
				next_state<=idle;
				coin_return<='0';
				water<='0';
				water_temp10<='0';
				water_temp20<='0';
				water_temp30<='0';
				detergent<='0';
				spin<='0';
				drain<='0';
				blower<='0';
			end if;	
				
			when dry_delicate=>
			if(lid_closed='1') then
				if(time_30m='0') then
					if(stop='0' )	then
						next_state<=dry_delicate;
						coin_return<='0'; -- coin can be returned only in idle and ready state
						water<='0';			-- water intake is OFF
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';  
						blower<='1';-- Drying blower is ON for DRYing cycle 	
					elsif(stop='1' or lid_closed='0') then --lid opened or stop pressed
						next_state<=idle;
						coin_return<='0'; -- coin can be returned only in idle and ready stat
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
					else
						next_state<=idle;
						coin_return<='0';
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
			
					end if;
				else
					next_state<=idle;		
					coin_return<='0'; -- coin can be returned only in idle and ready stat
					water<='0';
					water_temp10<='0';
					water_temp20<='0';
					water_temp30<='0';
					detergent<='0';
					spin<='0';
					drain<='0';
				end if;
				
				else
					next_state<=idle;
					coin_return<='0';
					water<='0';
					water_temp10<='0';
					water_temp20<='0';
					water_temp30<='0';
					detergent<='0';
					spin<='0';
					drain<='0';
					blower<='0';
			
					end if;
				
			when dry_casual=>
			if(lid_closed='1') then
				if(time_30m='0') then
					if(stop='0')	then
						next_state<=dry_casual;
						coin_return<='0'; -- coin can be returned only in idle and ready state
						water<='0';			-- water intake is OFF
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';  
						blower<='1';-- Drying blower is ON for DRYing cycle 
					elsif(stop='1' or lid_closed='0') then --lid opened or stop pressed
						next_state<=idle;
						coin_return<='0'; -- coin can be returned only in idle and ready stat
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
					else
						next_state<=idle;
						coin_return<='0';
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
			
					end if;
				else
					next_state<=idle;		
					coin_return<='0'; -- coin can be returned only in idle and ready stat
					water<='0';
					water_temp10<='0';
					water_temp20<='0';
					water_temp30<='0';
					detergent<='0';
					spin<='0';
					drain<='0';
				end if;
			
			else
				next_state<=idle;
				coin_return<='0';
				water<='0';
				water_temp10<='0';
				water_temp20<='0';
				water_temp30<='0';
				detergent<='0';
				spin<='0';
				drain<='0';
				blower<='0';
			
					end if;	
				
			when dry_dirty=>
			if(lid_closed='1') then
				if(time_30m='0') then
					if(stop='0')	then
						next_state<=dry_dirty;
						coin_return<='0'; -- coin can be returned only in idle and ready state
						water<='0';			-- water intake is OFF
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';  
						blower<='1';-- Drying blower is ON for DRYing cycle ;
					elsif(stop='1' or lid_closed='0') then --lid opened or stop pressed
						next_state<=idle;
						coin_return<='0'; -- coin can be returned only in idle and ready stat
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
					else
						next_state<=idle;
						coin_return<='0';
						water<='0';
						water_temp10<='0';
						water_temp20<='0';
						water_temp30<='0';
						detergent<='0';
						spin<='0';
						drain<='0';
						blower<='0';
			
					end if;
				else
					next_state<=idle;		
					coin_return<='0'; -- coin can be returned only in idle and ready stat
					water<='0';
					water_temp10<='0';
					water_temp20<='0';
					water_temp30<='0';
					detergent<='0';
					spin<='0';
					drain<='0';
			end if;

			else
				next_state<=idle;
				coin_return<='0';
				water<='0';
				water_temp10<='0';
				water_temp20<='0';
				water_temp30<='0';
				detergent<='0';
				spin<='0';
				drain<='0';
				blower<='0';
			
					end if;			
		end case;	
	end process;		
start_timer <= '1' 

	when (( present_state = soak_delicate or present_state = soak_dirty)  and ( time_10m = '1'))	
or 
(( present_state = wash_delicate or present_state = wash_casual or present_state = wash_dirty )	and ( time_30m = '1'))	
or
(( present_state = rinse_simple or present_state = rinse_delicate or present_state = rinse_casual or present_state = rinse_dirty ) and (time_20m='1'))
or 
(( present_state = spin_simple or present_state = spin_delicate or present_state = spin_casual or present_state = spin_dirty ) and (time_10m='1'))
or
 (( present_state = dry_simple or present_state = dry_delicate or present_state = dry_casual or present_state = dry_dirty ) and (time_20m='1'))
					

	else '0';

end a_design;