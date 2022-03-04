`timescale 1 ns / 1 ns 

module filter_tb;

 `include "filter_tb_pkg.v"
 `include "filter_tb_data.v"

  parameter MAX_ERROR_COUNT = 3779; //uint32


 // Signals
  reg  clk; // boolean
  reg  clk_enable; // boolean
  reg  reset; // boolean
  reg  [63:0] filter_in; // double
  wire [63:0] filter_out; // double

  reg  tb_enb; // boolean
  wire srcDone; // boolean
  wire snkDone; // boolean
  wire testFailure; // boolean
  reg  tbenb_dly; // boolean
  reg  rdEnb; // boolean
  wire filter_in_data_log_rdenb; // boolean
  reg  [11:0] filter_in_data_log_addr; // ufix12
  reg  filter_in_data_log_done; // boolean
  reg  filter_out_testFailure; // boolean
  integer filter_out_errCnt; // uint32
  wire delayLine_out; // boolean
  wire expected_ce_out; // boolean
  reg  int_delay_pipe [0:10] ; // boolean
  wire filter_out_rdenb; // boolean
  reg  [11:0] filter_out_addr; // ufix12
  reg  filter_out_done; // boolean
  wire [63:0] filter_out_ref; // double
  reg  check1_Done; // boolean

 // Module Instances
  testSRRCdesigner u_testSRRCdesigner
    (
    .clk(clk),
    .clk_enable(clk_enable),
    .reset(reset),
    .filter_in(filter_in),
    .filter_out(filter_out)
    );


 // Block Statements
  // -------------------------------------------------------------
  // Driving the test bench enable
  // -------------------------------------------------------------

  always @(reset, snkDone)
  begin
    if (reset == 1'b1)
      tb_enb <= 1'b0;
    else if (snkDone == 1'b0 )
      tb_enb <= 1'b1;
    else begin
    # (clk_period * 2);
      tb_enb <= 1'b0;
    end
  end

  always @(posedge clk or posedge reset) // completed_msg
  begin
    if (reset) begin 
       // Nothing to reset.
    end 
    else begin 
      if (snkDone == 1) begin
        if (testFailure == 0)
              $display("**************TEST COMPLETED (PASSED)**************");
        else
              $display("**************TEST COMPLETED (FAILED)**************");
      end
    end
  end // completed_msg;

  // -------------------------------------------------------------
  // System Clock (fast clock) and reset
  // -------------------------------------------------------------

  always  // clock generation
  begin // clk_gen
    clk <= 1'b1;
    # clk_high;
    clk <= 1'b0;
    # clk_low;
    if (snkDone == 1) begin
      clk <= 1'b1;
      # clk_high;
      clk <= 1'b0;
      # clk_low;
      $stop;
    end
  end  // clk_gen

  initial  // reset block
  begin // reset_gen
    reset <= 1'b1;
    # (clk_period * 2);
    @ (posedge clk);
    # (clk_hold);
    reset <= 1'b0;
  end  // reset_gen

  // -------------------------------------------------------------
  // Testbench clock enable
  // -------------------------------------------------------------

  always @ ( posedge clk)
    begin: tb_enb_delay
      if (reset == 1'b1) begin
        tbenb_dly <= 1'b0;
      end
      else begin
        if (tb_enb == 1'b1) begin
          tbenb_dly <= tb_enb;
        end
      end
    end // tb_enb_delay

  always @(snkDone, tbenb_dly)
  begin
    if (snkDone == 0)
      rdEnb <= tbenb_dly;
    else
      rdEnb <= 0;
  end

  // -------------------------------------------------------------
  // Read the data and transmit it to the DUT
  // -------------------------------------------------------------

  always @(posedge clk or posedge reset)
  begin
    filter_in_data_log_task(clk,reset,
                            filter_in_data_log_rdenb,filter_in_data_log_addr,
                            filter_in_data_log_done);
  end

  assign filter_in_data_log_rdenb = rdEnb;

  always @ (filter_in_data_log_rdenb, filter_in_data_log_addr, tbenb_dly)
  begin // stimuli_filter_in_data_log_filter_in
    if (tbenb_dly == 0) begin
      filter_in <= # clk_hold  0.0000000000000000E+00;
    end
    else if (filter_in_data_log_rdenb == 1) begin
      filter_in <= # clk_hold filter_in_data_log_force[filter_in_data_log_addr];
    end
  end // stimuli_filter_in_data_log_filter_in

  // -------------------------------------------------------------
  // Create done signal for Input data
  // -------------------------------------------------------------

  assign srcDone = filter_in_data_log_done;


  always @( posedge clk)
    begin: ceout_delayLine
      if (reset == 1'b1) begin
        int_delay_pipe[0] <= 1'b0;
        int_delay_pipe[1] <= 1'b0;
        int_delay_pipe[2] <= 1'b0;
        int_delay_pipe[3] <= 1'b0;
        int_delay_pipe[4] <= 1'b0;
        int_delay_pipe[5] <= 1'b0;
        int_delay_pipe[6] <= 1'b0;
        int_delay_pipe[7] <= 1'b0;
        int_delay_pipe[8] <= 1'b0;
        int_delay_pipe[9] <= 1'b0;
        int_delay_pipe[10] <= 1'b0;
      end
      else begin
        if (clk_enable == 1'b1) begin
        int_delay_pipe[0] <= rdEnb;
        int_delay_pipe[1] <= int_delay_pipe[0];
        int_delay_pipe[2] <= int_delay_pipe[1];
        int_delay_pipe[3] <= int_delay_pipe[2];
        int_delay_pipe[4] <= int_delay_pipe[3];
        int_delay_pipe[5] <= int_delay_pipe[4];
        int_delay_pipe[6] <= int_delay_pipe[5];
        int_delay_pipe[7] <= int_delay_pipe[6];
        int_delay_pipe[8] <= int_delay_pipe[7];
        int_delay_pipe[9] <= int_delay_pipe[8];
        int_delay_pipe[10] <= int_delay_pipe[9];
        end
      end
    end // ceout_delayLine

  assign delayLine_out = int_delay_pipe[10];

  assign expected_ce_out =  delayLine_out & clk_enable;

  // -------------------------------------------------------------
  //  Checker: Checking the data received from the DUT.
  // -------------------------------------------------------------

  always @(posedge clk or posedge reset)
  begin
    filter_out_task(clk,reset,
                    filter_out_rdenb,filter_out_addr,
                    filter_out_done);
  end

  assign filter_out_rdenb = expected_ce_out;

  assign filter_out_ref = filter_out_expected[filter_out_addr];


  always @ (posedge clk or posedge reset) // checker_filter_out
  begin
    if (reset == 1) begin
      filter_out_testFailure <= 0;
      filter_out_errCnt <= 0;
    end 
    else begin 
      if (filter_out_rdenb == 1 ) begin 
        if (abs_real($bitstoreal(filter_out) - filter_out_expected[filter_out_addr]) > 1.0e-9) begin
           filter_out_errCnt <= filter_out_errCnt + 1;
           filter_out_testFailure <= 1;
               $display("ERROR in filter_out at time %t : Expected '%f' Actual '%f'", 
                    $time, filter_out_expected[filter_out_addr], $bitstoreal(filter_out));
           if (filter_out_errCnt >= MAX_ERROR_COUNT) 
             $display("Warning: Number of errors for filter_out have exceeded the maximum error limit");
        end

      end
    end
  end // checker_filter_out

  always @ (posedge clk or posedge reset) // checkDone_1
  begin
    if (reset == 1)
      check1_Done <= 0;
    else if ((check1_Done == 0) && (filter_out_done == 1) && (filter_out_rdenb == 1))
      check1_Done <= 1;
  end

  // -------------------------------------------------------------
  // Create done and test failure signal for output data
  // -------------------------------------------------------------

  assign snkDone = check1_Done;

  assign testFailure = filter_out_testFailure;

  // -------------------------------------------------------------
  // Global clock enable
  // -------------------------------------------------------------
  always @(snkDone, tbenb_dly)
  begin
    if (snkDone == 0)
      # clk_hold clk_enable <= tbenb_dly;
    else
      # clk_hold clk_enable <= 0;
  end

 // Assignment Statements



endmodule // filter_tb
