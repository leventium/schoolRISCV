module sr_mem #(
    parameter DEPTH = 256
) (
    input      [31:0] data_addr,
    input      [31:0] write_data,
    input             we,
    input             sign,
    input             byte_w, half_w, word_w,
    output reg [31:0] read_data
);

    reg [7:0] mem [DEPTH-1:0];

    always @(*) begin
        if (we) begin

            case ({byte_w, half_w, word_w})
                3'b100: begin
                    mem[data_addr]   = write_data[ 7: 0];
                end
                3'b010: begin
                    mem[data_addr]   = write_data[ 7: 0];
                    mem[data_addr+1] = write_data[15: 8];
                end
                3'b001: begin
                    mem[data_addr]   = write_data[ 7: 0];
                    mem[data_addr+1] = write_data[15: 8];
                    mem[data_addr+2] = write_data[23:16];
                    mem[data_addr+3] = write_data[31:24];
                end
                default: read_data = 0;
            endcase

        end else begin

            case ({byte_w, half_w, word_w})
                3'b100: begin
                    read_data = sign ? {
                        { 24 { mem[data_addr][7] } }, mem[data_addr]
                    } : {
                        { 24 { 1'b0 } }, mem[data_addr]
                    };
                end
                3'b010: begin
                    read_data = sign ? {
                        { 16 { mem[data_addr+1][7] } },
                        mem[data_addr+1], mem[data_addr]
                    } : {
                        { 16 { 1'b0 } }, mem[data_addr+1], mem[data_addr]
                    };
                end
                3'b001 : begin
                    read_data = {
                        mem[data_addr+3], mem[data_addr+2],
                        mem[data_addr+1], mem[data_addr]
                    };
                end
                default: read_data = 0;
            endcase

        end
    end

endmodule
