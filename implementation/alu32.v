module alu32(sum,a,b,zout,gin);//ALU operation according to the ALU control line values
output [31:0] sum;
input [31:0] a,b; 
input [3:0] gin;//ALU control line
reg [31:0] sum;
reg [31:0] less;
reg [31:0] sumz;
output zout;
reg zout;
always @(a or b or gin)
begin
	case(gin)
	4'b0010: sum=a+b; 				//ALU control line=010, ADD
	4'b0110: sum=a+1+(~b);				//ALU control line=110, SUB
	4'b0111: begin less=a+1+(~b);			//ALU control line=111, set on less than
			if (less[31]) sum=1;	
			else sum=0;
		  end
	4'b0000: sum=a & b;				//ALU control line=000, AND
	4'b0001: sum=a|b;				//ALU control line=001, OR
	4'b1100: sum= ~(a|b)	;			// ALU control line = 1100, NOR

	4'b1000: sum= ~(a+1+(~b)) ;			// ALU control line=1000, bne 
	4'b1001: sum= ~(a[31] | (~(|a))) ;			// ALU control line = 1001, blez --> a<= 0 ?
	4'b1011: sum= ~a[31] ;              		// ALU control line = 1011, bltz --> a< 0  ?
	4'b1111: begin			// ALU control line = 1111, bgtz --> a > 0 ? 
			if (~(|a)) sum = 1 ;
			else sum = a[31] ;
		 end 	       		 	
	4'b1110: sum= ~( (~a[31]) | (~(|a)) )  ;   		// ALU control line = 1110, bgez --> a>= 0 ? 
		
	default: sum=31'bx;	
	endcase
zout=~(|sum);
end
endmodule
