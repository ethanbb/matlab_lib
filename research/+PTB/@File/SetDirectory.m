function SetDirectory(f,strName,strDir,varargin)
% PTB.File.SetDirectory
% 
% Description:	set the path to a named directory
% 
% Syntax:	f.SetDirectory(strName,strDir,<options>)
% 
% In:
% 	strName	- the directory name (e.g. 'base'), must be field name compatible
%	strDir	- the path to the directory
%	<options>: (see PTB.Info.Set)
% 
% Updated: 2011-12-10
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
f.parent.Info.Set('file',{'directory',strName},strDir,varargin{:});
