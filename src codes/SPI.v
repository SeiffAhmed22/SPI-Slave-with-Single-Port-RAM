module SPI #(
    parameter IDLE = 3'b000,
    parameter CHK_CMD = 3'b001,
    parameter WRITE = 3'b010,
    parameter READ_ADD = 3'b011,
    parameter READ_DATA = 3'b100
    ) (
    input clk, rst_n, SS_n, tx_valid, MOSI,
    input [7:0] tx_data,
    output reg [9:0] rx_data,
    output reg MISO, rx_valid
    );
    (* fsm_encoding = "gray" *)
    reg [2:0] cs, ns;
    reg internal_sig; // To check the path "READ_ADD" or "READ_DATA"
    reg [3:0] counter;

    // State Memory
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            cs <= IDLE;
        else
            cs <= ns;
    end

    // Next State Logic
    always @(*) begin
        case (cs)
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
                if(SS_n)
                    ns = IDLE;
                else
                    ns = WRITE;
            end
            READ_ADD: begin
                if(SS_n)
                    ns = IDLE;
                else
                    ns = READ_ADD;
            end
            READ_DATA: begin
                if(SS_n)
                    ns = IDLE;
                else
                    ns = READ_DATA;
            end
            default: ns = IDLE;
        endcase
    end

    // Output Logic
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            internal_sig <= 0;
            counter <= 0;
            MISO <= 0;
            rx_data <= 0;
            rx_valid <= 0;
        end
        else begin
            case (cs)
                IDLE: counter <= 0;
                CHK_CMD: counter <= 0;
                WRITE: begin
                    rx_data[9 - counter] <= MOSI;
                    counter <= counter + 1;
                    if(counter == 4'h9) begin
                        counter <= 0;
                        rx_valid <= 1;
                    end
                    else
                        rx_valid <= 0;
                end
                READ_ADD: begin
                    rx_data[9 - counter] <= MOSI;
                    counter <= counter + 1;
                    if(counter == 4'h9) begin
                        counter <= 0;
                        rx_valid <= 1;
                        internal_sig <= 1; 
                    end
                    else
                        rx_valid <= 0;
                end
                READ_DATA: begin
                    rx_data[9 - counter] <= MOSI;
                    counter <= counter + 1;
                    if(counter == 4'h9) begin
                        counter <= 0;
                        rx_valid <= 1;
                        internal_sig <= 0; 
                    end
                    else
                        rx_valid <= 0;
                    if(tx_valid && counter <= 7)
                        MISO <= tx_data[7 - counter];
                    else
                        MISO <= 0;
                end
                default: counter <= 0;
            endcase
        end
    end
endmodule