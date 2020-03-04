
# SuperClean
SuperCollider implementation of the Clean sampler for use inside of SuperCollider itself.

Alex McLean and Julian Rohrhuber built the thing initially, then I changed a few little things here and there.
Scott Cazan did _all_ of the heavy lifting

## Requirements

* SuperCollider >= v3.7
* Mos def you should get: sc3-plugins: https://github.com/supercollider/sc3-plugins/
* git

## Lean is good

I only included a tiny amount of samples inside the clean-samples folder. That's the main thing. I did that because that's a
lot of data to have to download if you're sharing a very slow wifi connection with 20 other kids who are also trying to get 
sat up at the same time.
There's a way to hot swap in samples as needed:

```
~clean.loadSoundFiles("~/Downloads/mmd*");
```

Get your own samples in there! That's what I think everyone should do. That way you'll make this thing your own and in no time
you'll be making your own kind of weird music.


## Installation 

Run this line in SuperCollider:  
`Quarks.install("https://github.com/danielmkarlsson/SuperClean.git");`

If you don't have git, then go ahead and get git, when you hopefully get asked to get git, as a consequence of running that
line. Git is good to have. It let's us have version control and install all kinds of neat stuff.

## Modify all of the things!!!11

Now I might not be the bestest gunSlinger there is round these here parts, but I was able to get this thing corralled, albeit
awkwardly, so just goes to show, you can too!
