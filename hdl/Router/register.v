module register( 
	clk,
	reset,
	i_Sig_Packet_Valid,
	i_Input_Data,
	i_Sig_Fifo_Full,
	i_Sig_Address_Detected,
	i_Load_Data_State,
	i_Load_After_State,
	i_Full_State,
	i_Load_First_Data_State,
	i_Reset_Low_Packet_Valid,
	o_Error,
	o_Sig_Parity_Done,
	o_Sig_Low_Packet_Valid,
	o_Output_Data
	);


	parameter DATA_WIDTH = 8;

	input clk;
	input reset;
	input i_Sig_Packet_Valid;
	input [DATA_WIDTH - 1 :0] i_Input_Data;
	input i_Sig_Fifo_Full;
	input i_Sig_Address_Detected;
	input i_Load_Data_State;
	input i_Load_After_State;
	input i_Full_State;
	input i_Load_First_Data_State;
	input i_Reset_Low_Packet_Valid;

	output reg o_Error;
	output reg o_Sig_Parity_Done;
	output reg o_Sig_Low_Packet_Valid;
	output reg [DATA_WIDTH - 1 :0] o_Output_Data;

	reg [DATA_WIDTH - 1 :0] r_Header;
	reg [DATA_WIDTH - 1 :0] r_Fifo_State;
	reg [DATA_WIDTH - 1 :0] r_Parity;
	reg [DATA_WIDTH - 1 :0] r_Packet_Parity;


	always @( posedge clk ) begin
		if( !reset )
			o_Sig_Parity_Done <= 1'b0;
			
		else begin
			if( i_Load_Data_State && !i_Sig_Fifo_Full && !i_Sig_Packet_Valid )
				o_Sig_Parity_Done <= 1'b1;

			else if( i_Load_After_State && o_Sig_Low_Packet_Valid && !o_Sig_Parity_Done )
				o_Sig_Parity_Done <= 1'b1;

			else begin
				if( i_Sig_Address_Detected )
					o_Sig_Parity_Done <= 1'b0;
			end
		end
	end
	

	always @( posedge clk ) begin
		if( !reset )
			o_Sig_Low_Packet_Valid <= 1'b0;

		else begin
			if( i_Reset_Low_Packet_Valid )
				o_Sig_Low_Packet_Valid <= 1'b0;

			if( i_Load_Data_State==1'b1 && i_Sig_Packet_Valid==1'b0 )
				o_Sig_Low_Packet_Valid <= 1'b1;
		end
	end
	

	always @( posedge clk ) begin
		if( !reset )
			o_Output_Data <= 8'b0;

		else begin
			if( i_Sig_Address_Detected && i_Sig_Packet_Valid )
				r_Header <= i_Input_Data;

			else if( i_Load_First_Data_State )
				o_Output_Data <= r_Header;

			else if( i_Load_Data_State && !i_Sig_Fifo_Full )
				o_Output_Data <= i_Input_Data;

			else if( i_Load_Data_State && i_Sig_Fifo_Full )
				r_Fifo_State <= i_Input_Data;

			else begin
				if( i_Load_After_State )
					o_Output_Data <= r_Fifo_State;
			end
		end
	end
	

	always @( posedge clk ) begin
		if( !reset )
			r_Parity <= 8'b0;

		else if( i_Load_First_Data_State )
			r_Parity <= r_Parity ^ r_Header;

		else if( i_Load_Data_State && i_Sig_Packet_Valid && !i_Full_State )
			r_Parity <= r_Parity ^ i_Input_Data;

		else begin	
			if ( i_Sig_Address_Detected )
				r_Parity <= 8'b0;
		end
	end
	

	always @( posedge clk ) begin
		if( !reset )
			r_Packet_Parity <= 8'b0;

		else begin
			if( !i_Sig_Packet_Valid && i_Load_Data_State )
				r_Packet_Parity <= i_Input_Data;
		end
	end
	

	always @( posedge clk ) begin
		if( !reset )
			o_Error <= 1'b0;

		else begin
			if( o_Sig_Parity_Done ) begin
				if( r_Parity!=r_Packet_Parity )
					o_Error <= 1'b1;
				else
					o_Error <= 1'b0;
			end
		end
	end

endmodule 
