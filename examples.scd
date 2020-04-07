// mmd example
(
    Pdef(\0,
        Pseed(Pn(999,1),
            Psync(
                Pbind(*[
                    type: \clean,
                    s: \mmd,
                    n: Pwhite(0,23),
                    dur: Pwrand([1/12,1/3],[9,1].normalizeSum,inf),
                    rel: Pstutter(Pwhite(1,8),Pseq([1/16,1/17,1/18,1/19,1/20,1/21,1/22,1/8,2],inf))*Pexprand(0.1,10.0),
                    gain: Pexprand(1.0,8.0),
                    pan: Pstutter(Pwhite(0,28),Pwrand([Pwhite(0.0,0.333),Pwhite(0.666,1.0)],[1,1.5].normalizeSum,inf)),
                    lpf: Pwrand([625,1250,2500,5000,10000,20000],(1..6).normalizeSum,inf),
                    speed: Pwrand([1/64,1/32,1/16,1/8,1/4,1/2,1,2,4,8,16,32,64],[1,2,4,8,16,32,64,32,16,8,4,2,1].normalizeSum,inf),
                    shp: Pwhite(0.0,0.999).trace,
                    dla: 0.001,
                    dlf: 0.94,
                    dlt: 1/2 / Pstutter(Pwrand([1,2,3],[256,16,1].normalizeSum,inf),Pbrown(1,199,Prand((1..19),inf),inf)),
                    room: Pwrand([0,0.05],[9,1].normalizeSum,inf),
                    size: 0.97,
                    dry: Pstutter(Pwhite(1,9),Pwrand([0.25,1],[3,1].normalizeSum,inf)),
                    hpf: 40,
                ]),1,15,
            )
        )
    ).play(quant:1);
);

// fmx example
(
Pdef(\0,
    Pseed(99,
    Pbind(*[
        type: \clean,
        s: \fmx,
        rps: Pwhite(1,99),
        hr1: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((1..4),inf)),
        hr2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((1..4),inf)),
        hr3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((1..4),inf)),
        hr4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((1..4),inf)),
        mi2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((1.0..4.0),inf)),
        mi3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((1.0..4.0),inf)),
        mi4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((1.0..4.0),inf)),
        fdb: Pexprand(0.01,100.0),
        amp: Pexprand(0.1,8.0),
        en1: Pstutter(Pkey(\rps)+Pwhite(0,7),Pexprand(0.0001,1.1)),
        en2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pexprand(0.0001,2.1)),
        en3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pkey(\en2)/Pexprand(0.0001,3.1)),
        en4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pkey(\en2)/Pkey(\en3)*Pexprand(0.0001,4.1)),
        hl1: Pexprand(0025,1.125),
        hl2: Pexprand(0.025,1.125),
        hl3: Pexprand(0.025,1.125),
        hl4: Pexprand(0.025,1.125),
        cu1: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.0,4.0)),
        cu2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.0,4.0)),
        cu3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.0,4.0)),
        cu4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.0,4.0)),
        dur: Pstutter(Pkey(\rps)+Pwhite(2,9),1.25/Pbrown(3,17,Pwhite(1,3),inf)),
        legato: Pexprand(7.5,90.0),
        freq: Pstutter(Pwhite(8,16),Prand((10,20..40),inf))*Pwhite(1,5)*Pstutter(Pkey(\rps),Pwhite(1,5)),
        hpf: Pexprand(20,20000),
        lpf: Pkey(\freq).linlin(10,1600,20000,100,\minmax).trace,
        room: Pseg(Pexprand(0.9,1),Pexprand(2.0,16.0),\welch,inf),
        size: Pseg(Pexprand(0.9,1),Pexprand(2.0,16.0),\welch,inf),
        dry: Pseg(Pexprand(0.1,1),Pexprand(2.0,32.0),\welch,inf).linlin(0.1,1,1,0,\minmax),
    ]);
)
).play;
);

// uio example
(
    Pdef(\0,
        Pbind(*[
            type: \clean,
            s: \uio,
            gain: Pexprand(1/4,4.0),
            freq: Pfunc{
                var x = 160 * rrand(1,500).geom(1,30/29);
                x.reject{|i| i > 20000 }
            },
            dur: Pstutter(Pexprand(1,5).asInteger,Pexprand(1,3).asInteger/Pexprand(5,29).asInteger),
            attack: Pexprand(0.0001,1.1),
            release: Pkey(\dur)-(Pexprand(0.000001,0.1)),
            hpf: Pexprand(20,10000),
            curve: Pexprand(-16.0,-4),
        ])
    ).play(quant: 1);
)
