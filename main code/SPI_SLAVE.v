module Spi_Wrapper (
    input clk , rst,MOSI,ss_n,
    output MISO
);
    wire [9:0] rx_data;
    wire rx_valid,tx_valid;
    wire [7:0] tx_data ;
    Spi_slave spi(.MOSI(MOSI), .clk(clk), .rst(rst), .ss_n(ss_n), .MISO(MISO), .tx_data(tx_data), 
    .rx_data(rx_data), .rx_valid(rx_valid), .tx_valid(tx_valid));
    
    Sync_Ram RAM(rx_data,clk,rst,rx_valid,tx_data,tx_valid);
    
endmodule