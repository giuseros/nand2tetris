module Decoder #(parameter IL=16)(
input[IL-1:0] I,
output loadRegA, 
       loadRegD,
		 selM, selA,
		 AMplus1, setOperandDTo1, memread,
		 izx, inx, izy, iny, inf, inno, 
		 jgt, jge, jlt, jne, jle, jmp, jeq, writeM);

// Instructions fields
wire c1, c2, c3, c4, c5, c6;
wire d1, d2, d3;
wire j1, j2, j3;
wire a;

// Operations
wire const0, const1, constNeg1, D, A, notD, notA, negD, negA;
wire Dplus1, Aplus1, Dminus1, Aminus1, DplusA, DminusA, AminusD, DandA, DorA;
// Operations (Memory)
wire M, notM, negM, Mplus1, Mminus1, DplusM, DminusM, MminusD, DandM, DorM;
// Destinations
wire dnull, dM, dD, dMD, dA, dAM, dAD, dAMD;


// Assign mnemonics to the instruction fields
assign a = I[12];
assign c1 = I[11];
assign c2 = I[10];
assign c3 = I[9];
assign c4 = I[8];
assign c5 = I[7];
assign c6 = I[6];
assign d1 = I[5];
assign d2 = I[4];
assign d3 = I[3];
assign j1 = I[2];
assign j2 = I[1];
assign j3 = I[0];

assign selA = I[IL-1];
assign memread = a & selA;

wire row0, row1, row2, row3, row4, row5, row6, row7, 
	 row8, row9, row10, row11, row12, row13, row14, 
	 row15, row16, row17;

 /* Decode data */
 /*1,0,1,0,1,0*/ assign row0 =  c1 & !c2 & c3 & !c4 & c5 & !c6; 
 /*1,1,1,1,1,1*/ assign row1 =  c1 & c2 & c3 & c4 & c5 & c6;
 /*1,1,1,0,1,0*/ assign row2 =  c1 & c2 & c3 & !c4 & c5 & !c6; 
 /*0,0,1,1,0,0*/ assign row3 =  !c1 & !c2 & c3 & c4 & !c5 & !c6;
 /*1,1,0,0,0,0*/ assign row4 =  c1 & c2 & !c3 & !c4 & !c5 & !c6;
 /*0,0,1,1,0,1*/ assign row5 =  !c1 & !c2 & c3 & c4 & !c5 & c6; 
 /*1,1,0,0,0,1*/ assign row6 =  c1 & c2 & !c3 & !c4 & !c5 & c6; 
 /*0,0,1,1,1,1*/ assign row7 =  !c1 & !c2 & c3 & c4 & c5 & c6;
 /*1,1,0,0,1,1*/ assign row8 =  c1 & c2 & !c3 & !c4 & c5 & c6;
 /*0,1,1,1,1,1*/ assign row9 =   !c1 & c2 & c3 & c4 & c5 & c6;
 /*1,1,0,1,1,1*/ assign row10 =  c1 & c2 & !c3 & c4 & c5 & c6;
 /*0,0,1,1,1,0*/ assign row11 =  !c1 & !c2 & c3 & c4 & c5 & !c6;
 /*1,1,0,0,1,0*/ assign row12 =  c1 & c1 & !c3 & !c4 & c5 & !c6;
 /*0,0,0,0,1,0*/ assign row13 =  !c1 & !c2 & !c3 & !c4 & c5 & !c6;
 /*0,1,0,0,1,1*/ assign row14 =  !c1 & c2 & !c3 & !c4 & c5 & c6;
 /*0,0,0,1,1,1*/ assign row15 =  !c1 & !c2 & !c3 & c4 & c5 & c6;
 /*0,0,0,0,0,0*/ assign row16 =  !c1 & !c2 & !c3 & !c4 & !c5 & !c6;
 /*0,1,0,1,0,1*/ assign row17 = !c1 & c2 & !c3 & c4 & !c5 & c6;
 
 
