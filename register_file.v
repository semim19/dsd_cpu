module register_file (
    input clk,
    input we,
    input [1:0] w_addr,
    input [15:0] w_data,
    input [1:0] r_addr1,
    input [1:0] r_addr2,
    output reg [15:0] r_data1,
    output reg [15:0] r_data2
);

    reg [15:0] regs [0:3];  

    always @(posedge clk) begin
        if (we) begin
            regs[w_addr] <= w_data;
        end
    end

    always @(posedge clk) begin
        r_data1 <= regs[r_addr1];
        r_data2 <= regs[r_addr2];
    end

endmodule
