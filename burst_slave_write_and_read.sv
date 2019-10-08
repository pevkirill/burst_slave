
module burst_slave_write_and_read #(
	parameter DW = 32,
	parameter AW = 16
) (
	input                 clk_i                  , // Clock
	input                 rst_n                  , // Asynchronous reset active low
	// master --> slave
	input  logic [AW-1:0] avms_address           ,
	input  logic          avms_beginbursttransfer,
	input  logic [   4:0] avms_burstcount        ,
	input  logic          avms_read              ,
	input  logic          avms_write             ,
	input  logic [DW-1:0] avms_writedata         ,
	// slave --> master
	output logic          avms_readdatavalid     ,
	output logic [DW-1:0] avms_readdata          ,
	output logic          avms_waitrequest
);

logic [AW-1:0][511:0] memory  = '0;
logic [   4:0]        counter     ;
logic [AW-1:0]        address     ;
logic [   4:0]        cnt_valid   ;
logic [   4:0]        cnt_burst   ;

assign avms_waitrequest = '0;

always_ff @(posedge clk_i or negedge rst_n) begin : proc_address
	if(~rst_n) begin
		address <= '0;
	end else if(avms_address == '0) begin
		address <= address;
	end else begin 
		address <= avms_address;
	end
end

always_ff @(posedge clk_i or negedge rst_n) begin : proc_counter
	if(~rst_n) begin
		counter <= 0;
	end else if(avms_write) begin
		counter <= counter + 1'b1;
	end else begin 
		counter <= '0;
	end
end

always_ff @(posedge clk_i) begin : proc_memory
	if(avms_write) begin
		memory[address][counter*32+:32] <= avms_writedata;
	end 
end

always_comb begin : proc_readdata
	if(avms_readdatavalid) begin
		avms_readdata <= memory[address][cnt_burst*32+:32];
	end
end

always_ff @(posedge clk_i or negedge rst_n) begin : proc_cnt_valid
	if(~rst_n) begin
		cnt_valid <= '0;
	end else if(avms_read) begin
		cnt_valid <= avms_burstcount;
	end
end

always_ff @(posedge clk_i or negedge rst_n) begin : proc_cnt_burst
	if(~rst_n) begin
		cnt_burst <= '0;
	end else if(avms_read) begin 
		cnt_burst <= '0;
	end else if(cnt_burst == cnt_valid) begin
		cnt_burst <= cnt_burst;
	end else begin 
		cnt_burst <= cnt_burst + 1'b1;
	end
end

always_ff @(posedge clk_i or negedge rst_n) begin : proc_avms_readdatavalid
	if(~rst_n) begin
		avms_readdatavalid <= '0;
	end if(cnt_burst == cnt_valid) begin
		avms_readdatavalid <= '0;
	end else begin 
		avms_readdatavalid <= '1;
	end
end

endmodule
