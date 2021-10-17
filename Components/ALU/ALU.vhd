library IEEE;
use IEEE.std_logic_1164.all;

entity ALU is
  generic( N: integer := 32; N5: integer := 5);
  port(i_A : in std_logic_vector(N-1 downto 0);
       i_B : in std_logic_vector(N-1 downto 0);
	   i_Shamt : in std_logic_vector(N5-1 downto 0);
	   i_ALUOP : in std_logic_vector(N5-1 downto 0);
	   o_Zero : out std_logic;
	   o_S : out std_logic_vector(N-1 downto 0));

end ALU;

architecture structure of ALU is

	component Ripple_Adder is
	  generic( N: integer := N );
	  port(i_A : in std_logic_vector(N-1 downto 0);
		   i_B : in std_logic_vector(N-1 downto 0);
		   o_S : out std_logic_vector(N-1 downto 0));

	end component;
	
	component invg_N is
	  generic( N: integer := N );
	  port(i_A          : in std_logic_vector( N - 1 downto 0);
		   o_F          : out std_logic_vector( N - 1 downto 0));

	end component;

	component and is
		generic( N: integer := N );
		port(i_A          : in std_logic_vector( N - 1 downto 0);
			 i_B          : in std_logic_vector( N - 1 downto 0);
			 o_F          : out std_logic_vector( N - 1 downto 0));
  
	  end component;

	  component or is
		generic( N: integer := N );
		port(i_A          : in std_logic_vector( N - 1 downto 0);
			 i_B          : in std_logic_vector( N - 1 downto 0);
			 o_F          : out std_logic_vector( N - 1 downto 0));
  
	  end component;

	  component nor is
		generic( N: integer := N );
		port(i_A          : in std_logic_vector( N - 1 downto 0);
			 i_B          : in std_logic_vector( N - 1 downto 0);
			 o_F          : out std_logic_vector( N - 1 downto 0));
  
	  end component;

	  component xor is
		generic( N: integer := N );
		port(i_A          : in std_logic_vector( N - 1 downto 0);
			 i_B          : in std_logic_vector( N - 1 downto 0);
			 o_F          : out std_logic_vector( N - 1 downto 0));
  
	  end component;
	

	component NBitMux is
	  port(i_S          : in std_logic;
		   i_D0         : in std_logic_vector(N-1 downto 0);
		   i_D1         : in std_logic_vector(N-1 downto 0);
		   o_O          : out std_logic_vector(N-1 downto 0));

	end component;	

	component barrel_shifter is
		port(i_src          : in std_logic;
			 i_shift_type   : in std_logic_vector(1 downto 0);
			 i_shamt		: in std_logic_vector(N5-1 downto 0);
			 o_shift_out    : out std_logic_vector(N-1 downto 0));

	end component;	


	signal inv_B: std_logic_vector(N-1 downto 0);
	signal mux_B: std_logic_vector(N-1 downto 0);
	signal ripple_out: std_logic_vector(N-1 downto 0);
	signal inv_out: std_logic_vector(N-1 downto 0);
	signal sub_out: std_logic_vector(N-1 downto 0);
	signal and_out: std_logic_vector(N-1 downto 0);
	signal or_out: std_logic_vector(N-1 downto 0);
	signal nor_out: std_logic_vector(N-1 downto 0);
	signal xor_out: std_logic_vector(N-1 downto 0);
	signal shift_out: std_logic_vector(N-1 downto 0);
	signal srl_out: std_logic_vector(N-1 downto 0);
	signal sra_out: std_logic_vector(N-1 downto 0);
	signal slt_out: std_logic_vector(N-1 downto 0);
	signal inmux: std_logic_vector(N-1 downto 0);



begin	
	
	inv0: invg_N
		generic map ( N => N ) 
		port map(i_A => i_B,
				  o_F => inv_B);

	adder0: Ripple_Adder
		generic map ( N => N ) 
		port map( i_A => i_A,
				  i_B => mux_B,
				  o_S => ripple_out);

	and0: and
		generic map ( N => N ) 
		port map( i_A => i_A,
				  i_B => i_B,
				  o_F => and_out);

	or0: or
		generic map ( N => N ) 
		port map( i_A => i_A,
				  i_B => i_B,
				  o_F => or_out);

	nor0: nor
		generic map ( N => N ) 
		port map( i_A => i_A,
				  i_B => i_B,
				  o_F => nor_out);

	nor1: nor_N
		generic map ( N => N ) 
		port map( i_A => sub_out,
				  i_B => i_B,
				  o_F => o_Zero);

	xor0: xor
		generic map ( N => N ) 
		port map( i_A => i_A,
				  i_B => i_B,
				  o_F => xor_out);

	inv1: invg_N
		generic map ( N => N ) 
		port map( i_A => ripple_out,
				  o_F => inv_out);

	mux0: NBitMux
		generic map ( NUM_SELECT => 1 ) 
		port map( i_S => nAdd_Sub,
				  i_D0 => i_B,
				  i_D1 => inv_B,
				  o_O => mux_B);

	mux1: NBitMux
		generic map (NUM_SELECT => 1 ) 
		port map( i_S  => nAdd_Sub,
				  i_D0 => ripple_out,
				  i_D1 => inv_out,
				  o_O  => o_S);

	mainmux: NBitMux
		generic map (NUM_SELECT => 1 ) 
		port map( i_S  => nAdd_Sub,
				  i_D0 => ripple_out,
				  i_D1 => inv_out,
				  o_O  => o_S);
  
end structure;
