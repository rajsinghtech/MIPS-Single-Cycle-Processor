library IEEE;
use IEEE.std_logic_1164.all;

entity nor is
	generic ( N : integer := 32 );
	port ( i_A: in std_logic_vector( N -1 downto 0 );
		   i_B: in std_logic_vector( N -1 downto 0 );
		   o_F: out std_logic_vector( N - 1 downto 0 ) );
end nor;			   

architecture structure of oneComp is

    signal nF: std_logic_vector;

	component invg is
		port(i_A          : in std_logic;
			 o_F          : out std_logic);
	end component;

    component org2 is
		port(i_A          : in std_logic;
             i_B          : in std_logic;
			 o_F          : out std_logic);
	end component;
	
	begin
	
	G_NOR: for i in 0 to N-1 generate
	
		ORG0: invg port MAP (i_A => i_A(i), i_B => i_B(i), o_F => nF(i));
        INVG0: invg port MAP (i_A => nF(i), o_F => o_F(i));
	
	end generate G_NOR;

end structure;