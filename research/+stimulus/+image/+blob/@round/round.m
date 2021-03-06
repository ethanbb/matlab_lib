classdef round < stimulus.image.blob
% stimulus.image.blob.round
% 
% Description:	create a round blobbish figure
% 
% Syntax: obj = stimulus.image.blob.round([param1,val1,...,paramN,valN])
% 
% Methods:
%	generate:	generate a stimulus
%	validate:	validate a set of parameter values
% 
% Properties:
%	param:	a property collection of parameters that the generator function will
%			use to generate the stimulus. includes:
%				interp: ('pchip') the interpolation method, either 'pchip',
%					'linear', or 'spline' (which sucks)
%				interp_space: ('polar') the space in which interpolation takes
%					place, either 'polar' or 'cartesian'
%			<see also stimulus.image.blob>
% 
% In:
%	[paramK]	- the Kth parameter whose value should be set explicitly
%	[valK]		- the explicit value of parameter paramK (or empty to skip
%				  skip setting the value)
% 
% Updated:	2015-10-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%METHODS------------------------------------------------------------------------
	%CONSTRUCTOR
		methods (Access=public)
			function obj = round(varargin)
				obj = obj@stimulus.image.blob();
				
				%set some parameter defaults
					add(obj.param,'interp','generic',{'pchip'});
					add(obj.param,'interp_space','generic',{'polar'});
				
				%parse the inputs
					obj.parseInputs(varargin{:});
			end
		end
%/METHODS-----------------------------------------------------------------------

end
