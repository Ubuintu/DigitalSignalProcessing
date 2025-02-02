// -------------------------------------------------------------
//
// Module: filter_tb
// Generated by MATLAB(R) 9.4 and Filter Design HDL Coder 3.1.3.
// Generated on: 2022-03-03 12:46:48
// -------------------------------------------------------------

// -------------------------------------------------------------
// HDL Code Generation Options:
//
// InputType: signed/unsigned
// ResetType: Synchronous
// FIRAdderStyle: tree
// MultiplierInputPipeline: 1
// MultiplierOutputPipeline: 1
// OptimizeForHDL: on
// HDLSimCmd: vsim %s.%s\n
// TargetDirectory: A:\School\EE465\EE465\examples\matlab
// AddPipelineRegisters: on
// Name: testSRRCdesigner
// TargetLanguage: Verilog
// MultifileTestBench: on
// TestBenchStimulus: impulse step ramp chirp noise 
// InitializeTestBenchInputs: on
// GenerateCoSimBlock: on
//
// Filter Settings:
//
// Discrete-Time FIR Filter (real)
// -------------------------------
// Filter Structure  : Direct-Form FIR
// Filter Length     : 101
// Stable            : Yes
// Linear Phase      : Yes (Type 1)
// -------------------------------------------------------------
  task filter_in_data_log_task; 
    input          clk;
    input          reset;
    input          rdenb;
    inout  [11:0]  addr;
    output         done;
  begin

    // Counter to generate the address
    if (reset == 1) 
      addr = 0;
    else begin
      if (rdenb == 1) begin
        if (addr == 3778)
          addr = addr; 
        else
          addr =  addr + 1; 
      end
    end

    // Done Signal generation.
    if (reset == 1)
      done = 0; 
    else if (addr == 3778)
      done = 1; 
    else
      done = 0; 

  end
  endtask // filter_in_data_log_task

  task filter_out_task; 
    input          clk;
    input          reset;
    input          rdenb;
    inout  [11:0]  addr;
    output         done;
  begin

    // Counter to generate the address
    if (reset == 1) 
      addr = 0;
    else begin
      if (rdenb == 1) begin
        if (addr == 3778)
          addr = addr; 
        else
          addr = #1  addr + 1; 
      end
    end

    // Done Signal generation.
    if (reset == 1)
      done = 0; 
    else if (addr == 3778)
      done = 1; 
    else
      done = 0; 

  end
  endtask // filter_out_task

 // Constants
 parameter clk_high                         = 5;
 parameter clk_low                          = 5;
 parameter clk_period                       = 10;
 parameter clk_hold                         = 2;
