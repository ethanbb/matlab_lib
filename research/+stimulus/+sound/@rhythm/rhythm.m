classdef rhythm < stimulus.sound.base
% stimulus.sound.rhythm
% 
% Description:	generate rhythm sequence stimuli
% 
% Syntax: obj = stimulus.sound.rhythm([param1,val1,...,paramN,valN])
% 
% Methods:
%	generate:	generate a stimulus
%	validate:	validate a set of parameter values
% 
% Properties:
%	param:	a property collection of parameters that the generator function will
%			use to generate the stimulus. includes:
%				n: (5) the number of tones in the sequence
%				instrument: ('sin') the name of an instrument function to use,
%					or a sound sample, or a cell array of such to choose from
%					multiple instruments for each beat of the rhythm sequence.
%					each function should accept a t parameter and return a
%					periodic value with period 2*pi. note that each item should
%					be the string name of the function, rather than a function
%					handle.
%				f: (400) for instrument functions, the frequency of the beat,
%					in Hz
%				pattern: ('random') the type of rhythm pattern to use:
%					'random': a randomly spaced sequence of beats
%					'uniform': a uniformly spaced sequence of beats
%				t: (<from pattern>) an array specifying the time at which each
%					beat should occur. overrides <pattern>.
%				sequence: (<random>) an array specifying the index of the
%					instrument to play each beat
%			<see also stimulus.sound.base>
% 
% In:
%	[paramK]	- the Kth parameter whose value should be set explicitly
%	[valK]		- the explicit value of parameter paramK (or empty to skip
%				  skip setting the value)
% 
% Updated:	2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = rhythm(varargin)
				obj = obj@stimulus.sound.base();
				
				%set some parameter defaults
					add(obj.param,'n','generic',{5});
					add(obj.param,'instrument','generic',{{'sin'}});
					add(obj.param,'f','generic',{400});
					add(obj.param,'pattern','generic',{'random'});
					add(obj.param,'t','generic',{@() obj.choose_t(obj.param.n,obj.param.dur,obj.param.pattern)});
					add(obj.param,'sequence','generic',{@() randFrom(1:numel(ForceCell(obj.param.instrument)),[obj.param.n 1],'unique',false,'seed',false)});
				
				%parse the inputs
					obj.parseInputs(varargin{:})
			end
		end
	
	%PRIVATE
		methods (Access=protected)
			[stim,ifo] = generate_sound(obj,ifo)
		end
%/METHODS-----------------------------------------------------------------------

end
