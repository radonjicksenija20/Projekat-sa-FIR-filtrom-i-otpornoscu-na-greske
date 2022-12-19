
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.util_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_structure is
generic(    fir_ord : natural :=20;
            input_data_width : natural := 17;
            output_data_width : natural := 17;
            number_samples_g:positive:=51000);
    Port ( clk : in STD_LOGIC;
           reset : in std_logic;
           start: in std_logic;
           we_i : in STD_LOGIC;
           
           coef_i : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           coef_addr_i : std_logic_vector(log2c(fir_ord+1)-1 downto 0);
           
           data_i : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           addr_data_i : std_logic_vector(log2c(number_samples_g+1)-1 downto 0); --netacno, ima vise
           
           data_o : out STD_LOGIC_VECTOR (output_data_width-1 downto 0);
           addr_data_o : std_logic_vector(log2c(number_samples_g+1)-1 downto 0);
           
           ready_o : out STD_LOGIC);
end top_structure;

architecture Behavioral of top_structure is

 --general signals for BRAM
    signal zero_4 : std_logic_vector(3 downto 0);
    signal zero_width_g : std_logic_vector(input_data_width-1 downto 0);
    signal en_mem_s : std_logic;
    
    
  --signals between BRAM1 and FIR
   signal data_i_FIR_S : STD_LOGIC_VECTOR (input_data_width-1 downto 0);
   signal addr_data_i_FIR_s : std_logic_vector(log2c(number_samples_g+1)-1 downto 0);
   --signals between FIR and BRAM2
   signal  data_o_FIR_s: STD_LOGIC_VECTOR (input_data_width-1 downto 0);
   signal addr_data_o_FIR_s : std_logic_vector(log2c(number_samples_g+1)-1 downto 0);
  
  
    component BRAM
    generic(
            width_g:positive:=8;
            size_g:positive:=51000
            );
    port(
        clka : in std_logic;
        clkb : in std_logic;
        ena: in std_logic;
        enb: in std_logic;
        wea: in std_logic_vector(3 downto 0);
        web: in std_logic_vector(3 downto 0);
        addra : in std_logic_vector(log2c(size_g)-1 downto 0);
        addrb : in std_logic_vector(log2c(size_g)-1 downto 0);
        dia: in std_logic_vector(width_g-1 downto 0);
        dib: in std_logic_vector(width_g-1 downto 0);
        doa: out std_logic_vector(width_g-1 downto 0);
        dob: out std_logic_vector(width_g-1 downto 0)
        );
    end component;
    
    
    component fir_param 
    generic(fir_ord : natural :=20;
            input_data_width : natural := 17;
            output_data_width : natural := 17;
            number_samples_g:positive:=51000);
    Port ( clk : in STD_LOGIC;
           reset : in std_logic;
           we_i_FIR : in STD_LOGIC;
           
           coef_i_FIR : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           coef_addr_i_FIR : std_logic_vector(log2c(fir_ord+1)-1 downto 0);
           
           data_i_FIR : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           addr_data_i_FIR : std_logic_vector(log2c(number_samples_g+1)-1 downto 0); --netacno, ima vise
           
           data_o_FIR : out STD_LOGIC_VECTOR (output_data_width-1 downto 0);
           addr_data_o_FIR : std_logic_vector(log2c(number_samples_g+1)-1 downto 0));
end component;
begin

 mem_c: BRAM
    generic map(
                width_g => input_data_width,
                size_g => number_samples_g
                )
    port map(
            clka => clk,
            clkb => clk,
            ena => en_mem_s,
            enb => en_mem_s,
            wea => zero_4, -- portA za upis pocetnih odbiraka u BRAM1 
            web => zero_4, -- portB za citanje odbiraka iz BRAM1 od strane FIR
            addra => addr_data_i, --adresa na koju se upisuje odbirak sa starta
            addrb => addr_data_i_FIR_s ,  --adresa sa koje fir cita ulazni podatak
            dia => data_i,
            dib => zero_width_g,  
            doa => zero_width_g,
            dob => data_i_FIR_s      --ulazni odbirci za FIR
            );
    
 FIR_c: FIR
    generic map(
                fir_ord  => fir_ord ,
                input_data_width  => input_data_width,
                output_data_width  => output_data_width,
                number_samples_g  => number_samples_g
                )
    port map(
            clk => clk,
            reset => reset;
            we_i_FIR => we_i_FIR;
           
           coef_i_FIR => coef_i_FIR;
           coef_addr_i_FIR => coef_addr_i_FIR;
           
           data_i_FIR => data_i_FIR_s;
           addr_data_i_FIR => addr_data_i_FIR_s; --netacno, ima vise
           
           data_o_FIR => data_o_FIR_s;
           addr_data_o_FIR => addr_data_o_FIR_s;
            );
end Behavioral;
