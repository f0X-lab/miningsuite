# Guided Tour: Symbolic music analysis #

This is a part of the MiningSuite GuidedTour.

"Symbolic" music analysis here means the analysis of either MIDI files or text representations of scores.

## Representing scores ##

Load and display a MIDI file:
```
mus.score('laksin.mid')
```

Load only the first ten notes of the MIDI file:
```
mus.score('laksin.mid','Notes',1:10)
```

Load only the first five seconds of the MIDI file.
```
mus.score('laksin.mid','EndTime',5)
```

Try with other MIDI files.

## Pitch spelling ##

Find the diatonic pitch representation (for each note: its letter and accident) corresponding to the MIDI sequence:
```
mus.score('laksin.mid','Spell')
```

Try with other MIDI files.

## Local grouping ##

Local grouping based on temporal proximity, shown in blue rectangles:
```
mus.score('laksin.mid','Spell','Group')
```

cf. MusGroup for more information.

Try with other MIDI files such as _auclair.mid_ and _mozart.mid_.

## Ornamentation Reduction ##

Show broderies (in red rectangles) and passing notes (in grey):
```
mus.score('laksin.mid','Spell','Group','Broderie','Passing')
```

cf. MusGroup for more information.

Try with other MIDI files such as _auclair.mid_ and _mozart.mid_.

## Motivic analysis ##

Find the repeated motifs in the MIDI file _auclair.mid_:
```
mus.score('auclair.mid','Motif')
```

cf. MusMotif for more information.

In the previous example, the motivic analysis is carried out only on pitch and pitch intervals. Add rhythm:
```
mus.score('auclair.mid','Motif','Onset')
```

Do the same with the MIDI file _mozart.mid_:
```
mus.score('mozart.mid','Motif')
```

So far, the pitch analysis is made only on the chromatic MIDI pitch information. To add diatonic information, we need to add the pitch spelling:
```
mus.score('mozart.mid','Motif','Spell')
```

The local grouping can be used to construct the syntagmatic network, and find ornamented motifs:
```
mus.score('mozart.mid','Motif','Spell','Group')
```

## To be continued... ##

You can go back to the MiningSuite GuidedTour.