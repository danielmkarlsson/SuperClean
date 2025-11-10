(
Pdef(0,
    Pseed(9990,
        Pbind(*[
            type: Pwrand2([\cln, \], [1, 3], inf),
            snd: Prand([\fm1, \fm5, \fm6, \fm7, \fm8, \fm9, \fma, \fmb, \fmc], inf), 
            sustain: Pexprand(0.2, 8.0),
            dur: (1 / Pwhite(0.075, 111)).trace,
            freq: Pdup(Pexprand(11, 22), Pexprand(64, 640)).round(32) 
                + Pdup(Pexprand(11, 22), Pwrand2([-32, 0, 32], [1, 20, 1], inf))
                * Pmeanrand(0.9999, 1.0001),
            amp: Plprand(0.3, 0.6) / Pkey(\freq).linlin(32, 672, 1.0, 1.2),
            pan: Pseq([Plprand(0.0, 0.5, 1), Phprand(0.5, 1.0, 1)], inf),
            jpr: 1/2,
            jpg: Pseg(Pwhite(0.5, 2.0), 10, \lin, inf),
            jps: Pseg(Pbrown(0.3, 1.0, Pexprand(0.01, 0.1)), 20, \lin, inf),
            hr1: Pwhite(1, 4),
            hr2: Pwhite(1, 4),
            hr3: Pwhite(1, 4),
            hr4: Pwhite(1, 4),
            hr5: Pwhite(1, 4),
            hr6: Pwhite(1, 4),
            mi1: Pexprand(0.00001, 4.0),
            mi2: Pexprand(0.00001, 4.0),
            mi3: Pexprand(0.00001, 4.0),
            mi4: Pexprand(0.00001, 4.0),
            mi5: Pexprand(0.00001, 4.0),
            mi6: Pexprand(0.00001, 4.0),
            en1: Pexprand(0.001, 1.0),
            en2: Pexprand(0.001, 1.0),
            en3: Pexprand(0.001, 1.0),
            en4: Pexprand(0.001, 1.0),
            en5: Pexprand(0.001, 1.0),
            en6: Pexprand(0.001, 1.0),
            cu1: Pexprand(0.001, 1.0),
            cu2: Pmeanrand(-4.0, 4.0),
            cu3: Pmeanrand(-4.0, 4.0),
            cu4: Pmeanrand(-4.0, 4.0),
            cu5: Pmeanrand(-4.0, 4.0),
            cu6: Pmeanrand(-4.0, 4.0),
        ])
    )
).play
)
