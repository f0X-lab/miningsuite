function varargout = sequence(varargin)


varargout = sig.operate('seq','sequence',seq.Sequence.sequenceoptions,...
                                         seq.Sequence.initmethod,...
                                         seq.Sequence.mainmethod,...
                                         varargin);