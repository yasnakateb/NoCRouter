module fifo( 
	clk,
	reset,
	i_Sig_Soft_Reset,
	i_Sig_Write_Enable,
	i_Sig_Read_Enable,
	i_Load_First_Data_State,
	i_Input_Data,
	o_Sig_Full,
	o_Sig_Empty,
	o_Output_Data
	);

	
	parameter DATA_WIDTH = 8;
	parameter MEMORY_DEPTH = 16;
	parameter POINTER_WIDTH = 4;
	parameter COUNTER_WIDTH = 6;

	input clk;
	input reset;
	input i_Sig_Soft_Reset;
	input i_Sig_Write_Enable;
	input i_Sig_Read_Enable;
	input i_Load_First_Data_State;
	input [DATA_WIDTH - 1:0]i_Input_Data;

	output reg o_Sig_Full;
	output reg o_Sig_Empty;
	output reg [DATA_WIDTH - 1:0] o_Output_Data;

	reg [POINTER_WIDTH - 1:0] r_Read_Pointer;
	reg [POINTER_WIDTH - 1:0] r_Write_Pointer;
	reg [POINTER_WIDTH:0] r_Adder;
	reg r_Temp;

	reg [COUNTER_WIDTH - 1:0] r_Counter;
	reg [DATA_WIDTH:0] r_Fifo_Memory [MEMORY_DEPTH - 1:0];
	
	integer i;


	always @( posedge clk ) begin
		if ( !reset ) 
			r_Adder <= 0;

		else if ( ( !o_Sig_Full && i_Sig_Write_Enable ) && 
		          ( !o_Sig_Empty && i_Sig_Read_Enable ) ) 
			r_Adder <= r_Adder;

		else if ( !o_Sig_Full && i_Sig_Write_Enable ) 
			r_Adder <= r_Adder + 1;					

		else if ( !o_Sig_Empty && i_Sig_Read_Enable ) 									
			r_Adder <= r_Adder - 1;
		else
			r_Adder <= r_Adder;
	end

	
	always @( r_Adder ) begin
		if ( r_Adder==0 )      
			o_Sig_Empty = 1;
		else
			o_Sig_Empty = 0;

		if ( r_Adder==4'b1111 )  
			o_Sig_Full = 1;
		else
			o_Sig_Full = 0;
	end 
	

	always @( posedge clk ) begin
		if ( !reset || i_Sig_Soft_Reset ) begin
			for ( i=0; i<16; i=i+1 ) 
				r_Fifo_Memory[i] <= 0; 
		end
		
		else if ( i_Sig_Write_Enable && !o_Sig_Full ) 
			{
			 r_Fifo_Memory[r_Write_Pointer[POINTER_WIDTH - 1:0]][DATA_WIDTH],
			 r_Fifo_Memory[r_Write_Pointer[POINTER_WIDTH-1:0]][DATA_WIDTH -1:0]
			} <= {r_Temp,i_Input_Data}; 
	
	end

	
	always @( posedge clk ) begin
		if ( !reset ) 
			o_Output_Data <= 0;

		else if ( i_Sig_Soft_Reset ) 
			o_Output_Data <= 8'bzz;
		
		else begin 
			if ( i_Sig_Read_Enable && !o_Sig_Empty ) 
				o_Output_Data <= r_Fifo_Memory[r_Read_Pointer[POINTER_WIDTH-1:0]];
				
			if ( r_Counter==0 ) 
				o_Output_Data <= 8'bz;
		end
	end
	

	always @( posedge clk ) begin
		if ( i_Sig_Read_Enable && !o_Sig_Empty ) begin
			if ( r_Fifo_Memory[r_Read_Pointer[POINTER_WIDTH-1:0]][DATA_WIDTH] )                         
				r_Counter<=r_Fifo_Memory[r_Read_Pointer[POINTER_WIDTH-1:0]][DATA_WIDTH-1:2]+1'b1;

			else if ( r_Counter!=6'd0 ) 
				r_Counter<=r_Counter-1'b1;				
		end
	end
	

	always @( posedge clk ) begin
		if ( !reset || i_Sig_Soft_Reset ) begin
			r_Read_Pointer = 0;
			r_Write_Pointer = 0;
		end

		else begin
			if ( i_Sig_Write_Enable && !o_Sig_Full ) 
				r_Write_Pointer=r_Write_Pointer+1'b1;

			if ( i_Sig_Read_Enable && !o_Sig_Empty ) 
				r_Read_Pointer=r_Read_Pointer+1'b1;
		end
	end


	always @( posedge clk ) begin
		if ( !reset ) 
			r_Temp <= 1'b0;
		else 
			r_Temp <= i_Load_First_Data_State;
	end 

endmodule
