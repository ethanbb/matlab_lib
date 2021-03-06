function Open(lg,varargin)
% PTB.Log.Open
% 
% Description:	start the log file
% 
% Syntax:	lg.Open([strPathLog]=<auto>,<options>)
% 
% In:
% 	[strPathLog]	- the path to the log file
%	<options>:
%		append:	(true) true to append, false to overwrite existing log files
% 
% Updated: 2011-12-17
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[strPathLog,opt]	= ParseArgs(varargin,[],...
						'append'	, true	  ...
						);

%get the log file path
	if isempty(strPathLog)
		strDir	= 'data';
		
		strCode	= lg.parent.Subject.Get('code');
		
		if isempty(strCode)
			strCode	= 'experiment_log';
		end
		
		strName	= [strCode '.log'];
	else
		strDir	= PathGetDirectory(strPathLog);
		strName	= PathGetFileName(strPathLog);
	end
	
	lg.parent.File.SetDirectory('log',strDir,'replace',false);
	lg.parent.File.Set('log','log',strName,'replace',false);
	
	strPathLog	= lg.parent.File.Get('log');
	bExists		= FileExists(strPathLog);

%delete the log if we're overwriting
	if ~opt.append && bExists
		delete(strPathLog);
	end
%load the existing log or create a new one
	cFieldGood	= {'time','type','info'};
	
	bBlank	= false;
	if bExists
		try
			evt			= table2struct(lg.parent.File.Read('log'));
		catch me
		%hmm
			evt	= [];
		end
		
		if isempty(evt)
		%nothing
			bBlank	= true;
		else
			if ~all(isfield(evt,cFieldGood))
			%we don't have all the needed fields
				bBlank	= true;
			else
			%we got something
				cField	= fieldnames(evt);
				bRemove	= ~ismember(cField,cFieldGood);
				
				if any(bRemove)
				%we got some extra fields
					evt	= rmfield(evt,cField(bRemove));
				end
				
				evt	= orderfields(evt,cFieldGood);
			end
		end
	else
	%the log doesn't exist
		bBlank	= true;
	end
	
	if bBlank
		evt	= struct('time',[],'type',{{}},'info',{{}});
		
		if bExists
			delete(strPathLog);
		end
		
		lg.parent.File.Write(join(cFieldGood,9),'log');
	end
	
	lg.parent.Info.Set('log','event',evt);
%open the log for fast writing
	b	= lg.parent.File.Open('log');
	if ~b
		error(['Could not open log: "' strPathLog '"']);
	end
%start the diary
	strNameDiary	= PathAddSuffix(strName,'','diary');
	lg.parent.File.Set('diary','log',strNameDiary,'replace',false);
	
	strPathDiary	= lg.parent.File.Get('diary');
	
	if ~opt.append && FileExists(strPathDiary)
		delete(strPathDiary);
	end
	
	diary(strPathDiary);
%show some info
	strStatusLog	= ['log saving to: "' strPathLog '"'];
	lg.parent.Status.Show(strStatusLog,'time',false);
	
	strStatusDiary	= ['diary saving to: "' strPathDiary '"'];
	lg.parent.Status.Show(strStatusDiary,'time',false);
