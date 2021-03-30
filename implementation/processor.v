module processor;
reg [31:0] pc; //32-bit program counter
reg clk; //clock
reg [7:0] datmem[0:31],mem[0:119]; //32-size data and 119 size instruction memory (8 bit(1 byte) for each location) 
wire [31:0] 
dataa,	//Read data 1 output of Register File
datab,	//Read data 2 output of Register File
out2,		//Output of mux with ALUSrc control-mult2
out3,		//Output of mux with MemToReg control-mult3 ####### 3_to_1
out4,		//Output of mux with (OR Gate) control-mult4
out5,           ///// NEW Output of mux with Jump control-mult5  
sum,		//ALU result
extad,		//Output of sign-extend unit
adder1out,	//Output of adder which adds PC and 4-add1
adder2out,	//Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad,	//Output of shift left 2 unit ( sign extend)
jumpaddress; // oconcatenation of shift left 2 unit ( inst25_0)	and  pc+4[31-28]

wire[27:0] shift26_28 ; // NEW output of shift26_28 unit.
wire [2:0] inst28_26; // NEW 28-26 bits of instruction

wire [5:0] 
inst31_26,	//31-26 bits of instruction
inst5_0 ;       //NEW  5-0 bits of instruction
	
wire [4:0] 
inst25_21,	//25-21 bits of instruction
inst20_16,	//20-16 bits of instruction
inst15_11,	//15-11 bits of instruction
out1;		//Write data input of Register File

wire [15:0] inst15_0;	//15-0 bits of instruction

wire [25:0] inst25_0;  // NEW 25-0 bits of instruction.

wire [31:0] instruc,	//current instruction
dpack;	//Read data output of memory (data read from memory)

wire [3:0] gout;	// NEW it's 4 bits. Output of ALU control unit

wire zout,	//Zero output of ALU
beqsrc,	 //Output of AND gate with beq and ZeroOut inputs --- Old name pcsrc.
bnesrc,  //Output of AND gate with bne and ZeroOut inputs
bgezsrc, //Output of AND gate with bgez and ZeroOut inputs
bgtzsrc, //Output of AND gate with bgtz and ZeroOut inputs
bltzsrc, //Output of AND gate with bltz and ZeroOut inputs
blezsrc, //Output of AND gate with blez and ZeroOut inputs
pcsrc,  // NEW pcsrc. Output of OR gate with beqsrc,bnesrc,bgezsrc,bgtzsrc,bltzsrc,blezsrc inputs

//Control signals
regdest0,regdest1,alusrc,memtoreg0,memtoreg1,regwrite,memread,memwrite,jump0,jump1,beq, bne, bgez, bgtz, bltz,blez,aluop0,aluop1,aluop2,aluop3 ;



//32-size register file (32 bit(1 word) for each register)
reg [31:0] registerfile[0:31];

integer i;

// datamemory connections

always @(posedge clk)
//write data to memory
if (memwrite)
begin 
//sum stores address,datab stores the value to be written
datmem[sum[4:0]+3]=datab[7:0];
datmem[sum[4:0]+2]=datab[15:8];
datmem[sum[4:0]+1]=datab[23:16];
datmem[sum[4:0]]=datab[31:24];
end

//instruction memory
//4-byte instruction
 assign instruc={mem[pc[10:0]],mem[pc[10:0]+1],mem[pc[10:0]+2],mem[pc[10:0]+3]};
 assign inst31_26=instruc[31:26];
 assign inst25_21=instruc[25:21];
 assign inst20_16=instruc[20:16];
 assign inst15_11=instruc[15:11];
 assign inst15_0=instruc[15:0];
 assign inst28_26= instruc[28:26];
 assign inst5_0= instruc[5:0];
 assign inst25_0 = instruc[25:0];

// jump address
 assign jumpaddress = {adder1out[31:28],shift26_28};


// registers

assign dataa=registerfile[inst25_21];//Read register 1
assign datab=registerfile[inst20_16];//Read register 2
always @(posedge clk)
 registerfile[out1]= regwrite ? out3:registerfile[out1];//Write data to register

//read data from memory, sum stores address
assign dpack={datmem[sum[5:0]],datmem[sum[5:0]+1],datmem[sum[5:0]+2],datmem[sum[5:0]+3]}; //big endian format

//multiplexers
//mux with RegDst control
mult3_to_1_5  mult1(out1, instruc[20:16],instruc[15:11],5'b11111,{regdest1,regdest0});

//mux with ALUSrc control
mult2_to_1_32 mult2(out2, datab,extad,alusrc);

//mux with MemToReg control // new adder1out 
mult3_to_1_32 mult3(out3, sum,dpack,adder1out,{memtoreg1, memtoreg0});

//mux with pcsrc control
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);

// mux with jump control
mult3_to_1_32 mult5(out5,out4,jumpaddress,dataa,{jump1,jump0});	 

// load pc
always @(posedge clk)
pc=out5;

// alu, adder and control logic connections

//ALU unit
alu32 alu1(sum,dataa,out2,zout,gout);

//adder which adds PC and 4
adder add1(pc,32'h4,adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out,sextad,adder2out);

//Control unit
control cont(inst31_26,inst5_0,inst20_16,regdest0,regdest1,alusrc,memtoreg0,memtoreg1,regwrite,memread,memwrite,jump0,jump1,aluop0,aluop1,aluop2,aluop3,beq,bne,bgez,bgtz,bltz,blez );


//Sign extend unit
signext sext(instruc[15:0],extad);

//ALU control unit
alucont acont(aluop0,aluop1,aluop2,aluop3,instruc[3],instruc[2], instruc[1], instruc[0] , instruc[26], instruc[27], instruc[28], gout);

//Shift-left 2 unit
shift shift2(sextad,extad);

// shiflt26_28 unit

shift26_28 shift26(shift26_28, inst25_0); 

//AND gates
assign beqsrc  = beq & zout ;
assign bnesrc  = bne & zout ;
assign bgezsrc = bgez & zout ;
assign bgtzsrc = bgtz & zout ;
assign bltzsrc = bltz & zout ;
assign blezsrc = blez & zout ;

//OR Gate 

assign pcsrc = (beqsrc | bnesrc | bgezsrc | bgtzsrc | bltzsrc | blezsrc);


//initialize datamemory,instruction memory and registers
//read initial data from files given in hex
initial
begin
$readmemh("initDM.dat",datmem); //read Data Memory
$readmemh("initIM.dat",mem);//read Instruction Memory
$readmemh("initReg.dat",registerfile);//read Register File

	for(i=0; i<120; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
pc=0; // #instruction * 40 
#1000 $finish;
	
end

initial
begin
clk=0;
//40 time unit for each cycle
forever #20  clk=~clk;
end
initial 
begin
  $monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
"   REGISTER 0) %h 1) %h 2) %h 3)%h 4)%h 5)%h 6)%h ra)%h   ",registerfile[0],registerfile[1],registerfile[2],registerfile[3],registerfile[4], registerfile[5],registerfile[6],registerfile[31]);
end
endmodule

