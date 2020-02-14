(
    Pdef(\1,
        Pbind(
            \type, \dirt,
            \s, \mmd,
            \n, Pshuf((0..23),inf),
            \dur, Pwrand([1/12,1/3],[9,1].normalizeSum,inf),
            \release, Pseq([1/16,1/17,1/19,1/20,1/21,1/22,1/8],inf),
            \gain, Pexprand(1/2,4.0),
            \pan, Pwhite(0.0,1.0),
            \cutoff, Pwrand([625,1250,2500,5000,10000,20000],(1..6).normalizeSum,inf),
            \speed, Pwrand([1/64,1/32,1/16,1/8,1/4,1/2,1,2,4,8,16,32,64],[1,2,4,8,16,32,64,32,16,8,4,2,1].normalizeSum,inf),
            \shape, Pstutter(Pexprand(1,99),Pexprand(0.1,0.99),inf), 
            \delay, Pbrown(0.0,1/64,Prand([0.001,0.01],inf),inf),
            \delayfeedback, 0.94,
            \delaytime, 1/2 / Pstutter(Pwrand([1,2,3],[256,16,1].normalizeSum,inf),Pbrown(1,199,Prand((1..19),inf),inf)),
            \room, Pwrand([0,0.05],[199,1].normalizeSum,inf),
            \size, 0.995,
        )
    ).play(quant:1);
)
