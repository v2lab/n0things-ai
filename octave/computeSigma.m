function [sigma min_d min_d_idx, cluster_sizes] = computeSigma(X,idx,centroids)

[m n] = size(X); % m points in n dimensions
K = size(centroids, 1); % number of clusters
sigma = zeros(K,1); % one sigma per cluster
cluster_sizes = zeros(K,1);
min_d = inf(K,1);
min_d_idx = zeros(K,1);

for i=1:m
  ki = idx(i); % i-th point belongs to ki-th cluster
  d = sumsq( centroids(ki,:) - X(i,:) );
  sigma( ki ) += d;
  cluster_sizes( ki ) += 1;
  if (d < min_d(ki) )
    min_d(ki) = d;
    min_d_idx(ki) = i;
  end
end

sigma = sqrt(sigma ./ cluster_sizes);
min_d = sqrt(min_d);

end
