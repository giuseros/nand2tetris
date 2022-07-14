module Decoder(
input[15:0] I,
output loadRegA, 
       loadRegD,
		 selM, selA,
		 AMplus1, const1OrDplus1, memread,
		 izx, inx, izy, iny, inf, inno, 
		 jgt, jge, jlt, jne, jle, jmp, jeq, writeM);

wire c1, c2, c3, c4, c5, c6;
wire d1, d2, d3;
wire j1, j2, j3;
wire a;

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

assign memread = a;

assign selA = I[15];

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
	 
	 
	assign const0 = row0 & !a;
	assign const1 = row1 & !a;
	assign constNeg1 = row2 & !a;
	assign D = row3 & !a;
	assign A = row4 & !a;
	assign notD = row5 & !a;
	assign notA = row6 & !a;
	assign negD = row7 & !a;
	assign negA = row8 & !a;
	assign Dplus1 = row9 & !a;
	assign Aplus1 = row10 & !a;
	assign Dminus1 = row11 & !a;
	assign Aminus1 = row12 & !a;
	assign DplusA = row13 & !a;
	assign DminusA = row14 & !a;
	assign AminusD = row15 & !a;
	assign DandA = row16 & !a;
	assign DorA = row17 & !a;
	 
	assign M = I[15] & row4 & a;
	assign notM = I[15] & row6 & a;
	assign negM = I[15] & row8 & a;
	assign Mplus1 = I[15] & row10 & a;
	assign Mminus1 = I[15] & row12 & a;
	assign DplusM = I[15] & row13 & a;
	assign DminusM = I[15] & row14 & a;
	assign MminusD = I[15] & row15 & a;
	assign DandM = I[15] & row16 & a;
	assign DorM = I[15] & row17 & a;
	 
	 // Decode destination
	assign dnull = I[15] & !d1 & !d2 & !d3;
	assign dM = I[15] & !d1 & !d2 & d3;
	assign dD = I[15] & !d1 & d2 & !d3;
	assign dMD = I[15] & !d1 & d2 & d3;
	assign dA = I[15] & d1 & !d2 & !d3;
	assign dAM = I[15] & d1 & !d2 & d3;
	assign dAD = I[15] & d1 & d2 & !d3;
	assign dAMD = I[15] & d1 & d2 & d3;
		 
	 // Decode jump
	//assign jnull = I[15] & !j1 & !j2 & !j3;
	assign jgt = I[15] & !j1 & !j2 & j3;
	assign jeq = I[15] & !j1 & j2 & !j3;
	assign jge = I[15] & !j1 & j2 & j3;
	assign jlt = I[15] & j1 & !j2 & !j3;
	assign jne = I[15] & j1 & !j2 & j3;
	assign jle = I[15] & j1 & j2 & !j3;
	assign jmp = I[15] & j1 & j2 & j3;
	 
	 // Flip-flop control signals
	assign loadRegA = dA | dAM | dAD | dAMD | !I[15];
	assign loadRegD = dD | dMD | dAD | dAMD;
	 
	 // Muxes constrol signals
	assign selM = M | MminusD | Mplus1 | Mminus1 | DminusM | DplusM | DandM | DorM | notM | negM;
	assign AMplus1 = Aplus1 | Mplus1;
	assign const1OrDplus1 = const1 | Dplus1;
	 
	 // ALU control signals
	assign izx = const0 | const1 | Aminus1 | negA | A | M | Mminus1 | negM | constNeg1;
	assign inx = constNeg1 | Aminus1 | Mminus1 | DminusM | DorM | DminusA | DorA | notD | negA;
	assign izy = const0 | negD | D | Dminus1 | constNeg1;
	assign iny = AminusD | MminusD | DorA | DorM | notA | notM | negD | Dminus1;
	assign inf = D | const1 | constNeg1 | Dplus1 | Aplus1 | Mplus1 | DplusA | DplusM | Dminus1 | DminusA | DminusM | MminusD | negD | A | M | Mminus1;
	assign inno = DminusA | DminusM | AminusD | MminusD | DorA | DorM | negD | negA | negM; 
	
   // Should we enable write?	
	assign writeM = dM | dMD | dAM | dAMD;

endmodule
