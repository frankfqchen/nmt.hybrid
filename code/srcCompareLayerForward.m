%%%
%
% For attention-based models, given:
%   srcHidVecs: lstmSize * curBatchSize * numSrcHidVecs
%   h_t: lstmSize * curBatchSize
%   srcHidVecs: lstmSize * batchSize * numPositions.
% compute:
%   alignWeights: numSrcHidVecs * curBatchSize
%
% Thang Luong @ 2015, <lmthang@stanford.edu>
%
%%% 
function [alignWeights] = srcCompareLayerForward(srcHidVecs, h_t, alignMask, params)
  alignScores = squeeze(sum(bsxfun(@times, srcHidVecs, h_t), 1))'; % numSrcHidVecs * curBatchSize
  
  if params.curBatchSize==1 || size(srcHidVecs, 3)==1 % handle special cases that causing squeezing to transpose row/col vectors.
    alignScores = alignScores';
  end

  alignWeights = normLayerForward(alignScores, alignMask, params); % numSrcHidVecs * curBatchSize
 
  % assert
  if params.assert
    assert(isequal(size(alignWeights), size(alignMask)));
    assert(isequal(size(alignWeights), size(alignScores)));
    alignScores1 = zeroMatrix(size(alignScores), params.isGPU, params.dataType);
    for ii=1:params.curBatchSize
      alignScores1(:, ii) = squeeze(srcHidVecs(:, ii, :))'*h_t(:, ii);
    end
    
    assert(computeSum(alignScores-alignScores1, params.isGPU)<1e-4);
  end
end