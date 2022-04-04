/***********************************************
  Name:   awgn_generator.v
  Author: Lance Pitka
  Date:   April 24, 2017
  
  Assuming 1s17 output:
    Standard of deviation = 0.1
    Full scale to RMS ratio = 10*log10(0.1^2) = 20 dB
    Variance = 0.01
    peak = 0.53

  Description: Generates an 18 bit full scale AWGN signal
    using 26 different length LFSR's. The MSB is the sign
    bit (multiples the output by +/- 1). The next 12 MSBs
    are the address bits for the ROM. And finally the 13 
    LSBs are used to linearly interpolate between ROM
    values to increase the resolution.
    
  The peak-to-rms ratio is 5.3 = 14.5 dB
  
  ROM data was calculated in matlab and stored in the text file
  "awgn_data.txt". This file MUST be in the compile directory and
  the simulation directory. The dual port ROM module must also be
  included.
  
  Resource Useage:
    Combinationals    713
    Registers         693
    Memory Bits       73728 (ROM)
    DSP Elements      4
    18x18 Multipliers 2
    
***********************************************/

module awgn_generator (
  input wire                clk,
  input wire                clk_en,
  input wire                reset_n,  //active LOW reset
  output reg signed [17:0]  awgn_out
);

localparam    DATA_WIDTH      = 18,
              NUM_LFSR        = 26,
              ROM_ADDR_WIDTH  = 12,
              NUM_LIN_INTERP  = 13;


////// LFSR Registers //////////////// 10 TO 35 BITS. 26 LFSRs  
reg [9:0]	  lfsr_10; //10 bit lfsr
reg [10:0]	lfsr_11;
reg [11:0]	lfsr_12;
reg [12:0]	lfsr_13;
reg [13:0]	lfsr_14;
reg [14:0]	lfsr_15;
reg [15:0]	lfsr_16;
reg [16:0]	lfsr_17;
reg [17:0]	lfsr_18;
reg [18:0]	lfsr_19;
reg [19:0]	lfsr_20;
reg [20:0]	lfsr_21;
reg [21:0]	lfsr_22;
reg [22:0]	lfsr_23;
reg [23:0]	lfsr_24;
reg [24:0]	lfsr_25;
reg [25:0]	lfsr_26;
reg [26:0]	lfsr_27;
reg [27:0]	lfsr_28;
reg [28:0]	lfsr_29;
reg [29:0]	lfsr_30;
reg [30:0]	lfsr_31;
reg [31:0]	lfsr_32;
reg [32:0]	lfsr_33;
reg [33:0]	lfsr_34;
reg [34:0]	lfsr_35;   

//feedback registers
wire         d_10,d_11,d_12,d_13,d_14,d_15,d_16,d_17,
             d_18,d_19,d_20,d_21,d_22,d_23,d_24,d_25,
             d_26,d_27,d_28,d_29,d_30,d_31,d_32,d_33,
             d_34,d_35;

reg                  seed_flag;   
reg [NUM_LFSR-1:0]   lfsr_rom_addr;   

////// AWGN ROM registers. All are unsigned //////////////// 
wire [DATA_WIDTH-1:0]      awgn_rom_out;   
wire [DATA_WIDTH-1:0]      awgn_rom_out_next;   
reg  [DATA_WIDTH-1:0]      awgn_rom_out_last; //highest possible value, not stored in rom
reg  [ROM_ADDR_WIDTH-1:0]  rom_addr_delay;
reg                        rom_addr_sign_delay;  
reg  [DATA_WIDTH-1:0]      awgn_rom_out_delayed;   

////// Linear Interpolation //////////////// 
wire [DATA_WIDTH-1:0]     rom_step;
reg  [2*DATA_WIDTH-1:0]   rom_step_multiplied;   
wire [2*DATA_WIDTH-1:0]   rom_step_mult_divided;    

////// Scaling the output ////////////////
reg  signed [DATA_WIDTH-1:0]   awgn_out_temp;
wire signed [2*DATA_WIDTH-1:0] awgn_out_scaled;

//********************************************//
// Generate LFSRs for ROM addr
//********************************************//

// Seed LFSRs with original value
always @(posedge clk or negedge reset_n)
  if (~reset_n)
    seed_flag <= 1'b0;
  else
    seed_flag <= 1'b1;

