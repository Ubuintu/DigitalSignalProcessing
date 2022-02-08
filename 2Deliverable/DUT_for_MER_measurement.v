// -----------------------------------------------------
// EE 465 Deliverable 2 MER Measurement Stimulus Module
// Rev 2.0, Feb 1, 2018 (Brian Berscheid)
// - added pipeline registers to module outputs
// -----------------------------------------------------

`default_nettype none
module DUT_for_MER_measurement #(
  parameter                           DATA_WIDTH = 18, //data width
  parameter                           CHANNEL_GAIN = 1 // the actual channel gain is 2^(-CHANNEL_GAIN). E.g. the
                                                       // actual channel gain is 1/8 if CHANNEL_GAIN=3.
                                                       // CHANNEL_GAIN must be an integer
)(
  input wire                          clk,     //system_clk, ie 25 MHz
  input wire                          clk_en,  //sym_clk_en, ie rate of 1.5625 Menables/second
  input wire                          reset,   //should have been called reset_bar as it asserted when negative
  input wire signed  [DATA_WIDTH-1:0] isi_power, // should be set to:
                                                 // round(sqrt(0.5/(10^(MER/10))))*2^(DATA_WIDTH-1)
                                                 // ie. for MER = 20 dB then isi_power = 18'sd9268
  input wire signed  [DATA_WIDTH-1:0] in_data, //in the symbol_clk clock domain
  output reg signed  [DATA_WIDTH-1:0] decision_variable, //decision variable including the error
  output reg signed  [DATA_WIDTH-1:0] errorless_decision_variable, //decision variable without error
  output reg signed  [DATA_WIDTH-1:0] error //error introduced by the system
);

//************************************************************
//  Declarations
//------------------------------------------------------------

  reg signed [DATA_WIDTH-1:0]         delay_reg          [2:0]; //delay registers
  reg signed [DATA_WIDTH:0]           sum_level_one;           //Summation of first and third registers, 19 bits wide so that if a + 3a is ever added it can fit
  reg signed [2*DATA_WIDTH:0]         isi_term_hp;             //multiplication of ISI_POWER and sum level one, 37 bits
  reg signed [DATA_WIDTH-1:0]         isi_term_lp;             //multiplication if ISI_POWER and sum level one, 18 bits
  
  reg signed  [DATA_WIDTH-1:0]        decision_variable_temp;           //decision variable including the error
  reg signed  [DATA_WIDTH-1:0]        errorless_decision_variable_temp; //decision variable without error
  reg signed  [DATA_WIDTH-1:0]        error_temp;                       //error introduced by the system
  
//************************************************************
//  SHIFT REGISTERS
//------------------------------------------------------------

always @ (posedge clk or negedge reset)
if(reset == 1'b0)
  begin
    delay_reg[0] <= {DATA_WIDTH{1'b0}}; //Values are set to 0 upon reset
    delay_reg[1] <= {DATA_WIDTH{1'b0}};
    delay_reg[2] <= {DATA_WIDTH{1'b0}};
  end
else if (clk_en == 1'b1)
  begin
    delay_reg[0] <= in_data; // incoming data is registered to remove
                             // the delay between the clock and in_data
    delay_reg[1] <= delay_reg[0];
    delay_reg[2] <= delay_reg[1];
  end
else
  begin
    delay_reg[0] <= delay_reg[0]; //otherwise registers hold their values
    delay_reg[1] <= delay_reg[1];
    delay_reg[2] <= delay_reg[2];
  end
    
//************************************************************
//  SUMMATION LEVEl
//------------------------------------------------------------

always @ *
if(reset == 1'b0)
  begin
    sum_level_one <= {DATA_WIDTH+1{1'b0}}; //Value sent to 0 upon reset
  end
else
  begin
    sum_level_one <= delay_reg[0] + delay_reg[2]; //Summing the values in the first and third registers
  end

//************************************************************
//  GENERATING ISI TERMS
//------------------------------------------------------------

always @ *
if(reset == 1'b0)
  begin
    isi_term_hp <= {2*DATA_WIDTH{1'b0}};
    isi_term_lp <= {DATA_WIDTH{1'b0}};
  end
else
  begin
    isi_term_hp <= sum_level_one * isi_power; //2s17 * 1s17 = 3s34
    isi_term_lp <= isi_term_hp[2*DATA_WIDTH-2:DATA_WIDTH-1]; //selecting the bits to give a 1s17 number
  end
  
//************************************************************
//  GENERATING OUTPUTS (combinational)
//------------------------------------------------------------

always @ *
if(reset == 1'b0)
  begin
    error_temp                       <= {DATA_WIDTH{1'b0}};  
    decision_variable_temp           <= {DATA_WIDTH{1'b0}};
    errorless_decision_variable_temp <= {DATA_WIDTH{1'b0}};
  end
else
  begin
    error_temp                       <= isi_term_lp >>> CHANNEL_GAIN; //signed bit shift is equivalent to dividing by 2^(CHANNEL_GAIN)
    errorless_decision_variable_temp <= delay_reg[1] >>> CHANNEL_GAIN;
    decision_variable_temp           <= error_temp + errorless_decision_variable_temp;
  end

//************************************************************
//  PIPELINE OUTPUTS
//------------------------------------------------------------  
  
always @ (posedge clk or negedge reset)
if(reset == 1'b0)
  begin
    error                       <= {DATA_WIDTH{1'b0}};  
    decision_variable           <= {DATA_WIDTH{1'b0}};
    errorless_decision_variable <= {DATA_WIDTH{1'b0}};
  end
else if (clk_en == 1'b1) 
  begin
    error                       <= error_temp;
    errorless_decision_variable <= errorless_decision_variable_temp;
    decision_variable           <= decision_variable_temp;
  end
else
  begin
    error                       <= error;
    errorless_decision_variable <= errorless_decision_variable;
    decision_variable           <= decision_variable;
  end
  
endmodule
`default_nettype wire
