# SuperClean
a shameless ripOff / fork of / homage to SuperDirt

`Quarks.install("https://github.com/danielmkarlsson/SuperClean.git");`

```text
(
    Pdef(\0,
        Pseed(Pn(9159,1),
            Psync(
                Pbind(*[
                    type: \dirt,
                    s: \mmd,
                    n: Pwhite(0,23),
                    dur: Pwrand([1/12,1/3],[9,1].normalizeSum,inf),
                    release: Pstutter(Pwhite(1,8),Pseq([1/(16..22),1/8,2],inf)),
                    gain: Pexprand(1.0,4.0),
                    pan: Pstutter(Pwhite(0,28),Pwrand([Pwhite(0.0,0.333),Pwhite(0.666,1.0)],[1,1.5].normalizeSum,inf)),
                    cutoff: Pwrand([625,1250,2500,5000,10000,20000],(1..6).normalizeSum,inf),
                    speed: Pwrand([1/64,1/32,1/16,1/8,1/4,1/2,1,2,4,8,16,32,64],[1,2,4,8,16,32,64,32,16,8,4,2,1].normalizeSum,inf),
                    shape: Pstutter(Pexprand(1,99),Pexprand(0.01,0.9),inf), 
                    delay: 0.01,
                    delayfeedback: 0.9,
                    delaytime: 1/2 / Pstutter(Pwrand([1,2,3],[256,16,1].normalizeSum,inf),Pbrown(1,199,Prand((1..19),inf),inf)),
                    room: Pwrand([0,0.05],[9,1].normalizeSum,inf),
                    size: 0.97,
                    dry: Pstutter(Pwhite(1,9),Pwrand([0,1],[2,1].normalizeSum,inf)),
                ]),1,16,
            )
        )
    ).play(quant:1);
)

(
    Pdef(\1,
        Pbind(*[
        type: \dirt,
        s: \mmd,
        reps: Pexprand(6,66),
        n: Pstutter(Pkey(\reps),Pwhite(0,12)),
        release: Pstutter(Pkey(\reps),Pexprand(0.1,1.1)),
        gain: Pstutter(Pkey(\reps),Pwhite(0.5,4.0)),
        speed: Pstutter(Pkey(\reps),Pexprand(1/2,512.0)),
        pan: Pstutter(Pkey(\reps),Pwhite(0.0,1.0)),
        dur: Pstutter(Pkey(\reps),Pwhite(0.001,0.1)),
        begin: Pstutter(Pkey(\reps),Pexprand(0.001,0.2)),
        end: Pstutter(Pkey(\reps),Pexprand(0.19,0.6)),
        loop: Pstutter(Pkey(\reps),Pwhite(1,20)),
        stretch: (Pstutter(Pkey(\reps),Pwhite(1,9))/6).trace,
        accelerate: Pstutter(Pkey(\reps),Pwhite(-8.0,8.0)),
        shape: Pstutter(Pkey(\reps),Pwhite(0.9,0.999999)),
        cut: Pwrand([0,1],[8,1].normalizeSum,inf),
        ])
    ).play(quant:1);
)

(
    Pdef(\2,
        Pbind(*[
        type: \dirt,
        s: \mmd,
        n: 9,
        dur: Pstutter(Pwhite(3,33),Pexprand(0.125,0.666)),
        attack: (Pkey(\dur)/3),
        hold: (Pkey(\dur)/3),
        release: (Pkey(\dur)/3),
        speed: (Pkey(\dur)*Pstutter(Pwhite(13,133),Pwhite(0.333,33.333))),
        cut: 1,
        delay: 1/256,
        delaytime: 1/1024 / Pstutter(Pexprand(1,3),Pkey(\dur)*Pwhite(0.0,2.0)),
        delayfeedback: 0.94,
        stretch: Pstutter(Pwhite(3,33),Pexprand(0.125,1.0)),
        bandf: Pexprand(20,20000),
        pan: Pwhite(0,1),
        gain: 16,
        room: 1,
        size: 0.0,
        dry: 0.999,
        ])
    ).play(quant:1);
)
```
