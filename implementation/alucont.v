module alucont(aluop0,aluop1,aluop2,aluop3,f3,f2,f1,f0,c0,c1,c2,gout);
input aluop0,aluop1,aluop2,aluop3,c0,c1,c2,f3,f2,f1,f0;
output [3:0] gout;
reg [3:0] gout; 
always @(aluop0 or aluop1 or aluop2 or aluop3 or c0 or c1 or c2 or  f3 or f2 or f1 or f0)
begin
if( (~aluop3) & (~aluop2) & (~aluop1)  & (~aluop0)) gout = 4'b0010;     // if aluop = 0000 it's lw/sw/addi  (add)     
                  
if( (~aluop3) & (~aluop2) & (~aluop1)  & (aluop0) )   // if aluop = 0001, it's bgtz/blez/bltz/bne/beq 
begin 
	if( (c2) & (~c1) & (~c0) ) gout = 4'b0110;	// if opcode is 100 it's beq instruction (sub)
	if( (c2) & (~c1) & (c0) ) gout = 4'b1000;	// if opcode is 101 it's bne instruction ( ~sub)
	if( (c2) & (c1) & (~c0) ) gout = 4'b1001;	// if opcode is 111 it's blez instruction ( a <= 0 ? ) 
	if( (~c2) & (~c1) & (c0) ) gout = 4'b1011;	// if opcode is 001 it's bltz instruction  ( a < 0 ?
	if( (c2) & (c1) & (c0) ) gout = 4'b1111;	// if opcdoe is 110 it's bgtz instruction  ( a> 0 ? )
end
if( (aluop3)  &  (~aluop2) & (~aluop1) & (aluop0) ) gout = 4'b1110 ;    // if aluop = 1001, it's bgez ( a >= 0 ? ) 

if( (~aluop3) & (~aluop2) & (aluop1)   & (~aluop0)) gout = 4'b0000 ;    // if aluop = 0010, it's andi (and)
if( (~aluop3) & (~aluop2) & (aluop1)   & (aluop0) ) gout = 4'b0001 ;    // if aluop = 0011, it's ori (or) 
if( (~aluop3) & (aluop2) & (aluop1)  & (~aluop0) ) // if aluop = 0110, it's R-type
begin
	if (~(f3|f2|f1|f0))gout=4'b0010; 	//function code=0000,ALU control=0010 (add)
	if (f1&f3)gout=4'b0111;			//function code=1x1x,ALU control=0111 (set on less than)
	if (f1&~(f3))gout=4'b0110;		//function code=0x10,ALU control=0110 (sub)
	if (f2&f0)gout=4'b0001;			//function code=x1x1,ALU control=0001 (or)
	if (f2&~(f0))gout=4'b0000;		//function code=x1x0,ALU control=0000 (and)
	if(f0&f1&f2) gout = 4'b1100;		//// function code= =x111, Alu control=1100 (nor) 
	
	
		
end
end
endmodule
