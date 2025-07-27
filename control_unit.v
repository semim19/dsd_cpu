module control_unit (
    input clk, 
    input reset, 
    input [15:0] alu_result,       
    input [15:0] mem_data,      // Data from memory for load
    input alu_done, 
    output reg alu_start,   
    output reg [15:0] mem_addr,  // Address to access memory
    output reg mem_we,         // Memory write enable
    output reg [1:0] rs1, rs2, rd,  // Register file selectors
    output reg reg_we,          // Register file write enable
    output reg alu_op,          // 0 = add, 1 = sub 
    output reg [15:0] sgnext_imm, 
    output reg [15:0] reg_wdata,        // Data to write back to register
    output reg [15:0] pc,   // PC output for instruction fetch
    output reg ready,               // Asserted when instruction completes
    output reg immediate   

);

    // FSM States
    localparam S_FETCH  = 3'b000,
        S_DECODE = 3'b001,
        S_EXEC   = 3'b010,
        S_MEM    = 3'b011,
        S_WB     = 3'b100;

    reg [2:0] state, next_state;
    reg [15:0] ir;




    // FSM sequential logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_FETCH;
            pc <= 16'b0;
            ir <= 16'b0;
        end else begin
            state <= next_state;
            if (state == S_DECODE) begin
                ir <= mem_data;
            end
            if (state == S_WB) begin
                pc <= pc + 1; 
                alu_op <= 0; 
                alu_start <= 0;
                reg_we <= 0; 
                mem_we <= 0; 
                immediate <= 0; 
                mem_addr <= 0; 
                reg_wdata <= 0; 
                ready <= 0; 
                rs1 <= 0; 
                rs2 <= 0; 
                rd <= 0; 
                sgnext_imm <= 0; 
            end
        end
    end

    // FSM combinational logic
    always @(*) begin

        case (state)
            S_FETCH: begin
                
                mem_addr = pc;
                next_state = S_DECODE;
            end

            S_DECODE: begin

                case (mem_data[15:13])
                    3'b000: begin // ADD
                        rd = mem_data[12:11];
                        rs1 = mem_data[10:9];
                        rs2 = mem_data[8:7];
                        alu_op = 0;
                        immediate = 0;
                        next_state = S_EXEC;
                    end

                    3'b001: begin // SUB
                        rd = mem_data[12:11];
                        rs1 = mem_data[10:9];
                        rs2 = mem_data[8:7];
                        alu_op = 1;
                        immediate = 0;
                        
                    end

                    3'b100, 3'b101: begin // LOAD / STORE
                        rd = mem_data[12:11];
                        rs1 = mem_data[10:9];
                        rs2 = mem_data[8:7];
                        alu_op = 0;
                        sgnext_imm = {{7{mem_data[8]}}, mem_data[8:0]}; // Sign-extend immediate
                        immediate = 1;
                        
                    end
                    default: alu_op = 0;
                endcase
                next_state = S_EXEC;
            end

            S_EXEC: begin
                alu_start = 1;
                if (alu_done) begin
                    
                    case (ir[15:13])
                        3'b000, 3'b001: begin // ADD / SUB
                            next_state = S_WB;
                        end

                        3'b100, 3'b101: begin // LOAD / STORE
                            next_state = S_MEM;
                        end

                    endcase
                end else begin
                    next_state = S_EXEC;
                end
            end

            S_MEM: begin
                case (ir[15:13])
                    3'b100: begin // LOAD
                        mem_addr = alu_result;
                        mem_we = 0;
                    end

                    3'b101: begin // STORE
                        mem_addr = alu_result;
                        mem_we = 1;
                        
                    end

                    default: next_state = S_WB;
                endcase
                next_state = S_WB;
            end

            S_WB: begin
                case (ir[15:13])
                    3'b000, 3'b001: begin // ADD / SUB
                        reg_wdata = alu_result;
                        reg_we = 1;
                    end

                    3'b100: begin // LOAD
                        reg_wdata = mem_data;
                        reg_we = 1; 
                    end

                    3'b101: begin // STORE
                        reg_we = 0; 
                    end

                    default:
                        reg_we = 0; 
                endcase
                next_state = S_FETCH;
            end
        endcase
    end
endmodule
