% For old plotting scripts, see scratchpad/archived/plotting-scripts/*

% Script to plot data from 20150429_2220_explore_SNR.mat
% See also create_20150429_explore_SNR.m


function hF = plot_20150429_explore_SNR(varargin)
opt				= ParseArgs(varargin, ...
					'yVarName'		, 'acc'		  ...
					);

hF				= zeros(1,0);
stem			= '20150429_2220_explore_SNR';

load(['../data_store/' stem '.mat']);


% Capsule 1 multiplots

vertVar			= {								  ...
					'nDataPerRun'	, {48 96}	  ...
				  };
fixedPairs		= {								  ...
					'nRun'			, 20		, ...
					'WSum'			, 0.2		  ...
				  };
hF				= plot_quads_nTBlock_SNR(hF,cCapsule{1},opt.yVarName,vertVar,fixedPairs);

vertVar			= {								  ...
					'nRun'			, {5 20}	  ...
				  };
fixedPairs		= {								  ...
					'nDataPerRun'	, 96		, ...
					'WSum'			, 0.2		  ...
				  };
hF				= plot_quads_nTBlock_SNR(hF,cCapsule{1},opt.yVarName,vertVar,fixedPairs);

vertVar			= {								  ...
					'WSum'			, {0.1 0.2}	  ...
				  };
fixedPairs		= {								  ...
					'nDataPerRun'	, 96		, ...
					'nRun'			, 20		  ...
				  };
hF				= plot_quads_nTBlock_SNR(hF,cCapsule{1},opt.yVarName,vertVar,fixedPairs);


figfilepath		= sprintf('scratchpad/figfiles/%s-%s-%s.fig',stem, ...
					opt.yVarName,FormatTime(nowms,'mmdd'));
savefig(hF(end:-1:1),figfilepath);
fprintf('Plots saved to %s\n',figfilepath);

end

function hF = plot_quads_nTBlock_SNR(hF,capsule,yVarName,vertVar,fixedPairs)
	p			= Pipeline;
	ha			= p.renderMultiLinePlot(capsule,'nTBlock'		, ...
					'yVarName'				, yVarName			, ...
					'lineVarName'			, 'SNR'				, ...
					'lineVarValues'			, {0.1 0.2 0.3 0.4}	, ...
					'horizVarName'			, 'hrf'				, ...
					'horizVarValues'		, {0 1}				, ...
					'vertVarName'			, vertVar{1}		, ...
					'vertVarValues'			, vertVar{2}		, ...
					'fixedVarValuePairs'	, fixedPairs		  ...
					);
	hF(end+1)	= ha.hF;

	ha			= p.renderMultiLinePlot(capsule,'SNR'			, ...
					'yVarName'				, yVarName			, ...
					'lineVarName'			, 'nTBlock'			, ...
					'lineVarValues'			, {1 3 6 12}		, ...
					'horizVarName'			, 'hrf'				, ...
					'horizVarValues'		, {0 1}				, ...
					'vertVarName'			, vertVar{1}		, ...
					'vertVarValues'			, vertVar{2}		, ...
					'fixedVarValuePairs'	, fixedPairs		  ...
					);
	hF(end+1)	= ha.hF;
end
