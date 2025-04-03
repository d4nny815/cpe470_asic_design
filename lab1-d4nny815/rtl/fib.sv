module fib #(
  parameter n1 = 8,
  parameter n2 = 32 
  ) (
  input bit clk, rst_n, vld_in, rdy_out,
  input bit [n1 - 1: 0] fib_in,
  output bit rdy_in, vld_out,
  output bit [n2 - 1: 0] fib_out
  );

  typedef enum {
    INIT,
    READY,
    COMPUTE,
    DONE
  } state_t;
  state_t PS, NS; 

  // **********************************************************************
  // * CONTROL PATH
  // **********************************************************************

  bit nth_eq;
  bit reset, reg_ld, new_calc;

  always_ff @(posedge clk) begin
    if (!rst_n) PS <= INIT;
    else PS <= NS;
  end

  always_comb begin
    reset = 1'b0; 
    reg_ld = 1'b0; 
    new_calc = 1'b0;
    rdy_in = 1'b0;
    vld_out = 1'b0;

    case (PS)
      INIT: begin
        reset = 1'b1;

        NS = READY;
      end

      READY: begin
        rdy_in = 1'b1;
        
        if (vld_in) begin
          new_calc = 1'b1;
          NS = COMPUTE;
        end
        else NS = READY;

      end

      COMPUTE: begin
        reg_ld = !nth_eq;
        NS = nth_eq ? DONE : COMPUTE;
      end

      DONE: begin
        vld_out = 1'b1;
        NS = rdy_out ? READY : DONE;
      end

      default: NS = INIT;
    endcase
  end


  // **********************************************************************
  // * DATA PATH
  // **********************************************************************
  
  bit [n1 - 1: 0] nth_cntr, nth_reg;
  bit [n2 - 1: 0] n1_reg, n2_reg, sum;
  
  always_ff @(posedge clk) begin
    if (reset) begin
      n1_reg <= 'd0;
      n2_reg <= 'd0;
      nth_cntr <= 'd0;
      nth_reg <= 'd0;
    end

    else if (new_calc) begin
      n1_reg <= 'd0;
      n2_reg <= 'd1;
      nth_cntr <= 'd0;
      nth_reg <= fib_in;
    end

    else if (reg_ld) begin
      n1_reg <= sum;
      n2_reg <= n1_reg;
      nth_cntr <= nth_cntr + 1;
    end

  end

  always_comb begin
    sum = n1_reg + n2_reg;
    nth_eq = nth_cntr == nth_reg;

    fib_out = n1_reg;
  end

endmodule