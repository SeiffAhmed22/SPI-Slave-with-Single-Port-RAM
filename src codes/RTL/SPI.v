module SPI #(
    parameter IDLE = 3'b000,
    parameter CHK_CMD = 3'b001,
    parameter WRITE = 3'b010,
    parameter READ_ADD = 3'b011,
    parameter READ_DATA = 3'b100
    ) (
    input clk, // Clock
    input rst_n, // Asynchronous reset
    input SS_n, // Slave select active low
    input tx_valid, // If HIGH: accept tx_data to save write/read address internally or write a memory word depending on tx_data[9:8]
    input MOSI, // Master out slave in
    input [7:0] tx_data, // Data input from RAM
    output reg [9:0] rx_data, // Data output to RAM
    output reg MISO, // Master in slave out
    output rx_valid // Whenever the command is memory read, this signal is HIGH
    );
    (* fsm_encoding = "gray" *) // Gray encoding for state machine

    reg [2:0] cs, ns; // Current state and next state
    reg internal_sig; // To check the path "READ_ADD" or "READ_DATA", 
    // if internal_sig is LOW, then path is "READ_ADD", if internal_sig is HIGH, then path is "READ_DATA"
    reg [3:0] counter1; // counter1 for SPI clock for serial to parallel
    reg [2:0] counter2; // counter2 for SPI clock for parallel to serial

    // State Memory
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            cs <= IDLE;
        else
            cs <= ns;
    end

    // Next State Logic
    always @(*) begin
        case(cs)
            IDLE: begin
                if(!SS_n)
                    ns = CHK_CMD;
                else
                    ns = IDLE;
            end
            CHK_CMD: begin
                if(SS_n)
                    ns = IDLE;
                else begin
                    if(!MOSI)
                        ns = WRITE;
                    else begin
                        if(!internal_sig)
                            ns = READ_ADD;
                        else
                            ns = READ_DATA;
                    end
                end
            end
            WRITE: begin
                if(!SS_n)
                    ns = WRITE;
                else
                    ns = IDLE;
            end
            READ_ADD: begin
                if(!SS_n)
                    ns = READ_ADD;
                else
                    ns = IDLE;
            end
            READ_DATA: begin
                if(!SS_n)
                    ns = READ_DATA;
                else
                    ns = IDLE;
            end
        endcase
    end

    // Output Logic
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            rx_data <= 0;
            MISO <= 0;
            internal_sig <= 0;
            counter1 <= 0;
            counter2 <= 3'b111;
        end
        else begin
            case(cs)
                IDLE: begin
                    rx_data <= 0;
                    MISO <= 0;
                    counter1 <= 0;
                    counter2 <= 3'b111;
                end
                CHK_CMD: begin
                    rx_data <= 0;
                    MISO <= 0;
                    counter1 <= 0;
                    counter2 <= 3'b111;
                end
                WRITE: begin
                    if(!SS_n) begin
                        if(counter1 != 10) begin
                            counter1 <= counter1 + 1;
                            rx_data <= {rx_data[8:0], MOSI};
                        end
                    end
                end
                READ_ADD: begin
                    if(!SS_n) begin
                        if(counter1 != 10) begin
                            counter1 <= counter1 + 1;
                            rx_data <= {rx_data[8:0], MOSI};
                            if(counter1 == 9)
                                internal_sig <= 1;
                        end
                    end
                end
                READ_DATA: begin
                    if(!SS_n) begin
                        if(counter1 == 10) begin
                            if(tx_valid) begin
                                if(counter2 != 0) begin
                                    counter2 <= counter2 - 1;
                                    MISO <= rx_data[counter2];
                                end
                            end
                        end
                        else begin
                            counter1 <= counter1 + 1;
                            rx_data <= {rx_data[8:0], MOSI};
                            if(counter1 == 9)
                                internal_sig <= 0;
                        end
                    end
                end
            endcase
        end
    end

    assign rx_valid = ((cs == WRITE || cs == READ_ADD || cs == READ_DATA) && (counter1 == 10)) ? 1 : 0;
endmodule