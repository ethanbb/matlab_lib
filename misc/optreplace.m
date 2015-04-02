function opt = optreplace(opt,varargin)
% optreplace
% 
% Description:	replace options in a varargin cell or opt struct
% 
% Syntax:	opt = optreplace(opt[,opt1,opt1def,...,optM,optMdef])
% 
% In:
% 	opt			- a parse opt struct or a varargin cell
% 	[optJ]		- the name of the Jth option to replace
% 	[optJdef]	- the default value of the Jth option
% 
% Out:
% 	opt	- the updated opt struct/varargin cell
% 
% Updated: 2015-03-19
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cKey	= varargin(1:2:end);
cVal	= varargin(2:2:end);
nKey	= numel(cKey);

switch class(opt)
	case 'cell'
		%existing options
			cKeyOld	= reshape(opt(1:2:end),1,[]);
			cValOld	= reshape(opt(2:2:end),1,[]);
		
		%which of the new options already exist?
			[bExist,kExist]	= ismember(cKey,cKeyOld);
		
		%options that don't already exist
			cKeyNew	= reshape(cKey(~bExist),1,[]);
			cValNew	= reshape(cVal(~bExist),1,[]);
		
		%replace existing options
			cValExist	= cVal(bExist);
			kExist		= kExist(bExist);
			nExist		= numel(kExist);
			for kE=1:nExist
				cValOld{kExist(kE)}	= cValExist{kExist(kE)};
			end
		
		cSize	= switch2(size(opt,1),1,{1,[]},{[],1});
		opt		= reshape([cKeyOld cKeyNew; cValOld cValNew],cSize{:});
	case 'struct'
		for kK=1:nKey
			strKey			= cKey{kK};
			opt.(strKey)	= cVal{kK};
		end
		
		opt	= optstruct(opt);
	otherwise
		error('Invalid opt argument');
end
