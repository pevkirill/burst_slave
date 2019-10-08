`timescale 1ns/1ns
module burst_slave_write_and_read_tb ;
	bit          clk               ; // Clock
	bit          rst_n             ; // Asynchronous reset active low
	logic [15:0] address           ;
	logic        beginbursttransfer;
	logic        read              ;
	logic        write             ;
	logic [31:0] writedata         ;
	logic [31:0] readdata          ;
	logic        readdatavalid     ;
	logic [4:0]  burstcount        ;
	logic        waitrequest       ;

	logic [15:0][31:0] memory;

	always #13 clk=~clk;

	initial begin
		rst_n = '0;
		address = 16'h0;
		read = '0;
		write = '0;
		burstcount = '0;
		writedata = '0;
		beginbursttransfer = '0;
		memory = {32'h11111111, 32'h22222222, 32'h33333333, 32'h44444444, 32'h55555555, 32'h66666666, 32'h77777777, 32'h88888888, 32'h99999999,
			32'haaaaaaaa, 32'hbbbbbbbb, 32'hcccccccc, 32'hdddddddd, 32'heeeeeeee, 32'hffffffff, 32'h16161616};
		wait_clocks(1);
		rst_n = '1;
		wait_clocks(7);

		for (int i = 0; i < 16; i++) begin
			address = i;
			burstcount = 5'd16;
			beginbursttransfer = 1;
			write_data(.num(burstcount));
			write = '0;
			address = '0;
			wait_clocks(3);
		end

		beginbursttransfer = 1;
		burstcount = 5'h9;
		read = 1;
		address = 16'h7;
		read_data(.num(burstcount));
		wait_clocks(5);
		beginbursttransfer = 1;
		burstcount = 5'h4;
		read = 1;
		address = 16'h1;
		read_data(.num(burstcount));



		wait_clocks(100);
		$stop;
	end

	task wait_clocks(int i);
		repeat (i) @(posedge clk) #1;
	endtask : wait_clocks

	task write_data(input bit [4:0] num);
		for (int i = 0; i < num; i++) begin
			if(waitrequest) begin
				beginbursttransfer = beginbursttransfer;
				burstcount = burstcount;
				address = address;
			end else begin
				writedata = memory[i];
				write = '1;
				wait_clocks(1);
				address = '0;
				writedata = '0;
				burstcount = 5'd0;
				beginbursttransfer = 0;
			end
		end
	endtask : write_data

	task read_data(input bit [3:0] num);
		for (int i = 0; i < num; i++) begin
			if(waitrequest) begin
				beginbursttransfer = beginbursttransfer;
				burstcount = burstcount;
				read = read;
				address = address;
			end else begin
				wait_clocks(1);
				address = '0;
				burstcount = 4'h0;
				read = '0;
				beginbursttransfer = 0;
			end
		end
	endtask : read_data



	burst_slave_write_and_read burst_slave_write_and_read_inst (
		.clk_i                  (clk               ),
		.rst_n                  (rst_n             ),
		.avms_address           (address           ),
		.avms_beginbursttransfer(beginbursttransfer),
		.avms_burstcount        (burstcount        ),
		.avms_read              (read              ),
		.avms_write             (write             ),
		.avms_writedata         (writedata         ),
		.avms_readdatavalid     (readdatavalid     ),
		.avms_readdata          (readdata          ),
		.avms_waitrequest       (waitrequest       )
	);

endmodule
