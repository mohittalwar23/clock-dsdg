module stop_watch(clk, rst, play, lap, switches, c_out);

parameter full_decisec = 32'd500000;	//cycles in a full second of a 50Mhz clock.
/*I/O*/
input clk, rst, play, lap;
input [3:0] switches;
output [18:0] c_out;				

reg [31:0] count = 32'd0;				//Counts every clock cycle.
reg detect = 1'd0;						//Helps detect push of play/pause button.
reg dfault = 2'd0;						//Helps control behaviour on initial run of design.
reg [11:0] lap_buffer [18:0];			//Stores lap times
reg [3:0] curr_lap = 4'd1;				//Stores index of next lap to be recorded
reg [18:0] c_out_buffer = 19'd0;		//Stores live stopwatch time
reg [18:0] out_buffer = 19'd0;

/*Logic for clock*/
always @(negedge clk or negedge rst or negedge lap)
begin
	if (rst == 0)		//If reset, reset times, and pause/play detection.
	begin	
		count <= 32'd0;
		c_out_buffer <= 19'd0;
		detect <= 1'd0;
		lap_buffer[11] <= 19'd0;
		lap_buffer[10] <= 19'd0;
		lap_buffer[9] <= 19'd0;
		lap_buffer[8] <= 19'd0;
		lap_buffer[7] <= 19'd0;
		lap_buffer[6] <= 19'd0;
		lap_buffer[5] <= 19'd0;
		lap_buffer[4] <= 19'd0;
		lap_buffer[3] <= 19'd0;
		lap_buffer[2] <= 19'd0;
		lap_buffer[1] <= 19'd0;
		lap_buffer[0] <= 19'd0;
		curr_lap <= 4'd1;
	end	
	else 			//If reset is not pushed
	begin
		if(lap == 0)		//if lap button is pushed down, detect the push
		begin
			detect <= (dfault==2'd0) ? (1'd0) : (1'd1);
		end
		else					//if lap button is released
		begin
			if (play == 1)					//if in play mode
			begin
				if(detect==1'd1 && dfault!=2'd0)		//if push was detected
				begin
					detect <= 1'd0;
					dfault <= 1'd1;
					lap_buffer[curr_lap] <= (curr_lap >= 4'd11) ? (lap_buffer[curr_lap]) : c_out_buffer;
					curr_lap <= (curr_lap >= 4'd11) ? (curr_lap) : curr_lap + 4'd1;		
				end
				else								//if no push detected
				begin
					dfault <= 2'd1;
					lap_buffer[curr_lap] <= 19'd0; 
					curr_lap <= curr_lap;
				end
				count <= count + 32'd1;
				if(count >= full_decisec - 32'd1)		//if full second is reached, reset count
				begin
					count <= 32'd0;
					c_out_buffer <= c_out_buffer + 19'd1;
				end
				else
				begin
					c_out_buffer <= c_out_buffer;
				end				
			end
			else								//if in pause mode
			begin
				if(detect==1'd1 && dfault!=2'd0)		//if push was detected
				begin
					detect <= 1'd0;
					dfault <= 2'd1;
					lap_buffer[curr_lap] <= (curr_lap >= 4'd11) ? (lap_buffer[curr_lap]) : c_out_buffer;
					curr_lap <= (curr_lap >= 4'd11) ? (curr_lap) : curr_lap + 4'd1;
				end
				else								//if no push was detected
				begin
					dfault <= 2'd1;
					lap_buffer[curr_lap] <= 19'd0; 
					curr_lap <= curr_lap;
				end
				count <= count;
				c_out_buffer <= c_out_buffer;				
			end
		end	
	end
end	

/*Limit the stopwatch to 1 hour*/
always @ (posedge clk) 
begin
	if (switches == 4'd0)
		out_buffer <= (c_out_buffer >= 19'd360000) ? (c_out_buffer - 19'd360000) : (c_out_buffer);
	else
		out_buffer <= (c_out_buffer >= 19'd360000) ? ( (curr_lap >= 4'd3) ? ((lap_buffer[switches]==19'd0)?(19'd0):(lap_buffer[switches] - lap_buffer[switches-4'd1])) : (lap_buffer[switches] - 19'd360000)) : ( (curr_lap >= 4'd3) ? ((lap_buffer[switches]==19'd0)?(19'd0):(lap_buffer[switches] - lap_buffer[switches-4'd1])) : (lap_buffer[switches]) );
end
/*wire outputs*/
assign c_out = out_buffer;

endmodule