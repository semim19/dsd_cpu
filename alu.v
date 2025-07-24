module alu (
    input [15:0] a,
    input [15:0] b,
    input op,                  // 0 = ADD, 1 = SUB
    output [15:0] result,
    output cout,
    output zero
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

    assign result = res;
    assign cout = carry_out;

    assign zero = (res == 16'b0) ? 1'b1 : 1'b0;

endmodule
