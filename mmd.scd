(
    Pdef(\1,
        Pseed(Pn(9159,1),
            Psync(
                Pbind(
                    \type, \dirt,
                    \s, \mmd,
                    \n, Pwhite(0,23),
                    \dur, Pwrand([1/12,1/3],[9,1].normalizeSum,inf),
                    \release, Pstutter(Pwhite(1,8),Pseq([1/(16..22),1/8,2],inf)),
                    \gain, Pexprand(1.0,4.0),
                    \pan, Pstutter(Pwhite(0,28),Pwrand([Pwhite(0.0,0.333),Pwhite(0.666,1.0)],[1,1.5].normalizeSum,inf)),
                    \cutoff, Pwrand([625,1250,2500,5000,10000,20000],(1..6).normalizeSum,inf),
                    \speed, Pwrand([1/64,1/32,1/16,1/8,1/4,1/2,1,2,4,8,16,32,64],[1,2,4,8,16,32,64,32,16,8,4,2,1].normalizeSum,inf),
                    \shape, Pstutter(Pexprand(1,99),Pexprand(0.01,0.9),inf), 
                    \delay, 0.01,
                    \delayfeedback, 0.9,
                    \delaytime, 1/2 / Pstutter(Pwrand([1,2,3],[256,16,1].normalizeSum,inf),Pbrown(1,199,Prand((1..19),inf),inf)),
                    \room, Pwrand([0,0.05],[9,1].normalizeSum,inf),
                    \size, 0.97,
                    \dry, Pstutter(Pwhite(1,9),Pwrand([0,1],[2,1].normalizeSum,inf)),
                ),1,16,
            )
        )
    ).play(quant:1);
)
