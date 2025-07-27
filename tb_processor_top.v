`timescale 1ns/1ps

module processor_tb;

    reg clk = 0;
    reg reset;

    // Instantiate processor
    processor_top DUT (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always #5 begin
        clk = ~clk; // 100MHz clock
        $display("pain: %b", DUT.alu_a);
    end

    // Initial block
    initial begin
        $display("Starting processor test...");
        reset = 1;

        // Wait for reset
        #20;
        reset = 0;

        // Wait sufficient time for instructions to execute
        #300;

        $display("==== Register File ====");
        $display("x0 = %h", DUT.regfile.regs[0]);
        $display("x1 = %h", DUT.regfile.regs[1]);
        $display("x2 = %h", DUT.regfile.regs[2]);
        $display("x3 = %h", DUT.regfile.regs[3]);

        $display("==== Memory ====");
        $display("mem[x0+3] = %h", DUT.mem.mem[DUT.regfile.regs[0] + 3]);
        $display("mem[x1+2] = %h", DUT.mem.mem[DUT.regfile.regs[1] + 2]);

        $stop;
    end

    // Instruction and data memory initialization
    initial begin
        // Init registers manually
        DUT.regfile.regs[0] = 16'd0;
        DUT.regfile.regs[2] = 16'd5;   // x2 = 5
        DUT.regfile.regs[3] = 16'd10;  // x3 = 10

        // Preload data memory for LOAD test
        // Assume x0 = 0 → x0 + 3 = 3
        DUT.mem.mem[3] = 16'hBEEF;

        // Program memory
        // ADD x1 = x2 + x3 → opcode=000, rd=01, rs1=10, rs2=11
        DUT.mem.mem[0] = 16'b000_01_10_11_0000000;

        // SUB x0 = x1 - x3 → opcode=001, rd=00, rs1=01, rs2=11
        DUT.mem.mem[1] = 16'b001_00_01_11_0000000;

        // LOAD x2 = mem[x0 + 3] → opcode=100, rd=10, base=00, imm=000000011
        DUT.mem.mem[2] = 16'b100_10_00_000000011;

        // STORE mem[x1 + 2] = x2 → opcode=101, rs=10, base=01, imm=000000010
        DUT.mem.mem[3] = 16'b101_10_01_000000010;
    end

endmodule
