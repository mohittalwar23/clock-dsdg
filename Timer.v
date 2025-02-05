module Timer( clk, rst, pause, state, start_num, final_down, final_clock, disp0, disp1, disp2, disp3, disp4, disp5 );

/*basic parameters*/
parameter zero = 2'b00;
parameter one = 2'b01;
parameter two = 2'b10;

/*I/O*/
input clk, rst, pause;															//Clock, reset(Key1) and play/pause(Key0) inputs
input [1:0] state;																//State input (from switches 9 and 8)
input [5:0] start_num;															//Input from switches 5 to 0
input final_down, final_clock;												//triggers storage of start time for clock and stop time for timer
output [6:0] disp0, disp1, disp2, disp3, disp4, disp5;				//Drives the displays

reg [16:0] c_out_buffer = 17'd0;												//Stores time from select, clock, or count down module
/*Select module parameters*/
reg [5:0] start_num_select_buffer = 6'd0;									//Stores time inputs from switches to be passed to the select module
reg rst_select_buffer = 1'd1;													//Stores reset input from key1 to be passed to the select module
reg pause_select_buffer = 1'd1;												//Stores pause input from key0 to be passed to the select module
/*Count down module parameters*/
reg [16:0] init_time_down_buffer = 17'd0;									//Stores stop time input to be passed to the count down module
reg rst_down_buffer = 1'd1;													//Stores reset input from Key1 to be passed to the count down module
reg pause_down_buffer = 1'd1;													//Stores pause input from key0 to be passed to the count down module
/*Clock module parameters*/
reg [16:0] init_time_clock_buffer = 17'd0;								//Stores start time input to be passed to the clock module
reg rst_clock_buffer = 1'd1;													//Stores reset input from key1 to be passed to the clock module
reg pause_clock_buffer = 1'd1;												//Stores pause input from key0 to be passed to the clock module
/*Stopwatch module parameters*/
reg [18:0] c_out_buffer_stopwatch = 19'd0;								//Stores time from stopwatch module
reg rst_stopwatch_buffer = 1'd1;												//Stores reset input from key1 to be passed to the Stopwatch module
reg lap_stopwatch_buffer = 1'd1;												//Stores lap record input from key0 to be passed to the stopwatch module
reg pause_stopwatch_buffer = 1'd0;											//Stores pause input from Switch 5 to be passed to the stopwatch module
reg [3:0] lap_display_buffer = 4'd0;										//Stores inputs for lap times to display. Passed to stopwatch module

/*Store blink status for display*/						
reg blink_hr_buffer = 1'd0;
reg blink_min_buffer = 1'd0;
reg blink_sec_buffer = 1'd0;

/*clock module wires*/ 
wire [16:0] c_out_clock;
wire [16:0] rst_clock;
wire [16:0] pause_clock;
wire [16:0] init_time_clock;

/*Select module wires*/
wire [16:0] c_out_select;
wire [5:0] start_num_select;
wire [16:0] rst_select;
wire [16:0] pause_select;
wire blink_hr_sig_select;
wire blink_min_sig_select;
wire blink_sec_sig_select;

/*Count down module wires*/
wire [16:0] c_out_down;
wire [16:0] rst_down;
wire [16:0] pause_down;
wire [16:0] init_time_down;
wire blink_hr_sig_down;
wire blink_min_sig_down;
wire blink_sec_sig_down;

/*Stopwatch module wires*/
wire [18:0] c_out_stopwatch;	
wire [3:0] lap_display;
wire [16:0] rst_stopwatch;
wire [16:0] pause_stopwatch;

/*display wires*/
wire [18:0] c_out;
wire [18:0] sec;																	
wire [18:0] min;																	
wire [18:0] hr;
wire [3:0] sec_0;
wire [3:0] sec_1;
wire [3:0] min_0;
wire [3:0] min_1;
wire [3:0] hr_0;
wire [3:0] hr_1;
wire blink_hr;
wire blink_min;
wire blink_sec;

/*Instantiate select module*/
select init (.clk(clk), .rst(rst_select), .start_num(start_num_select), .button(pause_select), .c_out(c_out_select), .blink_hr_sig(blink_hr_sig_select), .blink_min_sig(blink_min_sig_select), .blink_sec_sig(blink_sec_sig_select));

/*Instantiate clock module*/
clock my_clock (.clk(clk), .start_time(init_time_clock), .rst(rst_clock), .pause(pause_clock), .c_out(c_out_clock));

