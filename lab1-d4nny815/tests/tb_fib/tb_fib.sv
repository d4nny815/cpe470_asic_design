module tb_fib;

    // Declare test variables
    localparam N1 = 8;
    localparam N2 = 32;

    // Signals
    bit clk;
    bit rst_n;
    bit vld_in;
    bit rdy_out;
    bit [N1-1:0] fib_in;
    bit rdy_in;
    bit vld_out;
    bit [N2-1:0] fib_out;

    // Instantiate Design 
    fib #(
        .n1(N1),
        .n2(N2)
    ) Fib (
        .clk(clk),
        .rst_n(rst_n),
        .vld_in(vld_in),
        .rdy_out(rdy_out),
        .fib_in(fib_in),
        .rdy_in(rdy_in),
        .vld_out(vld_out),
        .fib_out(fib_out)
    );

    // Functions
    function automatic bit [N2-1: 0] nth_fib(input bit [N1-1:0] nth);
        bit [N2-1:0] first = 0, second = 1, sum;
        bit [N1-1:0] i = 0;
        for (i = 0; i < nth; i++) begin
            sum = first + second;
            second = first;
            first = sum;
        end
        nth_fib = first;
    endfunction


    // Tasks
    task reset_dut();
        rst_n = 1'b1;
        #(1 * CLK_PERIOD)
        rst_n = 1'b0;
        #(2 * CLK_PERIOD)
        rst_n = 1'b1;
    endtask

    task send_val(input bit [N1-1:0] val);
        wait (rdy_in == 1'b1);
        @(posedge clk);
        fib_in = val;
        vld_in = 1'b1;
        @(posedge clk);
        
        wait (rdy_in == 1'b0);
        vld_in = 1'b0;
    endtask

    task check_val(input bit [N1-1:0] val);
        bit [N2-1:0] expected_val;
        bit [N2-1:0] dut_val;
        
        expected_val = nth_fib(val);
        wait (vld_out == 1'b1);
        @(posedge clk);
        dut_val = fib_out;
        rdy_out = 1'b1;

        @(posedge clk);
        wait (vld_out == 1'b0);
        rdy_out = 1'b1;

        assert (dut_val == expected_val) $display("GOOD: Nth = %d DUT: %d, EXPECTED: %d", val, dut_val, expected_val);
        else $error("Failed. Nth = %d DUT: %d, EXPECTED: %d", val, dut_val, expected_val);

    endtask

    // Sample to drive clock
    localparam CLK_PERIOD = 10;
    always begin
        #(CLK_PERIOD/2) 
        clk <= ~clk;
    end

    // Necessary to create Waveform
    initial begin
        // Name as needed
        $dumpfile("tb_fib.vcd");
        $dumpvars(0);
    end

    // Tests
    initial begin
        // Test Goes Here
        clk = 1'b0;
        vld_in = 1'b0;
        rdy_out = 1'b0;

        reset_dut();

        for (bit [N1-1:0] i = 0; i < 10; i++) begin
            send_val(i);
            check_val(i);
        end

        #(10 * CLK_PERIOD)

        $display("PASSED All tests");

        // Make sure to call finish so test exits
        $finish();
    end

endmodule
