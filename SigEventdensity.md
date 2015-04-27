# sig.eventdensity: Average frequency of note events #

Estimates the average frequency of events, i.e., the number of note onsets per second.

## Frame decomposition ##
`sig.rms(…,'Frame',…)` performs first a frame decomposition, with by default a frame length of 10 s and no overlapping. For the specification of other frame configuration using additional parameters, cf. the previous SigFrame vs. 'Frame' section.