/*Instantiate count down module*/
count_down my_count_down (.clk(clk), .start_time(init_time_down), .rst(rst_down), .pause(pause_down), .blink_hr_sig(blink_hr_sig_down), .blink_min_sig(blink_min_sig_down), .blink_sec_sig(blink_sec_sig_down), .c_out (c_out_down));

/*Instantiate stopwatch module*/
stop_watch my_watch (.clk(clk), .rst(rst_stopwatch), .play(pause_stopwatch), .lap(lap_stopwatch), .c_out(c_out_stopwatch), .switches(lap_display));

/*STATE MACHINE*/
always @(posedge clk)
begin
	case (state)
		zero:										//Select mode
		begin
			c_out_buffer <= c_out_select;
			rst_select_buffer <= rst;
			pause_select_buffer <= pause;
			start_num_select_buffer [5:0] <= start_num [5:0];
			rst_down_buffer <= 1'd1;
			pause_down_buffer <= 1'd1;
			rst_clock_buffer <= 1'd1;
			pause_clock_buffer <= 1'd1;
			lap_stopwatch_buffer <= 1'd1;
			rst_stopwatch_buffer <= 1'd1;
			lap_display_buffer [3:0] <= 4'd0;
			blink_hr_buffer <= blink_hr_sig_select;
			blink_min_buffer <= blink_min_sig_select;
			blink_sec_buffer <= blink_sec_sig_select;
		end
		one:										//Count down mode
		begin
			c_out_buffer <= c_out_down;
			rst_down_buffer <= rst;
			pause_down_buffer <= pause;
			start_num_select_buffer [5:0] <= 6'd0;
			rst_select_buffer <= 1'd1;
			pause_select_buffer <= 1'd1;
			rst_clock_buffer <= 1'd1;
			pause_clock_buffer <= 1'd1;
			lap_stopwatch_buffer <= 1'd1;
			rst_stopwatch_buffer <= 1'd1;
			lap_display_buffer [3:0] <= 4'd0;
			blink_hr_buffer <= blink_hr_sig_down;
			blink_min_buffer <= blink_min_sig_down;
			blink_sec_buffer <= blink_sec_sig_down;
		end
		two:										//Clock mode
		begin
			c_out_buffer <= c_out_clock;
			rst_clock_buffer <= rst;
			pause_clock_buffer <= pause;
			start_num_select_buffer [5:0] <= 6'd0;
			rst_select_buffer <= 1'd1;
			pause_select_buffer <= 1'd1;
			rst_down_buffer <= 1'd1;
			pause_down_buffer <= 1'd1;
			lap_stopwatch_buffer <= 1'd1;
			rst_stopwatch_buffer <= 1'd1;
			lap_display_buffer [3:0] <= 4'd0;
			blink_hr_buffer <= 1'd0;
			blink_min_buffer <= 1'd0;
			blink_sec_buffer <= 1'd0;
		end
		default:									//Stopwatch mode
		begin
			c_out_buffer_stopwatch <= c_out_stopwatch;
			rst_select_buffer <= 1'd1;
			pause_select_buffer <= 1'd1;
			rst_down_buffer <= 1'd1;
			pause_down_buffer <= 1'd1;
			rst_clock_buffer <= 1'd1;
			pause_clock_buffer <= 1'd1;
			start_num_select_buffer [5:0] <= 6'd0;
			lap_stopwatch_buffer <= pause;
			rst_stopwatch_buffer <= rst;
			pause_stopwatch_buffer <= start_num[5];
			lap_display_buffer [3:0] <= start_num [3:0];
			blink_hr_buffer <= 1'd0;
			blink_min_buffer <= 1'd0;
			blink_sec_buffer <= 1'd0;
		end
	endcase
end

/*store start time once it is confirmed (by pushing switch 6 to high)*/
always @(posedge clk, posedge final_down, posedge final_clock)
begin
	if (final_clock == 1)
	begin
		if (final_down == 1)
		begin
			init_time_clock_buffer <= init_time_clock_buffer;
			init_time_down_buffer <= init_time_down_buffer;
		end
		else
		begin
			init_time_clock_buffer <= init_time_clock_buffer;
			init_time_down_buffer <= c_out_buffer;
		end
	end
	else
	begin
		if (final_down == 1)
		begin
			init_time_clock_buffer <= c_out_buffer;
			init_time_down_buffer <= init_time_down_buffer;
		end
		else
		begin
			init_time_clock_buffer <= c_out_buffer;
			init_time_down_buffer <= c_out_buffer;
		end
	end
	
