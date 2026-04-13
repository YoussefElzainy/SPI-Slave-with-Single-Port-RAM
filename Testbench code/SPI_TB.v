module SPI_TB();

reg clk, rst_n, ss_n, mosi; // Input Ports in Design
wire miso; // Output Ports in Design
reg [9:0] test_data; // Test data that will be applied on mosi
integer i = 0; // Variable used to iterate over loops

// Module Instantiation
Spi_Wrapper DUT (.clk(clk), .rst(rst_n), .MOSI(mosi), .ss_n(ss_n), .MISO(miso));

// Clock Generation
initial begin
    clk = 0;
    forever begin
        #1;
        clk=~clk;
    end
end


// Any @(negedge clk); just to see the change in signals in simulation
initial begin
    // ------Initializing memory------
    $readmemh("mem.dat",DUT.RAM.mem);
    // ------Testing Reset------
    rst_n = 0; // Activating Reset
    ss_n  = 0;
    mosi  = 0;
    test_data = $random;
    @(negedge clk);
    rst_n = 1; // Deactivating Reset
    // ------Testing Read Address------
    ss_n = 0;
    @(negedge clk); 
    mosi = 1;
    //@(negedge clk); // Not sure correct or not ,  it will work with which test_data??
    test_data = 10'b1001_1010;
    for(i=10;i>0;i=i-1) begin
        @(negedge clk);
        mosi = test_data[i-1];
    end
    ss_n = 1;
    @(negedge clk);
    // ------Testing Read Data------
    ss_n = 0;
    @(negedge clk); 
    mosi = 1;
    //@(negedge clk); // Not sure correct or not ,  it will work with which test_data??
    test_data = 10'b1100_0110;
    for(i=10;i>0;i=i-1) begin
        @(negedge clk);
        mosi = test_data[i-1];
    end
    //@(negedge clk);
    // To See Output (moiso) we will introduce delay
    repeat(10) begin
        @(negedge clk);
    end
    ss_n = 1;
    @(negedge clk);
    // ------Testing Write Address------
    ss_n = 0;
    @(negedge clk);
    mosi = 0;
    //@(negedge clk); // Not sure correct or not ,  it will work with which test_data??
    test_data = 10'b0000_0110;
    for(i=10;i>0;i=i-1) begin
        @(negedge clk);
        mosi = test_data[i-1];
    end
    ss_n = 1;
    @(negedge clk);
    // ------Testing Write Data------
    ss_n = 0;
    @(negedge clk);
    mosi = 0;
    //@(negedge clk); // Not sure correct or not ,  it will work with which test_data??
    test_data = 10'b0110_0100;
    for(i=10;i>0;i=i-1) begin
        @(negedge clk);
        mosi = test_data[i-1];
    end
    ss_n = 1;
    @(negedge clk);
    $stop;

end
endmodule