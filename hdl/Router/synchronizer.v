module  synchronizer(  
	clk,
	reset,
	i_Sig_Address_Detected,
	i_Sig_Write_Enable_Reg,
	i_Sig_Read_Enable_1,
	i_Sig_Read_Enable_2,
	i_Sig_Read_Enable_3,
	i_Sig_Empty_1,
	i_Sig_Empty_2,
	i_Sig_Empty_3,
	i_Sig_Full_1,
	i_Sig_Full_2,
	i_Sig_Full_3,
	i_Input_Data,
	o_Valid_Output_1,
	o_Valid_Output_2,
	o_Valid_Output_3,
	o_Sig_Write_Enable,
	o_Fifo_Full,
	o_Sig_Soft_Reset_1,
	o_Sig_Soft_Reset_2,
	o_Sig_Soft_Reset_3
	);


	parameter DATA_WIDTH = 2;
	parameter COUNTER_WIDTH = 5;

	input clk;
	input reset;
	input i_Sig_Address_Detected;
	input i_Sig_Write_Enable_Reg;
	input i_Sig_Read_Enable_1;
	input i_Sig_Read_Enable_2;
	input i_Sig_Read_Enable_3;
	input i_Sig_Empty_1;
	input i_Sig_Empty_2;
	input i_Sig_Empty_3;
	input i_Sig_Full_1;
	input i_Sig_Full_2;
	input i_Sig_Full_3;

	input [DATA_WIDTH -1:0]i_Input_Data;

	output o_Valid_Output_1;
	output o_Valid_Output_2;
	output o_Valid_Output_3;

	output reg [DATA_WIDTH:0]o_Sig_Write_Enable;
	
	output reg o_Fifo_Full;
	output reg o_Sig_Soft_Reset_1;
	output reg o_Sig_Soft_Reset_2;
	output reg o_Sig_Soft_Reset_3;
					
	reg [DATA_WIDTH -1:0]r_Temp;
	reg [COUNTER_WIDTH - 1:0] r_Counter_1; 
	reg [COUNTER_WIDTH - 1:0] r_Counter_2; 
	reg [COUNTER_WIDTH - 1:0] r_Counter_3;

	always @( posedge clk ) begin
		if( !reset )
			r_Temp  <=  2'd0;

		else if( i_Sig_Address_Detected )
			r_Temp <= i_Input_Data;
	end
		

	always @( * ) begin
		case( r_Temp )
			2'b00: 
				o_Fifo_Full=i_Sig_Full_1;     

			2'b01: 
				o_Fifo_Full=i_Sig_Full_2; 

			2'b10: 
				o_Fifo_Full=i_Sig_Full_3;	

			default o_Fifo_Full=0;

		endcase
	end


	always @( * ) begin 
		if( i_Sig_Write_Enable_Reg ) begin
			case( r_Temp )
				2'b00: 
					o_Sig_Write_Enable=3'b001;	

				2'b01: 
					o_Sig_Write_Enable=3'b010;

				2'b10: 
					o_Sig_Write_Enable=3'b100;

				default: 
					o_Sig_Write_Enable=3'b000;

			endcase

		end

		else
			o_Sig_Write_Enable = 3'b000;		
		end

	
	always @( posedge clk ) begin
		if( !reset )
			r_Counter_1 <= 5'b0;

		else if( o_Valid_Output_1 ) begin
			if( !i_Sig_Read_Enable_1 ) begin
				if( r_Counter_1==5'b11110 ) begin
					o_Sig_Soft_Reset_1 <= 1'b1;
					r_Counter_1 <= 1'b0;
				end

				else begin
					r_Counter_1 <= r_Counter_1+1'b1;
					o_Sig_Soft_Reset_1 <= 1'b0;
				end
			end

			else r_Counter_1 <= 5'd0;
		end

		else r_Counter_1 <= 5'd0;
	end
		
		
	always @( posedge clk ) begin
		if( !reset )
			r_Counter_2 <= 5'b0;

		else if( o_Valid_Output_2 ) begin
			if( !i_Sig_Read_Enable_2 ) begin
				if( r_Counter_2==5'b11110 ) begin
					o_Sig_Soft_Reset_2 <= 1'b1;
					r_Counter_2 <= 1'b0;
				end

				else begin
					r_Counter_2 <= r_Counter_2+1'b1;
					o_Sig_Soft_Reset_2 <= 1'b0;
				end
			end

			else r_Counter_2 <= 5'd0;
		end
		else r_Counter_2 <= 5'd0;
	end
		

	always @( posedge clk ) begin
		if( !reset )
			r_Counter_3 <= 5'b0;

		else if( o_Valid_Output_3 ) begin
			if( !i_Sig_Read_Enable_3 ) begin
				if( r_Counter_3==5'b11110 ) begin
					o_Sig_Soft_Reset_3 <= 1'b1;
					r_Counter_3 <= 1'b0;
				end
				else begin
					r_Counter_3 <= r_Counter_3+1'b1;
					o_Sig_Soft_Reset_3 <= 1'b0;
				end
			end
			else r_Counter_3 <= 5'd0;
		end
		else r_Counter_3 <= 5'd0;
	end

	assign o_Valid_Output_1 = !i_Sig_Empty_1;
	assign o_Valid_Output_2 = !i_Sig_Empty_2;
	assign o_Valid_Output_3 = !i_Sig_Empty_3;
				
endmodule
