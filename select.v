module select(clk, start_num, rst, button, c_out, blink_hr_sig, blink_min_sig, blink_sec_sig);

parameter half_sec = 32'd25000000;	//cycles in half second of 50Mhz clock
parameter full_sec = 32'd50000000;	//cycles in full second of 50Mhz clock
/*I/O*/
input clk, button, rst;
input [5:0] start_num;
output [16:0] c_out;
output blink_hr_sig, blink_min_sig, blink_sec_sig;
/*Store time values*/
reg [16:0] hr = 17'd0;
reg [16:0] min = 17'd0;
reg [16:0] sec = 17'd0;
/*Store blink status*/
reg blink_hr = 1'b0;
reg blink_min = 1'b0; 
reg blink_sec = 1'b0; 

reg [1:0] pushes = 2'd0;
reg detect = 1'd0;	
reg [1:0] dfault = 2'd0;
reg [31:0] count = 32'd0;

/*Help convert 6-bit to 17-bit numbers*/
reg conv = 11'd0;
wire [16:0] start_num_conv;
assign start_num_conv = {conv, start_num};		//Change format of input from 6 bit to 17 bit

/*Time selecting process*/
always @(posedge clk, negedge rst, negedge button)
begin
	if(rst == 0)					//If reset is low, reset times, and all other parameters.
	begin
		hr = 17'd0;
		min = 17'd0;
		sec = 17'd0;
		pushes = 2'd0;
		detect = 1'd0;	
		dfault = 2'd0;
		blink_hr = 1'b0;
		blink_min = 1'b0; 
		blink_sec = 1'b0; 
		count = 32'd0;
		conv = 11'd0;
	end
	else								//If reset is high, do not reset any parameters.
	begin
		if (button == 0)			//If button is low, set detect to 1.
		begin
			count <= count + 32'd1;
			detect <= (dfault == 2'd0) ? 1'd0 : 1'd1;
			blink_hr <= blink_hr;
			blink_min <= blink_min;
			blink_sec <= blink_sec;
			sec <= sec;
			min <= min;
			hr <= hr;
			pushes <= pushes;
			dfault <= dfault;
		end
		else							//If button is high
		begin	
			if ((detect == 1'd1) && (dfault != 2'd0))	//If push was detected
			begin
				detect <= 1'd0;							//set detect back to 0;
				/*Blink part of the display corresponding to hr, min, or sec.*/
				if (count >= full_sec - 32'd1)	
				begin
					count <= 32'd0;
					blink_hr <= 1'd0;
					blink_min <= 1'd0;
					blink_sec <= 1'd0;
					
				end
				else if (count >= half_sec - 32'd1)
				begin
					count <= count + 32'd1;
					blink_hr <= (pushes == 2'd0) ? 1'd1 : 1'd0;
					blink_min <= (pushes == 2'd1) ? 1'd1 : 1'd0;
					blink_sec <= (pushes == 2'd2) ? 1'd1 : 1'd0;
				end
				else
				begin
					count <= count + 32'd1;
					blink_hr <= blink_hr;
					blink_min <= blink_min;
					blink_sec <= blink_sec;
				end
				if(pushes == 2'd0)						//If first push detected, store number from switches in hours and increment pushes.
				begin
					hr <= start_num_conv;
					min <= min;
					sec <= sec;
					pushes <= pushes + 2'd1;
				end
				else if (pushes == 2'd1)				//If second push detected, store number from switches in minutes and increment pushes.
				begin
					min <= start_num_conv;
					sec <= sec;
					hr <= hr;
					pushes <= pushes + 2'd1;
				end
				else if (pushes == 2'd2)				//If third push detected, store number from switches in seconds and increment pushes.
				begin
					sec <= start_num_conv;
					min <= min;
					hr <= hr;
					pushes <= pushes + 2'd1;
				end
				else											//If fourth or more push detected, maintain pushes and time values.
				begin
					sec <= sec;
					min <= min;
					hr <= hr;
					pushes <= pushes;
				end
			end
			else												//If push was not detected.
			begin
				dfault <= 2'd1;							//clear default condition.
				detect <= 1'd0;							//set detect to 0
				pushes <= pushes;
				/*Blink part of the display corresponding to hr, min, or sec.*/
				if (count >= full_sec - 32'd1)	
				begin
					count <= 32'd0;
					blink_hr <= 1'd0;
					blink_min <= 1'd0;
					blink_sec <= 1'd0;
					
				end
				else if (count >= half_sec - 32'd1)
				begin
					count <= count + 32'd1;
					blink_hr <= (pushes == 2'd0) ? 1'd1 : 1'd0;
					blink_min <= (pushes == 2'd1) ? 1'd1 : 1'd0;
					blink_sec <= (pushes == 2'd2) ? 1'd1 : 1'd0;
				end
				else
				begin
					count <= count + 32'd1;
					blink_hr <= blink_hr;
					blink_min <= blink_min;
					blink_sec <= blink_sec;
				end
				if(pushes == 2'd0)						//If selecting hours, display number from switches in hours.
				begin
					hr <= start_num_conv;
					sec <= sec;
					min <= min;
				end
				else if (pushes == 2'd1)				//If selecting minutes, display number form switches in minutes.
				begin
					min <= start_num_conv;
					sec <= sec;
					hr <= hr;
				end
				else if (pushes == 2'd2)				//If selecting seconds, display number form switches in seconds.
				begin
					sec <= start_num_conv;
					min <= min;
					hr <= hr;
				end
				else											//If all times selected, maintain time values.
				begin
					sec <= sec;
					min <= min;
					hr <= hr;
				end
			end
		end
	end
end
/*Wire outputs*/
assign c_out = ( (hr * 17'd3600) + (min*17'd60) + sec );
assign blink_hr_sig = blink_hr;
assign blink_min_sig = blink_min;
assign blink_sec_sig = blink_sec;

endmodule