end

/*wire c_out from stopwatch or other modules*/
assign c_out = (state == 2'b11) ? c_out_buffer_stopwatch : c_out_buffer;
/*wire signals for clock*/
assign init_time_clock = init_time_clock_buffer;
assign rst_clock = rst_clock_buffer;
assign pause_clock = pause_clock_buffer;
/*wire signals for select*/
assign start_num_select = start_num_select_buffer;
assign rst_select = rst_select_buffer; 
assign pause_select = pause_select_buffer;
/*wire signals for count down*/
assign init_time_down = init_time_down_buffer;
assign rst_down = rst_down_buffer; 
assign pause_down = pause_down_buffer;
/*wire signals for stopwatch*/
assign pause_stopwatch = pause_stopwatch_buffer;
assign rst_stopwatch = rst_stopwatch_buffer;
assign lap_stopwatch = lap_stopwatch_buffer;
assign lap_display = lap_display_buffer;
/*wire blink signals*/
assign blink_hr = blink_hr_buffer;
assign blink_min = blink_min_buffer;
assign blink_sec = blink_sec_buffer;

/*Seperate seconds from minutes and hours*/
assign sec = (state == 2'b11) ? ((c_out >= 100) ? ( (c_out >= 6000) ? ((c_out%6000)%100) : (c_out % 100) ) : (c_out)) : ((c_out >= 60) ? ( (c_out >= 3600) ? ( (c_out%3600)%60) : (c_out % 60) ) : (c_out));
assign min = (state == 2'b11) ? ((c_out >= 100) ? ( (c_out >= 6000) ? ((c_out%6000)/100) : (c_out / 100) ) : (19'd0)) : ((c_out >= 60) ? ( (c_out >= 3600) ? ((c_out%3600)/60) : (c_out / 60) ) : (17'd0));
assign hr = (state == 2'b11) ? ((c_out >= 100) ? ( (c_out >= 6000) ? (c_out/6000) : (19'd0) ) : (19'd0)) : ((c_out >= 60) ? ( (c_out >= 3600) ? (c_out/3600) : (17'd0) ) : (17'd0));

/*Seperate ten's place from one's place*/
assign sec_0 = (state == 2'b11) ? (sec % 19'd10) : (sec % 17'd10);
assign sec_1 = (state == 2'b11) ? (sec / 19'd10) : (sec / 17'd10);
assign min_0 = (state == 2'b11) ? (min % 19'd10) : (min % 17'd10);
assign min_1 = (state == 2'b11) ? (min / 19'd10) : (min / 17'd10);
assign hr_0 = (state == 2'b11) ? (hr % 19'd10) : (hr % 17'd10);
assign hr_1 = (state == 2'b11) ? (hr / 19'd10) : (hr / 17'd10);

/*Drive each display according to seconds, minuntes, and hours*/

//	/*Boolean function for disp0. */
	assign disp0[0] = (blink_sec == 1) ? (1'b1) : (~sec_0[3]&~sec_0[2]&~sec_0[1]&sec_0[0]) | (~sec_0[3]&sec_0[2]&~sec_0[1]&~sec_0[0]);
	assign disp0[1] = (blink_sec == 1) ? (1'b1) : (~sec_0[3]&sec_0[2]&~sec_0[1]&sec_0[0]) | (~sec_0[3]&sec_0[2]&sec_0[1]&~sec_0[0]);
	assign disp0[2] = (blink_sec == 1) ? (1'b1) : (~sec_0[3]&~sec_0[2]&sec_0[1]&~sec_0[0]);
	assign disp0[3] = (blink_sec == 1) ? (1'b1) : (~sec_0[3]&~sec_0[2]&~sec_0[1]&sec_0[0]) | (~sec_0[3]&sec_0[2]&~sec_0[1]&~sec_0[0]) | (~sec_0[3]&sec_0[2]&sec_0[1]&sec_0[0]);
	assign disp0[4] = (blink_sec == 1) ? (1'b1) : (~sec_0[3]&~sec_0[2]&~sec_0[1]&sec_0[0]) | (~sec_0[3]&~sec_0[2]&sec_0[1]&sec_0[0]) | (~sec_0[3]&sec_0[2]&~sec_0[1]&~sec_0[0]) | (~sec_0[3]&sec_0[2]&~sec_0[1]&sec_0[0]) | (~sec_0[3]&sec_0[2]&sec_0[1]&sec_0[0]) | (sec_0[3]&~sec_0[2]&~sec_0[1]&sec_0[0]);
	assign disp0[5] = (blink_sec == 1) ? (1'b1) : (~sec_0[3]&~sec_0[2]&~sec_0[1]&sec_0[0]) | (~sec_0[3]&~sec_0[2]&sec_0[1]&~sec_0[0]) | (~sec_0[3]&~sec_0[2]&sec_0[1]&sec_0[0]) | (~sec_0[3]&sec_0[2]&sec_0[1]&sec_0[0]);
	assign disp0[6] = (blink_sec == 1) ? (1'b1) : (~sec_0[3]&~sec_0[2]&~sec_0[1]&~sec_0[0]) | (~sec_0[3]&~sec_0[2]&~sec_0[1]&sec_0[0]) | (~sec_0[3]&sec_0[2]&sec_0[1]&sec_0[0]);
	
//	/*Boolean function for disp1. */
	assign disp1[0] = (blink_sec == 1) ? (1'b1) : (~sec_1[3]&~sec_1[2]&~sec_1[1]&sec_1[0]) | (~sec_1[3]&sec_1[2]&~sec_1[1]&~sec_1[0]);
	assign disp1[1] = (blink_sec == 1) ? (1'b1) : (~sec_1[3]&sec_1[2]&~sec_1[1]&sec_1[0]) | (~sec_1[3]&sec_1[2]&sec_1[1]&~sec_1[0]);
	assign disp1[2] = (blink_sec == 1) ? (1'b1) : (~sec_1[3]&~sec_1[2]&sec_1[1]&~sec_1[0]);
	assign disp1[3] = (blink_sec == 1) ? (1'b1) : (~sec_1[3]&~sec_1[2]&~sec_1[1]&sec_1[0]) | (~sec_1[3]&sec_1[2]&~sec_1[1]&~sec_1[0]) | (~sec_1[3]&sec_1[2]&sec_1[1]&sec_1[0]);
	assign disp1[4] = (blink_sec == 1) ? (1'b1) : (~sec_1[3]&~sec_1[2]&~sec_1[1]&sec_1[0]) | (~sec_1[3]&~sec_1[2]&sec_1[1]&sec_1[0]) | (~sec_1[3]&sec_1[2]&~sec_1[1]&~sec_1[0]) | (~sec_1[3]&sec_1[2]&~sec_1[1]&sec_1[0]) | (~sec_1[3]&sec_1[2]&sec_1[1]&sec_1[0]) | (sec_1[3]&~sec_1[2]&~sec_1[1]&sec_1[0]);
	assign disp1[5] = (blink_sec == 1) ? (1'b1) : (~sec_1[3]&~sec_1[2]&~sec_1[1]&sec_1[0]) | (~sec_1[3]&~sec_1[2]&sec_1[1]&~sec_1[0]) | (~sec_1[3]&~sec_1[2]&sec_1[1]&sec_1[0]) | (~sec_1[3]&sec_1[2]&sec_1[1]&sec_1[0]);
	assign disp1[6] = (blink_sec == 1) ? (1'b1) : (~sec_1[3]&~sec_1[2]&~sec_1[1]&~sec_1[0]) | (~sec_1[3]&~sec_1[2]&~sec_1[1]&sec_1[0]) | (~sec_1[3]&sec_1[2]&sec_1[1]&sec_1[0]);

//	/*Boolean function for disp2. */
	assign disp2[0] = (blink_min == 1) ? (1'b1) : (~min_0[3]&~min_0[2]&~min_0[1]&min_0[0]) | (~min_0[3]&min_0[2]&~min_0[1]&~min_0[0]);
	assign disp2[1] = (blink_min == 1) ? (1'b1) : (~min_0[3]&min_0[2]&~min_0[1]&min_0[0]) | (~min_0[3]&min_0[2]&min_0[1]&~min_0[0]);
	assign disp2[2] = (blink_min == 1) ? (1'b1) : (~min_0[3]&~min_0[2]&min_0[1]&~min_0[0]);
	assign disp2[3] = (blink_min == 1) ? (1'b1) : (~min_0[3]&~min_0[2]&~min_0[1]&min_0[0]) | (~min_0[3]&min_0[2]&~min_0[1]&~min_0[0]) | (~min_0[3]&min_0[2]&min_0[1]&min_0[0]);
	assign disp2[4] = (blink_min == 1) ? (1'b1) : (~min_0[3]&~min_0[2]&~min_0[1]&min_0[0]) | (~min_0[3]&~min_0[2]&min_0[1]&min_0[0]) | (~min_0[3]&min_0[2]&~min_0[1]&~min_0[0]) | (~min_0[3]&min_0[2]&~min_0[1]&min_0[0]) | (~min_0[3]&min_0[2]&min_0[1]&min_0[0]) | (min_0[3]&~min_0[2]&~min_0[1]&min_0[0]);
	assign disp2[5] = (blink_min == 1) ? (1'b1) : (~min_0[3]&~min_0[2]&~min_0[1]&min_0[0]) | (~min_0[3]&~min_0[2]&min_0[1]&~min_0[0]) | (~min_0[3]&~min_0[2]&min_0[1]&min_0[0]) | (~min_0[3]&min_0[2]&min_0[1]&min_0[0]);
	assign disp2[6] = (blink_min == 1) ? (1'b1) : (~min_0[3]&~min_0[2]&~min_0[1]&~min_0[0]) | (~min_0[3]&~min_0[2]&~min_0[1]&min_0[0]) | (~min_0[3]&min_0[2]&min_0[1]&min_0[0]);
	
//	/*Boolean function for disp3. */
	assign disp3[0] = (blink_min == 1) ? (1'b1) : (~min_1[3]&~min_1[2]&~min_1[1]&min_1[0]) | (~min_1[3]&min_1[2]&~min_1[1]&~min_1[0]);
	assign disp3[1] = (blink_min == 1) ? (1'b1) : (~min_1[3]&min_1[2]&~min_1[1]&min_1[0]) | (~min_1[3]&min_1[2]&min_1[1]&~min_1[0]);
	assign disp3[2] = (blink_min == 1) ? (1'b1) : (~min_1[3]&~min_1[2]&min_1[1]&~min_1[0]);
	assign disp3[3] = (blink_min == 1) ? (1'b1) : (~min_1[3]&~min_1[2]&~min_1[1]&min_1[0]) | (~min_1[3]&min_1[2]&~min_1[1]&~min_1[0]) | (~min_1[3]&min_1[2]&min_1[1]&min_1[0]);
	assign disp3[4] = (blink_min == 1) ? (1'b1) : (~min_1[3]&~min_1[2]&~min_1[1]&min_1[0]) | (~min_1[3]&~min_1[2]&min_1[1]&min_1[0]) | (~min_1[3]&min_1[2]&~min_1[1]&~min_1[0]) | (~min_1[3]&min_1[2]&~min_1[1]&min_1[0]) | (~min_1[3]&min_1[2]&min_1[1]&min_1[0]) | (min_1[3]&~min_1[2]&~min_1[1]&min_1[0]);
	assign disp3[5] = (blink_min == 1) ? (1'b1) : (~min_1[3]&~min_1[2]&~min_1[1]&min_1[0]) | (~min_1[3]&~min_1[2]&min_1[1]&~min_1[0]) | (~min_1[3]&~min_1[2]&min_1[1]&min_1[0]) | (~min_1[3]&min_1[2]&min_1[1]&min_1[0]);
	assign disp3[6] = (blink_min == 1) ? (1'b1) : (~min_1[3]&~min_1[2]&~min_1[1]&~min_1[0]) | (~min_1[3]&~min_1[2]&~min_1[1]&min_1[0]) | (~min_1[3]&min_1[2]&min_1[1]&min_1[0]);
	
//	/*Boolean function for disp4. */
	assign disp4[0] = (blink_hr == 1) ? (1'b1) : (~hr_0[3]&~hr_0[2]&~hr_0[1]&hr_0[0]) | (~hr_0[3]&hr_0[2]&~hr_0[1]&~hr_0[0]);
	assign disp4[1] = (blink_hr == 1) ? (1'b1) : (~hr_0[3]&hr_0[2]&~hr_0[1]&hr_0[0]) | (~hr_0[3]&hr_0[2]&hr_0[1]&~hr_0[0]);
	assign disp4[2] = (blink_hr == 1) ? (1'b1) : (~hr_0[3]&~hr_0[2]&hr_0[1]&~hr_0[0]);
	assign disp4[3] = (blink_hr == 1) ? (1'b1) : (~hr_0[3]&~hr_0[2]&~hr_0[1]&hr_0[0]) | (~hr_0[3]&hr_0[2]&~hr_0[1]&~hr_0[0]) | (~hr_0[3]&hr_0[2]&hr_0[1]&hr_0[0]);
	assign disp4[4] = (blink_hr == 1) ? (1'b1) : (~hr_0[3]&~hr_0[2]&~hr_0[1]&hr_0[0]) | (~hr_0[3]&~hr_0[2]&hr_0[1]&hr_0[0]) | (~hr_0[3]&hr_0[2]&~hr_0[1]&~hr_0[0]) | (~hr_0[3]&hr_0[2]&~hr_0[1]&hr_0[0]) | (~hr_0[3]&hr_0[2]&hr_0[1]&hr_0[0]) | (hr_0[3]&~hr_0[2]&~hr_0[1]&hr_0[0]);
	assign disp4[5] = (blink_hr == 1) ? (1'b1) : (~hr_0[3]&~hr_0[2]&~hr_0[1]&hr_0[0]) | (~hr_0[3]&~hr_0[2]&hr_0[1]&~hr_0[0]) | (~hr_0[3]&~hr_0[2]&hr_0[1]&hr_0[0]) | (~hr_0[3]&hr_0[2]&hr_0[1]&hr_0[0]);
	assign disp4[6] = (blink_hr == 1) ? (1'b1) : (~hr_0[3]&~hr_0[2]&~hr_0[1]&~hr_0[0]) | (~hr_0[3]&~hr_0[2]&~hr_0[1]&hr_0[0]) | (~hr_0[3]&hr_0[2]&hr_0[1]&hr_0[0]);
	
//	/*Boolean function for disp5. */
	assign disp5[0] = (blink_hr == 1) ? (1'b1) : (~hr_1[3]&~hr_1[2]&~hr_1[1]&hr_1[0]) | (~hr_1[3]&hr_1[2]&~hr_1[1]&~hr_1[0]);
	assign disp5[1] = (blink_hr == 1) ? (1'b1) : (~hr_1[3]&hr_1[2]&~hr_1[1]&hr_1[0]) | (~hr_1[3]&hr_1[2]&hr_1[1]&~hr_1[0]);
	assign disp5[2] = (blink_hr == 1) ? (1'b1) : (~hr_1[3]&~hr_1[2]&hr_1[1]&~hr_1[0]);
	assign disp5[3] = (blink_hr == 1) ? (1'b1) : (~hr_1[3]&~hr_1[2]&~hr_1[1]&hr_1[0]) | (~hr_1[3]&hr_1[2]&~hr_1[1]&~hr_1[0]) | (~hr_1[3]&hr_1[2]&hr_1[1]&hr_1[0]);
	assign disp5[4] = (blink_hr == 1) ? (1'b1) : (~hr_1[3]&~hr_1[2]&~hr_1[1]&hr_1[0]) | (~hr_1[3]&~hr_1[2]&hr_1[1]&hr_1[0]) | (~hr_1[3]&hr_1[2]&~hr_1[1]&~hr_1[0]) | (~hr_1[3]&hr_1[2]&~hr_1[1]&hr_1[0]) | (~hr_1[3]&hr_1[2]&hr_1[1]&hr_1[0]) | (hr_1[3]&~hr_1[2]&~hr_1[1]&hr_1[0]);
	assign disp5[5] = (blink_hr == 1) ? (1'b1) : (~hr_1[3]&~hr_1[2]&~hr_1[1]&hr_1[0]) | (~hr_1[3]&~hr_1[2]&hr_1[1]&~hr_1[0]) | (~hr_1[3]&~hr_1[2]&hr_1[1]&hr_1[0]) | (~hr_1[3]&hr_1[2]&hr_1[1]&hr_1[0]);
	assign disp5[6] = (blink_hr == 1) ? (1'b1) : (~hr_1[3]&~hr_1[2]&~hr_1[1]&~hr_1[0]) | (~hr_1[3]&~hr_1[2]&~hr_1[1]&hr_1[0]) | (~hr_1[3]&hr_1[2]&hr_1[1]&hr_1[0]);
	
endmodule