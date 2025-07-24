module carry_select_block (
    input [3:0] a, b,
    input cin,
    output [3:0] sum,
    output cout
);
    wire [3:0] sum0, sum1;
    wire cout0, cout1;

    four_bit_adder adder0 (.a(a), .b(b), .cin(1'b0), .sum(sum0), .cout(cout0));
    four_bit_adder adder1 (.a(a), .b(b), .cin(1'b1), .sum(sum1), .cout(cout1));

    assign sum = cin ? sum1 : sum0;
    assign cout = cin ? cout1 : cout0;
endmodule
