module DDA(
				clk_int,rst_n,X_end,Y_end,X_P_out,Y_P_out
				);

input clk_int;			// 50MHz��ʱ��
input rst_n;		//�͵�ƽ��λ�ź�

input [23:0] X_end;		
input [23:0] Y_end;

output X_P_out,Y_P_out;

wire clk;
PLL 			PLL(
						.inclk0(clk_int),
						.c0(clk)
					);


reg [23:0] max;
reg [23:0] count;

reg signed [23:0] X_end_t;
reg signed [23:0] Y_end_t;

reg signed [23:0] X_end_0;
reg signed [23:0] Y_end_0;
reg dir_x;
reg dir_y;
reg [1:0] state0;
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			max <= 24'd0;
			X_end_t <= 24'd0;
			Y_end_t <= 24'd0;
			X_end_0 <= 24'd0;
			Y_end_0 <= 24'd0;
			dir_x <= 1'b0;
			dir_y <= 1'b0;
			state0 <= 2'd0;
		end
	else begin
		case(state0)
			2'd0:
				begin
					X_end_t <= X_end - Xs;
					Y_end_t <= Y_end - Ys;
					state0 <= 2'd1;
				end 
			2'd1:
				begin
					if(X_end_t < 0)
						begin
							dir_x <= 1'b1;
							X_end_t <= -X_end_t;
						end
					else
						dir_x <= 1'b0;

					if(Y_end_t < 0)
						begin
							dir_y <= 1'b1;
							Y_end_t <= -Y_end_t;
						end
					else
						dir_y <= 1'b0;
					state0 <= 2'd2;
				end
			2'd2:
				begin
					max <= X_end_t + Y_end_t;
					state0 <= 2'd3;
				end
			2'd3:
				if(X_end_0 != X_end || Y_end_0 != Y_end)
					begin
						X_end_0 <= X_end;
						Y_end_0 <= Y_end;
						state0 <= 2'd0;
					end
			endcase
		end
end

reg signed [23:0] Xn;
reg signed [23:0] Yn;

reg signed [23:0] Xs;
reg signed [23:0] Ys;

reg [1:0] state1;
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			state1 <= 3'd0;
			count <= 24'd0;
			Xs <= 24'd0;
			Ys <= 24'd0;
		end
	else begin
		case(state1)
			2'd0:
				begin
					if(state0 == 2'd2)
						state1 <= 2'd1;
				end
			2'd1:
				begin
					Xn <= Xn + X_end_t;
					Xn <= Xn + X_end_t;
					state1 <= 2'd2;
				end
			2'd2:
				if(state2 == 2'd0)
				begin
					if(Xn >= max)
						begin
							Xn <= Xn - max;
							if(dir_x == 0)
								Xs <= Xs + 1'b1;
							else
								Xs <= Xs - 1'b1;
						end
					if(Yn >= max)
						begin
							Yn <= Yn - max;
							if(dir_y == 0)
								Ys <= Ys + 1'b1;
							else
								Ys <= Ys - 1'b1;
						end
					if(max <= count)
						begin
							state1 <= 2'd0;
							count <= 24'd0;
						end
					else
						count <= count + 1'b1;
				end
			endcase
		end
end					


reg reg_Xs_0;
reg reg_Ys_0;
wire X_P_out_en;
wire Y_P_out_en;
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		reg_Xs_0 <= 1'b0;
		reg_Ys_0 <= 1'b0;
	end
	else begin
		reg_Xs_0 <= Xs[0];
		reg_Ys_0 <= Ys[0];
	end
end
assign X_P_out_en = reg_Xs_0 ^ Xs[0];
assign Y_P_out_en = reg_Ys_0 ^ Ys[0];

reg X_P_out;
reg Y_P_out;
reg [1:0] state2;
reg [15:0] count2;
reg X_en;
reg Y_en;
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		X_P_out <= 1'b1;
		Y_P_out <= 1'b1;
		state2 <= 2'd0;
		count2 <= 16'd0;
		X_en <= 1'b0;
		Y_en <= 1'b0;
		end
	else begin
		case(state2)
			2'd0:
				begin
					if(X_P_out_en)
						begin	
							X_en <= 1'b1;
							state2 <= 2'd1;
						end
					if(Y_P_out_en)
						begin
							Y_en <= 1'b1;
							state2 <= 2'd1;
						end
				end
			2'd1:
				begin
					if(X_en)
						X_P_out <= 1'b0;
					if(Y_en)
						Y_P_out <= 1'b0;
					if(count2 >= 16'd5000)
						begin
							state2 <= 2'd2;
							count2 <= 16'd0;
						end
					else
						count2 <= count2 + 1'b1;
				end
			2'd2:
				begin
					if(X_en)
						X_P_out <= 1'b1;
					if(Y_en)
						Y_P_out <= 1'b1;
					if(count2 >= 16'd5000)
						begin
							state2 <= 2'd0;
							count2 <= 16'd0;
							X_en <= 1'b0;
							Y_en <= 1'b0;
						end
					else
						count2 <= count2 + 1'b1;
				end
		endcase
	end
end
endmodule
