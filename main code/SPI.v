module Spi_slave #(
    parameter IDLE = 3'b000,
    parameter WRITE =3'b001,
    parameter CHK_CMD =3'b010,
    parameter READ_ADD =3'b011,
    parameter READ_DATA =3'b100
) (
    input MOSI,ss_n,clk,rst,tx_valid, input [7:0] tx_data,
    output reg[9:0] rx_data, output reg rx_valid, MISO
);
    reg get_add; // internal signal to identify to either read address or read data (0 -> read address , 1 -> read data)
    reg [2:0] cs,ns ;
    reg [3:0] IO_Ctr;
    

// NEXT STATE MODULE 

   always @(ss_n,MOSI) begin
   
        if (ss_n ) begin
            ns <= IDLE;
            if (cs==READ_ADD)   get_add =1; // read address and set get_add 
            else if (cs==READ_DATA)     get_add =0; // read data and clear ger_add
        end

        else begin
        case (cs)
           IDLE : ns <= CHK_CMD;
           WRITE : ns<= WRITE;
           READ_ADD : ns<= READ_ADD;
           READ_DATA : ns<= READ_DATA;
           CHK_CMD : if (get_add && MOSI) ns<=READ_DATA;
                    else if (MOSI) ns<= READ_ADD;
                    else ns<= WRITE;
            default: ns<=IDLE;
        endcase
        end
   end

// CURRENT STATE MODULE 

always @(posedge clk ) begin
    if (~rst)
        cs <=IDLE;
    else
        cs <= ns;
    
end


// OUTPUT LOGIC MODULE

always @(posedge clk) begin
    if (~rst) begin
        get_add <= 0; // get address -> (0 -> read address, 1 -> read data)
        rx_data <= 0; 
        rx_valid <= 0; // 1 -> data 
        MISO <= 0;
    end
    else begin
        case (cs)
            IDLE: rx_valid <= 0; // wait mode
            
            CHK_CMD: IO_Ctr <= 10; // Setting the counter by 10 for the serial read/write operation 
            
            WRITE: begin
                if (IO_Ctr > 0) begin
                    rx_valid <= 0; // still reading data from the master
                    rx_data[IO_Ctr - 1] <= MOSI; // receiving data bit by bit from the MOSI 
                    IO_Ctr <= IO_Ctr - 1; // decrementing the counter by one
                end
                else begin
                    rx_valid <= 1; // when the counter reaches the zero -> this means that the data is received (rx_valid = 1) 
                end
            end
            
            READ_ADD: begin
                if (IO_Ctr > 0) begin
                    rx_data[IO_Ctr - 1] <= MOSI; // reading the address from the master 
                    IO_Ctr <= IO_Ctr - 1; // decrementing the counter after each step
                end 
                else begin
                    rx_valid <= 1; // when the counter reaches the zero -> this means that the data is received (rx_valid = 1)
                end
            end
            
            READ_DATA: begin
                if (tx_valid) begin // if tx_valid is set -> means that the tx_data is ready to be sent to the master 
                    rx_valid <= 0; 
                    if (IO_Ctr > 0) begin 
                        MISO <= tx_data[IO_Ctr - 1]; // sending data to the MISO bit by bit (10 -> 0 - 9) 
                        IO_Ctr <= IO_Ctr - 1; // decrementing the counter by one each step 
                    end
                end
                else begin
                  
                    if (IO_Ctr > 0) begin
                        rx_data[IO_Ctr - 1] <= MOSI;
                        IO_Ctr <= IO_Ctr - 1;
                    end
                    
                    else begin
                        rx_valid <= 1; // the data is ready in the ram 
                        IO_Ctr <= 8; 
                    end
                end
            end
        endcase
    end
end

endmodule