module full_adder (
    input a, b, cin,
    output sum, cout
);
    wire axorb, aandb, aandcin, bxorcin;

    xor  (axorb, a, b);
    xor  (sum, axorb, cin);

    and  (aandb, a, b);
    and  (aandcin, axorb, cin);
    or   (cout, aandb, aandcin);
endmodule
