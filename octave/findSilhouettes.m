function silhouettes = findSilhouettes(distances, idx)
%FINDSILHOUETTES calculates silhouettes for currently found clusters
%
%  see: http://en.wikipedia.org/wiki/Silhouette_(clustering)
%
%  Peter J. Rousseeuw (1987). "Silhouettes: a Graphical Aid to the
%  Interpretation and Validation of Cluster Analysis". Computational
%  and Applied Mathematics 20: 53–65.
%
%  silhouettes = FINDSILHOUETTES(distances, idx)
%
%     distances  mutual distances between points in the dataset
%     idx        assignment of points to clusters
%
%  Returns
%     silhouettes row of silhouettes of each cluster

% For each datum find average distance from point to points in each cluster
N = size(distances,1);
K = max(idx);

D = zeros(K,1);
S = zeros(N,1);

for i = 1:N
  for j = 1:K
    D(j) = mean( distances( i, idx==j ) );
  end

  % dissimilarity with point's assigned cluster
  A = D( idx(i) );

  % smallest dissimilarity to unassigned cluster
  B = min( D( 1:K != idx(i) ) );

  % datum's silhouette
  S(i) = (B - A) / max( B, A );
end

silhouettes = zeros(K,1);
for j = 1:K
  silhouettes(j) = mean(S( idx==j ));
end

end
