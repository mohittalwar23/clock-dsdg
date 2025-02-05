module count_down (clk, start_time, rst, pause, /*led_out,*/ blink_hr_sig, blink_min_sig, blink_sec_sig, c_out);	

parameter full_sec = 32'd50000000;	//cycles in ful second of 50Mhz clock
/*I/O*/
input clk, rst, pause;
input [16:0] start_time;
output [16:0] c_out;
output blink_hr_sig, blink_min_sig, blink_sec_sig;

reg [31:0] count = 32'd0;				//Counts every clock cycle.
reg state = 1'd1;							//Keeps track of state (play=1/pause=0).
reg detect = 1'd0;						//Helps detect push of play/pause button.
reg dfault = 2'd0;						//Helps control behaviour on initial run of design.
reg done = 1'd0;							//Goes high if count down is complete
reg [16:0] c_out_buffer = 17'd0;		//Holds current value of count down
reg [16:0] out_buffer = 17'd0;		//Hold output value of count down
/*Store blink status*/
reg blink_hr = 1'd0;
reg blink_min = 1'd0;
reg blink_sec = 1'd0;

/*Count down process*/
always @(negedge clk or negedge rst or negedge pause)
begin
	if (rst == 0)		//If reset, reset state, times, and pause/play detection.
	begin	
		count <= 32'd0;
		c_out_buffer <= 17'd0;
		state <= 1'd1;
		detect <= 1'd0;
		done <= 1'd0;
		blink_hr <= done ? (~blink_hr) : (1'd0);
		blink_min <= done ? (~blink_min) : (1'd0);
		blink_sec <= done ? (~blink_sec) : (1'd0);
	end	
	else 
	begin
		if (pause == 0)		//If pause button is pushed down, set detect to 1.
		begin
			detect <= (dfault == 2'd0) ? 1'd0 : 1'd1;
			blink_hr <= 1'd0;
			blink_min <= 1'd0;
			blink_sec <= 1'd0;
		end
		else
		begin
			if ((detect == 1'd1) && (dfault != 2'd0))		//If paused button was released from a push down, change state (pause/play).
			begin
				detect <= 1'd0;			//Set detect back to 0.
				state <= ~state;			//Change state.
				if (state == 1'd1)		//If state is play (state=1), count. Else, don't count.
				begin
					/*Count*/
					count <= count + 32'd1;
					if (count >= full_sec - 32'd1)	//If 1 second is reached, increment sec.
					begin
						count <= 32'd0;
						c_out_buffer <= c_out_buffer + 17'd1;
						if(c_out_buffer >= start_time - 17'd1)
						begin
							c_out_buffer <= start_time;
							done <= 1'd1;
							blink_hr <= done ? (~blink_hr) : (1'd0);
							blink_min <= done ? (~blink_min) : (1'd0);
							blink_sec <= done ? (~blink_sec) : (1'd0);
						end
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
					/*Count*/
					count <= count + 32'd1;
					if (count >= full_sec - 32'd1)	//If 1 second is reached, increment sec.
					begin
						count <= 32'd0;
						c_out_buffer <= c_out_buffer + 17'd1;
						if(c_out_buffer >= start_time - 17'd1)
						begin
							c_out_buffer <= start_time;
							done <= 1'd1;
							blink_hr <= done ? (~blink_hr) : (1'd0);
							blink_min <= done ? (~blink_min) : (1'd0);
							blink_sec <= done ? (~blink_sec) : (1'd0);
						end
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


/*If start time is zero, pass zero to the output*/
always @(negedge clk)
begin
	out_buffer <= (start_time == 17'd0) ? (17'd0) : start_time - c_out_buffer;
end
/*Wire outputs*/
assign blink_hr_sig = (start_time == 17'd0) ? 1'd0 : blink_hr;
assign blink_min_sig = (start_time == 17'd0) ? 1'd0 : blink_min;
assign blink_sec_sig = (start_time == 17'd0) ? 1'd0 : blink_sec;
assign c_out = out_buffer;

endmodule