module alu (
    input clk,
    input rst,
    input [15:0] a,
    input [15:0] b,
    input op,          // 0 = ADD, 1 = SUB
    input start,
    output reg [15:0] result,
    output reg done
);

    wire [15:0] res;
    wire carry_out;

    add_sub_unit addsub (
        .a(a),
        .b(b),
        .sub(op),
        .result(res),
        .cout(carry_out)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            done <= 0;
            result <= 16'b0; 
        end else begin
            done <= 0;
            if (start) begin
                result <= res;
                done <= 1;
            end
        end
    end

endmodule
