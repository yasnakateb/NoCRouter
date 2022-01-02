module fsm( 
	clk,
	reset,
	i_Sig_Packet_Valid,
	i_Input_Data,
	i_Sig_Fifo_Full,
	i_Sig_Fifo_1_Empty,
	i_Sig_Fifo_2_Empty,
	i_Sig_Fifo_3_Empty,
	i_Sig_Soft_Reset_1,
	i_Sig_Soft_Reset_2,
	i_Sig_Soft_Reset_3,
	o_Sig_Parity_Done, 
	i_Sig_Low_Packet_Valid, 
	o_Sig_Write_Enable_Reg,
	o_Sig_Address_Detected,
	o_Load_Data_State,
	o_Load_After_State,
	o_Load_First_Data_State,
	o_Full_State,
	o_Reset_Low_Packet_Valid_Reg,
	o_Sig_Busy
	);


	parameter STATE_DECODE_ADDRESS = 4'b0001;
	parameter STATE_WAIT_TILL_EMPTY = 4'b0010;
	parameter STATE_LOAD_FIRST_DATA = 4'b0011;
	parameter STATE_LOAD_DATA = 4'b0100;
	parameter STATE_LOAD_PARITY = 4'b0101;
	parameter STATE_FIFO_FULL = 4'b0110;
	parameter STATE_LOAD_AFTER_FULL = 4'b0111;
	parameter STATE_CHECK_PARITY_ERROR = 4'b1000;
	parameter DATA_WIDTH = 2;

	input clk;
	input reset;
	input i_Sig_Packet_Valid;
	input [DATA_WIDTH - 1:0] i_Input_Data;
	input i_Sig_Fifo_Full;
	input i_Sig_Fifo_1_Empty;
	input i_Sig_Fifo_2_Empty;
	input i_Sig_Fifo_3_Empty;
	input i_Sig_Soft_Reset_1;
	input i_Sig_Soft_Reset_2;
	input i_Sig_Soft_Reset_3;
	input o_Sig_Parity_Done; 
	input i_Sig_Low_Packet_Valid; 

	output o_Sig_Write_Enable_Reg;
	output o_Sig_Address_Detected;
	output o_Load_Data_State;
	output o_Load_After_State;
	output o_Load_First_Data_State;
	output o_Full_State;
	output o_Reset_Low_Packet_Valid_Reg;
	output o_Sig_Busy;
				  			
	reg [3:0] r_State;
	reg [3:0] r_Next_State;
	reg [1:0] r_Temp;

	always @( posedge clk ) begin
		if( ~reset )
			r_Temp <= 2'b0;
		
		else if( o_Sig_Address_Detected )          
			r_Temp <= i_Input_Data;
	end

	always @( posedge clk ) begin
		if( !reset )
			r_State <= STATE_DECODE_ADDRESS;  
		
		else if ( ( ( i_Sig_Soft_Reset_1 ) && ( r_Temp == 2'b00 ) ) || 
				( ( i_Sig_Soft_Reset_2 ) && ( r_Temp == 2'b01 ) ) || 
				( ( i_Sig_Soft_Reset_3 ) && ( r_Temp == 2'b10 ) ) )		
				
			r_State <= STATE_DECODE_ADDRESS;

		else
			r_State <= r_Next_State;
				
	end


	always @( * ) begin
		case( r_State )
			STATE_DECODE_ADDRESS: begin
				if( ( i_Sig_Packet_Valid && ( i_Input_Data == 2'b00 ) && i_Sig_Fifo_1_Empty )|| 
				( i_Sig_Packet_Valid && ( i_Input_Data == 2'b01 ) && i_Sig_Fifo_2_Empty )|| 
				( i_Sig_Packet_Valid && ( i_Input_Data == 2'b10 ) && i_Sig_Fifo_3_Empty ) )

					r_Next_State <= STATE_LOAD_FIRST_DATA;  

				else if( ( i_Sig_Packet_Valid && ( i_Input_Data == 2'b00 ) && !i_Sig_Fifo_1_Empty )||
					   ( i_Sig_Packet_Valid && ( i_Input_Data == 2'b01 ) && !i_Sig_Fifo_2_Empty )||
					   ( i_Sig_Packet_Valid && ( i_Input_Data == 2'b10 ) && !i_Sig_Fifo_3_Empty ) )

						r_Next_State <= STATE_WAIT_TILL_EMPTY;  
					
				else 
					r_Next_State <= STATE_DECODE_ADDRESS;	   
			end

			STATE_LOAD_FIRST_DATA: begin	
				r_Next_State <= STATE_LOAD_DATA;
			end

			STATE_WAIT_TILL_EMPTY: begin
				if( ( i_Sig_Fifo_1_Empty && ( r_Temp == 2'b00 ) )||
				  ( i_Sig_Fifo_2_Empty && ( r_Temp == 2'b01 ) )||
				  ( i_Sig_Fifo_3_Empty && ( r_Temp == 2'b10 ) ) ) 
					r_Next_State <= STATE_LOAD_FIRST_DATA;
		
				else
					r_Next_State <= STATE_WAIT_TILL_EMPTY;
			end

			STATE_LOAD_DATA: begin
				if( i_Sig_Fifo_Full == 1'b1 ) 
					r_Next_State <= STATE_FIFO_FULL;

				else begin
					if ( !i_Sig_Fifo_Full && !i_Sig_Packet_Valid )
						r_Next_State <= STATE_LOAD_PARITY;

					else
						r_Next_State <= STATE_LOAD_DATA;
				end
			end

			STATE_FIFO_FULL: begin
				if( i_Sig_Fifo_Full == 0 )
					r_Next_State <= STATE_LOAD_AFTER_FULL;

				else 
					r_Next_State <= STATE_FIFO_FULL;
			end

			STATE_LOAD_AFTER_FULL: begin
				if( !o_Sig_Parity_Done && i_Sig_Low_Packet_Valid )
					r_Next_State <= STATE_LOAD_PARITY;

				else if( !o_Sig_Parity_Done && !i_Sig_Low_Packet_Valid )
					r_Next_State <= STATE_LOAD_DATA;
	
				else begin 
					if( o_Sig_Parity_Done == 1'b1 )
						r_Next_State <= STATE_DECODE_ADDRESS;

					else
						r_Next_State <= STATE_LOAD_AFTER_FULL;
				end
				
			end

			STATE_LOAD_PARITY: begin
				if( i_Sig_Fifo_Full )
					r_Next_State <= STATE_FIFO_FULL;
				else	
				r_Next_State <= STATE_CHECK_PARITY_ERROR;
			end

			STATE_CHECK_PARITY_ERROR: begin
				if( !i_Sig_Fifo_Full )
					r_Next_State <= STATE_DECODE_ADDRESS;

				else
					r_Next_State <= STATE_FIFO_FULL;
			end

			default:					
				r_Next_State <= STATE_DECODE_ADDRESS; 

		endcase																					
	end


	assign o_Sig_Busy=( ( r_State == STATE_LOAD_FIRST_DATA )||
					  (   r_State == STATE_LOAD_PARITY )||
					  (   r_State == STATE_FIFO_FULL )||
					  (   r_State == STATE_LOAD_AFTER_FULL )||
					  (   r_State == STATE_WAIT_TILL_EMPTY )||
					  (   r_State == STATE_CHECK_PARITY_ERROR ) )?1:0;


	assign o_Sig_Address_Detected=( ( r_State == STATE_DECODE_ADDRESS ) )?1:0;
	assign o_Load_First_Data_State=( ( r_State == STATE_LOAD_FIRST_DATA ) )?1:0;
	assign o_Load_Data_State=( ( r_State == STATE_LOAD_DATA ) )?1:0;

	assign o_Sig_Write_Enable_Reg=( ( r_State == STATE_LOAD_DATA )||
			              (   r_State == STATE_LOAD_AFTER_FULL )||
				      (   r_State == STATE_LOAD_PARITY ) ) ?1:0;
								  
	assign o_Full_State=( ( r_State == STATE_FIFO_FULL ) )?1:0;
	assign o_Load_After_State=( ( r_State == STATE_LOAD_AFTER_FULL ) )?1:0;
	assign o_Reset_Low_Packet_Valid_Reg=( ( r_State == STATE_CHECK_PARITY_ERROR ) )?1:0;

endmodule
