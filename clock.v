module clock (clk, start_time, rst, pause, c_out);

parameter full_sec = 32'd50000000;	//cycles in full second of 50Mhz clock.
parameter full_day = 17'd86400;		//Seconds in a full day
/*I/O*/
input clk, rst, pause;
input [16:0] start_time;
output [16:0] c_out;				
	
reg [31:0] count = 32'd0;				//Counts every clock cycle.
reg state = 1'd1;							//Keeps track of state (play=1/pause=0).
reg detect = 1'd0;						//Helps detect push of play/pause button.
reg dfault = 2'd0;						//Helps control behaviour on initial run of design.
reg [16:0] c_out_buffer = 17'd0;		//Hold current clock value
reg [16:0] out_buffer = 17'd0;		//Hold output clock value

/*Logic for clock*/
always @(negedge clk or negedge rst or negedge pause)
begin
	if (rst == 0)		//If reset button is pressed, reset state, times, and pause/play detection.
	begin	
		count <= 32'd0;
		c_out_buffer <= 17'd0;
		state <= 1'd1;
		detect <= 1'd0;
	end	
	else 
	begin
		if (pause == 0)		//If pause button is pushed down, set detect to 1.
		begin
			detect <= (dfault == 2'd0) ? 1'd0 : 1'd1;
		end
		else
		begin
			if ((detect == 1'd1) && (dfault != 2'd0))		//If paused button was released from a push down, change states (pause/play).
			begin
				detect <= 1'd0;			//Set detect back to 0.
				state <= ~state;			//Change state.
				if (state == 1'd1)		//If state is play, count. Else, don't count.
				begin
					/*Count*/
					count <= count + 32'd1;
					if (count >= full_sec - 32'd1)	//If 1 second is reached, increment sec.
					begin
						count <= 32'd0;
						c_out_buffer <= ((c_out_buffer + start_time) >= 17'd86399) ? (17'd0 - start_time) : c_out_buffer + 17'd1;
						/*False button push detection*/
						if (dfault <= 2'd0)
						begin
							dfault <= dfault + 2'd1;
							detect <= 1'd0;
						end
					end
				end				
			end
			else			//If paused button was not released from a push down, do not change state.
			begin
				if (state == 1'd1)	//If state is play, count. Else, don't count.
				begin
					count <= count + 32'd1;
					if (count >= full_sec - 32'd1)	//If 1 second is reached, increment sec.
					begin
						count <= 32'd0;
						c_out_buffer <= ((c_out_buffer + start_time) >= 17'd86399) ? (17'd0 - start_time) : c_out_buffer + 17'd1;
						/*False button push detection*/
						if (dfault <= 2'd0)
						begin
							dfault <= dfault + 2'd1;
							detect <= 1'd0;
						end
					end
				end
			end
		end
	end
end	

/*pass correct time to output buffer*/
always @(negedge clk)
begin
	out_buffer <= c_out_buffer + start_time;
end

/*wire outputs*/
assign c_out = out_buffer;

endmodule
