function res = MVPAROIClassify(varargin)
% MVPAROIClassify
% 
% Description:	perform an ROI classification analysis. PCA (via FSL's MELODIC)
%				is optionally performed on each ROI's dataset first.
% 
% Syntax:	res = MVPAROIClassify(<options>)
% 
% In:
% 	<options>:
%		<+ options for MRIParseDataPaths>
%		<+ options for FSLMELODIC/fMRIROI>
%		<+ options for MVPAClassify>
%		melodic:	(true) true to perform MELODIC on the extracted ROIs before
%					classification
%		pcaonly:	(true) (see FSLMELODIC)
%		targets:	(<required>) a cell specifying the target for each sample,
%					or a cell of cells (one for each dataset)
%		chunks:		(<required>) an array specifying the chunks for each sample,
%					or a cell of arrays (one for each dataset)
%		nthread:	(1) the number of threads to use
%		force:		(true) true to force classification if the outputs already
%					exist
%		force_pre:	(false) true to force preprocessing steps if the output
%					already exists
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	res	- a struct of results (see MVPAClassify)
%
% Example:
%	cMask	= {'dlpfc';'occ';'ppc'};
%	res = MVPAROIClassify(...
%			'dir_data'			, strDirData	, ...
%			'subject'			, cSubject		, ...
%			'mask'				, cMask			, ...
%			'targets'			, cTarget		, ...
%			'chunks'			, kChunk		, ...
%			'spatiotemporal'	, true			, ...
%			'target_blank'		, 'Blank'		, ...
%			'output_dir'		, strDirOut		, ...
%			'nthread'			, 11			  ...
%			);
% 
% Updated: 2015-03-18
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt		= ParseArgs(varargin,...
				'melodic'	, true	, ...
				'targets'	, []	, ...
				'chunks'	, []	, ...
				'nthread'	, 1		, ...
				'force'		, true	, ...
				'force_pre'	, false	, ...
				'silent'	, false	  ...
				);
	
	assert(~isempty(opt.targets),'targets must be specified.');
	assert(~isempty(opt.chunks),'chunks must be specified.');
	
	opt_path	= optreplace(opt.opt_extra,...
					'require'	, {'functional','mask'}	  ...
					);
	sPath		= ParseMRIDataPaths(opt_path);

%extract the ROI data
	if opt.melodic
		opt_melodic	= optadd(sPath.opt_extra,...
						'pcaonly'	, true	  ...
						);
		opt_melodic	= optreplace(opt_melodic,...
						'path_functional'	, sPath.functional	, ...
						'path_mask'			, sPath.mask		, ...
						'nthread'			, opt.nthread		, ...
						'force'				, opt.force_pre		, ...
						'silent'			, opt.silent		  ...
						);
		
		sMELODIC		= FSLMELODIC(opt_melodic);
		cPathDataROI	= sMELODIC.path_data;
	else
		opt_roi			= optreplace(sPath.opt_extra,...
							'path_functional'	, sPath.functional	, ...
							'path_mask'			, sPath.mask		, ...
							'nthread'			, opt.nthread		, ...
							'force'				, opt.force_pre		, ...
							'silent'			, opt.silent		  ...
							);
		cPathDataROI	= fMRIROI(opt_roi);
	end

%get the ROI names
	cSession					= sPath.functional_session;
	[cPathDataROI,cMaskName]	= varfun(@(x) ForceCell(x,'level',2),cPathDataROI,sPath.mask_name);
	
	cNameROI	= cellfun(@(s,cm) cellfun(@(m) sprintf('%s-%s',s,m),cm,'uni',false),cSession,cMaskName,'uni',false);

%classify!
	%get a target/chunk pair for each classification
		cTarget	= ForceCell(opt.targets,'level',2);
		kChunk	= ForceCell(opt.chunks);
		
		[cPathDataROI,cTarget,kChunk]	= FillSingletonArrays(cPathDataROI,cTarget,kChunk);
		
		cTargetRep	= cellfun(@(d,t) repmat({t},[size(d,1) 1]),cPathDataROI,cTarget,'uni',false);
		kChunkRep	= cellfun(@(d,c) repmat({c},[size(d,1) 1]),cPathDataROI,kChunk,'uni',false);
	
		%flatten for MVPAClassify
			[cPathDataFlat,cTargetFlat,kChunkFlat,cNameFlat]	= varfun(@(x) cat(1,x{:}),cPathDataROI,cTargetRep,kChunkRep,cNameROI);
	
	opt_mvpa	= optadd(sPath.opt_extra,...
					'output_prefix'	, cNameFlat	, ...
					'combine'		, true		, ...
					'group_stats'	, true		  ...
					);
	bCombine	= opt_mvpa.combine;
	bGroupStats	= opt_mvpa.group_stats;
	opt_mvpa	= optreplace(opt_mvpa,...
					'combine'			, false			, ...
					'nthread'			, opt.nthread	, ...
					'force'				, opt.force		, ...
					'silent'			, opt.silent	  ...
					);
					
	res	= MVPAClassify(cPathDataFlat,cTargetFlat,kChunkFlat,opt_mvpa);
	
%combine the results
	if bCombine
		try
			nSubject	= numel(sPath.functional);
			cMask		= reshape(cMaskName{1},[],1);
			nMask		= numel(cMask);
			
			sCombine	= [nMask nSubject];
			
			res			= structtreefun(@CombineResult,res{:});
			res.mask	= cMask;
		catch me
			status('combine option was selected but analysis results are not uniform.','warning',true,'silent',opt.silent);
		end
		
		if bGroupStats && size(cPathDataFlat,1) > 1
			res	= GroupStats(res);
		end
	end


%------------------------------------------------------------------------------%
function x = CombineResult(varargin)
	if nargin==0
		x	= [];
	else
		if isnumeric(varargin{1}) && uniform(cellfun(@size,varargin,'uni',false))
			if isscalar(varargin{1})
				x	= reshape(cat(1,varargin{:}),sCombine);
			else
				sz	= size(varargin{1});
				x	= reshape(stack(varargin{:}),[sz sCombine]);
			end
		else
			x	= reshape(varargin,sCombine);
		end
	end
end
%------------------------------------------------------------------------------%
function res = GroupStats(res)
	if isstruct(res)
		res	= structfun2(@GroupStats,res);
		
		if isfield(res,'accuracy')
			%accuracies
				acc		= res.accuracy.mean;
				nd		= ndims(acc);
				chance	= res.accuracy.chance(1,end);
				
				res.stats.accuracy.mean	= mean(acc,nd);
				res.stats.accuracy.se	= stderr(acc,[],nd);
				
				[h,p,ci,stats]	= ttest(acc,chance,'tail','right','dim',nd);
				
				res.stats.accuracy.chance	= chance;
				res.stats.accuracy.df		= stats.df;
				res.stats.accuracy.t		= stats.tstat;
				res.stats.accuracy.p		= p;
			%confusion matrices
				conf	= res.confusion;
				
				if ~iscell(conf)
					res.stats.confusion.mean	= mean(conf,4);
					res.stats.confusion.se		= stderr(conf,[],4);
				end
		end
	end
end
%------------------------------------------------------------------------------%

end