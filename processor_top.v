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
    wire [1:0] reg_in1; // Register to read from
    wire reg_we;
    wire alu_start, alu_done;
    wire [15:0] sgnext_imm; // Sign-extended immediate value
    // ALU wires
    wire [15:0] alu_a, alu_b, alu_result;
    wire [15:0] alu_out;
    wire alu_op;
    wire zero, cout;
    wire immediate;
    wire pcOrData;

    // Memory
    wire [15:0] mem_addr, mem_data_out, mem_data_in;
    wire mem_we;

    // Control signals
    wire ready;

    // === Program Counter Output ===
    assign alu_b = immediate ? sgnext_imm : rdata2;
    assign reg_in1 = immediate ? rd : rs1;
    
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
        .r_addr1(reg_in1),
        .r_addr2(rs2),
        .r_data1(rdata1),
        .r_data2(rdata2)
    );

    // === ALU ===
    alu alu_unit (
        .clk(clk),
        .rst(reset),
        .start(alu_start),
        .done(alu_done),
        .a(alu_a),
        .b(alu_b),
        .op(alu_op),
        .result(alu_result)
    );

    // === Control Unit ===
    control_unit ctrl (
        .clk(clk),
        .reset(reset),
        .mem_data(mem_data_out),       // Load result
        .mem_addr(mem_addr),
        .mem_we(mem_we),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .reg_we(reg_we),
        .alu_op(alu_op),
        .reg_wdata(reg_wdata),
        .pc(pc_out),
        .immediate(immediate),
        .ready(ready),
        .alu_start(alu_start),
        .alu_done(alu_done),
        .alu_result(alu_result),
        .sgnext_imm(sgnext_imm)
    );

endmodule