always @ (posedge clk or negedge reset_n)
if (~reset_n)
  begin
    lfsr_10 <= 10'd0;
    lfsr_11 <= 11'd0;
    lfsr_12 <= 12'd0;
    lfsr_13 <= 13'd0;
    lfsr_14 <= 14'd0;
    lfsr_15 <= 15'd0;
    lfsr_16 <= 16'd0;
    lfsr_17 <= 17'd0;
    lfsr_18 <= 18'd0;
    lfsr_19 <= 19'd0;
    lfsr_20 <= 20'd0;
    lfsr_21 <= 21'd0;
    lfsr_22 <= 22'd0;
    lfsr_23 <= 23'd0;
    lfsr_24 <= 24'd0;
    lfsr_25 <= 25'd0;
    lfsr_26 <= 26'd0;
    lfsr_27 <= 27'd0;
    lfsr_28 <= 28'd0;
    lfsr_29 <= 29'd0;
    lfsr_30 <= 30'd0;
    lfsr_31 <= 31'd0;
    lfsr_32 <= 32'd0;
    lfsr_33 <= 33'd0;
    lfsr_34 <= 34'd0;
    lfsr_35 <= 35'd0;
  end
else if (seed_flag == 1'b0)
  begin
    lfsr_10 <= 10'd115;
    lfsr_11 <= 11'd548;
    lfsr_12 <= 12'd641;
    lfsr_13 <= 13'd3057;
    lfsr_14 <= 14'd4537;
    lfsr_15 <= 15'd17942;
    lfsr_16 <= 16'd48231;
    lfsr_17 <= 17'd30081;
    lfsr_18 <= 18'd58413;
    lfsr_19 <= 19'd316894;
    lfsr_20 <= 20'd927897;
    lfsr_21 <= 21'd679168;
    lfsr_22 <= 22'd3731798;
    lfsr_23 <= 23'd4110254;
    lfsr_24 <= 24'd165457;
    lfsr_25 <= 25'd26428509;
    lfsr_26 <= 26'd43745905;
    lfsr_27 <= 27'd49973208;
    lfsr_28 <= 28'd227988833;
    lfsr_29 <= 29'd211729285;
    lfsr_30 <= 30'd1059269033;
    lfsr_31 <= 31'd860167024;
    lfsr_32 <= 32'd4014951737;
    lfsr_33 <= 33'd1733609249;
    lfsr_34 <= 34'd8376235492;
    lfsr_35 <= 35'd3941717697;
  end
else if (clk_en)
  begin
    lfsr_10 <= {lfsr_10[8:0],d_10};
    lfsr_11 <= {lfsr_11[9:0],d_11};
    lfsr_12 <= {lfsr_12[10:0],d_12};
    lfsr_13 <= {lfsr_13[11:0],d_13};
    lfsr_14 <= {lfsr_14[12:0],d_14};
    lfsr_15 <= {lfsr_15[13:0],d_15};
    lfsr_16 <= {lfsr_16[14:0],d_16};
    lfsr_17 <= {lfsr_17[15:0],d_17};
    lfsr_18 <= {lfsr_18[16:0],d_18};
    lfsr_19 <= {lfsr_19[17:0],d_19};
    lfsr_20 <= {lfsr_20[18:0],d_20};
    lfsr_21 <= {lfsr_21[19:0],d_21};
    lfsr_22 <= {lfsr_22[20:0],d_22};
    lfsr_23 <= {lfsr_23[21:0],d_23};
    lfsr_24 <= {lfsr_24[22:0],d_24};
    lfsr_25 <= {lfsr_25[23:0],d_25};
    lfsr_26 <= {lfsr_26[24:0],d_26};
    lfsr_27 <= {lfsr_27[25:0],d_27};
    lfsr_28 <= {lfsr_28[26:0],d_28};
    lfsr_29 <= {lfsr_29[27:0],d_29};
    lfsr_30 <= {lfsr_30[28:0],d_30};
    lfsr_31 <= {lfsr_31[29:0],d_31};
    lfsr_32 <= {lfsr_32[30:0],d_32};
    lfsr_33 <= {lfsr_33[31:0],d_33};
    lfsr_34 <= {lfsr_34[32:0],d_34};
    lfsr_35 <= {lfsr_35[33:0],d_35};
  end
else
  begin
    lfsr_10 <= lfsr_10;
    lfsr_11 <= lfsr_11;
    lfsr_12 <= lfsr_12;
    lfsr_13 <= lfsr_13;
    lfsr_14 <= lfsr_14;
    lfsr_15 <= lfsr_15;
    lfsr_16 <= lfsr_16;
    lfsr_17 <= lfsr_17;
    lfsr_18 <= lfsr_18;
    lfsr_19 <= lfsr_19;
    lfsr_20 <= lfsr_20;
    lfsr_21 <= lfsr_21;
    lfsr_22 <= lfsr_22;
    lfsr_23 <= lfsr_23;
    lfsr_24 <= lfsr_24;
    lfsr_25 <= lfsr_25;
    lfsr_26 <= lfsr_26;
    lfsr_27 <= lfsr_27;
    lfsr_28 <= lfsr_28;
    lfsr_29 <= lfsr_29;
    lfsr_30 <= lfsr_30;
    lfsr_31 <= lfsr_31;
    lfsr_32 <= lfsr_32;
    lfsr_33 <= lfsr_33;
    lfsr_34 <= lfsr_34;
    lfsr_35 <= lfsr_35;       
  end       
             
//Feedback registers
assign d_10 = lfsr_10[9]~^lfsr_10[6];
assign d_11 = lfsr_11[10]~^lfsr_11[8];
assign d_12 = lfsr_12[11]~^lfsr_12[5]~^lfsr_12[3]~^lfsr_12[0];
assign d_13 = lfsr_13[12]~^lfsr_13[3]~^lfsr_13[2]~^lfsr_13[0];
assign d_14 = lfsr_14[13]~^lfsr_14[4]~^lfsr_14[2]~^lfsr_14[0];
assign d_15 = lfsr_15[14]~^lfsr_15[13];
assign d_16 = lfsr_16[15]~^lfsr_16[14]~^lfsr_16[12]~^lfsr_16[3];
assign d_17 = lfsr_17[16]~^lfsr_17[13];
assign d_18 = lfsr_18[17]~^lfsr_18[10];
assign d_19 = lfsr_19[15]~^lfsr_19[14]~^lfsr_19[12]~^lfsr_19[3];
assign d_20 = lfsr_20[19]~^lfsr_20[16];
assign d_21 = lfsr_21[20]~^lfsr_21[18];
assign d_22 = lfsr_22[21]~^lfsr_22[20];
assign d_23 = lfsr_23[22]~^lfsr_23[17];
assign d_24 = lfsr_24[23]~^lfsr_24[22]~^lfsr_24[21]~^lfsr_24[16];
assign d_25 = lfsr_25[24]~^lfsr_25[21];
assign d_26 = lfsr_26[25]~^lfsr_26[5]~^lfsr_26[1]~^lfsr_26[0];
assign d_27 = lfsr_27[26]~^lfsr_27[4]~^lfsr_27[1]~^lfsr_27[0];
assign d_28 = lfsr_28[27]~^lfsr_28[26];
assign d_29 = lfsr_29[28]~^lfsr_29[26];
assign d_30 = lfsr_30[29]~^lfsr_30[5]~^lfsr_30[3]~^lfsr_30[0];
assign d_31 = lfsr_31[30]~^lfsr_31[27];
assign d_32 = lfsr_32[31]~^lfsr_32[21]~^lfsr_32[1]~^lfsr_32[0];
assign d_33 = lfsr_33[32]~^lfsr_33[19];
assign d_34 = lfsr_34[33]~^lfsr_34[26]~^lfsr_34[1]~^lfsr_34[0];
assign d_35 = lfsr_35[34]~^lfsr_35[32];

//ROM address from concatenating LFSR feedback values
always @ (posedge clk or negedge reset_n)
if (~reset_n)
  lfsr_rom_addr <= {NUM_LFSR{1'b0}};
else if (clk_en)
  lfsr_rom_addr <= {d_35,d_34,d_33,d_32,d_31,d_30,d_29,d_28,d_27,d_26,d_25,d_24,d_23,d_22,d_21,d_20,d_19,d_18,d_17,d_16,d_15,d_14,d_13,d_12,d_11,d_10};
else
  lfsr_rom_addr <= lfsr_rom_addr;


//********************************************//
// ROM containing noise values
//********************************************//

always @ (posedge clk or negedge reset_n)
  if (~reset_n)
    begin
      rom_addr_delay      <= {ROM_ADDR_WIDTH{1'b0}};
      rom_addr_sign_delay <= 1'b0;
    end
  else if (clk_en)
    begin
      rom_addr_delay      <= lfsr_rom_addr[NUM_LFSR-2:NUM_LFSR-ROM_ADDR_WIDTH-1];
      rom_addr_sign_delay <= lfsr_rom_addr[NUM_LFSR-1];
    end    
  else
    begin
      rom_addr_delay      <= rom_addr_delay;
      rom_addr_sign_delay <= rom_addr_sign_delay;
    end

dual_port_rom_awgn  #(
  .ADDR_WIDTH     (12)
) awgn_rom_inst_1 (
  .clk            (clk),
  .addr_a         (lfsr_rom_addr[NUM_LFSR-2:NUM_LFSR-ROM_ADDR_WIDTH-1]),
  .addr_b         (lfsr_rom_addr[NUM_LFSR-2:NUM_LFSR-ROM_ADDR_WIDTH-1]+1'b1),
  .q_a            (awgn_rom_out),
  .q_b            (awgn_rom_out_next)
);

always @ *
  if (~reset_n)
    awgn_rom_out_last <= {DATA_WIDTH{1'b0}};
  else if (rom_addr_delay == {ROM_ADDR_WIDTH{1'b1}}) //last value stored in rom
    awgn_rom_out_last <= 18'd 92782; //4s14 //from matlab
  else
    awgn_rom_out_last <= awgn_rom_out_next;
    
//********************************************//
// Linear Interpolation
//********************************************//

assign rom_step = awgn_rom_out_last-awgn_rom_out; //Line to interpolate

//interpolated value = rom_step * interpolate_value/2^(# of interpolation bits)
always @ (posedge clk or negedge reset_n)
  if (~reset_n)
    begin
      rom_step_multiplied <= {2*DATA_WIDTH{1'b0}};
    end
  else if (clk_en)
    begin
      //rom_step_multiplied <= rom_step*({{NUM_LIN_INTERP{1'b0}},lfsr_rom_addr[NUM_LIN_INTERP-1:NUM_LIN_INTERP-5]});  //divide before multiplying
      rom_step_multiplied <= rom_step*({lfsr_rom_addr[NUM_LIN_INTERP-1:0],{DATA_WIDTH-NUM_LIN_INTERP{1'b0}}});        //divide after multiplying
    end
  else
    begin
      rom_step_multiplied <= rom_step_multiplied;
    end
    
    assign rom_step_mult_divided = {{NUM_LIN_INTERP{1'b0}},rom_step_multiplied[2*DATA_WIDTH-1:NUM_LIN_INTERP]}; //divide after multiplying
    //assign rom_step_mult_divided = rom_step_multiplied; //divide before multiplying


// Delay the rom output to keep inline with the pipelined multiplier above
always @ (posedge clk or negedge reset_n)
  if (~reset_n)
    awgn_rom_out_delayed <= {DATA_WIDTH{1'b0}};
  else if (clk_en)
    awgn_rom_out_delayed <= awgn_rom_out;
  else
    awgn_rom_out_delayed <= awgn_rom_out_delayed;

//********************************************//
// Final Output
//********************************************//

//Raw output
always @ (posedge clk or negedge reset_n)
  if (~reset_n)
    awgn_out_temp    <= {DATA_WIDTH{1'b0}};
  else if (clk_en)
    if (lfsr_rom_addr[NUM_LFSR-1] == 1'b0)  //positive output
      awgn_out_temp  <= $signed(rom_step_mult_divided[2*DATA_WIDTH-NUM_LIN_INTERP-1:DATA_WIDTH-NUM_LIN_INTERP]) + $signed(awgn_rom_out_delayed);
    else                            //negative output
      awgn_out_temp  <= -$signed(rom_step_mult_divided[2*DATA_WIDTH-NUM_LIN_INTERP-1:DATA_WIDTH-NUM_LIN_INTERP]) - $signed(awgn_rom_out_delayed);
  else
    awgn_out_temp    <= awgn_out_temp;
  
//Scale output to have standard deviation = 0.1. Scale value found in Matlab  
assign awgn_out_scaled = $signed(awgn_out_temp) * 18'sd 104599; //1s17*1s17 = 2s34. Value from matlab to make standard deviation = 0.1, and full scale to RMS of 20 dB

//Reduce to 18 bits
always @ (posedge clk or negedge reset_n)
  if (~reset_n)
    awgn_out    <= {DATA_WIDTH{1'b0}};
  else if (clk_en)
    awgn_out    <= $signed(awgn_out_scaled[2*DATA_WIDTH-2:DATA_WIDTH-1]);
  else
    awgn_out    <= awgn_out;


endmodule
              
              