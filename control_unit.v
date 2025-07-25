module control_unit (
    input clk,
    input reset,
    input [15:0] instr,         // Fetched instruction from memory
    input [15:0] mem_data,      // Data from memory for load
    output reg [15:0] mem_addr, // Address to access memory
    output reg [15:0] mem_wdata,// Data to write to memory
    output reg mem_we,          // Memory write enable
    output reg [1:0] rs1, rs2, rd, // Register file selectors
    output reg reg_we,          // Register file write enable
    output reg alu_op,          // 0 = add, 1 = sub
    output reg [15:0] alu_in1, alu_in2, // ALU inputs
    output reg [15:0] reg_wdata,// Data to write back to register
    output reg [15:0] pc_out,   // PC output for instruction fetch
    output reg ready,            // Asserted when instruction completes
    output reg immediate,
    output reg pcOrData
);

    // FSM States
    typedef enum reg [2:0] {
        S_FETCH = 3'b000,
        S_DECODE = 3'b001,
        S_EXEC = 3'b010,
        S_MEM = 3'b011,
        S_WB = 3'b100,
        S_DONE = 3'b101
    } state_t;

    state_t state, next_state;

    reg [15:0] pc;
    reg [15:0] ir;
    reg [15:0] alu_result;

    // Sign extension for address (9-bit to 16-bit)
    wire [15:0] imm_sext = {{7{ir[8]}}, ir[8:0]};

    // Output current PC
    always @(*) begin
        pc_out = pc;
    end

    // FSM sequential logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_FETCH;
            pc <= 16'b0;
        end else begin
            state <= next_state;
            if (state == S_DONE) begin
                pcOrData <= 1;
                pc <= pc + 1;
            end
        end
    end

    // FSM combinational logic
    always @(*) begin
        // Default values
        ready = 0;
        reg_we = 0;
        mem_we = 0;
        alu_op = 0;
        alu_in1 = 0;
        alu_in2 = 0;
        mem_addr = 0;
        mem_wdata = 0;
        reg_wdata = 0;
        immediate = 0;
        pcOrData = 0;
        rd = 0;
        rs1 = 0;
        rs2 = 0;
        next_state = state;

        case (state)
            S_FETCH: begin
                // Memory read assumed external
                next_state = S_DECODE;
            end

            S_DECODE: begin
                ir = instr;  // Latch instruction
                case (instr[15:13]) // opcode
                    3'b000, 3'b001: next_state = S_EXEC;  // ADD/SUB
                    3'b100, 3'b101: next_state = S_EXEC;  // LOAD/STORE address calc
                    default: next_state = S_DONE;
                endcase
            end

            S_EXEC: begin
                case (ir[15:13])
                    3'b000: begin // ADD
                        rd = ir[12:11];
                        rs1 = ir[10:9];
                        rs2 = ir[8:7];
                        alu_op = 0;
                        immediate = 0;
                        next_state = S_WB;
                    end

                    3'b001: begin // SUB
                        rd = ir[12:11];
                        rs1 = ir[10:9];
                        rs2 = ir[8:7];
                        alu_op = 1;
                        immediate = 0;
                        next_state = S_WB;
                    end

                    3'b100, 3'b101: begin // LOAD / STORE
                        rs2 = ir[12:11];     // LOAD: destination, STORE: source
                        rs1 = ir[10:9];     // Base register
                        alu_op = 0;         // Always ADD for address calc
                        alu_in2 = imm_sext;
                        immediate = 1;
                        next_state = S_MEM;
                    end
                endcase
            end

            S_MEM: begin
                if (ir[15:13] == 3'b100) begin // LOAD
                    // mem_addr = alu_result;
                    immediate = 1;
                    next_state = S_WB;
                end else if (ir[15:13] == 3'b101) begin // STORE
                    // mem_addr = alu_result;
                    mem_wdata = 16'd0; // rs value from register file
                    mem_we = 1;
                    immediate = 1;
                    next_state = S_DONE;
                end
            end

            S_WB: begin
                if (ir[15:13] == 3'b100) begin // LOAD
                    // reg_wdata = mem_data;
                    immediate = 1;
                    reg_we = 1;
                end else begin // ADD, SUB
                    // reg_wdata = alu_result;
                    immediate = 0;
                    reg_we = 1;
                end
                next_state = S_DONE;
            end

            S_DONE: begin
                ready = 1;
                next_state = S_FETCH;
            end
        endcase
    end
endmodule
// Note: The ALU operations (alu_in1, alu_in2) are expected to be assigned in the datapath module.
