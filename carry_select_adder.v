module carry_select_adder (
    input [15:0] a, b,
    input cin,
    output [15:0] sum,
    output cout
);
    wire [3:0] sum0, sum1, sum2, sum3;
    wire c1, c2, c3, c4;

    four_bit_adder block0 (.a(a[3:0]), .b(b[3:0]), .cin(cin), .sum(sum0), .cout(c1));

    carry_select_block block1 (.a(a[7:4]), .b(b[7:4]), .cin(c1), .sum(sum1), .cout(c2));

    carry_select_block block2 (.a(a[11:8]), .b(b[11:8]), .cin(c2), .sum(sum2), .cout(c3));

    carry_select_block block3 (.a(a[15:12]), .b(b[15:12]), .cin(c3), .sum(sum3), .cout(cout));

    assign sum = {sum3, sum2, sum1, sum0};
endmodule
