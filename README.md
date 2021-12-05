# Norns Recording #30

This recording, which is currently nameless, was written as a norns script. Norns is set up to send midi to Digitone (bass and pad sounds), Digitakt (bass drum and cymbals - samples by BlankFor.ms) and Analog Four (lead). An additional voice is played by the tombola sequncer on the OP-1 playing a stock piano sample.

I used Digitone as the master clock, but everything else is controlled by calling functions in the norns script to play each part of the song.

The scripts use some libs that I wrote myself, but rely alot on sequins and lattice. Vox is something I have gravitated towards as a simple way of playing notes based on the index of a scale table (e.g. the first index corresponds to the tonic, the fifth index corresponds to the fifth degree of the scale, etc). Seq is a wrapper for sequins which allows some additional functionality that I have found useful. There is also a hacked version of sequins, the additional features of which I don't really use in this particular script. There are some comments in those lib files explaining what they do.

The Digitone, Digitakt, Analog Four and OP-1 all go through a mixer. There are some effects (Timeline and Big Sky). There is also a tape delay using an FX send from my mixer to a Marantz PMD-222, which is then filtered using a high pass and low pass Jove filters. The tape loop I used is quite old and rather noisy. Oto Boum comes at the end of the chain and I recorded it as a stereo track to the norns tape.

I hope to explore this way of writing music a bit more. While this track is quite simple (especially the chords), I really like the the bass and lead lines.