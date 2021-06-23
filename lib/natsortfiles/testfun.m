function chk = testfun(fun)
% Test function for NATSORT, NATSORTFILES, and NATSORTROWS. Do NOT call!
%
% (c) 2012-2021 Stephen Cobeldick
%
% See also NATSORT_TEST NATSORTFILES_TEST NATSORTROWS_TEST

chk = @nestfun;
wrn = warning('off','SC:natsort:rgx:SanityCheck');
itr = 0;
cnt = 0;
if feature('hotlinks')
	fmt = '<a href="matlab:opentoline(''%1$s'',%2$3d)">%1$s %2$3d</a>';
else
	fmt = '%s %3d';
end
%
	function nestfun(varargin) % (function inputs..., fun, expected function outputs...)
		%
		dbs = dbstack();
		%
		if ~nargin % post-processing
			fprintf('%s: %d of %d testcases failed.\n',dbs(2).file,cnt,itr)
			warning(wrn);
			return
		end
		%
		boo = false;
		idx = find(cellfun(@(f)isequal(f,fun),varargin));
		assert(nnz(idx)==1,'SC:testfun:MissFun','Missing function handle.')
		xfa = varargin(idx+1:end);
		ofa = cell(size(xfa));
		%
		[ofa{:}] = fun(varargin{1:idx-1});
		%
		for k = 1:numel(xfa)
			if isnumeric(xfa{k})&&isequal(xfa{k},[])
				% [] indicates to ignore this output
			elseif isequaln(ofa{k},xfa{k})
				% function output matches expected output
			else
				boo = true;
				otx = tfPretty(ofa{k});
				xtx = tfPretty(xfa{k});
				ntx = min(numel(otx),numel(xtx));
				dtx = otx(1:ntx)~=xtx(1:ntx);
				fprintf(fmt, dbs(2).file, dbs(2).line);
				fprintf(' (output argument %d)\n',k);
				fprintf('output:%s\nexpect:%s\n', otx, xtx);
				fprintf('diff:  ')
				fprintf(2,'%s\n',32+char(62*dtx)); % red!
			end
		end
		cnt = cnt+boo;
		itr = itr+1;
	end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%testfun
function out = tfPretty(inp)
if isempty(inp)&&any(size(inp)) || ndims(inp)>2 %#ok<ISMAT>
	asz = sprintf('x%d',size(inp));
	inp = inp(:);
else
	asz = '';
end
if isnumeric(inp)
	if isscalar(inp)
		out = sprintf('%.15g',inp);
	else
		fmt = repmat(',%.15g',1,size(inp,2));
		out = sprintf([';',fmt(2:end)],inp.');
		out = sprintf('%s[%s]',asz(2:end),out(2:end));
	end
elseif ischar(inp)
	if size(inp,1)<2
		out = sprintf('%s''%s''',asz(2:end),inp);
	else
		tmp = num2cell(inp,2);
		out = sprintf(';''%s''',tmp{:});
		out = sprintf('%s[%s]',asz(2:end),out(2:end));
	end
elseif iscell(inp)
	tmp = cellfun(@tfPretty,inp.','uni',0);
	fmt = repmat(',%s',1,size(inp,2));
	out = sprintf([';',fmt(2:end)],tmp{:});
	out = sprintf('%s{%s}',asz(2:end),out(2:end));
else
	error('SC:testfun:UnsupportedClass','Class "%s" is not supported',class(inp))
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%tfPretty