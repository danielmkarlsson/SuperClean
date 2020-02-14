
# SuperClean
SuperCollider implementation of the Dirt sampler for use inside of SuperCollider itself.

Alex McLean and Julian Rohrhuber built the thing initially, then I changed a few little things here and there.

## Requirements

* SuperCollider >= v3.7
* Mos def you should get: sc3-plugins: https://github.com/supercollider/sc3-plugins/
* git

Note that you'll have to create the folder `dirt-samples` yourself.   
You might be expecting that.  
Do you really need that tho?   
There's another way to hot swap in samples as needed:

```
~dirt.loadSoundFiles("~/Downloads/mmd*");
```

## The big change

I commented out the part where the dirt-samples folder gets added. That's the main thing. I did that because that's a lot of data to have to download if you're sharing a very slow wifi connection with 20 other kids who are also trying to get sat up at the same time.

## Installation 

Run this line in SuperCollider:  
`Quarks.install("https://github.com/danielmkarlsson/SuperClean.git");`

If you don't have git, then go ahead and get git, when you hopefully get asked to get git, as a consequence of running that line.

## Modify all of the things!!!11

Now I might not be the bestest gunSlinger there is round these here parts, but I was able to get this thing corralled, albeit awkwardly, so just goes to show, you can too!
