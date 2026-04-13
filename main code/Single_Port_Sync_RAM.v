module Sync_Ram #(
    parameter mem_width = 8,
    parameter mem_depth = 256,
    parameter addr_size = 8
) (
    input [9 : 0] Din,
    input clk,
    input rst,
    input rx_valid,
    output reg [7 : 0] Dout,
    output reg tx_valid
);
    reg [mem_width - 1 : 0] mem [mem_depth - 1 : 0];
    reg [7 : 0] write_address, read_address;

    always @(posedge clk) begin
        if (~rst) begin
            Dout <= 0;
            tx_valid <= 0;
            read_address <= 0;
            write_address <= 0;
        end else if (rx_valid) begin
            case (Din[9:8])
                2'b00: write_address <= Din [7 : 0];
                2'b01: mem [write_address] <= Din[7 : 0];
                2'b10: read_address <= Din[7 : 0];
                2'b11: Dout <= mem [read_address];
                default: Dout <= mem[read_address];
            endcase
        end
        tx_valid <= (Din[9] && Din[8] && rx_valid)? 1 : 0; // rx_valid -> data is ready 
    end

endmodule