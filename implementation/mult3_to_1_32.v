module mult3_to_1_32(out,i0,i1,i2,s);
output [31:0] out;
input [31:0]i0,i1,i2;
input [1:0]s;
reg [31:0] out;
always @(s or i2 or i1 or i0)
begin
  case(s)
    2'b00: out=i0;
    2'b01: out=i1;
    2'b10: out=i2;
  endcase
end 
endmodule