function [N, F] = compute_bw_stats(feaFilename, ubmFilename, statFilename)
% extracts sufficient statistics for features in feaFilename and GMM 
% ubmFilename, and optionally save the stats in statsFilename. The 
% first order statistics are centered.
%
% Inputs:
%   - feaFilename  : input feature file name (string) or a feature matrix 
%					(one observation per column)
%   - ubmFilename  : file name of the UBM or a structure with UBM 
%					 hyperparameters.
%   - statFilename : output file name (optional)   
%
% Outputs:
%   - N			   : mixture occupation counts (responsibilities) 
%   - F            : centered first order stats
%
% References:
%   [1] N. Dehak, P. Kenny, R. Dehak, P. Dumouchel, and P. Ouellet, "Front-end 
%       factor analysis for speaker verification," IEEE TASLP, vol. 19, pp. 788-798,
%       May 2011. 
%   [2] P. Kenny, "A small footprint i-vector extractor," in Proc. Odyssey, 
%       The Speaker and Language Recognition Workshop, Jun. 2012.
%
%
% Omid Sadjadi <s.omid.sadjadi@gmail.com>
% Microsoft Research, Conversational Systems Research Center

%parameters stuff
if ischar(ubmFilename),
	tmp  = load(ubmFilename);
	ubm  = tmp.gmm;
elseif isstruct(ubmFilename),
	ubm = ubmFilename;
else
    error('Oops! ubmFilename should be either a string or a structure!');
end
%create a super vector from the UBM (before adaptation)
[ndim, nmix] = size(ubm.mu);
m = reshape(ubm.mu, ndim * nmix, 1);
%creates a new super vector of indexes by stacking M vectors 
%corresponding to each component each have D elements with 
%thier values as the index of their component
idx_sv = reshape(repmat(1 : nmix, ndim, 1), ndim * nmix, 1);

%here the features are always in the RAM so always else
if ischar(feaFilename),
    data = htkread(feaFilename);
else
    data = feaFilename;
end

[N, F] = expectation(data, ubm);
F = reshape(F, ndim * nmix, 1);
F = F - N(idx_sv) .* m; % centered first order stats

if ( nargin == 3)
	% create the path if it does not exist and save the file
	path = fileparts(statFilename);
	if ( exist(path, 'dir')~=7 && ~isempty(path) ), mkdir(path); end
	parsave(statFilename, N, F);
end

function parsave(fname, N, F) %#ok
save(fname, 'N', 'F')

function [N, F] = expectation(data, gmm)
% compute the sufficient statistics
% first calculates the Posterior 
post = postprob(data, gmm.mu, gmm.sigma, gmm.w(:));
% sum the posterior for each component to get the zeroth bw statistic
N = sum(post, 2);
% and the first BW statistics 
F = data * post';

function [post, llk] = postprob(data, mu, sigma, w)
% compute the posterior probability of mixtures for each frame
% the log of the numinator of the posterior propability 
post = lgmmprob(data, mu, sigma, w);
% the log of the denomenater of the posterior 
llk  = logsumexp(post, 1);
% and by 
post = exp(bsxfun(@minus, post, llk));

function logprob = lgmmprob(data, mu, sigma, w)
% compute the log probability of observations given the GMM
ndim = size(data, 1);
% just the logarithm of the multi-variate natural 
C = sum(mu.*mu./sigma) + sum(log(sigma));
D = (1./sigma)' * (data .* data) - 2 * (mu./sigma)' * data  + ndim * log(2 * pi);
logprob = -0.5 * (bsxfun(@plus, C',  D));
%add to it the logarithm of the prior (the wieght) to get the lgarithm of the nominater of the 
%posterior 
logprob = bsxfun(@plus, logprob, log(w));

function y = logsumexp(x, dim)
% compute log(sum(exp(x),dim)) while avoiding numerical underflow
% all what this guy do is calculating the denominator of the posterior 
%propability in an efficient way 
% the main idea is that in order to calculate the denominatore you need to
% calculate { sum(p(x|Mi)) for all i } where Mi is the i-th mixture in the
% model x is an observation in our case a frame of the features 
% the probleme is that we have the propabilities as log(p(x|Mi)) now in
% order to calculate the sum we need to take the exp of these probabilities
% and then sum them up and here where the probleme arise .
% what happens if p(x|Mi) is too small then when we add them up most of the
% time we will get rounding errors . So the trick is to increase their
% value by some amount (so no rounding error might occure) add them up and
% then remove the factor but what factor shall we use ?? let mx be the max
% of the probabilties we can use the factor (1/mx) to increase the values
% (since mx <1 then (1/mx)>1 ) and then divide by that factor . but why the
% max ? why not say the min ?? because it is possible that one of the
% mixtures has a propability of 0 for a given observation so we will get
% infinity 
% So first calculate the ( max(log(p(x|Mi)) among the mixtures ) which
% happens to be the same as  ( log(max(p(x|Mi))) ) since the log is
% monotically increasing . So xmax will be a 1×NumFrames which is 
% log(1/factor ) let xmax1 be 1/factor 
xmax = max(x, [], dim);
% now here where the magic happens : 
% first bsxfun(@minus, x, xmax) means log(p(x|Mi))-log(xmax1) which is equal
% to log(p(x|Mi) / xmax1) so we increased the values inside the logarithm 
% next take the exp and sum over the mixtures to get {sum (p(x|Mi)/ xmax1)}
% i.e. (p(x|M1)/ xmax1) + (p(x|M2)/ xmax1) + ... + (p(x|Mn)/ xmax1) so it
% becomes {S/xmax1} where S is the true sum without numirical underflow 
% finally take the log of it and add to it log(xmax1) which will give us 
% log(xmax1 * S / xmax ) = log( S )
y    = xmax + log(sum(exp(bsxfun(@minus, x, xmax)), dim));
% just in case off numerical error y should be modified or it will become
% NaN
ind  = find(~isfinite(xmax));
if ~isempty(ind)
    y(ind) = xmax(ind);
end
