module processor_top (
    input clk,
    input reset
);

    // Instruction from memory
    wire [15:0] instr;
    wire [15:0] pc_out;

    // Register file wires
    wire [15:0] rdata1, rdata2;
    wire [15:0] reg_wdata;
    wire [1:0] rs1, rs2, rd;
    wire reg_we;

    // ALU wires
    wire [15:0] alu_a, alu_b, alu_result;
    wire [15:0] alu_out;
    wire alu_op;
    wire zero, cout;

    // Memory
    wire [15:0] mem_addr, mem_data_out, mem_data_in;
    wire mem_we;

    // Control signals
    wire ready;

    // === Program Counter Output ===
    assign mem_addr = pc_out;

    // === Memory Module ===
    unified_memory mem (
        .clk(clk),
        .addr(mem_addr),
        .we(mem_we),
        .wd(mem_data_in),
        .rd(mem_data_out)
    );

    // === Register File ===
    register_file regfile (
        .clk(clk),
        .we(reg_we),
        .w_addr(rd),
        .w_data(reg_wdata),
        .r_addr1(rs1),
        .r_addr2(rs2),
        .r_data1(rdata1),
        .r_data2(rdata2)
    );

    // === ALU ===
    alu alu_unit (
        .a(alu_a),
        .b(alu_b),
        .op(alu_op),
        .result(alu_result),
        .cout(cout),
        .zero(zero)
    );

    // === Control Unit ===
    control_unit ctrl (
        .clk(clk),
        .reset(reset),
        .instr(mem_data_out),          // Instruction from memory
        .mem_data(mem_data_out),       // Load result
        .mem_addr(mem_addr),
        .mem_wdata(mem_data_in),
        .mem_we(mem_we),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .reg_we(reg_we),
        .alu_op(alu_op),
        .alu_in1(alu_a),
        .alu_in2(alu_b),
        .reg_wdata(reg_wdata),
        .pc_out(pc_out),
        .ready(ready)
    );

endmodule
