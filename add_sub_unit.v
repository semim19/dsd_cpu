module add_sub_unit (
    input [15:0] a, b,
    input sub,           // 0 for ADD, 1 for SUB
    output [15:0] result,
    output cout
);
    wire [15:0] b_invert;
    wire cin;

    assign b_invert = b ^ {16{sub}};  
    assign cin = sub;                 

    carry_select_adder_ csa16 (
        .a(a),
        .b(b_invert),
        .cin(cin),
        .sum(result),
        .cout(cout)
    );
endmodule
