# sig.segment: Segmentation #

  * A signal _a_ can be segmented manually, based on temporal position directly given by the user, in the form:
```
sg=sig.segment(a,v)
```
where _v_ is an array of numbers corresponding to time positions in seconds.

  * A signal _a_ can be segmented using the output _p_ of a peak picking from data resulting from a itself, using the following syntax:
```
sg=sig.segment(a,p)
```

If _p_ is a frame-decomposed scalar curve, the audio waveform _a_ will be segmented at the middle of each frame containing a peak.