assign const0 = selA & row0 & !a;
assign const1 = selA &row1 & !a;
assign constNeg1 = selA &row2 & !a;
assign D = selA &row3 & !a;
assign A = selA &row4 & !a;
assign notD = selA &row5 & !a;
assign notA = selA &row6 & !a;
assign negD = selA &row7 & !a;
assign negA = selA &row8 & !a;
assign Dplus1 = selA &row9 & !a;
assign Aplus1 = selA &row10 & !a;
assign Dminus1 = selA &row11 & !a;
assign Aminus1 = selA &row12 & !a;
assign DplusA = selA &row13 & !a;
assign DminusA = selA &row14 & !a;
assign AminusD = selA &row15 & !a;
assign DandA = selA &row16 & !a;
assign DorA = selA &row17 & !a;
 
assign M = selA & row4 & a;
assign notM = selA & row6 & a;
assign negM = selA & row8 & a;
assign Mplus1 = selA & row10 & a;
assign Mminus1 = selA & row12 & a;
assign DplusM = selA & row13 & a;
assign DminusM = selA & row14 & a;
assign MminusD = selA & row15 & a;
assign DandM = selA & row16 & a;
assign DorM = selA & row17 & a;
 
 // Decode destination
assign dnull = selA & !d1 & !d2 & !d3;
assign dM = selA & !d1 & !d2 & d3;
assign dD = selA & !d1 & d2 & !d3;
assign dMD = selA & !d1 & d2 & d3;
assign dA = selA & d1 & !d2 & !d3;
assign dAM = selA & d1 & !d2 & d3;
assign dAD = selA & d1 & d2 & !d3;
assign dAMD = selA & d1 & d2 & d3;
	 
// Decode jump
//assign jnull = selA & !j1 & !j2 & !j3;
assign jgt = selA & !j1 & !j2 & j3;
assign jeq = selA & !j1 & j2 & !j3;
assign jge = selA & !j1 & j2 & j3;
assign jlt = selA & j1 & !j2 & !j3;
assign jne = selA & j1 & !j2 & j3;
assign jle = selA & j1 & j2 & !j3;
assign jmp = selA & j1 & j2 & j3;
 
// Flip-flop control signals
assign loadRegA = dA | dAM | dAD | dAMD | !selA;
assign loadRegD = dD | dMD | dAD | dAMD;
 
// Muxes constrol signals
assign selM = M | MminusD | Mplus1 | Mminus1 | DminusM | DplusM | DandM | DorM | notM | negM;
assign AMplus1 = Aplus1 | Mplus1;
assign setOperandDTo1 = const1 | Dplus1;

// Subtraction (x-y)
// x_1 = -x -1 -- one's complement
// x_2 = -x -- two's complement
// x - y = (x_1 +y)_1 = (-x -1 + y)_1 = -(-x-1+y) -1 = x+1-y -1 = x-y
// for negK simply set x->0 and y->K
 
// ALU control signals
assign izx = const0 | const1 | Aminus1 | negA | A | M | Mminus1 | negM | constNeg1 | notM;
assign inx = constNeg1 | Aminus1 | Mminus1 | DminusM | DorM | DminusA | DorA | notD | negA | negM;
assign izy = const0 | negD | D | Dminus1 | constNeg1 | notD;
assign iny = AminusD | MminusD | DorA | DorM | notA | notM | negD | Dminus1;
assign inf = negM | notM | AminusD | D | const1 | constNeg1 | Dplus1 | Aplus1 | Aminus1 | Mplus1 | DplusA | DplusM | Dminus1 | DminusA | DminusM | MminusD | negD | notD | negA | A | M | Mminus1;
assign inno = DminusA | DminusM | AminusD | MminusD | DorA | DorM | negD | negA | negM; 

// Should we enable write?	
assign writeM = dM | dMD | dAM | dAMD;

endmodule
