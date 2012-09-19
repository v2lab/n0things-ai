function sigma = computeSigma(X,idx,centroids)

[m n] = size(X); % m points in n dimensions
K = size(centroids, 1); % number of clusters
sigma = zeros(K,1); % one sigma per cluster

for i=1:m
  ki = idx(i); % i-th point belongs to ki-th cluster
  sigma( ki ) += sumsq( centroids(ki) - X(i) );
end

sigma = sqrt(sigma);

end
