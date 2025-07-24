module unified_memory (
    input clk,
    input [15:0] addr,
    input we,
    input [15:0] wd,
    output reg [15:0] rd
);

    reg [15:0] mem [0:65535];


    always @(posedge clk) begin
        rd <= mem[addr];           
        if (we) begin
            mem[addr] <= wd;       
        end
    end

endmodule
